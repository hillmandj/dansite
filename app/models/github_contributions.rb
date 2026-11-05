require "net/http"

# The contribution heatmap shown on the home page.
#
# Data comes from GitHub's public contributions calendar, the same one an
# anonymous visitor sees on github.com/hillmandj. (The GraphQL API undercounts:
# private org contributions only appear for tokens authorized for that org.)
#
# The latest snapshot is kept in storage/ (a persistent volume in production),
# so it survives deploys. When it is older than REFRESH_AFTER, the next request
# refreshes it. If GitHub is slow or down, the last good snapshot keeps being
# served and the next attempt waits RETRY_AFTER.
class GithubContributions
  USER = "hillmandj".freeze
  URL = URI("https://github.com/users/#{USER}/contributions")
  REFRESH_AFTER = 6.hours
  RETRY_AFTER = 30.minutes

  class FetchError < StandardError; end

  class << self
    attr_writer :snapshot_path

    def snapshot_path
      @snapshot_path || Rails.root.join("storage", "github_contributions.json")
    end

    # => { "days" => [["2026-01-01", 3, 2], ...], "total" => 631, "active_days" => 184 } or nil
    def current
      snapshot = read_snapshot
      snapshot = refresh(snapshot) if due?(snapshot)
      snapshot&.slice("days", "total", "active_days")
    end

    # Parses the calendar HTML into [[date, count, level], ...] sorted by date.
    def parse(html)
      doc = Nokogiri::HTML(html)
      counts = doc.css("tool-tip[for]").to_h do |tip|
        [ tip["for"], tip.text[/\A\s*(\d+) contributions?/, 1].to_i ]
      end
      days = doc.css("td[data-date][data-level]").map do |cell|
        [ cell["data-date"], counts.fetch(cell["id"], 0), cell["data-level"].to_i ]
      end
      raise FetchError, "no contribution days found" if days.empty?

      days.sort_by(&:first)
    end

    # Downloads the public contributions calendar HTML.
    def fetch_html
      response = Net::HTTP.start(URL.host, URL.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|
        http.get(URL.request_uri, "User-Agent" => "daniel-hillman.com", "Accept" => "text/html")
      end
      raise FetchError, "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    private

    def due?(snapshot)
      checked_at = snapshot && Time.zone.parse(snapshot["checked_at"].to_s)
      checked_at.nil? || checked_at < REFRESH_AFTER.ago
    end

    def refresh(previous)
      with_lock(previous) do
        days = parse(fetch_html)
        write_snapshot(
          "days" => days,
          "total" => days.sum { |d| d[1] },
          "active_days" => days.count { |d| d[1].positive? },
          "fetched_at" => Time.current.iso8601,
          "checked_at" => Time.current.iso8601
        )
      end
    rescue StandardError => e
      Rails.logger.warn("[GithubContributions] refresh failed: #{e.class}: #{e.message}")
      return nil unless previous

      # Keep serving the old data; try again after RETRY_AFTER.
      write_snapshot(previous.merge("checked_at" => (REFRESH_AFTER.ago + RETRY_AFTER).iso8601))
    end

    # Only one request refreshes at a time; others keep serving the old snapshot.
    def with_lock(previous)
      FileUtils.mkdir_p(File.dirname(snapshot_path))
      File.open("#{snapshot_path}.lock", File::RDWR | File::CREAT) do |lock|
        return previous unless lock.flock(File::LOCK_EX | File::LOCK_NB)

        yield
      end
    end

    def read_snapshot
      JSON.parse(File.read(snapshot_path))
    rescue Errno::ENOENT, JSON::ParserError
      nil
    end

    def write_snapshot(data)
      tmp = "#{snapshot_path}.tmp"
      File.write(tmp, JSON.generate(data))
      File.rename(tmp, snapshot_path)
      data
    end
  end
end

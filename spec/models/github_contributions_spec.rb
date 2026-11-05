require "rails_helper"

RSpec.describe GithubContributions do
  def calendar_html(days)
    cells = days.map.with_index do |(date, count, level), i|
      tip = count.zero? ? "No contributions on #{date}." : "#{count} contribution#{'s' unless count == 1} on #{date}."
      %(<td data-date="#{date}" id="day-#{i}" data-level="#{level}" class="ContributionCalendar-day"></td>
        <tool-tip for="day-#{i}" class="sr-only">#{tip}</tool-tip>)
    end
    "<table><tbody><tr>#{cells.join}</tr></tbody></table>"
  end

  let(:html) { calendar_html([ [ "2026-01-02", 3, 2 ], [ "2026-01-01", 0, 0 ], [ "2026-01-03", 1, 1 ] ]) }

  describe ".parse" do
    it "returns [date, count, level] per day, sorted by date" do
      expect(described_class.parse(html)).to eq([
        [ "2026-01-01", 0, 0 ], [ "2026-01-02", 3, 2 ], [ "2026-01-03", 1, 1 ]
      ])
    end

    it "raises when the page has no calendar" do
      expect { described_class.parse("<html></html>") }.to raise_error(described_class::FetchError)
    end
  end

  describe ".current" do
    it "fetches, summarizes and saves a snapshot" do
      allow(described_class).to receive(:fetch_html).and_return(html)

      expect(described_class.current).to eq(
        "days" => [ [ "2026-01-01", 0, 0 ], [ "2026-01-02", 3, 2 ], [ "2026-01-03", 1, 1 ] ],
        "total" => 4,
        "active_days" => 2
      )
      expect(File).to exist(described_class.snapshot_path)
    end

    it "serves the saved snapshot without refetching while it is fresh" do
      allow(described_class).to receive(:fetch_html).and_return(html)
      described_class.current

      described_class.current
      expect(described_class).to have_received(:fetch_html).once
    end

    it "refreshes once the snapshot is older than REFRESH_AFTER" do
      allow(described_class).to receive(:fetch_html).and_return(html)
      described_class.current

      travel(described_class::REFRESH_AFTER + 1.minute) { described_class.current }
      expect(described_class).to have_received(:fetch_html).twice
    end

    it "keeps serving the last good snapshot when GitHub fails, and backs off" do
      allow(described_class).to receive(:fetch_html).and_return(html)
      described_class.current

      allow(described_class).to receive(:fetch_html).and_raise(described_class::FetchError, "HTTP 503")
      travel(described_class::REFRESH_AFTER + 1.minute) do
        expect(described_class.current["total"]).to eq(4)
        described_class.current # inside the retry window: no new attempt
      end
      expect(described_class).to have_received(:fetch_html).twice
    end

    it "returns nil when there is no snapshot and GitHub fails" do
      expect(described_class.current).to be_nil
    end
  end
end

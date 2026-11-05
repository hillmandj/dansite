# Never hit GitHub from tests: use a throwaway snapshot file and fail fetches
# unless a spec stubs GithubContributions.fetch_html itself.
RSpec.configure do |config|
  config.before do
    path = Rails.root.join("tmp", "test", "github_contributions_#{ENV.fetch('TEST_ENV_NUMBER', '')}.json")
    FileUtils.rm_f(path)
    GithubContributions.snapshot_path = path
    allow(GithubContributions).to receive(:fetch_html).and_raise(GithubContributions::FetchError, "network disabled in tests")
  end
end

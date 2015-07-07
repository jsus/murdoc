require "rubygems"
require "bundler/setup"
require "rspec"

require "murdoc"

RSpec.configure do |config|
  config.expect_with(:rspec) {|expectations| expectations.syntax = [:should, :expect] }
  config.mock_with(:rspec) {|mocks| mocks.syntax = :should }
  config.raise_errors_for_deprecations!

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

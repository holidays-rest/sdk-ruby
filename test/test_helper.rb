require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = "coverage/lcov.info"

SimpleCov.start do
  add_filter "/test/"
  formatter SimpleCov::Formatter::LcovFormatter
end

require "minitest/autorun"
require "webmock/minitest"
require_relative "../lib/holidays_rest"

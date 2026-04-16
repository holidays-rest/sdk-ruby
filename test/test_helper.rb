require "simplecov"
require "simplecov-cobertura"

SimpleCov.start do
  add_filter "/test/"
  formatter SimpleCov::Formatter::CoberturaFormatter
end

require "minitest/autorun"
require "webmock/minitest"
require_relative "../lib/holidays_rest"

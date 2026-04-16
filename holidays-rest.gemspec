require_relative "lib/holidays_rest/version"

Gem::Specification.new do |spec|
  spec.name        = "holidays-rest"
  spec.version     = HolidaysRest::VERSION
  spec.authors     = ["msdundar"]
  spec.summary     = "Official Ruby SDK for the holidays.rest API"
  spec.description = "Fetch public holidays by country, year, region, type, and more."
  spec.homepage    = "https://holidays.rest"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/msdundar/holidays.rest"
  spec.metadata["documentation_uri"] = "https://docs.holidays.rest"

  spec.files = Dir["lib/**/*.rb", "README.md", "holidays-rest.gemspec"]

  # Zero runtime dependencies — uses only Ruby stdlib (net/http, json, uri)
end

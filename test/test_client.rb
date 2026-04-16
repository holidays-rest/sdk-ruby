require_relative "test_helper"

BASE = "https://api.holidays.rest/v1"

HOLIDAY_PAYLOAD = [
  {
    "country_code" => "US",
    "country_name" => "United States",
    "date"         => "2024-01-01",
    "name"         => { "en" => "New Year's Day" },
    "isNational"   => true,
    "isReligious"  => false,
    "isLocal"      => false,
    "isEstimate"   => false,
    "day"          => { "actual" => "Monday", "observed" => "Monday" },
    "religion"     => "",
    "regions"      => []
  }
].freeze

class TestClientInitialize < Minitest::Test
  def test_raises_on_nil_api_key
    assert_raises(ArgumentError) { HolidaysRest::Client.new(api_key: nil) }
  end

  def test_raises_on_empty_api_key
    assert_raises(ArgumentError) { HolidaysRest::Client.new(api_key: "") }
  end

  def test_valid_api_key
    assert_instance_of HolidaysRest::Client, HolidaysRest::Client.new(api_key: "key")
  end
end

class TestClientHolidays < Minitest::Test
  def setup
    @client = HolidaysRest::Client.new(api_key: "test-key")
  end

  def test_returns_array_of_holiday_objects
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "US", "year" => "2024"))
      .to_return(status: 200, body: HOLIDAY_PAYLOAD.to_json,
                 headers: { "Content-Type" => "application/json" })

    result = @client.holidays(country: "US", year: 2024)

    assert_equal 1, result.size
    assert_instance_of HolidaysRest::Holiday, result.first
    assert_equal({ "en" => "New Year's Day" }, result.first.name)
    assert_equal "2024-01-01",                 result.first.date
    assert_equal true,                         result.first.is_national
  end

  def test_sends_bearer_token
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "US", "year" => "2024"))
      .to_return(status: 200, body: "[]",
                 headers: { "Content-Type" => "application/json" })

    @client.holidays(country: "US", year: 2024)

    assert_requested :get, "#{BASE}/holidays",
      query:   hash_including("country" => "US", "year" => "2024"),
      headers: { "Authorization" => "Bearer test-key" }
  end

  def test_array_params_joined_with_comma
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("type" => "national,religious"))
      .to_return(status: 200, body: "[]",
                 headers: { "Content-Type" => "application/json" })

    @client.holidays(country: "US", year: 2024, type: %w[national religious])

    assert_requested :get, "#{BASE}/holidays",
      query: hash_including("type" => "national,religious")
  end

  def test_nil_optional_params_excluded_from_query
    # Exact query match — month/day must not appear
    stub_request(:get, "#{BASE}/holidays")
      .with(query: { "country" => "US", "year" => "2024" })
      .to_return(status: 200, body: "[]",
                 headers: { "Content-Type" => "application/json" })

    @client.holidays(country: "US", year: 2024, month: nil, day: nil)

    assert_requested :get, "#{BASE}/holidays",
      query: { "country" => "US", "year" => "2024" }
  end

  def test_raises_api_error_on_401_with_json_body
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "US", "year" => "2024"))
      .to_return(status: 401, body: '{"message":"Invalid API key"}',
                 headers: { "Content-Type" => "application/json" })

    error = assert_raises(HolidaysRest::ApiError) do
      @client.holidays(country: "US", year: 2024)
    end

    assert_equal 401,               error.status_code
    assert_equal "Invalid API key", error.message
  end

  def test_raises_api_error_on_404
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "XX", "year" => "2024"))
      .to_return(status: 404, body: '{"message":"Not found"}',
                 headers: { "Content-Type" => "application/json" })

    error = assert_raises(HolidaysRest::ApiError) do
      @client.holidays(country: "XX", year: 2024)
    end

    assert_equal 404,         error.status_code
    assert_equal "Not found", error.message
  end

  def test_raises_api_error_on_500_non_json_body
    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "US", "year" => "2024"))
      .to_return(status: 500, body: "Internal Server Error",
                 headers: { "Content-Type" => "text/plain" })

    error = assert_raises(HolidaysRest::ApiError) do
      @client.holidays(country: "US", year: 2024)
    end

    assert_equal 500,                     error.status_code
    assert_equal "Internal Server Error", error.body
  end

  def test_stores_raw_body_on_api_error
    raw = '{"message":"Bad request","detail":"year is required"}'

    stub_request(:get, "#{BASE}/holidays")
      .with(query: hash_including("country" => "US", "year" => "2024"))
      .to_return(status: 400, body: raw,
                 headers: { "Content-Type" => "application/json" })

    error = assert_raises(HolidaysRest::ApiError) do
      @client.holidays(country: "US", year: 2024)
    end

    assert_equal raw, error.body
  end
end

class TestClientCountries < Minitest::Test
  def setup
    @client = HolidaysRest::Client.new(api_key: "test-key")
  end

  def test_returns_array_of_country_objects
    body = [{ "name" => "United States", "alpha2" => "US", "subdivisions" => [] }].to_json

    stub_request(:get, "#{BASE}/countries")
      .to_return(status: 200, body: body,
                 headers: { "Content-Type" => "application/json" })

    result = @client.countries

    assert_equal 1, result.size
    assert_instance_of HolidaysRest::Country, result.first
    assert_equal "US", result.first.alpha2
  end
end

class TestClientCountry < Minitest::Test
  def setup
    @client = HolidaysRest::Client.new(api_key: "test-key")
  end

  def test_raises_on_nil_country_code
    assert_raises(ArgumentError) { @client.country(nil) }
  end

  def test_raises_on_empty_country_code
    assert_raises(ArgumentError) { @client.country("") }
  end

  def test_returns_country_object
    body = { "name" => "United States", "alpha2" => "US", "subdivisions" => [] }.to_json

    stub_request(:get, "#{BASE}/country/US")
      .to_return(status: 200, body: body,
                 headers: { "Content-Type" => "application/json" })

    result = @client.country("US")

    assert_instance_of HolidaysRest::Country, result
    assert_equal "US",            result.alpha2
    assert_equal "United States", result.name
  end

  def test_returns_country_with_subdivisions
    body = {
      "name"         => "United States",
      "alpha2"       => "US",
      "subdivisions" => [{ "code" => "US-CA", "name" => "California" }]
    }.to_json

    stub_request(:get, "#{BASE}/country/US")
      .to_return(status: 200, body: body,
                 headers: { "Content-Type" => "application/json" })

    result = @client.country("US")

    assert_equal 1,        result.subdivisions.size
    assert_equal "US-CA",  result.subdivisions.first.code
  end

  def test_url_encodes_country_code
    body = { "name" => "Test", "alpha2" => "T+", "subdivisions" => [] }.to_json

    stub_request(:get, "#{BASE}/country/T%2B")
      .to_return(status: 200, body: body,
                 headers: { "Content-Type" => "application/json" })

    result = @client.country("T+")

    assert_equal "T+", result.alpha2
  end
end

class TestClientLanguages < Minitest::Test
  def setup
    @client = HolidaysRest::Client.new(api_key: "test-key")
  end

  def test_returns_array_of_language_objects
    body = [{ "code" => "en", "name" => "English" }].to_json

    stub_request(:get, "#{BASE}/languages")
      .to_return(status: 200, body: body,
                 headers: { "Content-Type" => "application/json" })

    result = @client.languages

    assert_equal 1,         result.size
    assert_instance_of HolidaysRest::Language, result.first
    assert_equal "en",      result.first.code
    assert_equal "English", result.first.name
  end
end

require "json"
require "net/http"
require "uri"

module HolidaysRest
  class Client
    BASE_URL = "https://api.holidays.rest/v1"

    # @param api_key [String] Bearer token from https://www.holidays.rest/dashboard
    # @param base_url [String] Override base URL (useful for testing)
    # @param open_timeout [Integer] Seconds to wait for connection (default 5)
    # @param read_timeout [Integer] Seconds to wait for response (default 15)
    def initialize(api_key:, base_url: BASE_URL, open_timeout: 5, read_timeout: 15)
      raise ArgumentError, "api_key must not be empty" if api_key.nil? || api_key.empty?

      @api_key      = api_key
      @base_url     = base_url.chomp("/")
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    # Fetch public holidays.
    #
    # @param country [String] ISO 3166 alpha-2 code, e.g. "US"  (required)
    # @param year    [Integer, String]  Four-digit year          (required)
    # @param month   [Integer, String]  1–12                     (optional)
    # @param day     [Integer, String]  1–31                     (optional)
    # @param type    [String, Array<String>]  "religious", "national", "local"
    # @param religion [Integer, Array<Integer>]  Religion code(s) 1–11
    # @param region  [String, Array<String>]  Subdivision code(s)
    # @param lang    [String, Array<String>]  Language code(s)
    # @param response [String] "json" | "xml" | "yaml" | "csv"
    # @return [Array<Holiday>]
    def holidays(country:, year:, month: nil, day: nil, type: nil,
                 religion: nil, region: nil, lang: nil, response: nil)
      params = build_params(
        country:  country,
        year:     year,
        month:    month,
        day:      day,
        type:     type,
        religion: religion,
        region:   region,
        lang:     lang,
        response: response
      )
      get("/holidays", params).map { Holiday.from_hash(_1) }
    end

    # Return all supported countries.
    # @return [Array<Country>]
    def countries
      get("/countries", {}).map { Country.from_hash(_1) }
    end

    # Return details for one country, including subdivision codes.
    # @param country_code [String] ISO 3166 alpha-2 code, e.g. "US"
    # @return [Country]
    def country(country_code)
      raise ArgumentError, "country_code must not be empty" if country_code.nil? || country_code.empty?

      Country.from_hash(get("/country/#{URI.encode_uri_component(country_code)}", {}))
    end

    # Return all supported language codes.
    # @return [Array<Language>]
    def languages
      get("/languages", {}).map { Language.from_hash(_1) }
    end

    private

    def build_params(**kwargs)
      kwargs.each_with_object({}) do |(key, value), out|
        next if value.nil?

        out[key] = value.is_a?(Array) ? value.join(",") : value.to_s
      end
    end

    def get(path, params)
      uri = URI("#{@base_url}#{path}")
      uri.query = URI.encode_www_form(params) unless params.empty?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme == "https"
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Accept"]        = "application/json"

      response = http.request(request)
      body     = response.body

      unless response.is_a?(Net::HTTPSuccess)
        message = begin
          JSON.parse(body).fetch("message", response.message)
        rescue JSON::ParserError
          response.message
        end
        raise ApiError.new(message, response.code.to_i, body)
      end

      JSON.parse(body)
    end
  end
end

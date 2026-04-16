# holidays.rest Ruby SDK

[![Test](https://github.com/holidays-rest/sdk-ruby/actions/workflows/test.yml/badge.svg)](https://github.com/holidays-rest/sdk-ruby/actions/workflows/test.yml)
[![Publish](https://github.com/holidays-rest/sdk-ruby/actions/workflows/publish.yml/badge.svg?branch=main)](https://github.com/holidays-rest/sdk-ruby/actions/workflows/publish.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/bce07ed633394f069b4c2c6d87057d32)](https://app.codacy.com/gh/holidays-rest/sdk-ruby/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

Official Ruby SDK for the [holidays.rest](https://www.holidays.rest) API.

## Requirements

- Ruby 3.2+
- Zero runtime dependencies — uses only the standard library (`net/http`, `json`, `uri`)

## Installation

```bash
gem install holidays-rest
```

Or in your `Gemfile`:

```ruby
gem "holidays-rest"
```

## Quick Start

```ruby
require "holidays_rest"

client = HolidaysRest::Client.new(api_key: "YOUR_API_KEY")

holidays = client.holidays(country: "US", year: 2024)
holidays.each { |h| puts "#{h.date} — #{h.name}" }
```

Get an API key at [holidays.rest/dashboard](https://www.holidays.rest/dashboard).

---

## API

### `HolidaysRest::Client.new`

```ruby
client = HolidaysRest::Client.new(
  api_key:      "YOUR_API_KEY",   # required
  open_timeout: 5,                # optional, default 5s
  read_timeout: 15,               # optional, default 15s
  base_url:     "https://..."     # optional, override for testing
)
```

---

### `client.holidays(...)` → `Array<Holiday>`

| Parameter  | Type                  | Required | Description                                      |
|------------|-----------------------|----------|--------------------------------------------------|
| `country`  | `String`              | yes      | ISO 3166 alpha-2 code (e.g. `"US"`)              |
| `year`     | `Integer \| String`   | yes      | Four-digit year (e.g. `2024`)                    |
| `month`    | `Integer \| String`   | no       | Month filter (1–12)                              |
| `day`      | `Integer \| String`   | no       | Day filter (1–31)                                |
| `type`     | `String \| Array`     | no       | `"religious"`, `"national"`, `"local"`           |
| `religion` | `Integer \| Array`    | no       | Religion code(s) 1–11                            |
| `region`   | `String \| Array`     | no       | Subdivision code(s) — from `#country`            |
| `lang`     | `String \| Array`     | no       | Language code(s) — from `#languages`             |
| `response` | `String`              | no       | `"json"` (default) \| `"xml"` \| `"yaml"` \| `"csv"` |

```ruby
# All US holidays in 2024
client.holidays(country: "US", year: 2024)

# National holidays only
client.holidays(country: "DE", year: 2024, type: "national")

# Multiple types
client.holidays(country: "TR", year: 2024, type: ["national", "religious"])

# Filter by month and day
client.holidays(country: "GB", year: 2024, month: 12, day: 25)

# Specific region
client.holidays(country: "US", year: 2024, region: "US-CA")

# Multiple regions
client.holidays(country: "US", year: 2024, region: ["US-CA", "US-NY"])
```

---

### `client.countries` → `Array<Country>`

```ruby
client.countries.each { |c| puts "#{c.alpha2} — #{c.name}" }
```

---

### `client.country(country_code)` → `Country`

Returns country details including subdivision codes usable as `region:` filters.

```ruby
us = client.country("US")
us.subdivisions.each { |s| puts "#{s.code} — #{s.name}" }
```

---

### `client.languages` → `Array<Language>`

```ruby
client.languages.each { |l| puts "#{l.code} — #{l.name}" }
```

---

## Models

All responses are deserialized into immutable `Data` objects.

```ruby
Holiday
  .country_code   # String   — ISO 3166 alpha-2, e.g. "DE"
  .country_name   # String   — e.g. "Germany"
  .date           # String   — ISO 8601, e.g. "2026-01-01"
  .name           # Hash     — language code => name, e.g. { "en" => "New Year's Day" }
  .is_national    # Boolean
  .is_religious   # Boolean
  .is_local       # Boolean
  .is_estimate    # Boolean
  .day            # HolidayDay
  .religion       # String   — e.g. "Christianity", or "" if not applicable
  .regions        # Array<String> — subdivision codes, e.g. ["BW", "BY"]

HolidayDay
  .actual         # String   — day of week the holiday actually falls on
  .observed       # String   — day of week the holiday is observed

Country         # .name, .alpha2, .subdivisions → Array<Subdivision>
Subdivision     # .code, .name
Language        # .code, .name
```

---

## Error Handling

Non-2xx responses raise `HolidaysRest::ApiError`:

```ruby
begin
  client.holidays(country: "US", year: 2024)
rescue HolidaysRest::ApiError => e
  puts e.status_code   # HTTP status code (Integer)
  puts e.message       # Error message (String)
  puts e.body          # Raw response body (String)
end
```

| Status | Meaning             |
|--------|---------------------|
| 400    | Bad request         |
| 401    | Invalid API key     |
| 404    | Not found           |
| 500    | Server error        |
| 503    | Service unavailable |

---

## License

MIT

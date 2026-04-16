require_relative "test_helper"

class TestHolidayDay < Minitest::Test
  def test_from_hash
    d = HolidaysRest::HolidayDay.from_hash("actual" => "Thursday", "observed" => "Thursday")
    assert_equal "Thursday", d.actual
    assert_equal "Thursday", d.observed
  end

  def test_from_hash_missing_keys_default_to_empty_string
    d = HolidaysRest::HolidayDay.from_hash({})
    assert_equal "", d.actual
    assert_equal "", d.observed
  end
end

class TestHoliday < Minitest::Test
  FULL_HASH = {
    "country_code" => "DE",
    "country_name" => "Germany",
    "date"         => "2026-01-06",
    "name"         => { "en" => "Epiphany" },
    "isNational"   => false,
    "isReligious"  => true,
    "isLocal"      => true,
    "isEstimate"   => false,
    "day"          => { "actual" => "Tuesday", "observed" => "Tuesday" },
    "religion"     => "Christianity",
    "regions"      => ["BW", "BY", "ST"]
  }.freeze

  def test_from_hash_full
    h = HolidaysRest::Holiday.from_hash(FULL_HASH)
    assert_equal "DE",                   h.country_code
    assert_equal "Germany",              h.country_name
    assert_equal "2026-01-06",           h.date
    assert_equal({ "en" => "Epiphany" }, h.name)
    assert_equal false,                  h.is_national
    assert_equal true,                   h.is_religious
    assert_equal true,                   h.is_local
    assert_equal false,                  h.is_estimate
    assert_equal "Christianity",         h.religion
    assert_equal %w[BW BY ST],           h.regions
  end

  def test_from_hash_day_is_holiday_day_object
    h = HolidaysRest::Holiday.from_hash(FULL_HASH)
    assert_instance_of HolidaysRest::HolidayDay, h.day
    assert_equal "Tuesday", h.day.actual
    assert_equal "Tuesday", h.day.observed
  end

  def test_from_hash_missing_keys_use_safe_defaults
    h = HolidaysRest::Holiday.from_hash({})
    assert_equal "",    h.country_code
    assert_equal "",    h.country_name
    assert_equal "",    h.date
    assert_equal({}  , h.name)
    assert_equal false, h.is_national
    assert_equal false, h.is_religious
    assert_equal false, h.is_local
    assert_equal false, h.is_estimate
    assert_equal "",    h.religion
    assert_equal [],    h.regions
    assert_instance_of HolidaysRest::HolidayDay, h.day
  end

  def test_from_hash_national_holiday
    h = HolidaysRest::Holiday.from_hash(
      "country_code" => "DE", "country_name" => "Germany",
      "date" => "2026-01-01", "name" => { "en" => "New Year's Day" },
      "isNational" => true, "isReligious" => false,
      "isLocal" => false, "isEstimate" => false,
      "day" => { "actual" => "Thursday", "observed" => "Thursday" },
      "religion" => "", "regions" => []
    )
    assert_equal true,  h.is_national
    assert_equal false, h.is_religious
    assert_equal false, h.is_local
    assert_equal [],    h.regions
    assert_equal "",    h.religion
  end
end

class TestSubdivision < Minitest::Test
  def test_from_hash
    s = HolidaysRest::Subdivision.from_hash("code" => "US-CA", "name" => "California")
    assert_equal "US-CA",      s.code
    assert_equal "California", s.name
  end

  def test_from_hash_missing_keys_default_to_empty_string
    s = HolidaysRest::Subdivision.from_hash({})
    assert_equal "", s.code
    assert_equal "", s.name
  end
end

class TestCountry < Minitest::Test
  def test_from_hash_with_subdivisions
    c = HolidaysRest::Country.from_hash(
      "name"         => "United States",
      "alpha2"       => "US",
      "subdivisions" => [{ "code" => "US-CA", "name" => "California" }]
    )
    assert_equal "United States", c.name
    assert_equal "US",            c.alpha2
    assert_equal 1,               c.subdivisions.size
    assert_instance_of HolidaysRest::Subdivision, c.subdivisions.first
    assert_equal "US-CA",         c.subdivisions.first.code
    assert_equal "California",    c.subdivisions.first.name
  end

  def test_from_hash_without_subdivisions_key
    c = HolidaysRest::Country.from_hash("name" => "Germany", "alpha2" => "DE")
    assert_equal [], c.subdivisions
  end

  def test_from_hash_with_null_subdivisions
    c = HolidaysRest::Country.from_hash("name" => "Germany", "alpha2" => "DE", "subdivisions" => nil)
    assert_equal [], c.subdivisions
  end

  def test_from_hash_missing_keys_default_to_empty_string
    c = HolidaysRest::Country.from_hash({})
    assert_equal "", c.name
    assert_equal "", c.alpha2
    assert_equal [], c.subdivisions
  end
end

class TestLanguage < Minitest::Test
  def test_from_hash
    l = HolidaysRest::Language.from_hash("code" => "en", "name" => "English")
    assert_equal "en",      l.code
    assert_equal "English", l.name
  end

  def test_from_hash_missing_keys_default_to_empty_string
    l = HolidaysRest::Language.from_hash({})
    assert_equal "", l.code
    assert_equal "", l.name
  end
end

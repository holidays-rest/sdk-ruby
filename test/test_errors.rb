require_relative "test_helper"

class TestApiError < Minitest::Test
  def setup
    @error = HolidaysRest::ApiError.new("Not Found", 404, '{"message":"Not Found"}')
  end

  def test_is_a_standard_error
    assert_kind_of StandardError, @error
  end

  def test_message
    assert_equal "Not Found", @error.message
  end

  def test_status_code
    assert_equal 404, @error.status_code
  end

  def test_body
    assert_equal '{"message":"Not Found"}', @error.body
  end

  def test_inspect
    assert_equal '#<HolidaysRest::ApiError status_code=404 message="Not Found">', @error.inspect
  end
end

# frozen_string_literal: false
require_relative 'test_optparse'

class TestOptionParserInvalidEncoding < TestOptionParser
  # Ruby passes arguments through ARGV as the bytes it was given, so an
  # argument can hold bytes that are not valid in its encoding, such as a
  # file name from a system using another one.
  INVALID = "caf\xE9.txt".force_encoding(Encoding::UTF_8)

  def setup
    super
    @opt.def_option("-n", "--name=NAME") {|x| @flag = x}
    @opt.def_option("-v", "--verbose") {|x| @flag = x}
    assert_not_predicate(INVALID, :valid_encoding?)
  end

  def test_non_option_argument_is_left_alone
    rest = no_error {@opt.parse!([INVALID.dup])}
    assert_equal([INVALID.bytes], rest.map(&:bytes))
    assert_equal(self.class, @flag)
  end

  def test_option_argument_joined_by_equals
    assert_empty(no_error {@opt.parse!(["--name=#{INVALID}"])})
    assert_equal(INVALID.bytes, @flag.bytes)
  end

  def test_option_argument_in_the_next_element
    assert_empty(no_error {@opt.parse!(["--name", INVALID.dup])})
    assert_equal(INVALID.bytes, @flag.bytes)
  end

  def test_short_option_argument
    assert_empty(no_error {@opt.parse!(["-n#{INVALID}"])})
    assert_equal(INVALID.bytes, @flag.bytes)
  end

  def test_option_before_a_non_option_argument
    rest = no_error {@opt.parse!(["--verbose", INVALID.dup])}
    assert_equal([INVALID.bytes], rest.map(&:bytes))
    assert_equal(true, @flag)
  end

  def test_an_unknown_option_still_raises_parse_error
    assert_raise(OptionParser::InvalidOption) {@opt.parse!(["--bogus", INVALID.dup])}
  end
end

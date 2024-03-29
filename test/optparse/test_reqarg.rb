# frozen_string_literal: false
require_relative 'test_optparse'

module TestOptionParserReqArg
  def setup
    super
    @opt.def_option "--with_underscore=VAL" do |x| @flag = x end
    @opt.def_option "--with-hyphen=VAL" do |x| @flag = x end
    @opt.def_option("--lambda=VAL", &->(x) {@flag = x})
  end

  class Def1 < TestOptionParser
    include TestOptionParserReqArg
    def setup
      super
      @opt.def_option("-xVAL") {|x| @flag = x}
      @opt.def_option("--option=VAL") {|x| @flag = x}
      @opt.def_option("--regexp=REGEXP", Regexp) {|x| @reopt = x}
      @reopt = nil
    end
  end
  class Def2 < TestOptionParser
    include TestOptionParserReqArg
    def setup
      super
      @opt.def_option("-x", "--option=VAL") {|x| @flag = x}
    end
  end
  class Def3 < TestOptionParser
    include TestOptionParserReqArg
    def setup
      super
      @opt.def_option("--option=VAL", "-x") {|x| @flag = x}
    end
  end
  class Def4 < TestOptionParser
    include TestOptionParserReqArg
    def setup
      super
      @opt.def_option("-xVAL", "--option=VAL") {|x| @flag = x}
    end
  end

  def test_short
    assert_raise(OptionParser::MissingArgument) {@opt.parse!(%w"-x")}
    assert_equal(%w"", no_error {@opt.parse!(%w"-x foo")})
    assert_equal("foo", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"-xbar")})
    assert_equal("bar", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"-x=")})
    assert_equal("=", @flag)
  end

  def test_abbrev
    assert_raise(OptionParser::MissingArgument) {@opt.parse!(%w"-o")}
    assert_equal(%w"", no_error {@opt.parse!(%w"-o foo")})
    assert_equal("foo", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"-obar")})
    assert_equal("bar", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"-o=")})
    assert_equal("=", @flag)
  end

  def test_long
    assert_raise(OptionParser::MissingArgument) {@opt.parse!(%w"--opt")}
    assert_equal(%w"", no_error {@opt.parse!(%w"--opt foo")})
    assert_equal("foo", @flag)
    assert_equal(%w"foo", no_error {@opt.parse!(%w"--opt= foo")})
    assert_equal("", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"--opt=foo")})
    assert_equal("foo", @flag)
  end

  def test_hyphenize
    assert_equal(%w"", no_error {@opt.parse!(%w"--with_underscore foo1")})
    assert_equal("foo1", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"--with-underscore foo2")})
    assert_equal("foo2", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"--with-hyphen foo3")})
    assert_equal("foo3", @flag)
    assert_equal(%w"", no_error {@opt.parse!(%w"--with_hyphen foo4")})
    assert_equal("foo4", @flag)
  end

  def test_lambda
    assert_equal(%w"", no_error {@opt.parse!(%w"--lambda=lambda1")})
    assert_equal("lambda1", @flag)
  end

  class TestOptionParser::WithPattern < TestOptionParser
    def test_pattern
      pat = num = nil
      @opt.def_option("--pattern=VAL", /(\w+)(?:\s*:\s*(\w+))?/) {|x, y, z| pat = [x, y, z]}
      @opt.def_option("-T NUM", /\A[1-4]\z/) {|n| num = n}
      no_error {@opt.parse!(%w"--pattern=key:val")}
      assert_equal(%w"key:val key val", pat, '[ruby-list:45645]')
      no_error {@opt.parse!(%w"-T 4")}
      assert_equal("4", num, '[ruby-dev:37514]')
    end
  end
end

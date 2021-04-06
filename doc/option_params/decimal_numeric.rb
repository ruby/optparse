require 'optparse'
include OptionParser::Acceptables
parser = OptionParser.new
parser.on('--decimal_numeric=DECIMAL_numeric', DecimalNumeric) do |value|
  p [value, value.class]
end
parser.parse!

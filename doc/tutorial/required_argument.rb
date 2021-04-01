require 'optparse'
parser = OptionParser.new
parser.on('-x XXX', '--xxx') do |option|
  p "--xxx #{option}"
end
parser.on('-y', '--y YYY') do |option|
  p "--yyy #{option}"
end
parser.parse!

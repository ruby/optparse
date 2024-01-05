#! /usr/bin/ruby
# contributed by Minero Aoki.

require 'optparse'

opts = {}
parser = OptionParser.new
parser.on('-i') { opts["i"] = true }
parser.on('-o') { opts["o"] = true }

parser.subparser('add') {opts[:add] = {}}
  .on('-i') { opts[:add]["i"] = true }
parser.subparser('del') {opts[:del] = {}}.then do |sub|
  sub.on('-i') { opts[:del]["i"] = true }
end
parser.subparser('list') {opts[:list] = {}}.then do |sub|
  sub.on('-iN', Integer) {|i| opts[:list]["i"] = i }
end

h = {}
p parser.parse!(ARGV, into: h)
p h
p opts

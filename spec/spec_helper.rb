# Add the projects lib directory to our load path so we can require libraries
# within it easily.
dir = File.expand_path(File.dirname(__FILE__))

SPECDIR = dir
$LOAD_PATH.unshift("#{dir}/../lib")

require 'rubygems'
require 'rspec'
require 'spikor_forge'

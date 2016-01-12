#!/usr/bin/env ruby

require "fileutils"
include FileUtils

if RUBY_PLATFORM.start_with?("x86_64")
  puts "64bits"
  `cp  xflux/64bits/xflux ~/bin`
else
  puts "32bits"
  `cp  xflux/32bits/xflux ~/bin`
end

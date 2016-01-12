#!/usr/bin/env ruby

require 'fileutils' #I know, no underscore is not ruby-like
include FileUtils

def shell_execute(command, options = {})
  silent = options.fetch(:silent, false)
  raise_error = options.fetch(:raise_error, false)
  puts command unless silent
  o = `#{command}`
  r = $CHILD_STATUS.to_i
  if r != 0
    error_msg = "Error: #{o} Code: #{r} Command: #{command}"
    puts error_msg
    fail error_msg if raise_error
  end
  r
end

system("google-chrome &")

if RUBY_PLATFORM.start_with?("x86_64")
  puts "64bits"
  system(__dir__ + "/../xflux/64bits/xflux -l -13.0 -g -38.5")
else
  puts "32bits"
  system(__dir__ + "/../xflux/32bits/xflux -l -13.0 -g -38.5")
end

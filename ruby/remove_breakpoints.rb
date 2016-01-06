#!/usr/bin/env ruby
require 'fileutils'

all_files = Dir.glob('**/*').select { |f| !File.directory?(f) && (f.end_with?('.rb') || f.end_with?('.erb')) }
files_with_bp = []

all_files.each do |filename|
  next if filename.include?('features/support/debug.rb')
  begin
    open(filename, 'r') do |f|
      f.each_line do |line|
        if /.*binding\.pry.*/ =~ line
          files_with_bp << filename
          break
        end
      end
    end
  rescue => error
    puts("#{error.class} and #{error.message}")
  end
end

puts 'Files with breakpoint'
puts files_with_bp.inspect

files_with_bp.each do |filename|
  put filename if filename == 'doc/aaa'
  problem_writing_file = false
  open(filename, 'r') do |f|
    break if problem_writing_file
    open("#{filename}.rb_tmp", 'w') do |f2|
      f.each_line do |line|
        begin
          f2.write(line) unless /.*binding\.pry.*/ =~ line
        rescue
          problem_writing_file = true
          break
        end
      end
    end
  end
  next if problem_writing_file
  s = File.stat(filename)
  FileUtils.mv "#{filename}.rb_tmp", filename
  File.chmod(s.mode, filename)
end

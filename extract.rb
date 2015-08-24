#!/usr/bin/env ruby
## -*- coding: utf-8 -*-

# Extract english subtitles from MKV files.
# Usage
# extract.rb [list of files]
# extract.rb *
#
# Does not find files in subdirectories

require 'shellwords'

if ARGV[0] == "*"
  names = `ls`
else
  names = ARGV
end

names.each do |name|
  puts "Processing file #{name}"
  unless name[-3..-1].downcase == "mkv"
    puts "Wrong file type"
    next
  end

  unless File.exists?(name)
    puts "File not found: #{name}"
    next
  end

  puts "Checking tracks..."
  list = `mkvmerge --identify-verbose #{Shellwords.escape(name)}`

  puts "Looking for english subtitles"
  subtitle = list
   . split("\n")
   .select { |line| line.include?("subtitles") && line.include?("language:eng") }
   .first

  if subtitle
    track = subtitle.match(/Track ID (\d+)/)[1]
    puts "Found on Track #{track}"
    subfile = name.gsub("mkv", "srt")
    system "mkvextract tracks #{name} #{track}:#{subfile}"
  else
    puts "Not found"
  end
end

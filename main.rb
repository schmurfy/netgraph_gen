
require File.expand_path('../lib/core', __FILE__)
require File.expand_path('../lib/types', __FILE__)

if ARGV.size == 1
  path = ARGV[0]
  if File.exist?(path)
    puts "Executing file #{path}...\n\n"
    require(path)
  else
    puts "File not found: #{path} !"
  end
else
  puts "Usage: $0 <script_path>"
end



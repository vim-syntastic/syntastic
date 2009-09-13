# Copyright (c) 2009 Travis Jeffery <github:travisjeffery>
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Contributions by scrooloose <github:scrooloose>

require 'rake'
require 'find'
require 'pathname'

IGNORE = [/\.gitignore$/, /Rakefile$/]

files = `git ls-files`.split("\n")
files.reject! { |f| IGNORE.any? { |re| f.match(re) } }

desc 'Zip up the project files'
task :zip do
  zip_name = File.basename(File.dirname(__FILE__))
  zip_name.gsub!(/ /, '_')
  zip_name = "#{zip_name}.zip"

  if File.exist?(zip_name)
    abort("Zip file #{zip_name} already exists. Remove it first.")
  end

  puts "Creating zip file: #{zip_name}"
  system("zip #{zip_name} #{files.join(" ")}")
end

desc 'Install plugin and documentation'
task :install do
  vimfiles = if ENV['VIMFILES']
               ENV['VIMFILES']
             elsif RUBY_PLATFORM =~ /(win|w)32$/
               File.expand_path("~/vimfiles")
             else
               File.expand_path("~/.vim")
             end
  files.each do |file|
    target_file = File.join(vimfiles, file)
    FileUtils.mkdir_p File.dirname(target_file)
    FileUtils.cp file, target_file

    puts "Installed #{file} to #{target_file}"
  end

end

desc 'Pulls from origin'
task :pull do
  puts "Updating local repo..."
  system("cd " << Dir.new(File.dirname(__FILE__)).path << " && git pull")
end

desc 'Calls pull task and then install task'
task :update => ['pull', 'install'] do
  puts "Update of vim script complete."
end

desc 'Uninstall plugin and documentation'
task :uninstall do
  vimfiles = if ENV['VIMFILES']
               ENV['VIMFILES']
             elsif RUBY_PLATFORM =~ /(win|w)32$/
               File.expand_path("~/vimfiles")
             else
               File.expand_path("~/.vim")
             end
  files.each do |file|
    target_file = File.join(vimfiles, file)
    FileUtils.rm target_file

    puts "Uninstalled #{target_file}"
  end

end

task :default => ['update']

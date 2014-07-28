#!/usr/bin/env ruby

require 'yaml'
require 'fileutils' #I know, no underscore is not ruby-like
include FileUtils


yaml = YAML.load_file("config/cldstr.yml")

site = yaml['site']
tmpdir = "/tmp/#{ site }"
filename = "#{ site }.cldstr-backup"
addr = "#{ yaml['user'] }@#{ yaml['server']}"

rm_rf tmpdir
mkdir tmpdir

puts "generating backup file"
system %{ ssh #{ addr } "cldstr-backup-export --siteid #{ yaml['site_id'] } --out /tmp/#{ filename }" }

puts 'copying backup file'
system %{ scp -l 8192 #{ addr }:/tmp/#{ filename } #{tmpdir}/#{filename} }


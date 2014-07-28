#!/usr/bin/env ruby

require 'yaml'
require 'fileutils' #I know, no underscore is not ruby-like
include FileUtils

yaml = YAML.load_file("config/cldstr.yml")

site = yaml['site']
tmpdir = "/tmp/#{ site }"
filename = "#{ site }.cldstr-backup"
db = "#{ site }_copy"

id_folders = "#{ yaml['site_id']}/#{ yaml['appconfig_id']}"


puts "unzipping backup file"
system "unzip #{tmpdir}/#{filename} -d #{tmpdir}"

puts "dropping database"
system %{ echo "drop database #{ db }" | mysql -u root }

puts "creating database"
system %{ echo "create database #{db}" | mysql -u root }

puts "importing data"
system %{ mysql -u root #{ db } < #{tmpdir}/cldstr-appconfigs/ctrl/#{ id_folders }/cldstr+wagn.org+wagn/db }


puts "copying over uploaded files"
rm_rf 'files'
mv "#{tmpdir}/cldstr-appconfigs/ws/#{ id_folders }/cldstr+wagn.org+wagn/uploads", 'files'

puts "removing tmp directory"
rm_rf 'tmp'
mkdir 'tmp'

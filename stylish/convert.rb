#!/usr/bin/env ruby
require 'json'
require 'pathname'
require 'yaml'

def filename(name)
  Pathname(__FILE__).dirname + name
end

YAML.load_file(filename 'stylish.yml').tap do |me|
  me['data'].map! do |entry|
    entry['json'] = JSON.generate entry['json']
    entry
  end
  File.write filename('stylish.json'), JSON.generate(me)
end

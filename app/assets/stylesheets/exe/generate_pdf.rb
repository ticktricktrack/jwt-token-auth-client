#!/usr/bin/env ruby
require 'pry'
require 'fileutils'
require './lib/queue_workers/message_types'
require './lib/config/report_config.rb'

=begin
TODO:
 - append 'inofa' or 'passed' to report name
 - Figure out how to get both the JSON & the images to the local directory
 for specific reports (ie, re-run a file locally)
 - Figure out how to have a bug-fixing version - a flag to enter that
 prints the name of the file that generated it?
=end

def report_list
  {
    'av' => 'avista_res',
    'fv' => 'flood',
    'go' => 'goad',
    'hb' => 'homebuyers',
    'hs' => 'hs',
    'pv' => 'planning',
    'tm' => 'tm_gs_in_one', # Not currently working
    'c'  => 'configvista'
  }
end

report_type = ARGV[0]
inofa_or_passed = ARGV[1]
report_name = ARGV[2]

def get_report(report_type)
  report_list
    .find { |k, v| k == report_type || v == report_type }
end

def check_report?(report_type)
  get_report(report_type).nil?
end

if check_report?(report_type)
  abort("#{report_list.each { |k, v| puts "#{k} (#{v})\n" }} \nAre your options dear")
end

report_type = get_report(report_type).last

if inofa_or_passed == 'p' && report_type == 'goad'
  abort("Goad doesn't have passed data, exiting program")
end

if inofa_or_passed.nil?
  puts 'Using INOFA data - the second parameter ' \
    'was not specified ' \
    'If you want to use passed [that is, blank] data ' \
    'please enter \'p\' or \'passed\' when running ' \
    'the script.'
end

if report_name.nil?
  puts 'You\'ve not provided a report name; ' \
    'therefore, I\'m going to call your report ' \
    "#{report_type}.pdf. Just so you know."
  report_name = "#{report_type}.pdf"
end

fixtures = File.expand_path('../../spec/fixtures/', __FILE__)

inofa = '/avista/avista_inofa.json'
pass = '/avista/avista_autopass.json'

report_json_file =
  if inofa_or_passed == 'p' || inofa_or_passed == 'passed'
    fixtures + pass
  else
    fixtures + inofa
  end

report_json_data = JSON.parse(File.read(report_json_file))

FileUtils.mkdir_p('tmp')
path = 'tmp/' + report_name + '.pdf'


job = Job.new(
  job_request: {
    report_type: report_type,
    customer_id: 1,
    order_date: Date.new(2017, 1, 1).to_s,
    report_address: '1 Madeup St, Fictionaland, FL1 1EE',
    easting: 345345,
    northing: 345345,
    reportName: 'RGT-' + report_name,
    customer_reference: 'test-client',
    urban_rural: :rural,
    scottish: false,
    point_buffer: false,
    third_party_reference: nil
  }
)


case report_type
when 'avista_res'
  require './lib/reports/avista'
  Pdf::Avista.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
when 'flood'
  require './lib/reports/flood'
  Pdf::Flood.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
when 'goad'
  require './lib/reports/goad'
  Pdf::Goad.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/goad/', job: job).generate
when 'homebuyers'
  require './lib/reports/homebuyers'
  Pdf::Homebuyers.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/').generate
when 'hs'
  require './lib/reports/homescreen'
  Pdf::Homescreen.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
when 'planning'
  require './lib/reports/planning'
  Pdf::Planning.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
when 'tm_gs_in_one'
  require './lib/reports/tmvista'
  Pdf::Tmvista.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
when 'configvista'
  require './lib/reports/configvista'
  Pdf::Configvista.new(path: path, report_json_data: report_json_data, asset_path: 'spec/fixtures/avista/', job: job).generate
else
  puts 'something\'s not right here.'
end

`open #{path}`

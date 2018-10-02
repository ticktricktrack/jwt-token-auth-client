#!/usr/bin/env ruby
require 'aws-sdk'
require 'chamber'
require 'pry'
require 'json'
# require './lib/queue_workers/aws_environment'
# require './lib/report_generator/data_checker'
require './lib/helpers/zip_string'
require './lib/data_layers/data_layer'
require './lib/data_layers/flood/flood_risk_overall'

class FloodRisk
  attr_accessor :job, :report_json

  def initialize(job)
    Chamber.load namespaces: ENV['GS_ENV']
    @job = job
    @report_json = fetch_report_json
  end

  def calculate
    return "no json" unless report_json
    puts "calculate royalties for #{job.job_id}"
    # DataChecker.new(job_id, report_json).check!
    DataLayer.job = job
    DataLayer.source = report_json
    DataLayer.for(:flood_risk_overall).risk
  end

  private

  def fetch_report_json
    return nil unless report_files_bucket.object(report_path).exists?

    response = report_files_bucket.object(report_path).get
    body = response.body.read
    body = unzip(body) if response.content_encoding == 'gzip'
    JSON.parse(body)
  end

  def unzip(string)
    ZipString.new.decompress string
  end

  def zip(string)
    ZipString.new.compress string
  end

  def report_files_bucket
    Aws::S3::Bucket.new("gs-#{ENV['GS_ENV']}-report-files")
  end

  def report_path
    "#{job.job_id}/#{job.job_id}.json"
  end
end

Hashie.logger = Logger.new(nil)
file_name = 'exe/flood_risk.json'
job_ids = JSON.parse(File.read(file_name))
# job_ids = [{'job_id' => '3606439_BULK_1'}]
job_ids.each_with_index do |h, i|
  next if h['done']
  puts "i am doing #{file_name}"
  puts "doing #{i + 1} from #{job_ids.length}"

  job = Job.find job_id: h['taskid']
# binding.pry
puts h['taskid']
  risk = FloodRisk.new(job).calculate
  # risk = DataLayer::FloodRiskOverall.new.risk
  # binding.pry
  h['done'] = true
  h['flood_risk_overall'] = risk
  File.write(file_name, JSON.pretty_generate(job_ids))
end

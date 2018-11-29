require 'open3'
require './course_maker/course_maker'
require 'dotenv'


if ARGV.size != 1
  puts 'usage: entry_point.rb course_setting_file'
  exit(-1)
end

Dotenv.load
app_dir = ENV['STEPMANIA_APPLICATION_DIRECTORY']

setting_hash_array = eval File.read ARGV[0]

setting_hash_array.each do |setting_hash|
  setting = CourseMaker::CourseSetting.new(setting_hash)
  CourseMaker.make(app_dir, setting)
end


Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

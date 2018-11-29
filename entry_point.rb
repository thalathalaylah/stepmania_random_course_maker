require 'open3'
require './course_maker/course_maker'
require 'dotenv'

Dotenv.load
app_dir = ENV['STEPMANIA_APPLICATION_DIRECTORY']


setting_hash_array = [
    {
        target_level: 10,
        sample_number: 8,
        target_bpm_ranges: [[400, 430], [380, 400], [300, 380]],
        course_name: 'WarmingUp',
        meter: 'Medium:10',
        scripter: 'Thalathalaylah'
    },
    {
        target_level: 11,
        sample_number: 4,
        target_bpm_ranges: [[400, 430], [380, 400], [300, 380]],
        course_name: 'Advance',
        meter: 'Medium:10',
        scripter: 'Thalathalaylah'
    }
]

setting_hash_array.each do |setting_hash|
  setting = CourseMaker::CourseSetting.new(setting_hash)
  CourseMaker.make(app_dir, setting)
end


Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

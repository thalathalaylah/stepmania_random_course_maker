require 'open3'
require './course_maker/course_maker'

app_dir = '/Applications/StepMania-5.0.12'


setting_hash = {
    target_level:10,
    sample_number:8,
    target_bpm_ranges:[[400, 430], [380, 400], [300, 380]],
    course_name:'WarmingUp',
    meter:'Medium:10',
    scripter:'Thalathalaylah'
}

setting = CourseMaker::CourseSetting.new(setting_hash)
CourseMaker.make(app_dir, setting)

setting_hash[:target_level] = 11
setting_hash[:sample_number] = 4
setting_hash[:course_name] = 'Advance'

setting = CourseMaker::CourseSetting.new(setting_hash)
CourseMaker.make(app_dir, setting)

Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

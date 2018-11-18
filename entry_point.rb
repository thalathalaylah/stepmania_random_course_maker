require 'open3'
require './course_maker/course_maker'

app_dir = '/Applications/StepMania-5.0.12'
target_level = 10
sample_number = 8
target_bpms_array = [[400, 430], [380, 400]]
course_name = 'WarmingUp'
meter = 'Medium:10'
scripter = 'Thalathalaylah'

CourseMaker.make(app_dir, target_level, sample_number, target_bpms_array, course_name, meter, scripter)

target_level = 11
sample_number = 4
course_name = 'Advance'

CourseMaker.make(app_dir, target_level, sample_number, target_bpms_array, course_name, meter, scripter)

Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

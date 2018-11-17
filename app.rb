require 'open3'
require 'erb'
require './song'

app_dir = '/Applications/StepMania-5.0.12'

simfiles = %w(.sm .ssc).reduce([]) {|result, item| result + Dir.glob(app_dir + '/Songs/*/*/*' + item)}

all_songs = simfiles.map do |simfile_path|
  File.open(simfile_path, 'r') do |f|
    content = f.read.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
    Song::generate(app_dir, simfile_path, content)
  end
end

pp all_songs.size
pp all_songs.select{|song| song.difficulties[0].difficulty_str != nil}.size


target_level = 10
sample_number = 6
target_bpms_array = [[400, 430], [380, 400]]

songs = all_songs.select {|song| song.soflan? }  # ソフラン除外（倍速を決められないため）
    .select{|song| song.difficulties.find{|difficulty| difficulty.level == target_level}} # 曲レベル指定取得
    .sample(sample_number) # プレイしたい曲数分抜き出す

course_name = 'advance'
auther = 'Thalathalaylah'
meter = 'Medium:10'

course_file_name = course_name + '.crs'
File.open('course.erb', 'r') do |erb|
  File.open(app_dir + '/Courses/' + course_file_name, 'w') do |f|
    f.print(ERB.new(erb.read).result(binding))
  end
end

Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

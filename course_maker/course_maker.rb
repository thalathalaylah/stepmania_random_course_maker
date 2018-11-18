require 'erb'
require './course_maker/song'


module CourseMaker
  def make(app_dir, target_level, sample_number, target_bpms_array, course_name, meter, scripter)
    simfiles = %w(.sm .ssc).reduce([]) {|result, item| result + Dir.glob(app_dir + '/Songs/*/*/*' + item)}

    all_songs = simfiles.map do |simfile_path|
      File.open(simfile_path, 'r') do |f|
        content = f.read.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
        Song::generate(app_dir, simfile_path, content)
      end
    end

    pp all_songs.size
    pp all_songs.select {|song| song.difficulties[0].difficulty_str != nil}.size

    songs = all_songs.select {|song| song.soflan?} # ソフラン除外（倍速を決められないため）
                .select {|song| song.difficulties.find {|difficulty| difficulty.level == target_level}} # 曲レベル指定取得
                .sample(sample_number) # プレイしたい曲数分抜き出す

    course_file_name = course_name + '.crs'
    File.open('course.erb', 'r') do |erb|
      File.open(app_dir + '/Courses/' + course_file_name, 'w') do |f|
        f.print(ERB.new(erb.read).result(binding))
      end
    end
  end

  module_function :make
end


require 'open3'
require 'erb'

app_dir = '/Applications/StepMania-5.0.12'

simfiles = %w(.sm .ssc).reduce([]) {|result, item| result + Dir.glob(app_dir + '/Songs/*/*/*' + item)}

def detect_difficulty(content, sign)
  difficulty = ''
  count = 0
  read = false
  content.each_line do |line|
    if line.include?(sign)
      read = true
    end
    if read
      difficulty += line
      count += 1

      if count == 5
        count = 0
        read = false
      end
    end
  end
  difficulty
end

simfiles_with_bpm = simfiles.map do |simfile|
  display_bpm = ''
  bpms = ''
  difficulty = ''
  File.open(simfile, 'r') do |f|
    content = f.read.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
    content.each_line do |line|
      display_bpm = display_bpm + (/DISPLAYBPM/i =~ line ? line : '')
      bpms = bpms + (/bpms/i =~ line ? line : '')
    end

    difficulty = detect_difficulty(content, 'NOTEDATA')
    if difficulty == ''
      difficulty = detect_difficulty(content, 'NOTES')
      difficulty = difficulty.split("\r\n")
                       .each_slice(5)
                       .map{ |item| item.reduce(''){|result, item| result + item.strip} }
                       .select{ |item| item.include?('dance-single') }
                       .map{ |item| /#notes:dance-single::(?<difficulty>[a-zA-z]+):(?<level>[0-9]+)/i.match(item) }
    else
      difficulty = difficulty.split("\r\n")
                       .each_slice(5)
                       .map{ |item| item.reduce(''){|result, item| result + item.strip} }
                       .select{ |item| item.include?('dance-single') }
                       .map{ |item| /#notedata:;#stepstype:dance-single;#difficulty:(?<difficulty>[a-zA-z]+);#meter:(?<level>[0-9]+)/i.match(item) }
    end
  end

  display_bpm_str = /#DISPLAYBPM:(?<bpm>[[:alnum:]:.]+)/i.match(display_bpm.partition("\r")[0])
  bpm_str = /#BPMS:[0-9.]+=(?<bpm>[0-9.]+)/i.match(bpms.partition("\r")[0])

  [simfile, display_bpm_str ? display_bpm_str[:bpm] : nil, bpm_str ? bpm_str[:bpm] : nil, difficulty]
end

pp simfiles_with_bpm.size
fixed_bpm = simfiles_with_bpm.select {|sim, display_bpm, bpm, difficulty| display_bpm ? !display_bpm.include?(':') : true}
pp fixed_bpm.size
data = fixed_bpm.map {|sim, display_bpm, bpm, difficulty| [sim, (display_bpm ? /(?<bpm>[0-9]+)/.match(display_bpm)[:bpm] : /(?<bpm>[0-9]+)/.match(bpm)[:bpm]).to_i, difficulty]}
pp data.size

pp data.select{|data| data[2][0][:difficulty] != nil}.size

target_level = '11'

target = data.select{|data| data[2].find{|difficulty| difficulty&.[](:level) == target_level}}.sample(3)


def calc_speed(bpm)
  result_array = (0..16).map do |num|
    speed = 1.0 + 0.25 * num
    [speed, speed * bpm]
  end
  result = result_array.find{|info| 400 <= info[1] && info[1] <= 430}
  pp result
  unless result
    result = result_array.find{|info| 380 <= info[1] && info[1] <= 400}
  end
  p result_array
  result[0]
end

songs = target.map do |data|
  data[0][app_dir + '/Songs/'] = ''
  tmp = data[0].split('/')
  path = tmp[0] + '/' + tmp[1]
  pp data
  difficulty = data[2].find{|di| di&.[](:level) == target_level}[:difficulty]

  {path:path, difficulty:difficulty, speed:calc_speed(data[1])}
end

course_name = 'test2.crs'
auther = 'Thalathalaylah'
meter = 'Medium:10'

#songs = [{path:'X2/shining', difficulty:'Hard', speed:2.5}]

File.open('course.erb', 'r') do |erb|
  File.open(app_dir + '/Courses/' + course_name, 'w') do |f|
    f.print(ERB.new(erb.read).result(binding))
  end
end



#Open3.pipeline_rw('open ' + app_dir + '/StepMania.app')

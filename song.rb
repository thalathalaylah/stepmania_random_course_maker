class Song
  def initialize(app_dir, simfile_path, simfile)
    display_bpm = ''
    bpms = ''
    simfile.each_line do |line|
      display_bpm += (/DISPLAYBPM/i =~ line ? line : '')
      bpms += (/bpms/i =~ line ? line : '')
    end

    difficulty = detect_difficulty(simfile, 'NOTEDATA')
    if difficulty == ''
      difficulty = detect_difficulty(simfile, 'NOTES')
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


    display_bpm_str = /#DISPLAYBPM:(?<bpm>[[:alnum:]:.]+)/i.match(display_bpm.partition("\r")[0])
    bpm_str = /#BPMS:[0-9.]+=(?<bpm>[0-9.]+)/i.match(bpms.partition("\r")[0])

    @display_bpm = display_bpm_str ? display_bpm_str[:bpm] : nil
    @bpm = bpm_str ? bpm_str[:bpm] : nil
    @difficulty = difficulty
    @simfile_full_path = simfile_path
    @app_dir = app_dir
  end

  def bpm_num
    (@display_bpm ? /(?<bpm>[0-9]+)/.match(@display_bpm)[:bpm] : /(?<bpm>[0-9]+)/.match(@bpm)[:bpm]).to_i
  end

  def speed(target_bpms_array)
    result_array = (0..16).map do |num|
      speed = 1.0 + 0.25 * num
      [speed, speed * bpm_num]
    end
    result = result_array.find{|info| target_bpms_array[0][0] <= info[1] && info[1] <= target_bpms_array[0][1]}
    unless result
      result = result_array.find{|info| target_bpms_array[1][0] <= info[1] && info[1] <= target_bpms_array[1][1]}
    end
    result[0]
  end

  def relative_dir
    tmp = @simfile_full_path
    tmp[@app_dir + '/Songs/'] = ''
    tmp = tmp.split('/')
    tmp[0] + '/' + tmp[1]
  end

  attr_reader :bpm, :display_bpm, :difficulty, :simfile_full_path

  private
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
end
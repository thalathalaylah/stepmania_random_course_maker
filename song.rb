require './difficulty'

class Song
  def self.generate(app_dir, simfile_path, simfile)
    display_bpm = ''
    bpms = ''
    simfile.each_line do |line|
      display_bpm += (/DISPLAYBPM/i =~ line ? line : '')
      bpms += (/bpms/i =~ line ? line : '')
    end

    difficulties = detect_difficulty(simfile, 'NOTEDATA')
    if difficulties == ''
      difficulties = detect_difficulty(simfile, 'NOTES')
    end

    difficulties = difficulties.split("\r\n")
                        .each_slice(5)
                        .map {|item| item.reduce('') {|result, item| result + item.strip}}
                        .select {|item| item.include?('dance-single')}
                        .map {|item|
                          dif = Difficulty::generate(item)
                          if dif.nil?
                            pp simfile_path
                            pp item
                          end
                          dif
                        }
                        .delete_if {|item| item.nil?}


    display_bpm_str = /#DISPLAYBPM:(?<bpm>[[:alnum:]:.]+)/i.match(display_bpm.partition("\r")[0])
    bpm_str = /#BPMS:[0-9.]+=(?<bpm>[0-9.]+)/i.match(bpms.partition("\r")[0])
    Song.new(
        bpm_str ? bpm_str[:bpm] : nil,
        display_bpm_str ? display_bpm_str[:bpm] : nil,
        simfile_path,
        difficulties,
        app_dir
    )
  end

  def self.detect_difficulty(content, sign)
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

  private_class_method :detect_difficulty
end


class Song
  def initialize(bpm, display_bpm, simfile_full_path, difficulties, app_dir)
    @bpm = bpm
    @display_bpm = display_bpm
    @simfile_full_path = simfile_full_path
    @difficulties = difficulties
    @app_dir = app_dir
  end

  def bpm_num
    (@display_bpm ? /(?<bpm>[0-9]+)/.match(@display_bpm)[:bpm] : /(?<bpm>[0-9]+)/.match(@bpm)[:bpm]).to_i
  end

  def soflan?
    @display_bpm ? !@display_bpm.include?(':') : true
  end

  def speed(target_bpms_array)
    result_array = (0..16).map do |num|
      speed = 1.0 + 0.25 * num
      [speed, speed * bpm_num]
    end
    result = result_array.find {|info| target_bpms_array[0][0] <= info[1] && info[1] <= target_bpms_array[0][1]}
    unless result
      result = result_array.find {|info| target_bpms_array[1][0] <= info[1] && info[1] <= target_bpms_array[1][1]}
    end
    result[0]
  end

  def relative_dir
    tmp = @simfile_full_path
    tmp[@app_dir + '/Songs/'] = ''
    tmp = tmp.split('/')
    tmp[0] + '/' + tmp[1]
  end

  attr_reader :difficulties
end

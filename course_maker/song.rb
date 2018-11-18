require './course_maker/difficulty'

module CourseMaker
  # Factory実装
  class Song
    def self.generate(app_dir, simfile_path, simfile)
      display_bpm = ''
      bpms = ''
      simfile.each_line do |line|
        display_bpm += (/DISPLAYBPM/i =~ line ? line : '')
        bpms += (/bpms/i =~ line ? line : '')
      end

      difficulties = Difficulty::generate_difficulties(simfile)
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
  end

  # Class実装
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

    def speed(target_bpm_ranges)
      speed_and_bpm_array = (0..16).map do |num|
        speed = 1.0 + 0.25 * num
        [speed, speed * bpm_num]
      end

      target_bpm_ranges.map do |target_bpm_slow, target_bpm_fast|
        speed_and_bpm_array.find do |speed_and_bpm|
          target_bpm_slow <= speed_and_bpm[1] && speed_and_bpm[1] <= target_bpm_fast
        end
      end.find { |speed_and_bpm| speed_and_bpm }[0]
    end

    def relative_dir
      /#{@app_dir}\/Songs\/(?<dir>[^\/]+\/[^\/]+)/.match(@simfile_full_path)[:dir]
    end

    attr_reader :difficulties
  end
end

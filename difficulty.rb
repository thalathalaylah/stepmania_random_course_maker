# Factory実装
class Difficulty
  def self.generate_all_difficulties(simfile, path)
    simfile.include?('#VERSION') ? generate_all_from_ssc(simfile) : generate_all_from_sm(simfile)
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


  def self.generate_all_from_sm(simfile)
    simfile
        .scan(/#NOTES:[\s]+dance-single:[\s]+:[\s]+([a-zA-Z]+):[\s]+([0-9]+):/)
        .map{ |match| Difficulty.new(match[0], match[1].to_i) }
  end

  def self.generate_all_from_ssc(simfile)
    difficulties = detect_difficulty(simfile, 'NOTEDATA')
    difficulties = difficulties.split("\r\n")
                       .each_slice(5)
                       .map {|item| item.reduce('') {|result, item| result + item.strip}}
                       .select {|item| item.include?('dance-single')}
    difficulties = difficulties
                       .map {|item|
                         dif = generate_from_ssc(item)
                         if dif.nil?
                           pp item
                         end
                         dif
                       }
                       .delete_if {|item| item.nil?}
    difficulties
  end

  def self.generate_from_ssc(notedata_str)
    match_data =
        /#notedata:;#stepstype:dance-single;#difficulty:(?<difficulty>[a-zA-Z]+);#meter:(?<level>[0-9]+)[[:alnum:]#:;]+/i
            .match(notedata_str)

    if match_data
      Difficulty.new(match_data[:difficulty], match_data[:level].to_i)
    end
  end

  private_class_method :generate_from_sm, :generate_from_ssc
end

# Class実装
class Difficulty

  # @param [String]  difficulty_str 難易度文字列
  # @param [Fixnum]  level 難易度数値
  def initialize(difficulty_str, level)
    @difficulty_str = difficulty_str
    @level = level
  end

  attr_reader :difficulty_str, :level
end

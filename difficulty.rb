class Difficulty

  # @param [String]  notedata_str simfile中の各難易度に関する情報を含む文字列
  # @return [Difficulty|Nil] notedata_strが不正な形式だった場合nilを返す
  def self.generate(notedata_str)
    match_data =
        if notedata_str.include?('#NOTEDATA')
          /#notedata:;#stepstype:dance-single;#difficulty:(?<difficulty>[a-zA-Z]+);#meter:(?<level>[0-9]+)[[:alnum:]#:;]+/i
              .match(notedata_str)
        else
          /#notes:dance-single::(?<difficulty>[a-zA-z]+):(?<level>[0-9]+)/i
              .match(notedata_str)
        end
    if match_data
      Difficulty.new(match_data[:difficulty], match_data[:level].to_i)
    end
  end

  # @param [String]  difficulty_str 難易度文字列
  # @param [Fixnum]  level 難易度数値
  def initialize(difficulty_str, level)
    @difficulty_str = difficulty_str
    @level = level
  end

  attr_reader :difficulty_str, :level
end

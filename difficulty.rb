# Factory実装
class Difficulty

  # @param [String]  simfile 譜面データ(.sm or .ssc)
  # @return [Array[Difficulty]] 譜面の各難易度情報
  def self.generate_difficulties(simfile)
    simfile.include?('#VERSION') ? generate_from_ssc(simfile) : generate_from_sm(simfile)
  end

  def self.generate_from_sm(simfile)
    generate_by_regexp(
        simfile,
        /#NOTES:[\s]+dance-single:[\s]+:[\s]+([a-zA-Z]+):[\s]+([0-9]+):/
    )
  end

  def self.generate_from_ssc(simfile)
    generate_by_regexp(
        simfile,
        /#NOTEDATA[[:alnum:]:;\s]+#STEPSTYPE:dance-single[[:alnum:]:;\s#]+#DIFFICULTY:([a-zA-Z]+)[[:alnum:]:;\s#]+#METER:([0-9]+)/
    )
  end

  def self.generate_by_regexp(simfile, regexp)
    simfile
        .scan(regexp)
        .map {|match| Difficulty.new(match[0], match[1].to_i)}
  end

  private_class_method :generate_from_sm, :generate_from_ssc, :generate_by_regexp
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

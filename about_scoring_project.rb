require File.expand_path(File.dirname(__FILE__) + '/edgecase')

# Greed is a dice game where you roll up to five dice to accumulate
# points.  The following "score" function will be used to calculate the
# score of a single roll of the dice.
#
# A greed roll is scored as follows:
#
# * A set of three ones is 1000 points
#
# * A set of three numbers (other than ones) is worth 100 times the
#   number. (e.g. three fives is 500 points).
#
# * A one (that is not part of a set of three) is worth 100 points.
#
# * A five (that is not part of a set of three) is worth 50 points.
#
# * Everything else is worth 0 points.
#
#
# Examples:
#
# score([1,1,1,5,1]) => 1150 points
# score([2,3,4,6,2]) => 0 points
# score([3,4,5,3,3]) => 350 points
# score([1,5,1,2,4]) => 250 points
#
# More scoring examples are given in the tests below:
#
# Your goal is to write the score method.
#

class DiceParser
	def initialize(dice)
		@dice = dice
		@singles = []
	end
	def parse
		@groups = self.group_sets
		self.split_groups_from_singles
		return {:groups => @groups, :singles => @singles}
	end
  def group_sets
    @dice.group_by { |i| i }
	end
	def split_groups_from_singles
    @groups.each do |key, value| 
			if value.length > 2
        @groups[key] = value[0, value.length - 3]
			  @singles << key
		  end
		end
	end
end

class DiceSet
	def initialize(dice)
		@dice = dice
	end
  def score
		self.parse
		scorer = Scorer.new([DiceGroup.new(@parsed[:singles]), DiceSingle.new(@parsed[:groups])])
		scorer.score
	end
	def parse
		dp = DiceParser.new(@dice)
    @parsed = dp.parse
	end
end

class Scorer
	def initialize(dice_sets)
		@dice_sets = dice_sets
	end
	def score
		score = 0
		@dice_sets.each { |dice| score += dice.score }
		return score
	end
end

class DiceGroup < Struct.new(:sets)
  def score
		score = 0
		sets.each do |key|
      score += key == 1 ? 1000 : 100 * key 
		end
		return score
	end
end

class DiceSingle < Struct.new(:singles)
	def score
		score = 0
    singles.each do |key, value|
			score += key == 1 ? value.length * 100 : 0
			score += key == 5 ? value.length * 50 : 0
		end
		return score
	end
end


def score(dice)
	ds = DiceSet.new(dice)
  ds.score
end

class AboutScoringProject < EdgeCase::Koan
  def test_score_of_an_empty_list_is_zero
    assert_equal 0, score([])
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal 50, score([5])
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal 100, score([1])
  end

  def test_score_of_multiple_1s_and_5s_is_the_sum_of_individual_scores
    assert_equal 300, score([1,5,5,1])
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal 0, score([2,3,4,6])
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal 1000, score([1,1,1])
  end

  def test_score_of_other_triples_is_100x
    assert_equal 200, score([2,2,2])
    assert_equal 300, score([3,3,3])
    assert_equal 400, score([4,4,4])
    assert_equal 500, score([5,5,5])
    assert_equal 600, score([6,6,6])
  end

  def test_score_of_mixed_is_sum
    assert_equal 250, score([2,5,2,2,3])
    assert_equal 550, score([5,5,5,5])
  end

end

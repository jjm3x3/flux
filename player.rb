
class Player
  attr_accessor :keepers, :next, :name, :hand, :creepers
  
  def initialize(name, game)
    @name = name
    @keepers = []
    @creepers = []
    @game = game
  end

  def takeTurn
    drawCards
    @game.playCards
  end 

  def drawCards
    @hand += @game.drawCards(self, :draw_rule)
  end

  def won?
    if @game.hasGoal?
      @game.goalMet?(self)
    else
      false
    end
  end

  def add_creeper(creeper)
    @creepers << creeper
  end

  def set_hand(hand)
    oldHand = @hand
    @hand = hand
    oldHand
  end

  def to_s
    @name
  end
end

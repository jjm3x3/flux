
class Player
  attr_accessor :keepers, :next, :name, :hand
  
  def initialize(name, game)
    @name = name
    @keepers = []
    @game = game
  end

  def takeTurn
    drawCards
    @game.playCards
  end 

  def drawCards
    @hand += @game.drawCards
  end

  def won?
    if @game.hasGoal?
      @game.goalMet?(self)
    else
      false
    end
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

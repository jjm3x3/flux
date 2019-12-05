
class Player
  attr_accessor :keepers, :hand
  attr_reader :creepers, :name
  
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

  # TODO:: cannot win if the player has any creepers
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

  def has_peace?
    @keepers.select do |keeper|
      keeper.is_peace?
    end.size > 0
  end

  def has_war?
    @creepers.select do |creeper|
      creeper.is_war?
    end.size > 0
  end

  def take_war
    warCreeper = @creepers.select do |creeper|
      creeper.is_war?
    end[0]
    @creepers = @creepers.select do |creeper|
      !creeper.is_war?
    end
    warCreeper
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

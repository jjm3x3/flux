
class Player
  attr_accessor :keepers, :hand, :take_another_turn
  attr_reader :creepers, :name
  
  def initialize(name, game)
    @name = name
    @keepers = []
    @creepers = []
    @game = game
    @take_another_turn = false
  end

  def takeTurn
    drawCards
    @game.playCards(self)
    @game.discardDownToLimit(self)
    @game.removeDownToKeeperLimit(self)
    if(@take_another_turn)
      @game.currentPlayerCounter -= 1
      @take_another_turn = false
    end
  end 

  def drawCards
    @hand += @game.drawCards(self, :draw_rule)
  end

  def won?
    if @game.hasGoal?
      @game.goalMet?(self) && !@creepers.any?
    else
      false
    end
  end

  def add_permanent(permanent1)
    if permanent1.card_type == "Keeper"
      @keepers << permanent1
    elsif permanent1.card_type == "Creeper"
      add_creeper(permanent1)
    else
      puts "attempting to play a permanent1 with an unknown type '#{permanent1.card_type}'"
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

  def has_money?
    @keepers.select do |keeper|
      keeper.is_money?
    end.size > 0
  end

  def has_taxes?
    @creepers.select do |creeper|
      creeper.is_taxes?
    end.size > 0
  end

  def take_money
    moenyKeeper = @keepers.select do |keeper|
      keeper.is_money?
    end[0]
    @keepers = @keepers.select do |keeper|
      !keeper.is_money?
    end
    moenyKeeper
  end

  def take_taxes
    taxesCreeper = @creepers.select do |creeper|
      creeper.is_taxes?
    end[0]
    @creepers = @creepers.select do |creeper|
      !creeper.is_taxes?
    end
    taxesCreeper
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

  def clear_permanents
    @keepers = []
    @creepers = []
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

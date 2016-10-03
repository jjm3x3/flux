
class Card
  attr_reader :card_type
  attr_reader :name

  def initialize(number=1,name="thing")
    @name = name
    case number
    when 1
      @card_type = "Keeper"
    when 2
      @card_type = "Goal"
    when 3
      @card_type = "Rule"
    when 4
      @card_type = "Action"
    end
  end

  def ==(other_card)
    self.name == other_card.name
  end

  def play
    puts "sub classes must implment this"
  end

  def to_s
    @name
  end
end

class Keeper < Card
  
  def initialize(name)
    super(1,name)
  end

  def play(player, game)
    player.keepers << self
  end

end

class Goal < Card

  def initialize(name, cards, rule)
    super(2, name)
    @related_keepers = cards
  end

  def play(player, game)
    game.setGoal(self)
  end

  def met?(player, game)
    # puts "\ncheck if #{player} won"
    haveCard1 = player.keepers.include?(@related_keepers[0])
    # puts "do the have card #{@related_keepers[0]}?: #{haveCard1}"
    haveCard2 = player.keepers.include?(@related_keepers[1])
    # puts "do the have card #{@related_keepers[1]}?: #{haveCard2}"
    if haveCard1 && haveCard2
      return true
    end
  end

end

class Rule < Card
  attr_reader :rule_type, :rule_text

  def initialize(name, ruleType, rulesText)
    super(3,name)
    @rule_type = ruleType
    @rule_text = rulesText
  end

  def play(player, game)
    game.ruleBase.addRule(self)
  end

end

class Action < Card

  def initialize(id, name, rule_text)
    super(4,name)
    @id = id
    @rule_text = rule_text
  end

  def play(player, game)
    case @id
    when 1
      game.ruleBase.resetToBasic
    when 2
      game.playTwoAndUseEm(player)
      # puts "draw 2 and use 'em"
    when 3
      game.jackpot(player)
    when 4
      game.removeLimits
    end
  end
end

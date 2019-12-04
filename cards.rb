
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
    when 6
      @card_type = "Creeper"
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
  @@PeaceId = 16
  
  def initialize(id, name)
    super(1,name)
    @id = id
  end

  def play(player, game)
    player.keepers << self
    if @id == @@PeaceId
      game.resolve_war_rule(player)
    end
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

class Limit < Rule
  attr_reader :limit

  def initialize(name, ruleType, rulesText, limit)
    super(name, ruleType, rulesText)
    @limit = limit
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
      game.draw_2_and_use_em(player)
    when 3
      game.jackpot(player)
    when 4
      game.ruleBase.removeLimits
    when 5
      game.draw_3_play_2_of_them(player)
    when 6
      game.discard_and_draw(player)
    when 7
      game.useWhatYouTake(player)
    when 8
      game.taxation(player)
    when 9
      game.todaysSpecial(player)
    when 10
      game.mixItAllUp(player)
    when 11
      game.letsDoThatAgain(player)
    when 12
      game.everybody_gets_1(player)
    when 13
      game.tradeHands(player)
    when 14
      game.rotateHands(player)
    when 15
      game.take_another_turn
    when 16
      game.exchange_keepers(player)
    end
    game.discard(self)
  end
end

class Creeper < Card
  def initialize(id, name, rule_text)
    super(6, name)
    @id = id
    @rule_text = rule_text
  end

  def is_war?
    @id == 1
  end

  def play(player, game)
    player.add_creeper(self)
    case @id
    when 1
      game.resolve_war_rule(player)
    end
  end
end

class FakeCard < Card
  attr_reader :played
  def initialize(name)
    super(5,name)
    @played = false
  end

  def play(player, game)
    @played = true
  end
end

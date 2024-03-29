class Card

  attr_reader :card_type,
    :name,
    :rule_text

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
    return false if other_card == nil
    return false unless other_card.respond_to? :name
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
  @@peace_id = 16
  @@money_id = 19

  def initialize(id, name)
    super(1,name)
    @id = id
    if is_peace?
      @rule_text = "#{name}\n (If you have War, move it to another player if you have this on the table)"
    else
      @rule_text = name
    end
  end

  def play(player, game)
    player.keepers << self
    if @id == @@peace_id
      game.resolve_war_rule(player)
    elsif @id == @@money_id
      game.resolve_taxes_rule(player)
    end
  end

  def is_peace?
    @id == @@peace_id
  end

  def is_money?
    @id == @@money_id
  end

end

class Goal < Card
  def initialize(name, cards, rule)
    super(2, name)
    @related_keepers = cards
    if rule == "? and ?"
      @rule_text = "The player with #{cards[0]}, and #{cards[1]} on the table wins"
    else
      @rule_text = rule
    end
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
  attr_reader :rule_type

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

class Creeper < Card
  @@war_id = 1
  @@taxes_id = 2
  @@death_id = 3

  def initialize(id, name, rule_text)
    super(6, name)
    @id = id
    @rule_text = rule_text
  end

  def is_war?
    @id == @@war_id
  end

  def is_taxes?
    @id == @@taxes_id
  end

  def is_death?
    @id == @@death_id
  end

  def play(player, game)
    player.add_creeper(self)
    case @id
    when 1
      game.resolve_war_rule(player)
    when 2
      game.resolve_taxes_rule(player)
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

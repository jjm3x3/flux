
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
    end
  end

  def ==(other_card)
    self.name == other_card.name
  end


  def play
    puts "sub classes must implment this"
  end
end

class Keeper < Card
  
  def initialize(name)
    super(1,name)
  end

  def play(player, game, ruleBase)
    player.keepers << self
  end

  def to_s
    @name
  end
end

class Goal < Card

  def initialize(name, cards, rule)
    super(2, name)
    @related_keepers = cards
  end

  def play(player, game, ruleBase)
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

  def to_s
    @name
  end
end

class Rule < Card

  def initialize(name, ruleType, rulesText)
    super(3,name)
    @rule_type = ruleType
    @rule_text = rulesText
  end

  def play(player, game, ruleBase)
    puts "here is the rule text of the card: \n'#{@rule_text}'\n ->and has a type of: #{@rule_type}"
    if @rule_type == 1
      ruleBase.drawRule = @rule_text[5].to_i
      puts "changes the draw rule to #{ruleBase.drawRule}"
    end
    if @rule_type == 2
      if @rule_text[5] == 'a'
        ruleBase.playRule = Float::INFINITY
      else
        ruleBase.playRule = @rule_text[5].to_i
      end
      # puts "this changes play to '#{ruleBase.playRule}'"
    end
    if @rule_type == 3
      # puts "this changes the hand limmit to: '#{@rule_text[18]}'"
      ruleBase.handLimit = @rule_text[18].to_i
    end
    if @rule_type == 4
      ruleBase.keeperLimit = @rule_text[18].to_i
      puts "going to change the keeper limit to #{ruleBase.keeperLimit}"
    end
  end

  def to_s
    @name
  end
end

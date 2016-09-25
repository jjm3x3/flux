
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
    end
  end

  def play
    puts "sub classes must implment this"
  end
end

class Keeper < Card
  
  def initialize(name)
    super(1,name)
  end

  def play(player, game)
    player.keepers << self
  end

  def ==(other_card)
    self.name == other_card.name
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

  def play(player, game)
    game.goal = self
  end

  def met?(player, game)
    puts "\ncheck if #{player} won"
    haveCard1 = player.keepers.include?(@related_keepers[0])
    puts "do the have card #{@related_keepers[0]}?: #{haveCard1}"
    haveCard2 = player.keepers.include?(@related_keepers[1])
    puts "do the have card #{@related_keepers[1]}?: #{haveCard2}"
    if haveCard1 && haveCard2
      return true
    end
  end

  def to_s
    @name
  end
end

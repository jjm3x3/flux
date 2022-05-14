require "sqlite3"
require "json"
require "./cards/action.rb"
require "./cards/cards.rb"
require "./util.rb"

class Deck

  def initialize(anInterface)
    @interface = anInterface

    @firstCard = true
    @cards = buildDeck
  end

  def drawCards(number=-1)
    cardsToDraw = (number != -1 ? number : 1)
    drawnCards = []
    # puts "what is the value of #{@firstCard}"
    # put in for debugging
    # if @firstCard
    #   @firstCard = false
    #   # newInjectedCard = Action.new(16,"extra exchange keepers", "put some rule text here")
    #   # newInjectedCard = Limit.new("no keepers", 4, "put some rule text here", 0)
    #   newInjectedCard = Creeper.new(1, "wanna be war", "Some rule text")
    #   drawnCards = [newInjectedCard]
    #   drawnCards << Keeper.new(16, "pease")
    #   cardsToDraw -= 1
    # end
    @interface.debug "draw #{cardsToDraw} card(s) from the game..."

    drawnCards += drawMultipleCards(cardsToDraw)
    @interface.debug "deck now has #{@cards.length} cards"
    drawnCards
  end

  def count
    @cards.length
  end

  private
  def drawMultipleCards(amount)
    drawnCards = (1..amount).to_a.map do |time|
      drawACard
    end
    # this filters out "nil" cards when there are no more cards in the deck to draw
    drawnCards = drawnCards.select do |card|
      card
    end
    if (drawnCards.size > 0 && Util.are_all_nil(drawnCards))
      return []
    end
    drawnCards
  end

  def drawACard
    if(!@cards.any?)
      return nil
    end
    randValue = Random.new.rand(@cards.length)
    @cards.delete_at(randValue)
  end

  def buildDeck
    deck = []
    db = SQLite3::Database.new "cards.db"
    db.execute("select * from keepers;") do |row|
      deck << Keeper.new(row[0], row[1])
    end
    db.execute("select * from goals;") do |row|
      cards = JSON.parse(row[2]).map do |index|
        # some "blind indexing going on here..."
        deck[index-1]
      end
      deck << Goal.new(row[1],cards,row[3])
    end
    db.execute("select * from rules;") do |row|
      name = row[1]
      ruleType = row[2]
      rulesText = row[3]
      if(ruleType == 4 || ruleType == 3)
        # TODO: hack until I add these card types to the db proper
        limit = rulesText[18].to_i
        deck << Limit.new(name, row[2], row[3], limit)
      else
        deck << Rule.new(row[1], row[2], row[3])
      end
    end
    db.execute("select * from actions;") do |row|
      deck << Action.new(row[0], row[1], row[2])
    end
    db.execute("select * from creepers;") do |row|
      deck << Creeper.new(row[0], row[1], row[2])
    end
    @interface.debug "deck starts with #{deck.length} cards"
    deck
  end

end

class StackedDeck < Deck

  def initialize(anInterface, cardsToPutOnTop = [], startEmpty=false, withCreepers=true)
    super(anInterface)
    if startEmpty
      @cards = []
    end
    cardsToPutOnTop.select do |card|
      @cards.unshift(card)
    end
    if(!withCreepers)
      @cards = @cards.select do |card|
        card.card_type != "Creeper"
      end
    end
  end

  def drawACard
    @cards.delete_at(0)
  end
end

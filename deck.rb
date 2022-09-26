require "sqlite3"
require "json"
require "./cards/action.rb"
require "./cards/cards.rb"
require "./util.rb"

class Deck

  def initialize(anInterface)
    @interface = anInterface

    @firstCard = true
    @cards = []
  end

  def setup
    @cards = buildDeck
  end

  def drawCards(number=-1)
    cardsToDraw = (number != -1 ? number : 1)
    drawnCards = []
    # put in for debugging
    # if @firstCard
    #   @firstCard = false
    #   newInjectedCard = Action.new(16,"extra exchange keepers", "put some rule text here")
    #   drawnCards = [newInjectedCard]
    #   # drawnCards << Keeper.new(16, "pease")
    #   cardsToDraw -= 1
    # end
    @interface.debug "draw #{cardsToDraw} card(s) from the game..."

    drawnCards += drawMultipleCards(cardsToDraw)
    @interface.debug "deck now has #{@cards.length} cards"
    drawnCards
  end

  def add_cards(cards)
    @cards += cards
  end

  def each
    @cards.each do |card|
      yield card
    end
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
    @interface.debug "Deck:buildDeck: Start deck building"
    db = SQLite3::Database.new "cards.db"
    @interface.debug "Deck:buildDeck: DB handle created"
    cards_in_deck = {keepers: 0, goals: 0, rules: 0, actions: 0, creepers: 0}
    db.execute("select * from keepers;") do |row|
      deck << Keeper.new(row[0], row[1])
      cards_in_deck[:keepers]  += 1
    end
    db.execute("select * from goals;") do |row|
      cards = JSON.parse(row[2]).map do |index|
        # some "blind indexing going on here..."
        deck[index-1]
      end
      deck << Goal.new(row[1],cards,row[3])
      cards_in_deck[:goals]  += 1
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
      cards_in_deck[:rules]  += 1
    end
    db.execute("select * from actions;") do |row|
      deck << Action.new(row[0], row[1], row[2])
      cards_in_deck[:actions]  += 1
    end
    db.execute("select * from creepers;") do |row|
      deck << Creeper.new(row[0], row[1], row[2])
      cards_in_deck[:creepers]  += 1
    end
    @interface.debug "deck starts with #{deck.length} cards of types #{cards_in_deck}"
    deck
  end

end

class StackedDeck < Deck

  def initialize(logger, cardsToPutOnTop = [], startEmpty=false, withCreepers=true)
    super(logger)
    @cards_to_put_on_top = cardsToPutOnTop
    @start_empty = startEmpty
    @with_creepers = withCreepers
  end

  def setup
    super
    if @start_empty
      @cards = []
    end
    @cards_to_put_on_top.select do |card|
      @cards.unshift(card)
    end
    if(!@with_creepers)
      @cards = @cards.select do |card|
        card.card_type != "Creeper"
      end
    end
  end

  def drawACard
    @cards.delete_at(0)
  end
end

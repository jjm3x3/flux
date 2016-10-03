class Deck

  def initialize
    @firstCard = true
    @cards = buildDeck
  end

  def drawCards(number=-1)
    cardsToDraw = (number != -1 ? number : 1)
    drawnCards = []
    # puts "what is the value of #{@firstCard}"
    if @firstCard
      @firstCard = false
      drawnCards = [@cards.delete_at(@cards.length-18)]
      cardsToDraw -= 1
    end
    puts "draw #{cardsToDraw} card(s) from the game..."

    drawnCards += drawMultipleCards(cardsToDraw)
    puts "deck now has #{@cards.length} cards"
    drawnCards
  end


  private
  def drawMultipleCards(amount)
    drawnCards = (1..amount).to_a.map do |time|
      # puts "draw loop run"
      drawACard
    end
  end

  def drawACard
    randValue = Random.new.rand(@cards.length)
    @cards.delete_at(randValue)
  end

  def buildDeck
    deck = []
    db = SQLite3::Database.new "cards.db"
    db.execute("select * from keepers;") do |row|
      deck << Keeper.new(row[1])
    end
    db.execute("select * from goals;") do |row|
      cards = JSON.parse(row[2]).map do |index|
        deck[index-1]
      end
      deck << Goal.new(row[1],cards,row[3])
    end
    db.execute("select * from rules;") do |row|
      deck << Rule.new(row[1], row[2], row[3])
    end
    db.execute("select * from actions;") do |row|
      deck << Action.new(row[0], row[1], row[2])
    end
    puts "deck starts with #{deck.length} cards"
    deck
  end
end

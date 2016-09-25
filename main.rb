require "sqlite3"
require "json"
require "./cards.rb"

class Player
  attr_accessor :keepers, :next, :name, :hand
  
  def initialize(name, game)
    @name = name
    @keepers = []
    @game = game
  end

  def takeTurn
    drawCards
    @game.playCards
  end 

  def drawCards
    @hand = @game.drawCards
  end

  def won?
    if @game.goal
      @game.goal.met?(self, @game)
    else
      false
    end
  end

  def to_s
    @name
  end
end

class Game
  attr_accessor :goal

  def initialize
    @firstPlayer = Player.new("player1", self)
    @firstPlayer.next = Player.new("player2", self)
    @firstPlayer.next.next = @firstPlayer
    @activePlayer = @firstPlayer
    
    firstKeeper = Keeper.new("thing")

    @drawRule = 1

    @playRule = 1

    @deck = buildDeck
    
    puts "here is the first keeper #{firstKeeper.to_s}"
    puts "here is the first keepers type #{firstKeeper.card_type}"
    
    # puts firstKeeper.play(firstPlayer, self)
  end

  def playCards
    puts "here is the current goal #{goal}"
    puts "here are the keepers you have:\n #{@activePlayer.keepers}"
    cardsPlayed = 0
    while cardsPlayed < @playRule
      puts "Here is your current hand:\n #{@activePlayer.hand}"
      puts "Pick a card to play"
      cardPos = gets
      cardToPlay = hand.delete_at(cardPos.to_i)
      cardToPlay.play(@activePlayer, self)
      cardsPlayed += 1
    end
    puts "next persons turn"
    @activePlayer = @activePlayer.next
  end

  def drawCards
    puts "draw #{@drawRule} card(s) from the game..."
    drawnCards = [0..@drawRule].map do |time|
      randValue = Random.new.rand(@deck.length)
      @deck.delete_at(randValue)
    end
    drawnCards
  end

  def run
    while !winner
      @activePlayer.takeTurn
    end
  end

  def winner 
    checkingPlayer = @firstPlayer
    winner = false
    loop do
      winner ||= @firstPlayer.won?
      checkingPlayer = checkingPlayer.next
      break if !(checkingPlayer == @firstPlayer)
    end
    winner 
  end

  private
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
    deck
  end
end

game = Game.new

game.run




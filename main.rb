require "sqlite3"
require "json"
require "./cards.rb"
require "./deck.rb"

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
    @hand += @game.drawCards
  end

  def won?
    if @game.hasGoal?
      @game.goalMet?(self)
    else
      false
    end
  end

  def to_s
    @name
  end
end

class Game

  def initialize

    @ruleBase = RuleBase.new
    @deck = Deck.new
    @discardPile = []

    @players = []
    @players << Player.new("player1", self)
    @players << Player.new("player2", self)
    @players.each do |player|
      firstHand = @deck.drawCards(3)
      puts "draw your opening hand #{firstHand}"
      player.hand = firstHand
    end

    @currentPlayer = 0
    
    firstKeeper = Keeper.new("thing")


    
    # puts "here is the first keeper #{firstKeeper.to_s}"
    # puts "here is the first keepers type #{firstKeeper.card_type}"
    
    # puts firstKeeper.play(firstPlayer, self)
  end

  def activePlayer
    @currentPlayer = @currentPlayer % @players.length
    @players[@currentPlayer]
  end

  def drawCards
    @deck.drawCards(@ruleBase.drawRule)
  end

  def playCards
    puts "here is the current goal: #{@goal }"
    puts "here are the current rules:\n#{@ruleBase}"
    printKeepers(activePlayer)
    cardsPlayed = 0
    cardsDrawn = @ruleBase.drawRule
    hand = activePlayer.hand
    while cardsPlayed < @ruleBase.playRule && !winner && hand.length > 0
      printHand(hand)
      cardPos = selectCardFromHand
      cardToPlay = hand.delete_at(cardPos.to_i)
      cardToPlay.play(activePlayer, self, @ruleBase)
      cardsPlayed += 1
      checkForWinner # should check for a winner before discarding
      enforceNonActivePlayerLimits
      puts "the discard has #{@discardPile.length} card(s) in it"
      # do something if the discard need reshufleing
      cardsDrawn = replenishHand(cardsDrawn, activePlayer)
      hand = activePlayer.hand # really a sad sideeffect of much statefull programming
      puts "played: #{cardsPlayed} of play: #{@ruleBase.playRule}, winner? (#{!winner}), hand_length: #{hand.length}"
    end
    discardDownToLimit(activePlayer)
    removeDownToKeeperLimit(activePlayer)
    @currentPlayer += 1
    puts "#{activePlayer}'s turn"
  end

  def enforceNonActivePlayerLimits
    @players.each do |player|
      if player != activePlayer
        discardDownToLimit(player)
        removeDownToKeeperLimit(player)
      end
    end
  end

  def removeDownToKeeperLimit(player)
    while player.keepers.length > @ruleBase.keeperLimit
      puts "choose a card to discard"
      printKeepers(player)
      cardPos = selectCardFromHand("to discard")
      removeKeeper = player.keepers.delete_at(cardPos)
      @discardPile << removeKeeper
      puts "discarding #{removeKeeper}"
    end
  end

  def discardDownToLimit(player)
    while player.hand.count > @ruleBase.handLimit
      puts "choose a card to discard"
      printHand(player.hand)
      cardPos = selectCardFromHand("to discard")
      removedCard = player.hand.delete_at(cardPos)
      @discardPile << removedCard
      puts "removing '#{removedCard}'"
    end
  end

  def hasGoal?
    !@goal.nil?
  end

  def goalMet?(player)
    @goal.met?(player, self)
  end

  def setGoal(newGoal)
    puts "changeing goal to #{newGoal}"
    if @goal
      @discardPile << @goal
    end
    @goal = newGoal
    puts "here is the new value of goal #{@goal}"
  end

  def replenishHand(numberOfCardsDrawn, currentPlayer)
    puts "here is #{numberOfCardsDrawn} < #{@ruleBase.drawRule}"
    if numberOfCardsDrawn < @ruleBase.drawRule
      lackingCards = @ruleBase.drawRule - numberOfCardsDrawn
      currentPlayer.hand += @deck.drawCards(lackingCards)
      numberOfCardsDrawn += lackingCards
    end
    numberOfCardsDrawn
  end

  def checkForWinner
    if winner
      puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
      exit 0
    end
  end

  def printKeepers(player)
    keepersPrintOut = player.keepers.map do |keeper|
      keeper.to_s
    end
    puts "here are the keepers you have:\n #{keepersPrintOut}"
  end

  def selectCardFromHand(reason="to play")
    puts "Pick a card " + reason
    cardPos = gets.to_i
  end

  def printHand(hand)
    handPrintOut = hand.map do |card|
      card.to_s
    end
    puts "Here is your current hand:\n #{handPrintOut}"
  end


  def run
    loop do
      activePlayer.takeTurn
    end
  end

  def winner 
    checkingPlayer = @firstPlayer
    winner = false
    @players.each do |player|
      winner ||= player.won?
    end
    puts "is there a winner? #{winner.to_s}\n"
    winner 
  end

end


class RuleBase
  attr_accessor :drawRule, :playRule, :handLimit, :keeperLimit

  def initialize
    @drawRule = 1
    @playRule = 1
    @handLimit = Float::INFINITY
    @keeperLimit = Float::INFINITY
  end

  def to_s
    return "\tdraw #{@drawRule}\n\tplay #{@playRule}\n\thandLimit #{@handLimit}\n\tkeeperLimit #{@keeperLimit}"
  end
end

game = Game.new

game.run




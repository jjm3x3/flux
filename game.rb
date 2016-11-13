require "sqlite3"
require "json"
require "./cards.rb"
require "./deck.rb"
require "./player.rb"
require "./ruleBase.rb"


class Game
  attr_accessor :ruleBase

  def initialize

    @ruleBase = RuleBase.new(self)
    @deck = Deck.new
    @discardPile = []

    @players = []
    @players << Player.new("player1", self)
    @players << Player.new("player2", self)
    @players << Player.new("player3", self)
    @players.each do |player|
      firstHand = @deck.drawCards(3)
      puts "draw your opening hand #{firstHand}"
      player.hand = firstHand
    end

    @currentPlayer = 0
  end

  def activePlayer
    @currentPlayer = @currentPlayer % @players.length
    @players[@currentPlayer]
  end

  def drawCards
    @deck.drawCards(@ruleBase.drawRule)
  end

  def playCards
    puts "the discard has #{@discardPile.length} card(s) in it"
    puts "here is the current goal: #{@goal }"
    puts "here are the current rules:\n#{@ruleBase}"
    printKeepers(activePlayer)
    cardsPlayed = 0
    cardsDrawn = @ruleBase.drawRule
    hand = activePlayer.hand
    while cardsPlayed < @ruleBase.playRule && !winner && hand.length > 0
      printCardList(hand)
      cardPos = selectCardFromHand
      cardToPlay = hand.delete_at(cardPos.to_i)
      cardToPlay.play(activePlayer, self)
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
    puts "\n#{activePlayer}'s turn"
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
      printCardList(player.hand)
      cardPos = selectCardFromHand("to discard")
      removedCard = player.hand.delete_at(cardPos)
      @discardPile << removedCard
      puts "removing '#{removedCard}'"
    end
  end

  def discard(card)
    puts "discarding #{card}"
    @discardPile << card
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
    # puts "here is #{numberOfCardsDrawn} < #{@ruleBase.drawRule}"
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

  def printCardList(hand,prompt="Here is your current hand:")
    i = 0
    numbering = "   "
    hand.map do |card|
      numbering += i.to_s
      numbering += (" " * card.to_s.length) + "   "
      i += 1
    end
    handPrintOut = hand.map do |card|
      card.to_s
    end
    puts "#{prompt}\n#{numbering}\n#{handPrintOut}"
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

  def playTwoAndUseEm(player)
    cardsDrawn = @deck.drawCards(2)
    puts "here are the cards:"
    printCardList(cardsDrawn)
    puts "which would you like to play first?"
    whichCard = gets
    firstOne = cardsDrawn.delete_at(whichCard.to_i)
    firstOne.play(player, self)
    cardsDrawn[0].play(player, self)
  end

  def jackpot(player)
    player.hand += @deck.drawCards(3)
  end

  def draw3playe2ofThem(player)
    cardsDrawn = @deck.drawCards(3)
    puts "here are the cards:"
    printCardList(cardsDrawn)
    puts "which would you like to play first?"
    whichCard = gets
    firstOne = cardsDrawn.delete_at(whichCard.to_i)
    firstOne.play(player, self)
    puts "which would you like to play next?"
    whichCard = gets
    firstOne = cardsDrawn.delete_at(whichCard.to_i)
    firstOne.play(player, self)
    discard(cardsDrawn[0])
  end

  def discardAndDraw(player)
    numberOfCardsToDraw = player.hand.length
    player.hand.each do |card|
      discard(card)
    end
    player.hand = @deck.drawCards(numberOfCardsToDraw)
  end

  def opponents
    # puts "who is the current player: #{activePlayer}"
    @players.select do |player|
      player != activePlayer
    end
  end

  def useWhatYouTake(player)
    playerList = opponents.map do |player|
      player.to_s
    end
    puts "which player would you like to pick from\n#{playerList}"
    playerPosition = gets.to_i
    selectedPlayer = opponents[playerPosition]
    randomPosition = Random.new.rand(selectedPlayer.hand.length)
    selectedCard = selectedPlayer.hand.delete_at(randomPosition)
    puts "playing #{selectedCard}"
    selectedCard.play(player, self)
  end

  def taxation(player)
    puts "playing taxation!"
    newCardsForPlayer = @players.select do |player|
      player != activePlayer
    end.map do |player|
      puts "choose a card to give to #{activePlayer}"
      printCardList(player.hand)
      whichCard = gets.to_i
      player.hand.delete_at(whichCard)
    end
    player.hand += newCardsForPlayer
  end

  def todaysSpecial(player)
    drawnCards = @deck.drawCards(3)
    puts "pick a card to play"
    printCardList(drawnCards)
    whichCard = gets.strip.to_i
    cardToPlay = drawnCards.delete_at(whichCard)
    cardToPlay.play(player, self)

    puts "Is today your birthday? (y/n)"
    response = gets.strip
    if response == 'y' || response == 'Y'
      puts "pick a card to play"
      printCardList(drawnCards)
      whichCard = gets.strip.to_i
      cardToPlay = drawnCards.delete_at(whichCard)
      cardToPlay.play(player, self)

      puts "pick a card to play"
      printCardList(drawnCards)
      whichCard = gets.strip.to_i
      cardToPlay = drawnCards.delete_at(whichCard)
      cardToPlay.play(player, self)
    else
      puts "Is today a holiday or an anniversary (y/n)"
      response = gets.strip
      if response == 'y' || response == 'Y'
        puts "pick a card to play"
        printCardList(drawnCards)
        whichCard = gets.strip.to_i
        cardToPlay = drawnCards.delete_at(whichCard)
        cardToPlay.play(player, self)
      end
    end

    drawnCards.each do |card|
      discard(card)
    end
  end

  def mixItAllUp(player)
    allKeepers = @players.flat_map do |player|
      player.keepers
    end

    @players.each do |player|
      player.keepers = []
    end
    
    puts "how many keepers do I have: #{allKeepers.count} but the length is #{allKeepers.length}"
    puts "and here they are: \n#{allKeepers}"
    playerCur = @currentPlayer
    random = Random.new
    while allKeepers.length > 0
      puts "here are the keepers now: \n#{allKeepers}"
      playerCur = playerCur % @players.length
      randomPosition = random.rand(allKeepers.length)
      @players[playerCur].keepers << allKeepers.delete_at(randomPosition)
      playerCur += 1
    end
    printKeepers(activePlayer)
  end

  def letsDoThatAgain(player)
    eligibleCards = @discardPile.select do |card|
      puts "this card is of type: #{card.card_type}"
      card.card_type == "Rule" || card.card_type == "Action"
    end
    puts "pick a card you would like to replay"
    printCardList(eligibleCards)
    whichCard = gets.strip.to_i
    pickedCard = eligibleCards[whichCard]
    @discardPile = @discardPile.select do |card|
      card != pickedCard
    end
    puts "replaying #{pickedCard}"
    pickedCard.play(player, self)
  end

  def everyBodyGets1(player)
    cardsDrawn = @deck.drawCards(@players.length)
    playerCur = @currentPlayer
    while cardsDrawn.length > 0
      if playerCur == @currentPlayer
        puts "which card would you like to giver to yourself"
      else 
        puts "which card would you like to give to #{@players[playerCur]}"
      end
      printCardList(cardsDrawn)
      whichCard = gets.strip.to_i
      @players[playerCur].hand << cardsDrawn.delete_at(whichCard)
      playerCur += 1
    end
  end

  def tradeHands(player)
    opponentsText = opponents.map do |player|
      player.to_s
    end
    puts "who would you like to trade hands with?\n#{opponentsText}"
    whichPlayer = gets.strip.to_i
    otherHand = opponents[whichPlayer].hand
    opponents[whichPlayer].hand = player.hand
    player.hand = otherHand
  end

  def rotateHands(player)
    puts "which way would you like to got (clockwise, counter-clockwise)"
    whichOption = gets.strip

    playerCur = @currentPlayer
    tempHand = @players[playerCur].hand
    nextPlayer = -1
    while nextPlayer != @currentPlayer
      if whichOption.start_with?("cl")
        puts "move clockwise"
        nextPlayer  = (playerCur + 1) % @players.length
      else
        puts "move counterclockwise curentPlayer: #{playerCur} nextPlayer: #{nextPlayer} " 
        nextPlayer  = (playerCur - 1) % @players.length
      end

      puts "player #{playerCur} gets =  #{nextPlayer}'s hand "

      printCardList(@players[nextPlayer].hand, "This is #{playerCur}'s new hand")
      @players[playerCur].set_hand(@players[nextPlayer].hand)
      # printCardList(@players[playerCur].hand, "This is #{playerCur}'s new hand")

      playerCur = nextPlayer
      puts "here is the value of nextPlayer: #{nextPlayer} and #{@currentPlayer}"
    end
    printCardList(tempHand, "here is the onehandLeft out:") 
    @players[playerCur].set_hand(tempHand)
    printCardList(@players[playerCur].hand, "This should be the same as above: ")
    puts "\n"
    @players.each do |player|
      printCardList(player.hand, "What is my hand now #{player}:")
    end
  end

end
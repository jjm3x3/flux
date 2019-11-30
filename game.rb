require "sqlite3"
require "json"
require "./cards.rb"
require "./deck.rb"
require "./player.rb"
require "./ruleBase.rb"
require "./game_interface.rb"


class Game
  attr_accessor :ruleBase
  attr_accessor :players
  attr_accessor :deck
  attr_accessor :discardPile

  def initialize(input_steam, numberOfPlayers = 3, anInterface = CliInterface.new)

    @interface = anInterface
    @input_steam = input_steam

    @ruleBase = RuleBase.new(self, anInterface)
    @deck = Deck.new(anInterface)
    @discardPile = []

    @players = []
    (1..numberOfPlayers).select do |playerId|
      @players << Player.new("player" + playerId.to_s, self)
    end

    @players.each do |player|
      firstHand = @deck.drawCards(3) # basic rules draw three cards to start
      @interface.debug "draw your opening hand #{firstHand}"
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
    @interface.debug "discarding #{card}"
    @discardPile << card
  end

  def hasGoal?
    !@goal.nil?
  end

  def goalMet?(player)
    @goal.met?(player, self)
  end

  def setGoal(newGoal)
    @interface.information "changeing goal to #{newGoal}"
    if @goal
      @discardPile << @goal
    end
    @goal = newGoal
    @interface.debug "here is the new value of goal #{@goal}"
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
    cardPos = STDIN::gets.to_i
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
    @output_stream.puts "#{prompt}\n#{numbering}\n#{handPrintOut}"
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
    whichCard = STDIN::gets
    firstOne = cardsDrawn.delete_at(whichCard.to_i)
    firstOne.play(player, self)
    cardsDrawn[0].play(player, self)
  end

  def jackpot(player)
    player.hand += @deck.drawCards(3)
  end

  def draw3play2OfThem(player)
    cardsDrawn = @deck.drawCards(3)
    firstOne = @interface.select_a_card(cardsDrawn, "which would you like to play first?")
    firstOne.play(player, self)
    secondOne = @interface.select_a_card(cardsDrawn, "which would you like to play next?")
    secondOne.play(player, self)
    discard(cardsDrawn[0])
  end

  def discardAndDraw(player)
    numberOfCardsToDraw = player.hand.length - 1
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
    selectedPlayer = @interface.select_a_player(opponents, "which player would you like to pick from")
    randomPosition = Random.new.rand(selectedPlayer.hand.length)
    selectedCard = selectedPlayer.hand.delete_at(randomPosition)
    @interface.debug "playing #{selectedCard}"
    selectedCard.play(player, self)
  end

  def taxation(player)
    @interface.debug "playing taxation!"
    newCardsForPlayer = opponents.map do |player|
      @interface.select_a_card(player.hand, "Choose a card to give to #{activePlayer}")
    end
    player.hand += newCardsForPlayer
  end

  def todaysSpecial(player)
    drawnCards = @deck.drawCards(3)
    cardToPlay = @interface.select_a_card(drawnCards, "pick a card to play")
    cardToPlay.play(player, self)

    if @interface.ask_yes_no("is today your birthday")
      cardToPlay = @interface.select_a_card(drawnCards, "pick a card to play")
      cardToPlay.play(player, self)

      cardToPlay = @interface.select_a_card(drawnCards, "pick a card to play")
      cardToPlay.play(player, self)
    else
      if @interface.ask_yes_no "Is today a holiday or an anniversary"
        cardToPlay = @interface.select_a_card(drawnCards, "pick a card to play")
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
    
    @interface.debug "how many keepers do I have: #{allKeepers.count} but the length is #{allKeepers.length}"
    @interface.debug "and here they are: \n#{allKeepers}"
    playerCur = @currentPlayer
    random = Random.new
    while allKeepers.length > 0
      @interface.debug "here are the keepers now: \n#{allKeepers}"
      playerCur = playerCur % @players.length
      randomPosition = random.rand(allKeepers.length)
      @players[playerCur].keepers << allKeepers.delete_at(randomPosition)
      playerCur += 1
    end
    @interface.printKeepers(activePlayer)
  end

  def letsDoThatAgain(player)
    eligibleCards = @discardPile.select do |card|
      @interface.debug "this card is of type: #{card.card_type}"
      card.card_type == "Rule" || card.card_type == "Action"
    end
    @interface.displayCards(eligibleCards, "pick a card you would like to replay")
    whichCard = get_input.to_i
    pickedCard = eligibleCards[whichCard]
    @discardPile = @discardPile.select do |card|
      card != pickedCard
    end
    @interface.information "replaying #{pickedCard}"
    pickedCard.play(player, self)
  end

  def everyBodyGets1(player)
    cardsDrawn = @deck.drawCards(@players.length)
    playerCur = @currentPlayer
    while cardsDrawn.length > 0
      if playerCur == @currentPlayer
        selectedCard = @interface.select_a_card(cardsDrawn, "which card would you like to giver to yourself")
      else 
        selectedCard = @interface.select_a_card(cardsDrawn, "which card would you like to give to #{@players[playerCur]}")
      end
      @players[playerCur].hand << selectedCard
      playerCur += 1
    end
  end

  def get_input
    input = @input_steam.gets
    result = input.strip
    result
  end

  def tradeHands(player)
    opponentsText = opponents.map do |player|
      player.to_s
    end
    @interface.information "who would you like to trade hands with?\n#{opponentsText}"
    whichPlayer = get_input.to_i
    otherHand = opponents[whichPlayer].hand
    opponents[whichPlayer].hand = player.hand
    player.hand = otherHand
  end

  def rotateHands(player)
    @interface.information "which way would you like to got (clockwise, counter-clockwise)"
    whichOption = get_input

    playerCur = @currentPlayer
    tempHand = @players[playerCur].hand
    nextPlayer = -1
    while nextPlayer != @currentPlayer
      if whichOption.start_with?("cl")
        @interface.debug "move clockwise"
        nextPlayer  = (playerCur + 1) % @players.length
      else
        @interface.debug "move counterclockwise curentPlayer: #{playerCur} nextPlayer: #{nextPlayer} " 
        nextPlayer  = (playerCur - 1) % @players.length
      end

      @interface.information "player #{playerCur} STDIN::gets =  #{nextPlayer}'s hand "
      if playerCur == @players.length - 1 && whichOption.start_with?("cl")
        @players[playerCur].set_hand(tempHand)
      elsif playerCur == 1 && !whichOption.start_with?("cl")
        @players[playerCur].set_hand(tempHand)
      else
        @players[playerCur].set_hand(@players[nextPlayer].hand)
      end

      playerCur = nextPlayer
      @interface.debug "here is the value of nextPlayer: #{nextPlayer} and #{@currentPlayer}"
    end
    # @output_stream.puts "\n"
    @players.each do |player|
      @interface.displayCards(player.hand, "What is my hand now #{player}:")
    end
  end

end

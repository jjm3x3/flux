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
  attr_accessor :currentPlayerCounter

  def initialize(numberOfPlayers, anInterface = CliInterface.new)

    @interface = anInterface

    @ruleBase = RuleBase.new(self, anInterface)
    @deck = Deck.new(anInterface)
    @discardPile = []

    @players = []
    (1..numberOfPlayers).select do |playerId|
      @players << Player.new("player" + playerId.to_s, self)
    end

    @players.each do |player|
      firstHand = drawCards(player, 3) # basic rules draw three cards to start
      @interface.trace "draw your opening hand #{firstHand}"
      player.hand = firstHand
    end

    @currentPlayerCounter = 0
  end

  def activePlayer
    playerCur = @currentPlayerCounter % @players.length
    @players[playerCur]
  end

  def drawCards(player, count)
    expectedNumberOfCards = (count == :draw_rule ? @ruleBase.drawRule : count)
    @interface.debug "expecting to draw #{expectedNumberOfCards} cards"
    drawnCards = @deck.drawCards(expectedNumberOfCards)
    loop do
      drawnCards = drawnCards.select do |card|
        @interface.debug "What is this card? #{card.card_type}"
        if card.card_type == "Creeper"
          @interface.debug "Found a creeper: #{card}"
          card.play(player, self)
        end
        card.card_type != "Creeper"
       end
      if drawnCards.length == expectedNumberOfCards
        break
      else
      drawnCards += @deck.drawCards(expectedNumberOfCards - drawnCards.length)
      end
    end
    drawnCards
  end

  def playCards
    @interface.information "the discard has #{@discardPile.length} card(s) in it"
    @interface.information "here is the current goal: #{@goal }"
    @interface.information "here are the current rules:\n#{@ruleBase}"
    @interface.printPermanents(activePlayer)
    cardsPlayed = 0
    cardsDrawn = @ruleBase.drawRule
    hand = activePlayer.hand
    while cardsPlayed < @ruleBase.playRule && !winner && hand.length > 0
      cardToPlay = @interface.select_a_card(hand, "Select a card from your hand to play")
      cardToPlay.play(activePlayer, self)
      cardsPlayed += 1
      checkForWinner # should check for a winner before discarding
      enforceNonActivePlayerLimits
      @interface.information "the discard has #{@discardPile.length} card(s) in it"
      # do something if the discard need reshufleing
      cardsDrawn = replenishHand(cardsDrawn, activePlayer)
      hand = activePlayer.hand # really a sad sideeffect of much statefull programming
      @interface.information "played: #{cardsPlayed} of play: #{@ruleBase.playRule}, winner? (#{!winner}), hand_length: #{hand.length}"
    end
    discardDownToLimit(activePlayer)
    removeDownToKeeperLimit(activePlayer)
    @currentPlayerCounter += 1
    @interface.information "\n#{activePlayer}'s turn"
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
      removeKeeper = @interface.select_a_card(player.keepers, "Choose a card to discard")
      @discardPile << removeKeeper
      @interface.debug "discarding #{removeKeeper}"
    end
  end

  def discardDownToLimit(player)
    @interface.debug "The hand limit is #{@ruleBase.handLimit}"
    while player.hand.count > @ruleBase.handLimit
      removedCard = @interface.select_a_card(player.hand, "Player #{player}\n\tSelect a card to discard")
      @discardPile << removedCard
      @interface.debug "removing '#{removedCard}'"
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
      currentPlayer.hand += drawCards(currentPlayer, lackingCards)
      numberOfCardsDrawn += lackingCards
    end
    numberOfCardsDrawn
  end

  def currentPlayer
    @currentPlayerCounter % @players.length
  end

  def checkForWinner
    if winner
      puts "the game is over!!!!==============\\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"
      exit 0
    end
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
    @interface.debug "is there a winner? #{winner.to_s}\n"
    winner 
  end

  def opponents(of_player=nil)
    of_player = of_player ?  of_player : activePlayer

    @players.select do |player|
      player != of_player
    end
  end

  def draw_2_and_use_em(player)
    cardsDrawn = drawCards(player, 2)
    firstOne = @interface.select_a_card(cardsDrawn, "Which one would you like to play first?")
    firstOne.play(player, self)
    cardsDrawn[0].play(player, self)
  end

  def jackpot(player)
    player.hand += drawCards(player, 3)
  end

  def draw_3_play_2_of_them(player)
    cardsDrawn = drawCards(player, 3)
    firstOne = @interface.select_a_card(cardsDrawn, "which would you like to play first?")
    firstOne.play(player, self)
    secondOne = @interface.select_a_card(cardsDrawn, "which would you like to play next?")
    secondOne.play(player, self)
    discard(cardsDrawn[0])
  end

  def discard_and_draw(player)
    numberOfCardsToDraw = player.hand.length - 1
    player.hand.each do |card|
      discard(card)
    end
    player.hand = drawCards(player, numberOfCardsToDraw)
  end

  def useWhatYouTake(player)
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
    drawnCards = drawCards(player, 3)
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
    playerCur = @currentPlayerCounter
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
    pickedCard = @interface.select_a_card(eligibleCards, "pick a card you would like to replay")
    @discardPile = @discardPile.select do |card|
      card != pickedCard
    end
    @interface.information "replaying #{pickedCard}"
    pickedCard.play(player, self)
  end

  def everybody_gets_1(player)
    cardsDrawn = drawCards(player, @players.length)
    playerCur = currentPlayer
    while cardsDrawn.length > 0
      if playerCur == currentPlayer
        selectedCard = @interface.select_a_card(cardsDrawn, "which card would you like to giver to yourself")
      else 
        selectedCard = @interface.select_a_card(cardsDrawn, "which card would you like to give to #{@players[playerCur]}")
      end
      @players[playerCur].hand << selectedCard
      playerCur += 1
      playerCur %= @players.length
    end
  end

  def tradeHands(player)
    opponentsText = opponents.map do |player|
      player.to_s
    end
    selectedPlayer = @interface.select_a_player(opponents, "who would you like to trade hands with?")
    otherHand = selectedPlayer.hand
    selectedPlayer.hand = player.hand
    player.hand = otherHand
  end

  def rotateHands(player)
    direction = @interface.ask_rotation("Which way would you like to rotate? ")

    #candidate for debug
    @players.each do |player|
      @interface.displayCardsDebug(player.hand, "What is my hand now #{player}:")
    end

    playerCur = currentPlayer
    tempHand = @players[playerCur].hand
    nextPlayer = -1
    while nextPlayer != currentPlayer
      if @interface.isClockwise(direction)
        @interface.debug "move clockwise"
        nextPlayer  = (playerCur + 1) % @players.length
      else
        @interface.debug "move counterclockwise playerCur: #{playerCur} nextPlayer: #{nextPlayer} "
        nextPlayer  = (playerCur - 1) % @players.length
      end

      @interface.information "player #{playerCur+1} gets =  #{nextPlayer+1}'s hand "
      @interface.trace "giving plyer #{playerCur+1} the hand\n\t#{@players[nextPlayer].hand}"
      @players[playerCur].set_hand(@players[nextPlayer].hand)

      playerCur = nextPlayer
      @interface.debug "here is the value of nextPlayer: #{nextPlayer}"
    end
    @interface.trace "giving plyer #{playerCur+1} the hand\n\t#{tempHand}"
    if @interface.isClockwise(direction)
      newNextPlayer = (playerCur - 1) % @players.length
    else
      newNextPlayer = (playerCur + 1) % @players.length
    end
    @players[newNextPlayer].set_hand(tempHand)

    # candidate for debug
    @players.each do |player|
      @interface.displayCards(player.hand, "What is my hand now #{player}:")
    end
  end

  def take_another_turn
    @currentPlayerCounter -= 1
  end

  def exchange_keepers(player)
    if player.keepers.length == 0
      @interface.information "Too bad you have no keepers"
      return
    end
    otherKeepers = false
    opponents.select do |player|
      otherKeepers ||= player.keepers.length != 0
    end
    if !otherKeepers
      @interface.information "Too bad you have no keepers"
      return
    end

    eligibleOpponents = opponents.select do |player|
      player.keepers.length > 0
    end



    eligibleOpponents.select do |palyer|
      @interface.printKeepers(player, "Here are the keepers: #{player.to_s} has:")
    end

    eligibleOpponents.unshift(:no_one)
    selectedPlayer = :no_one
    loop do
      selectedPlayer = @interface.select_a_player(eligibleOpponents, "Which player would you like to take a keeper from")
      areYouSure = selectedPlayer != :no_one
      if selectedPlayer == :no_one
        areYouSure = @interface.ask_yes_no "Are you sure you don't want to trade with anyone?"
      end
      if areYouSure
        break
      end
    end
    if selectedPlayer == :no_one
      return
    end

    if selectedPlayer.keepers.length > 1
      myNewKeeper = @interface.select_a_card(selectedPlayer.keepers, "Slect which Keeper you would like")
    else
      myNewKeeper = selectedPlayer.keepers.delete_at(0)
    end
    if player.keepers.length > 1
      myOldKeeper = @interface.select_a_card(player.keepers, "Which Keeper would you like to exchange")
    else
      myOldKeeper = player.keepers.delete_at(0)
    end
    player.keepers << myNewKeeper
    selectedPlayer.keepers << myOldKeeper

    @interface.displayCardsDebug(player.keepers, "Here are your Keepers after the exchange")

  end

  # TODO:: needs to be called any time any keeper or creeper gets played  or changes hands :(
  def resolve_war_rule(player)
    # TODO:: find a better way to see if a player has Peace
    if player.keepers.include? Keeper.new("Peace")

      selectedPlayer = @interface.select_a_player(opponents(player), "#{player} since you have peace. Who would you like to give war too?")
      warCreeper = player.creepers.select do |creeper|
        creeper.is_war?
      end
      player.creepers = player.creepers.select do |creeper|
        !creeper.is_war?
      end
      @interface.debug "Who is the selected playar #{selectedPlayer}\n who is the original #{player}"
      selectedPlayer.creepers << warCreeper[0]
    end
  end

end

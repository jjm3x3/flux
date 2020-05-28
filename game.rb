require "./cards/cards.rb"
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
  attr_reader :goal

  def initialize(numberOfPlayers, anInterface, aTrueInterface = TrueCliInterface.new, aRandom = Random.new, aDeck = Deck.new(anInterface))

    @logger = anInterface
    @interface = aTrueInterface

    @random = aRandom

    @ruleBase = RuleBase.new(self, anInterface)
    @deck = aDeck
    @discardPile = []

    @players = []
    (1..numberOfPlayers).select do |playerId|
      @players << Player.new("player" + playerId.to_s)
    end

    @players.each do |player|
      firstHand = drawCards(player, 3) # basic rules draw three cards to start
      @logger.trace "draw your opening hand #{firstHand}"
      player.hand = firstHand
    end

    @currentPlayerCounter = 0
  end

  def drawCards(player, count)
    expectedNumberOfCards = (count == :draw_rule ? @ruleBase.drawRule : count)
    @logger.debug "expecting to draw #{expectedNumberOfCards} cards"
    drawnCards = @deck.drawCards(expectedNumberOfCards)
    loop do
      @logger.debug "How many cards where actually drawn #{drawnCards.size}"
      drawnCards = drawnCards.select do |card|
        @logger.debug "What is this card? #{card.card_type}"
        if card.card_type == "Creeper"
          @logger.debug "Found a creeper: #{card}"
          card.play(player, self)
        end
        card.card_type != "Creeper"
      end
      if drawnCards.length == expectedNumberOfCards
        break
      else
      # TODO: should shuffle the discard back in the draw at this point
      if @deck.count == 0
        @logger.debug "No cards left to draw"
        break
      end
      drawnCards += @deck.drawCards(expectedNumberOfCards - drawnCards.length)
      end
    end
    drawnCards
  end

  def progress_turn
    @currentPlayerCounter += 1
  end

  def enforceNonActivePlayerLimits(the_active_player)
    @players.each do |player|
      if player != the_active_player
        discardDownToLimit(player)
        removeDownToKeeperLimit(player)
      end
    end
  end

  def removeDownToKeeperLimit(player)
    while player.keepers.length > @ruleBase.keeperLimit
      @logger.information "Since the keeper limit is #{@ruleBase.keeperLimit} you must discard a keeper"
      removeKeeper = @logger.select_a_card(player.keepers, "Choose a keeper to discard")
      @discardPile << removeKeeper
      @logger.debug "discarding #{removeKeeper}"
    end
  end

  def discardDownToLimit(player)
    @logger.debug "The hand limit is #{@ruleBase.handLimit}"
    while player.hand.count > @ruleBase.handLimit
      removedCard = @interface.await.choose_from_list(player.hand, "Player #{player}\n\tSelect a card to discard").value
      @discardPile << removedCard
      @logger.debug "removing '#{removedCard}'"
    end
  end

  def discard(card)
    @logger.debug "discarding #{card}"
    @discardPile << card
  end

  def play_limit
    @ruleBase.playRule
  end

  def hasGoal?
    !@goal.nil?
  end

  def goalMet?(player)
    @goal.met?(player, self)
  end

  def setGoal(newGoal)
    @logger.information "changeing goal to #{newGoal}"
    if @goal
      @discardPile << @goal
    end
    @goal = newGoal
    @logger.debug "here is the new value of goal #{@goal}"
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

  def active_player
    players[currentPlayer]
  end

  def winner
    checkingPlayer = @firstPlayer
    winner = false
    @players.each do |player|
      winner ||= has_player_won?(player)
    end
    @logger.debug "is there a winner? #{winner.to_s}\n"
    winner
  end

  def has_player_won?(player)
    if hasGoal?
      goalMet?(player) && !player.creepers.any?
    else
      false
    end
  end

  def opponents(of_player)
    @players.select do |player|
      player != of_player
    end
  end

  def play_card(card, player)
    card.play(player, self)
  end

  def draw_2_and_use_em(player)
    @logger.debug "happens sync at the beginning of draw_2_and_use_em"
    cardsDrawn = drawCards(player, 2)
    # firstOne = @logger.select_a_card(cardsDrawn, "Which one would you like to play first?")
    select_result = @interface.await.choose_from_list(cardsDrawn, "Which one would you like to play first?")
    @logger.debug "Here is the selected card in draw_2_and_use_em: '#{select_result.value}'"
    selected_card = select_result.value
    selected_card.play(player, self)
    cardsDrawn[0].play(player, self)
  end

  def jackpot(player)
    player.hand += drawCards(player, 3)
  end

  def draw_3_play_2_of_them(player)
    cardsDrawn = drawCards(player, 3)
    firstOne = @interface.await.choose_from_list(cardsDrawn, "which would you like to play first?")
    @logger.debug "Here is the first card that was selected #{firstOne.value}"
    firstOne.value.play(player, self)
    @logger.debug "Going to select a second one"
    secondOne = @interface.await.choose_from_list(cardsDrawn, "which would you like to play next?")
    secondOne.value.play(player, self)
    discard(cardsDrawn[0])
  end

  def discard_and_draw(player)
    numberOfCardsToDraw = player.hand.length
    player.hand.each do |card|
      discard(card)
    end
    player.hand = drawCards(player, numberOfCardsToDraw)
  end

  def use_what_you_take(player)
    validOpponents = opponents(player).select do |opp|
      opp.hand.size > 0
    end
    if(validOpponents.size == 0)
      @logger.information "Too bad no body has any cards for you"
      return
    end
    selectedPlayer = @interface.await.choose_from_list(validOpponents, "which player would you like to pick from").value
    randomPosition = Random.new.rand(selectedPlayer.hand.length)
    selectedCard = selectedPlayer.hand.delete_at(randomPosition)
    @logger.debug "playing #{selectedCard}"
    selectedCard.play(player, self)
  end

  def taxation(player)
    @logger.debug "playing taxation!"
    newCardsForPlayer = opponents(player).select do |player|
      player.hand.size > 0
    end.map do |aPlayer|
      @logger.select_a_card(aPlayer.hand, "Choose a card to give to #{player}")
    end
    player.hand += newCardsForPlayer
  end

  def todaysSpecial(player)
    drawnCards = drawCards(player, 3)
    cardToPlay = @logger.select_a_card(drawnCards, "pick a card to play")
    cardToPlay.play(player, self)

    if @logger.ask_yes_no("is today your birthday")
      cardToPlay = @logger.select_a_card(drawnCards, "pick a card to play")
      cardToPlay.play(player, self)

      cardToPlay = @logger.select_a_card(drawnCards, "pick a card to play")
      cardToPlay.play(player, self)
    else
      if @logger.ask_yes_no "Is today a holiday or an anniversary"
        cardToPlay = @logger.select_a_card(drawnCards, "pick a card to play")
        cardToPlay.play(player, self)
      end
    end

    drawnCards.each do |card|
      discard(card)
    end
  end

  def mix_it_all_up(player)
    allPermanents = @players.flat_map do |aPlayer|
      aPlayer.keepers
    end

    allPermanents += @players.flat_map do |aPlayer|
      aPlayer.creepers
    end

    @players.each do |aPlayer|
      aPlayer.clear_permanents
    end

    @logger.debug "how many keepers do I have: #{allPermanents.count} but the length is #{allPermanents.length}"
    @logger.debug "and here they are: \n#{allPermanents}"
    playerCur = @currentPlayerCounter
    random = @random
    while allPermanents.length > 0
      @logger.debug "here are the keepers now: \n#{allPermanents}"
      playerCur = playerCur % @players.length
      randomPosition = random.rand(allPermanents.length)
      aPermanent = allPermanents.delete_at(randomPosition)
      @logger.debug "Trying to add the permanent #{aPermanent}"
      @players[playerCur].add_permanent(aPermanent)
      playerCur += 1
    end

    # might regret this decission but I am going to resolve the war rule for
    # every player since it will check for both permanents anyway it will be a
    # no-op for most players
    @players.each do |aPlayer|
      resolve_war_rule(aPlayer)
      resolve_taxes_rule(aPlayer)
    end

    @logger.printPermanents(player)
  end

  def letsDoThatAgain(player)
    eligibleCards = @discardPile.select do |card|
      @logger.debug "this card is of type: #{card.card_type}"
      card.card_type == "Rule" || card.card_type == "Action"
    end
    pickedCard = @logger.select_a_card(eligibleCards, "pick a card you would like to replay")
    @discardPile = @discardPile.select do |card|
      card != pickedCard
    end
    @logger.information "replaying #{pickedCard}"
    pickedCard.play(player, self)
  end

  def everybody_gets_1(player)
    cardsDrawn = drawCards(player, @players.length)
    playerCur = currentPlayer
    while cardsDrawn.length > 0
      if playerCur == currentPlayer
        selectedCard = @logger.select_a_card(cardsDrawn, "which card would you like to giver to yourself")
      else
        selectedCard = @logger.select_a_card(cardsDrawn, "which card would you like to give to #{@players[playerCur]}")
      end
      @players[playerCur].hand << selectedCard
      playerCur += 1
      playerCur %= @players.length
    end
  end

  def tradeHands(player)
    opponentsText = opponents(player).map do |player|
      player.to_s
    end
    selectedPlayer = @logger.select_a_player(opponents(player), "who would you like to trade hands with?")
    otherHand = selectedPlayer.hand
    selectedPlayer.hand = player.hand
    player.hand = otherHand
  end

  def rotateHands(player)
    direction = @logger.ask_rotation("Which way would you like to rotate? ")

    #candidate for debug
    @players.each do |player|
      @logger.displayCardsDebug(player.hand, "What is my hand now #{player}:")
    end

    playerCur = currentPlayer
    tempHand = @players[playerCur].hand
    nextPlayer = -1
    while nextPlayer != currentPlayer
      if @logger.isClockwise(direction)
        @logger.debug "move clockwise"
        nextPlayer  = (playerCur + 1) % @players.length
      else
        @logger.debug "move counterclockwise playerCur: #{playerCur} nextPlayer: #{nextPlayer} "
        nextPlayer  = (playerCur - 1) % @players.length
      end

      @logger.information "player #{playerCur+1} gets =  #{nextPlayer+1}'s hand "
      @logger.trace "giving plyer #{playerCur+1} the hand\n\t#{@players[nextPlayer].hand}"
      @players[playerCur].set_hand(@players[nextPlayer].hand)

      playerCur = nextPlayer
      @logger.debug "here is the value of nextPlayer: #{nextPlayer}"
    end
    @logger.trace "giving plyer #{playerCur+1} the hand\n\t#{tempHand}"
    if @logger.isClockwise(direction)
      newNextPlayer = (playerCur - 1) % @players.length
    else
      newNextPlayer = (playerCur + 1) % @players.length
    end
    @players[newNextPlayer].set_hand(tempHand)

    # candidate for debug
    @players.each do |player|
      @logger.displayCards(player.hand, "What is my hand now #{player}:")
    end
  end

  def take_another_turn(player)
    player.take_another_turn = true
  end

  def exchange_keepers(player)
    if player.keepers.length == 0
      @logger.information "Too bad you have no keepers"
      return
    end
    otherKeepers = false
    opponents(player).select do |player|
      otherKeepers ||= player.keepers.length != 0
    end
    if !otherKeepers
      @logger.information "Too bad you have no keepers"
      return
    end

    eligibleOpponents = opponents(player).select do |aPlayer|
      aPlayer.keepers.length > 0
    end



    eligibleOpponents.select do |aPlayer|
      @logger.printKeepers(aPlayer, "Here are the keepers: #{aPlayer.to_s} has:")
    end

    eligibleOpponents.unshift(:no_one)
    selectedPlayer = :no_one
    loop do
      selectedPlayer = @logger.select_a_player(eligibleOpponents, "Which player would you like to take a keeper from")
      areYouSure = selectedPlayer != :no_one
      if selectedPlayer == :no_one
        areYouSure = @logger.ask_yes_no "Are you sure you don't want to trade with anyone?"
      end
      if areYouSure
        break
      end
    end
    if selectedPlayer == :no_one
      return
    end

    if selectedPlayer.keepers.length > 1
      myNewKeeper = @logger.select_a_card(selectedPlayer.keepers, "Slect which Keeper you would like")
    else
      myNewKeeper = selectedPlayer.keepers.delete_at(0)
    end
    if player.keepers.length > 1
      myOldKeeper = @logger.select_a_card(player.keepers, "Which Keeper would you like to exchange")
    else
      myOldKeeper = player.keepers.delete_at(0)
    end
    player.keepers << myNewKeeper
    selectedPlayer.keepers << myOldKeeper

    resolve_war_rule(player)
    resolve_war_rule(selectedPlayer)
    resolve_taxes_rule(player)
    resolve_taxes_rule(selectedPlayer)

    @logger.displayCardsDebug(player.keepers, "Here are your Keepers after the exchange")

  end

  def resolve_war_rule(player)
    playerHasPeace = player.has_peace?
    playerHasWar = player.has_war?
    if (playerHasPeace && playerHasWar)
      selectedPlayer = @logger.select_a_player(opponents(player), "#{player} since you have peace. Who would you like to give war too?")
      @logger.debug "Who is the selected playar #{selectedPlayer}\n who is the original #{player}"

      selectedPlayer.add_creeper(player.take_war)
    end
  end

  def resolve_taxes_rule(player)
    if(player.has_money? && player.has_taxes?)
      discard(player.take_taxes)
      discard(player.take_money)
    end
  end

  def resolve_death_rule(player)
    if(player.has_death?)
      eligiablePermanents = player.permanents.select do |perm|
        perm.card_type != "Creeper" || !perm.is_death?
      end
      if(eligiablePermanents.size == 0)
        discard(player.take_death)
      else
        selectedCard = @logger.select_a_card(eligiablePermanents, "Which permanent would you like to discard to death?")
        player.discard_permanent(selectedCard)
      end
    end
  end

end

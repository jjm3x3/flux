require "./cards/cards.rb"

module StackedDecks
    def StackedDecks.stacked_deck_factory(logger, deck_list)
        StackedDeck.new(logger, deck_list)
    end

    keeper1 = Keeper.new(1, "one")
    keeper2 = Keeper.new(2, "two")

    QUICK_WIN =
    [
        keeper1,
        Keeper.new(0, "doesn't matter"), # these are for the rest of the game setup
        Keeper.new(0, "doesn't matter"), #   that way the next card player1 grabs is
        Keeper.new(0, "doesn't matter"), #   the keeper1 card
        Keeper.new(0, "doesn't matter"),
        Keeper.new(0, "doesn't matter"),
        Keeper.new(0, "doesn't matter"),
        keeper2,
        Goal.new("one and two", [keeper1, keeper2], "Have keeper1 & keeper2"),
        Rule.new("Play forever", 2, "XXXXXa"),
    ]

    DISCARD_TO_DEATH_ON_FIRST_TURN =
    [
        Creeper.new(3, "extra death", "some rules text"),
        Creeper.new(2, "extra taxes", "some rules text"),
    ]

    STARTS_WITH_NO_HAND_LIMIT =
    [
        Limit.new("max of 1", 3, "put some rule text here", 1)
    ]

    EXTRA_LONG_DIALOG_COMBO =
    [
        Limit.new("No hands", 3, "some rules text", 0),
        Rule.new("Draw 9", 1, "XXXXX9"),
        Rule.new("Play tree", 2, "XXXXX3"),
    ]

    STARTS_WITH_DRAW_3_PLAY_2 =
    [
        Action.new(5, "draw a few play a couple", "Draw 3 cards the play 2 of them")
    ]
end

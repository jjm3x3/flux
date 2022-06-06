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
end

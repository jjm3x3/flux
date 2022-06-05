module StackedDecks
    def StackedDecks.stacked_deck_factory(logger, deck_list)
        StackedDeck.new(logger, deck_list)
    end

    keeper1 = Keeper.new(1, "one")
    keeper2 = Keeper.new(2, "two")

    QUICK_WIN =
        [
            keeper1,
            Keeper.new(0, "doesn't matter"),
            Keeper.new(0, "doesn't matter"),
            Keeper.new(0, "doesn't matter"),
            Keeper.new(0, "doesn't matter"),
            Keeper.new(0, "doesn't matter"),
            Keeper.new(0, "doesn't matter"),
            keeper2,
            Goal.new("one and two", [keeper1, keeper2], "Have keeper1 & keeper2"),
            Rule.new("Play forever", 2, "XXXXXa"),
        ]
end

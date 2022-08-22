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

    QUICK_USER_PROMT =
    [
        Action.new(7, "grab & play" , "Grab a card from someone and play it immediately"),
    ]

    ROTATE_HANDS_COMBO =
    [
        Action.new(14, "Some rotation", "Lets rotate"),
        Rule.new("Draw 9", 1, "XXXXX9"),
        Rule.new("Play tree", 2, "XXXXX3"),
    ]

    EXCHANGE_KEEPERS_COMBO =
    [
        Action.new(16, "Exchanges some stuff", "EXCHANGE!!")
    ]

    TAKE_ANOTHER_TURN =
    [
        Action.new(15, "AGAIN?", "GO AGAIN!!")
    ]

    EXTRA_LONG_TOOL_TIP_TEXT =
    [
        Action.new(9, "A special day?", "Set your hand aside and draw 3 cards. If today is your birthday, play all 3 cards. If today is a holiday or a specaial annicersary, play 2 of the cards. If it's just another day, play only 1 card. Discard the remainder."),
    ]

    STARTS_WITH_PEACE =
    [
        Keeper.new(16, "peas"),
    ]
end

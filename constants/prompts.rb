module Constants
    PROMPT_STRINGS = {
        default: "Some default prompt",
        are_you_sure_no_trade_prompt: "Are you sure you don't want to trade with anyone?",
        birthday_prompt: "is today your birthday",
        choose_card_to_play_prompt: "pick a card to play",
        death_discard_prompt: "Which permanent would you like to discard to death?",
        discard_down_to_keeper_limit: "Choose a keeper to discard",
        give_card_to_yourself_prompt: "which card would you like to giver to yourself",
        holiday_anniversary_prompt: "Is today a holiday or an anniversary",
        keeper_to_give_prompt: "Which player would you like to take a keeper from",
        pick_a_keeper_from_prompt: "Which player would you like to take a keeper from",
        play_first_prompt: "Which one would you like to play first?",
        play_next_prompt: "which would you like to play next?",
        replay_prompt: "pick a card you would like to replay",
        rotation_prompt: "Which way would you like to rotate?",
        select_a_card_to_play_prompt: "Select a card from your hand to play",
        select_a_keeper_prompt: "Slect which Keeper you would like",
        trade_hands_prompt: "who would you like to trade hands with?",
        which_player_to_pick_from_prompt: "which player would you like to pick from",
    }

    USER_SPECIFIC_PROMPTS = {
        discard_prompt_name: {
            key_template: "discard_down_to_limit_{name}",
            value_template: "Player {name} Select a card to discard"
        },
        taxation_prompt_name: {
            key_template: "give_card_to_player_{name}",
            value_template: "Choose a card to give to {name}"
        }
    }
end

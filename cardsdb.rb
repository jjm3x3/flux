require "sqlite3"

db = SQLite3::Database.new "cards.db"

rows = db.execute <<-SQL
create table if not exists keepers (
       id int,
       name varchar(30)
);
SQL

[
  [1, "Milk"],
  [2, "Time"],
  [3, "Toaster"],
  [4, "The Rocket"],
  [5, "The Brain"],
  [6, "Television"],
  [7, "Cookies"],
  [8, "Dreams"],
  [9, "Chocolate"],
  [10, "Sleep"],
  [11, "The Sun"],
  [12, "The Cosmos"],
  [13, "Bread"],
  [14, "The Party"],
  [15, "Love"],
  [16, "Peace"],
  [17, "The Moon"],
  [18, "The Eye"],
  [19, "Money"]

].each do |pair|
  db.execute "insert into keepers values ( ? , ? )", pair
end

rows = db.execute <<-SQL
create table if not exists goals (
       id int,
       name varchar(30),
       related_keepers varchar(10),
       rules varchar(30)
);
SQL

[
  [1, "The Appliances", "[3,6]", "? and ?"],
  [2, "Rocket Science", "[4,5]", "? and ?"],
  [3, "Milk and Cookies", "[1,7]", "? and ?"],
  [4, "Interstellar Spacecraft", "[4,12]", "? and ?"],
  [5, "Star Gazing", "[12,18]", "? and ?"],
  [6, "Bed Time", "[2,10]", "? and ?"],
  [7, "The Mind's Eye", "[5,18]", "? and ?"],
  [8, "Night and Day", "[11,17]", "? and ?"],
  [9, "Dough", "[13,19]", "? and ?"],
  [10, "Chocolate Cookies", "[9,7]", "? and ?"],
  [11, "Chocolate Milk", "[1,9]", "? and ?"],
  [12, "Winning the Lottery", "[8,19]", "? and ?"],
  [13, "Squishy Chocolate", "[9,11]", "? and ?"],
  [14, "Dreamland", "[8,10]", "? and ?"],
  [15, "Time is money", "[2,19]", "? and ?"],
  [16, "Rocket to the Moon", "[4,17]", "? and ?"],
  [17, "Hearts and Minds", "[5,15]", "? and ?"],
  [18, "Hippyism", "[15,16]", "? and ?"],
  [19, "Toast", "[3,13]", "? and ?"],
  [20, "Baked Goods", "[7,13]", "? and ?"]
].each do |value|
  db.execute "insert into goals values ( ? , ? , ? , ?)", value
end

rows = db.execute <<-SQL
create table if not exists rules (
       id int,
       name varchar(30),
       rule_type int,
       rule varchar(50)
);
SQL

[
  [1, "Draw 2", 1, "Draw 2 cards per turn"],
  [2, "Draw 3", 1, "Draw 3 cards per turn"],
  [3, "Draw 4", 1, "Draw 4 cards per turn"],
  [4, "Draw 5", 1, "Draw 5 cards per turn"],
  [5, "Play 2", 2, "Play 2 cards per turn"],
  [6, "Play 3", 2, "Play 3 cards per turn"],
  [7, "Play 4", 2, "Play 4 cards per turn"],
  [8, "Play All", 2, "Play all of the cards in your hand on each turn"],
  [9, "Hand Limit 0", 3, "you can only have 0 cards in your hand"],
  [10, "Hand Limit 1", 3, "you can only have 1 cards in your hand"],
  [11, "Hand Limit 2", 3, "you can only have 2 cards in your hand"],
  [12, "Keeper Limit 2", 4, "you can only have 2 keepers in play."],
  [13, "Keeper Limit 3", 4, "you can only have 3 keepers in play."],
  [14, "Keeper Limit 4", 4, "you can only have 4 keepers in play."] #,
  # [15, "First Play Random", 5, "The first card you play must be chosen at random from your hand by the player on your left. Ignore this rule if, at the start of your turn , the current Rule cards allow you to play only one card"]
].each do |value|
  db.execute "insert into rules values ( ? , ? , ? , ? )", value
end

rows = db.execute <<-SQL
create table if not exists actions (
       id int,
       name varchar(30),
       rule_text varchar(250)
);
SQL

[
  [1, "Rules Reset", "Reset to the Basic Rules. Discard all New Rules cards, and leave only the Basic Rules (and any Meta Rule cards) in play. Don't discard the current Goal."],
  [2, "Draw 2 and Use 'em", "Set your hand aside. Draw 2 cards, play them in any order you choose, then pick up your hand and continue with your turn. This card and all cards played becauyse of it are counted as a single play."],
  [3, "Jackpot!", "Draw 3 cards"],
  [4, "No Limits", "Discard all Hand and Keeper Limit rules currently in play."],
  [5, "Draw 3, play 2 of them", "Set your hand aside. Draw 3cards and play 2 of them. Discard the last card, then pick up your hand and continue with your turn. This card and all all cards played because of it, counted as a single play."],
  [6, "Discard & Draw", "Disacrd your entire hand, then draw as many cards as you discarded.i Do not count this card when determining how many replacement cards to draw."],
  [7, "Use What You Take", "Take a card at random from another player's hand, and play it"],
  [8, "Taxation!", "Each player mush choose 1 card from his or her hand and give it to you"],
  [9, "Today's Special!", "Set your hand aside and draw 3 cards.  If today is your birthday, play all 3 cards. If today is a holoday or a specaial annicersary, play 2 of the cards. If it's just another day, play only 1 card. Discard the remainder."],
  [10, "Mix It All Up", "Gather up all Keepers and Creepers on the table, shuggle them together and deal them back out to all players, starting with yourself. These cards go back into play in front of whoever receives them."],
  [11, "Let's Do That Again!", "Search through the discard pile. Take any Action or New Rule card you wish and immediately play it. Anyone may look through the disacrd pile at any time, but the order of what's in the pile should not be changed."],
  [12, "Everybody Gets 1", "Set your hand aside. Count the number of players in the game (including yourself). Draw enough cards to give 1 card to each player, then do so. You decide who gets what."],
  [13, "Trade Hands", "Trade your hand for the hand of one of your opponents. This is one of those times when you cat get something for nothing."],
  [14, "Rotate Hands", "All players pass their ahnd to the player next to them. You decide the direction."],
  [15, "Take Another Turn", "Take another turn as soon as you finish this one"],
  [16, "Exchange Keepers", "Pick any Keeper another player has on the table and exchange it for one that you have on the table. If you have no Keepers in play, of if no one else has a Keeper, nothing happens."]
].each do |value|
  db.execute "insert into actions values ( ? , ? , ? )", value
end

rows = db.execute <<-SQL
create table if not exists creepers (
  id int,
  name varchar(30),
  rules_text varchar(200)
);
SQL

[
  [1, "War", "You cannot win if you have this unless the Goal says otherwise"]
].each do |value|
  db.execute "insert into creepers values ( ? , ? , ? )", value
end

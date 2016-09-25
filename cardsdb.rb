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
  [19, "Toast", "[3,13]", "? and ?"]
].each do |value|
  db.execute "insert into goals values ( ? , ? , ? , ?)", value
end

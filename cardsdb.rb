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
  [7, "Chookies"],
  [8, "Dreams"]

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
  [3, "Milk and Cookies", "[1,7]", "? and ?"]
].each do |value|
  db.execute "insert into goals values ( ? , ? , ? , ?)", value
end

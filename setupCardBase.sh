if [[ -f 'cards.db' ]] ; then
	rm cards.db
fi
ruby cardsdb.rb


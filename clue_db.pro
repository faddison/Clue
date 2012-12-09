% %%%%% RESET DATABASE

reset_all :- 
		retractall(weapon(X, Y, Z)),
		retractall(room(X, Y, Z)),
		retractall(person(X, Y, Z)),
		retractall(card(X, Y, Z)),
		retractall(suggestion(P, X, Y, Z)),
		retractall(player(_,_)),
		retractall(self(_)),
		retractall(character_name(_,_)),
		retractall(weapon_name(_,_)),
		retractall(room_name(_,_)).

add_cards :-
		assert(card(X,Y,Z) :- room(X, Y, Z); person(X, Y, Z); weapon(X,Y,Z)),
		%
		assert(person('Miss Scarlett', -1, [])),
		assert(person('Colonel Mustard', -1, [])),
		assert(person('Mrs. White', -1, [])),
		assert(person('Mr. Green', -1, [])),
		assert(person('Mrs. Peacock', -1, [])),
		assert(person('Professor Plum', -1, [])),
		%
		assert(room('kitchen', -1, [])),
		assert(room('ballroom', -1, [])),
		assert(room('conservatory', -1, [])),
		assert(room('billiard room', -1, [])),
		assert(room('library', -1, [])),
		assert(room('study', -1, [])),
		assert(room('hall', -1, [])),
		assert(room('lounge', -1, [])),
		assert(room('dining room', -1, [])),
		%
		assert(weapon('knife', -1, [])),
		assert(weapon('candlestick', -1, [])),
		assert(weapon('revolver', -1, [])),
		assert(weapon('rope', -1, [])),
		assert(weapon('lead pipe', -1, [])),
		assert(weapon('wrench', -1, [])).

win_condition1 :-
		assert(card(X,Y,Z) :- room(X, Y, Z); person(X, Y, Z); weapon(X,Y,Z)),
		%
		assert(person('Miss Scarlett', 1, [])),
		assert(person('Colonel Mustard', 1, [])),
		assert(person('Mrs. White', 1, [])),
		assert(person('Mr. Green', 1, [])),
		assert(person('Mrs. Peacock', 1, [])),
		assert(person('Professor Plum', -1, [])),
		%
		assert(room('kitchen', 1, [])),
		assert(room('ballroom', 1, [])),
		assert(room('conservatory', 1, [])),
		assert(room('billiard room', 1, [])),
		assert(room('library', 1, [])),
		assert(room('study', 1, [])),
		assert(room('hall', 1, [])),
		assert(room('lounge', 1, [])),
		assert(room('dining room', -1, [])),
		%
		assert(weapon('knife', 1, [])),
		assert(weapon('candlestick', 1, [])),
		assert(weapon('revolver', 1, [])),
		assert(weapon('rope', 1, [])),
		assert(weapon('lead pipe', 1, [])),
		assert(weapon('wrench', -1, [])).

win_condition2 :-		
		assert(card(X,Y,Z) :- room(X, Y, Z); person(X, Y, Z); weapon(X,Y,Z)),
		%
		assert(person('Miss Scarlett', 1, [])),
		assert(person('Colonel Mustard', 1, [])),
		assert(person('Mrs. White', 1, [])),
		assert(person('Mr. Green', 1, [])),
		assert(person('Mrs. Peacock', 1, [])),
		assert(person('Professor Plum', -1, [])),
		%
		assert(room('kitchen', 1, [])),
		assert(room('ballroom', 1, [])),
		assert(room('conservatory', 1, [])),
		assert(room('billiard room', 1, [])),
		assert(room('library', 1, [])),
		assert(room('study', 1, [])),
		assert(room('hall', 1, [])),
		assert(room('lounge', 1, [])),
		assert(room('dining room', -1, [])),
		%
		assert(weapon('knife', 1, [])),
		assert(weapon('candlestick', 1, [])),
		assert(weapon('revolver', 1, [])),
		assert(weapon('rope', -1, [1,2])),
		assert(weapon('lead pipe', 1, [])),
		assert(weapon('wrench', -1, [])).
	
% %%%%% RESET DATABASE
setup :-
		map_character_names,
		map_weapon_names,
		map_room_names.
		
% maps the full character and abbreviation for quick reference and code reduction
map_character_names :-
		assert(character_name('s', 'Miss Scarlett')),
		assert(character_name('m', 'Colonel Mustard')),
		assert(character_name('w', 'Mrs. White')),
		assert(character_name('g', 'Mr. Green')),
		assert(character_name('p', 'Mrs. Peacock')),
		assert(character_name('pl', 'Professor Plum')).
		
map_weapon_names :-
		assert(weapon_name('k', 'knife')),
		assert(weapon_name('c', 'candlestick')),
		assert(weapon_name('r', 'revolver')),
		assert(weapon_name('ro', 'rope')),
		assert(weapon_name('l', 'lead pipe')),
		assert(weapon_name('w', 'wrench')).
		
map_room_names :-
		assert(room_name('k', 'kitchen')),
		assert(room_name('b', 'ballroom')),
		assert(room_name('c', 'conservatory')),
		assert(room_name('bi', 'billiard room')),
		assert(room_name('l', 'library')),
		assert(room_name('s', 'study')),
		assert(room_name('h', 'hall')),
		assert(room_name('lo', 'lounge')),
		assert(room_name('d', 'dining room')).

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
	
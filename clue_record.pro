% %%%%%% RECORD CARD INFO

init_record_card :-
		get_self(Index),
		record_card(Index),
		more_cards.
		
% ask if any more cards need to be added
more_cards :-
		write('More Cards to enter? ("y" or "n".)'), nl, read(X),
        (X == 'y' -> init_record_card;
		X == 'n' -> writeln('No more cards to add.');
        invalid_command).

% Record the card with the specified player.
record_card(Player) :-
		writeln('Which type of card ?'),
		print_cards,
		read(Card),
		get_card(Player, Card),
		writeln('Card recorded.').

% retrieve the correct card to add to the database.
get_card(Player, 's') :- 
		get_character(Character), 
		record_character(Player, Character).
		
get_card(Player, 'w') :- 
		get_weapon(Weapon), 
		record_weapon(Player, Weapon).
		
get_card(Player, 'r') :- 
		get_room(Room), 
		record_room(Player, Room).
		
get_card(Player, Invalid) :- 
		invalid_command, 
		record_card(Player).


% add the specified suspect card information to the database
% need to implement check for existing card
record_character(Player, Character) :- 
		retract(person(Character, _, _)), 
		assert(person(Character, Player, [])).
		
% add the specified weapon card information to the database		
record_weapon(Player, Weapon) :-
		retract(weapon(Weapon, _, _)), 
		assert(weapon(Weapon, Player, [])).
		
% add the specified room card information to the database
record_room(Player, Room) :-
		retract(room(Room, _, _)), 
		assert(room(Room, P, [])).
		
% Ask for and retrieve the specified type of card.	
get_character(Character) :-
		writeln('Which suspect was suggested?'),
		print_characters,
		read(X),
		character_name(X,_) ->
			character_name(X, Character);
			invalid_command, get_character(Character).

get_room(Room) :-
		writeln('Which room was suggested?'),
		print_rooms,
		read(X),
		room_name(X,_) ->
			room_name(X, Room);
			invalid_command, get_room(Room).
			
get_weapon(Weapon) :-
		writeln('Which weapon was suggested?'),
		print_weapons,
		read(X),
		weapon_name(X,_) ->
			weapon_name(X, Weapon);
			invalid_command, get_weapon(Weapon).
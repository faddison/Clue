% %%%%%% MAKE A SUGGESTION

% Begins the suggestion process
make_suggestion(CurrIndex, NumPlayers) :- 
		enter_suggestion(CurrIndex, NumPlayers), 
		writeln('Suggestion Made').

% Enter a suggestion here
enter_suggestion(CurrIndex, NumPlayers) :-
		player(CurrIndex, Player),
		get_room(Room),
		get_character(Character),
		get_weapon(Weapon),
		/*
		Z = 'Miss Scarlett',
		Y = 'kitchen',
		I = 'knife',
		*/
		% add the suggestion to the database
		assert(suggestion(Player, Room, Character, Weapon)),
		update_cards(CurrIndex, NumPlayers, 1, Player, Room, Character, Weapon).
		
% %%%%% UPDATE CARDS WHEN NO CARDS SHOWN BY PLAYER

% get the next index using a circular array tactic
next_index(CurrIndex, NumPlayers, Count, NextIndex) :-
		ModTerm is Count + CurrIndex,
		(mod(ModTerm, NumPlayers) < 1 -> NextIndex is NumPlayers + 0;
		NextIndex is mod(ModTerm, NumPlayers)).
		
% enters into a suggestion loop to find out who shows which card
% paths with differ depending on whether the current player is human or machine
update_cards(CurrIndex, NumPlayers, Count, Suggestor, Room, Suspect, Weapon) :-
		Count == NumPlayers -> writeln('Suggestion round finished.');
		next_index(CurrIndex, NumPlayers, Count, NextIndex),
		% write('Next Index is '), write(NextIndex),
		player(NextIndex, Player), NewCount is Count + 1,
		write('Did '), write(Player), write(' show a card? "y"./"n".'), nl, read(CardShown),
		(CardShown == 'y' -> 
			(self(Suggestor) -> 
				record_player_card(Player); 
				writeln('No information stored.'));
			CardShown == 'n' -> 
				writeln('Saving information. Moving on to next player...'),
					update_weapon(Weapon, [Player]), 
					update_room(Room, [Player]), 
					update_suspect(Suspect, [Player]), 
					update_cards(CurrIndex, NumPlayers, NewCount, Suggestor, Room, Suspect, Weapon); 
				invalid_command). 

% when player doesnt have weapon, player ID is added to the list of opponents that definitely dont hold the card
update_weapon(W, DontHold) :-
		weapon(W , N, List),
		retract(weapon(W ,N, List)),
		append(List, DontHold, UpdatedList),
		remove_duplicates(UpdatedList, NoDuplicates),
		assert(weapon(W,N,NoDuplicates)).

% when player doesnt have room, player ID is added to the list of opponents that definitely dont hold the card
update_room(R, DontHold) :-
		room(R , N, List),
		retract(room(R ,N, List)),
		append(List, DontHold, UpdatedList),
		remove_duplicates(UpdatedList, NoDuplicates),
		assert(room(R,N,NoDuplicates)).

% when player doesnt have suspect, player ID is added to the list of people that definitely dont hold the card
update_suspect(S, DontHold) :-
		person(S , N, List),
		retract(person(S ,N, List)),
		append(List, DontHold, UpdatedList),
		remove_duplicates(UpdatedList, NoDuplicates),
		assert(person(S,N,NoDuplicates)).

:- dynamic(weapon/3), dynamic(person/3), dynamic(room/3), dynamic(player/2), dynamic(suggestion/4), dynamic(card/3), dynamic(player_list/2), dynamic(sugg_list/4).

% intializes all players participating in the game and begins the game itself
create_players :- 
		nl, write('Please enter the number of players. Clue can be played with 2-6 players.'), nl, read(NumPlayers), 
		(NumPlayers > 6 -> nl, write('Too many players.'), create_players;
		(NumPlayers < 2 -> nl, write('Clue needs at least two players.'), create_players; 
		nl, write('Creating players in specified order... You will be asked to specify the human player after.'), nl,
		create_opponents(NumPlayers, 1), begin_game(NumPlayers))).
		
% allows human player to specifiy which character they will be playing 
specify_self :- 
		writeln('Please specify which character you are playing as.'),
		print_characters,
		read(Name), character_name(Name, Player), assign_self(Player).

% add the human players character to the database for lookup
assign_self(Player) :-  
		player(_,Player) -> assert(self(Player));
		write('Character is not playing.'), specify_self.

% create all the game characters participating in the game as well as who the human player is
create_opponents(NumPlayers, CurrIndex) :- nl, write('Enter name as specified below for player '), write(CurrIndex), write(':'), nl, nl,
					print_characters,
					read(Name), character_name(Name, Player),
					assign_player(CurrIndex, Player), (NumPlayers>1 -> X is NumPlayers - 1, Acc is CurrIndex + 1, create_opponents(X, Acc)); 
					specify_self, self(HumanPlayer), player(HumanIndex, HumanPlayer), get_cards(HumanIndex).

% add the character and corresponding turn order to the database  
assign_player(Index, Player) :- assert(player(Index, Player)). 

% %%%%% INITIAL CARD KNOWLEDGE

% set up cards so -1 flag is changed to playerIndex. this represents which player definitely holds the card
% asks for card type
get_cards(PlayerIndex) :- nl, writeln('What cards do you have?'), print_cards, read(I), 
	get_card_title(I, PlayerIndex).

% since card type is known, adds shortcut input keys depending on card type 
get_card_title('s', PlayerIndex) :- init_person_card(PlayerIndex).
get_card_title('w', PlayerIndex) :- init_weapon_card(PlayerIndex).
get_card_title('r', PlayerIndex) :- init_room_card(PlayerIndex).
get_card_title(I, PlayerIndex) :- invalid_command, get_cards(PlayerIndex).

init_person_card(PlayerIndex) :- 
		writeln('Enter the suspect name as specified below: '), print_characters, read(S),
		character_name(S,_) -> 
			init_person(S, PlayerIndex); 
			invalid_command, get_cards(PlayerIndex).

init_weapon_card(PlayerIndex) :-
		writeln('Enter the weapon type as specified below: '), print_weapons, read(W), 
		weapon_name(W,_) -> 
			init_weapon(W, PlayerIndex); 
			invalid_command, get_cards(PlayerIndex).

init_room_card(PlayerIndex) :-
		writeln('Enter the room type as specified below: '), print_rooms, read(R), 
		room_name(R,_) -> 
			init_room(R, PlayerIndex);
			invalid_command, get_cards(PlayerIndex).
		
% given that the card is a person, update person with playerindex in database, remove -1 flag
% prompt to add more cards if desired
% error checking needs to be handled by parent caller
init_person(S, PlayerIndex) :-
		character_name(S, Name),
	    retract(person(Name, -1, [])), assert(person(Name, PlayerIndex, [])),
		more_cards(PlayerIndex).

% given that the card is a weapon, update weapon with playerindex in database, remove -1 flag
% prompt to add more cards if desired
% put yes no in loop instead of hardcoded to capture errors
init_weapon(W, PlayerIndex) :-
		weapon_name(W, Name),
	    retract(weapon(Name, -1, [])), assert(weapon(Name, PlayerIndex, [])),
		more_cards(PlayerIndex).
		
% given that the card is a room, update room with playerindex in database, remove -1 flag
% prompt to add more cards if desired
% the invalid_command call is skipping turns i think
init_room(R, PlayerIndex) :- 
		room_name(R, Name),
	    retract(room(Name, -1, [])), assert(room(Name, PlayerIndex, [])),
        more_cards(PlayerIndex).

%
more_cards(PlayerIndex) :-
		write('More Cards to enter? ("y" or "n".)'), nl, read(X),
        X == 'y' -> 
			get_cards(PlayerIndex);
			X == 'n' -> 
				writeln('No more cards to add.');
        invalid_command.

% %%%% INITIALIZE ORDER OF PLAY

% %%%%%% GAME BEGINS

/* 
begins the game. this method is called after all player 
turns have been completed. defined as a "round." it also checks if
any accusations can be made.
*/
begin_game(NumPlayers) :- nl, nl, write('Beginning next round...'), nl, accusation(NumPlayers), game_loop(1, NumPlayers).

/*
Main game loop. Loops through the list of players using a counter. 
Menu is called and after it returns the game loop runs again on next player.
*/
game_loop(CurrIndex, NumPlayers) :- nl, write(CurrIndex), player(CurrIndex, Name), write(', '), write(Name), write(' turn.'), 
									(self(Name) -> write(' (Your turn!)'); write(' (Opponents turn!)')), nl,
									menu(CurrIndex, NumPlayers), 
									(CurrIndex = NumPlayers) -> begin_game(NumPlayers);
									(NextPlayer is CurrIndex + 1), game_loop(NextPlayer, NumPlayers).

% %%%%%%% MAIN MENU

% entry point for the command menu system.
menu(CurrIndex, NumPlayers) :- 
		write('Please enter a command ("help" for list of commands)'), nl, read(X), exec_command(CurrIndex, NumPlayers, X).
	
% Print the list of available menu commands.	
print_commands :-
		writeln('"next"    - finish the turn.'),
        writeln('"record"  - record a card shown to you.'),
        writeln('"suggest" - record a suggestion.'),
        writeln('"history" - list the database of events.'),
		writeln('"suggestions" - list all the suggestions.'),
		writeln('"cards" - list all the cards.'),
		writeln('"players" - list all the players.'),
		writeln('"accuse"  - check if an accusation can be made.'),
        writeln('"restart"   - clears all current game information.'),
		writeln('"hint"   - provides a suggestion hint.'),
		writeln('"current"   - shows who the current player is.'),
		writeln('"quit" 	 - end game and stop the program.').

% Quit the game by throwing an exception to prevent the termination of swipl process.
quit_game :- nl, write('Are you sure you want to exit the game?'),
			 nl, write('Type "yes" to exit or "no" to cancel'),
			 nl, read(X), (X = 'yes' -> throw(gameover)). 

% Execute the specified menu command.
exec_command(CurrIndex, NumPlayers, X) :- 
			player(CurrIndex, Player),
			( X = 'next' -> write('End turn.');
			  X = 'help' -> print_commands, menu(CurrIndex, NumPlayers);
              X = 'record' -> record_player_card(CurrIndex), menu(CurrIndex, NumPlayers);
			  X = 'suggest' -> make_suggestion(CurrIndex, NumPlayers), menu(CurrIndex, NumPlayers);
			  X = 'history' -> history, menu(CurrIndex, NumPlayers);
			  X = 'suggestions' -> history_suggestions, menu(CurrIndex, NumPlayers);
			  X = 'cards' -> history_cards, menu(CurrIndex, NumPlayers);
			  X = 'players' -> history_players, menu(CurrIndex, NumPlayers);
			  X = 'accuse' -> accusation(NumPlayers), menu(CurrIndex, NumPlayers);
              X = 'reset' -> reset_all, add_cards, begin_game(NumPlayers);
			  X = 'current' -> current_player(Player), menu(CurrIndex, NumPlayers);
			  X = 'hint' -> get_hint(Player), menu(CurrIndex, NumPlayers);
			  X = 'quit' -> quit_game, menu(CurrIndex, NumPlayers);
			  invalid_command). 
			  
% Determine whether a hint can be give or not.
get_hint(Player) :-
		self(Player) -> print_hint; write('No hints for opponents!'), nl.

% Retrieve the best hints from the database. Does not produce a room.	
print_hint :-
		writeln('-'),
		findall(X, weapon(X,-1,_), [C|Cs]), writeln(C),
		findall(Y, person(Y,-1,_), [D|Ds]), writeln(D), 
		writeln('-').
	
% Returns the current user and whether its computer or player turn.	
current_player(Player) :-
		nl, write('Current player is '), write(Player),
		self(Player) -> write(' (Your turn!)'); write(' (Opponents turn!)'), nl.

% %%%%%% RECORD CARD INFO

% Record the card with the specified player.
record_player_card(Player) :-
	writeln('Which type of card was it?'),
	print_cards,
	read(T), nl, nl, get_card(Player, T).

% retrieve the correct card to add to the database.
get_card(Player, 's') :- get_character(Character), save_character_card(Player, Character).
get_card(Player, 'w') :- get_weapon(Weapon), save_weapon_card(Player, Weapon).
get_card(Player, 'r') :- get_room(Room), save_room_card(Player, Room).
get_card(Player, Invalid) :- invalid_command, record_player_card(Player).


% add the specified suspect card information to the database
% need to implement check for existing card
save_character_card(Player, Character) :- 
		retract(person(Character, _, _)), 
		assert(person(Character, Player, [])).
		
% add the specified weapon card information to the database		
save_weapon_card(Player, Weapon) :-
		retract(weapon(Weapon, _, _)), 
		assert(weapon(Weapon, Player, [])).
		
% add the specified room card information to the database
save_room_card(Player, Room) :-
		retract(room(Room, _, _)), 
		assert(room(Room, P, [])).
		
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
			
% %%%%%% MAKE A SUGGESTION

% Begins the suggestion process
make_suggestion(CurrIndex, NumPlayers) :- enter_suggestion(CurrIndex, NumPlayers), writeln('Suggestion Made').

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
		(CardShown == 'y' -> (self(Suggestor) -> record_player_card(Player); writeln('No information stored.'));
		CardShown == 'n' -> writeln('Saving information. Moving on to next player...'),
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

% ensures that player ID is not added more than once to DontHold: Without this check we may falsely assume an accusation can be made.
remove_duplicates([],[]).
remove_duplicates([X],[X]).
remove_duplicates([X,X|Xs],Ys) :- remove_duplicates([X|Xs],Ys).
remove_duplicates([X,Y|Ys],[X|Zs]) :- X \= Y, remove_duplicates([Y|Ys],Zs).

% %%%%% CURRENT GAME HISTORY

% prints out the history of card information that we know
history :- 
		history_cards,
		history_players,
		history_suggestions.
			
history_cards :-
		writeln('Current Card Information: '),
		findall(card(X,Y,Z), card(X,Y,Z), AllCards), maplist(writeln, AllCards), nl.
		
history_players :- 
		writeln('Current Player Information: '),
		findall(player(N, T), player(N, T), AllPlayers), maplist(writeln, Allplayers), nl.
		
history_suggestions :-
		writeln('Previous Suggestions: '),
		findall(suggestion(P,X,Y,Z), suggestion(P,X,Y,Z), AllSuggestions), maplist(writeln, AllSuggestions).


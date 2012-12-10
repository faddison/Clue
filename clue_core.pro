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
		player(_,Player) -> 
			assert(self(Player));
		write('Character is not playing.'), 
		specify_self.

% create all the game characters participating in the game as well as who the human player is
create_opponents(NumPlayers, CurrIndex) :- nl, write('Enter name as specified below for player '), write(CurrIndex), write(':'), nl, nl,
					print_characters,
					read(Character), 
					character_name(Character, Player),
					assign_player(CurrIndex, Player), 
					(NumPlayers > 1 -> 
						X is NumPlayers - 1, 
							Acc is CurrIndex + 1, 
							create_opponents(X, Acc)); 
					specify_self, init_record_card.

% returns the index of the human player
get_self(Index) :-
		self(Player), 
		player(Index, Player).
					
% add the character and corresponding turn order to the database  
assign_player(Index, Player) :- assert(player(Index, Player)). 

% %%%%%% GAME BEGINS

/* 
begins the game. this method is called after all player 
turns have been completed. defined as a "round." it also checks if
any accusations can be made.
*/
begin_game(NumPlayers) :- 
		writeln('Beginning next round...'), 
		accusation(NumPlayers), 
		game_loop(1, NumPlayers).

/*
Main game loop. Loops through the list of players using a counter. 
Menu is called and after it returns the game loop runs again on next player.
*/
game_loop(CurrIndex, NumPlayers) :- 
		nl, write(CurrIndex), player(CurrIndex, Name), write(', '), write(Name), write(' turn.'), 
		(self(Name) -> 
			write(' (Your turn!)'); 
			write(' (Opponents turn!)')), nl,
		menu(CurrIndex, NumPlayers), 
		(CurrIndex = NumPlayers) -> 
			begin_game(NumPlayers);
			(NextPlayer is CurrIndex + 1), 
		game_loop(NextPlayer, NumPlayers).

% %%%%%%% MAIN MENU

% entry point for the command menu system.
menu(CurrIndex, NumPlayers) :- 
		writeln('Please enter a command ("help" for list of commands)'),
		read(Command), 
		exec_command(CurrIndex, NumPlayers, Command).

% Quit the game by throwing an exception to prevent the termination of swipl process.
quit_game :- 
		writeln('Are you sure you want to exit the game?'),
		writeln('Type "yes" to exit or "no" to cancel'),
		read(X), 
		(X = 'yes' -> 
			throw(gameover)). 

% Execute the specified menu command.
exec_command(CurrIndex, NumPlayers, X) :- 
		player(CurrIndex, Player),
		(X = 'next' -> write('End turn.');
		X = 'help' -> print_commands, menu(CurrIndex, NumPlayers);
		X = 'record' -> record_card(CurrIndex), menu(CurrIndex, NumPlayers);
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
		self(Player) -> 
			print_hint; 
			writeln('No hints for opponents!').

% Retrieve the best hints from the database. Does not produce a room.	
print_hint :-
		writeln('-'),
		findall(X, weapon(X,-1,_), [C|Cs]), writeln(C),
		findall(Y, person(Y,-1,_), [D|Ds]), writeln(D), 
		writeln('-').
	
% Returns the current user and whether its computer or player turn.	
current_player(Player) :-
		write('Current player is '), write(Player),
		self(Player) -> 
			write(' (Your turn!)'); 
			write(' (Opponents turn!)').

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


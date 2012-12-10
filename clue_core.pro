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
exec_command(CurrIndex, NumPlayers, Command) :- 
		player(CurrIndex, Player),
		(Command == 'next' -> 
			writeln('End turn.');
			exec_command_helper(CurrIndex, NumPlayers, Player, Command),
				menu(CurrIndex, NumPlayers)).
				
exec_command_helper(CurrIndex, NumPlayers, Player, 'help') :- print_commands.
exec_command_helper(CurrIndex, NumPlayers, Player, 'record') :- record_card(CurrIndex).
exec_command_helper(CurrIndex, NumPlayers, Player, 'suggest') :- make_suggestion(CurrIndex, NumPlayers).
exec_command_helper(CurrIndex, NumPlayers, Player, 'history') :- history.
exec_command_helper(CurrIndex, NumPlayers, Player, 'suggestions') :- history_suggestions.
exec_command_helper(CurrIndex, NumPlayers, Player, 'cards') :- history_cards.
exec_command_helper(CurrIndex, NumPlayers, Player, 'players') :- history_players.
exec_command_helper(CurrIndex, NumPlayers, Player, 'accuse') :- accusation(NumPlayers).
exec_command_helper(CurrIndex, NumPlayers, Player, 'current') :- current_player(Player).
exec_command_helper(CurrIndex, NumPlayers, Player, 'hint') :- get_hint(Player).
exec_command_helper(CurrIndex, NumPlayers, Player, 'quit') :- quit_game.
exec_command_helper(CurrIndex, NumPlayers, Player, 'reset') :- reset_all, add_cards, begin_game(NumPlayers).
exec_command_helper(CurrIndex, NumPlayers, Player, Invalid) :- invalid_command.
			  
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
		(self(Player) -> 
			write(' (Your turn!)'); 
			write(' (Opponents turn!)')),
		nl.






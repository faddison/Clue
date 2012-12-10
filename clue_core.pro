:- dynamic(weapon/3), dynamic(person/3), dynamic(room/3), dynamic(player/2), dynamic(suggestion/4), dynamic(card/3), dynamic(player_list/2), dynamic(sugg_list/4).

/*
RUN clue. to begin the assistant.

alyssa dunn
fraser addison b4u7
*/

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
              X = 'record' -> record_card, menu(CurrIndex, NumPlayers);
			  X = 'suggest' -> make_suggestion(CurrIndex, NumPlayers), menu(CurrIndex, NumPlayers);
			  X = 'history' -> history, menu(CurrIndex, NumPlayers);
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


% Record the card given the player.
record_player_card(Player) :-
	writeln('Which type of card was it?'),
	print_cards,
	read(T), nl, nl, get_card(Player, T).

% add the specified card information to the database
record_card :-  nl,
	write('Which opponent showed you a card?'), nl, nl,
	print_characters,
	read(P), nl, nl,
	write('Which type of card was it?'), nl, nl,
	print_cards,
	(P == 's' -> X = 'Miss Scarlett';
	P == 'w' -> X  = 'Mrs. White';
	P == 'g' -> X  = 'Mr. Green';
	P == 'p' -> X  = 'Mrs. Peacock';
	P == 'pl'-> X  = 'Professor Plum';   
	P == 'm' -> X  = 'Colonel Mustard'; invalid_command),

	read(T), nl, nl, get_card(X, T).

% retrieve the correct card to add to the database.
get_card(P, T) :-
		player(PlayerKey, P),
		(T == 's' -> nl, write('Enter the card as specified below: '), nl, 
		print_characters,
		read(S), save_card_info_suspect(PlayerKey, S);
		T == 'w' -> nl, write('Enter the card as specified below: '), nl, 
		print_weapons, 
		read(W), save_card_info_weapon(PlayerKey,W); 
		T == 'r' -> nl, write('Enter the card as specified below: '), nl, 
		print_rooms,
		read(R), save_card_info_room(PlayerKey,R); 
		invalid_command).

% add the specified suspect card information to the database
save_card_info_suspect(P, S) :- 
		(S == 's' -> retract(person('Miss Scarlett', _, _)), assert(person('Miss Scarlett', P, []));
		S == 'w' -> retract(person('Mrs. White', _, _)), assert(person('Mrs. White', P, []));
		S == 'g' -> retract(person('Mr. Green', _, _)), assert(person('Mr. Green', P, [])); 
		S == 'p' -> retract(person('Mrs. Peacock', _, _)), assert(person('Mrs. Peacock', P, []));
		S == 'pl' -> retract(person('Professor Plum', _, _)), assert(person('Professor Plum', P, []));
		S == 'm' -> retract(person('Colonel Mustard', _, _)), assert(person('Colonel Mustard', P, []));
		invalid_command).

% add the specified weapon card information to the database		
save_card_info_weapon(P, W) :-
		(W == 'k' -> retract(weapon('knife', _, _)), assert(weapon('knife', P, [])); 
		W == 'c' -> retract(weapon('candlestick', _, _)), assert(weapon('candlestick', P, []));
		W == 'r' -> retract(weapon('revolver', _, _)), assert(weapon('revolver', P, []));
		W == 'ro' -> retract(weapon('rope', _, _)), assert(weapon('rope', P, [])); 
		W == 'l' -> retract(weapon('lead pipe', _, _)), assert(weapon('lead pipe', P, []));
		W == 'w' -> retract(weapon('wrench', _, _)), assert(weapon('wrench', P, []));
		invalid_command).

% add the specified room card information to the database
save_card_info_room(P, R) :-
		(R == 'k' -> retract(room('kitchen', _, _)), assert(room('kitchen', P, []));
		R == 'b' -> retract(room('ballroom', _, _)), assert(room('ballroom', P, [])); 
		R == 'c' -> retract(room('conservatory', _, _)), assert(room('conservatory', P, []));
		R == 'bi' -> retract(room('billiard room', _, _)), assert(room('billiard room', P, []));
		R == 'l' -> retract(room('library', _, _)), assert(room('library', P, []));
		R == 's' -> retract(room('study', _, _)), assert(room('study', P, []));
		R == 'h' -> retract(room('hall', _, _)), assert(room('hall', P, []));
		R == 'lo' -> retract(room('lounge', _, _)), assert(room('lounge', P, []));
		R == 'd' -> retract(room('dining room', _, _)), assert(room('dining room', P, []));
		invalid_command).



% %%%%%% MAKE A SUGGESTION

% Begins the suggestion process
make_suggestion(CurrIndex, NumPlayers) :- enter_suggestion(CurrIndex, NumPlayers), write('Suggestion Made'), nl.

% Enter a suggestion here
enter_suggestion(CurrIndex, NumPlayers) :-
		
		player(CurrIndex, P),

		write('Which Suspect was suggested?'), nl, nl,
		print_characters,
		read(S), nl, nl, 

		(S == 's' -> Z = 'Miss Scarlett';
		 S == 'w' -> Z = 'Mrs. White';
		 S == 'g' -> Z  = 'Mr. Green';
		 S == 'p' -> Z  = 'Mrs. Peacock';
		 S == 'pl'-> Z  = 'Professor Plum';   
		 S == 'm' -> Z  = 'Colonel Mustard';invalid_command),

		write('Which room was suggested?'), nl, nl,
		print_rooms,
		read(R), nl, nl, 

		(R == 'k' -> Y = 'kitchen';
		R == 'b' -> Y = 'ballroom'; 
		R == 'c' -> Y = 'conservatory';
		R == 'bi' -> Y = 'billiard room';
		R == 'l' -> Y = 'library';
		R == 's' -> Y = 'study';
		R == 'h' -> Y = 'hall';
		R == 'lo' -> Y = 'lounge';
		R == 'd' -> Y = 'dining room'; invalid_command),

		write('Which weapon was suggested?'), nl, nl,
		print_weapons,
		read(W), nl, nl,

		(W == 'k' -> I = 'knife'; 
		 W == 'c' -> I = 'candlestick';
		 W == 'r' -> I = 'revolver';
		 W == 'ro' -> I = 'rope'; 
		 W == 'l' -> I = 'lead pipe';
		 W == 'w' -> I = 'wrench'; invalid_command),
/*
		Z = 'Miss Scarlett',
		Y = 'kitchen',
		I = 'knife',
*/
		% add the suggestion to the database
		assert(suggestion(P,Y,Z,I)),
		update_cards(CurrIndex,NumPlayers,1,P,Y,Z,I).
		
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

% %%% CHECKING FOR AN ACCUSATION 

% alerts if accusation can be made or not
accusation(NumPlayers) :- 
        (check_accusation(NumPlayers) -> nl, write('Accusation can be made!'), print_accusation(NumPlayers), nl; 
        nl, write('No accusation available'), nl).

% checks to see that there is only one suspect, room and weapon card (indicated by -1s)
check_accusation(NumPlayers) :-    
        findall(card(X,Y,Z),card(_,-1,_),L), 
        (length(L,3) -> only_neg_weapon(NumPlayers), only_neg_room(NumPlayers), only_neg_suspect(NumPlayers);
        not_held_weapon(NumPlayers), not_held_room(NumPlayers), not_held_suspect(NumPlayers)).

% ensures only one weapon holds the -1 flag, repesenting nobody has the card    
only_neg_weapon(NumPlayers):- 
        findall(weapon(X,Y,Z), weapon(_,-1,_),L), length(L,1).

% ensures that length of DontHold is equal to the number of opponents in the game, repesenting nobody has the card
not_held_weapon(NumPlayers):- 
        findall(weapon(Name,Num,List), weapon(_,_,_), R), nl, check_length_w(R, NumPlayers).

% returns true if numplayers is correct length
check_length_w([], NumPlayers) :- 
        false.
check_length_w([weapon(Name, Num, List)|T], NumPlayers) :- 
        (grab_length_w(weapon(Name,Num,List), NumPlayers) -> nl, write('Goal Weapon Known: '), write(Name);
		check_length_w(T, NumPlayers)).
grab_length_w(weapon(Name,Num,List), NumPlayers) :- 
        weapon(Name,Num,List), X is NumPlayers - 1, length(List, X).


% ensures only one room holds the -1 flag, repesenting nobody has the card    
only_neg_room(NumPlayers) :- 
        findall(room(X,Y,Z),room(_,-1,_),L), length(L,1).

% ensures that length of DontHold is equal to the number of opponents in the game, repesenting nobody has the card
not_held_room(NumPlayers) :- 
        findall(room(Name,Num,List), room(_,_,_), R), check_length_r(R, NumPlayers).

% returns true if numplayers is correct length
check_length_r([], NumPlayers) :- 
        false.
check_length_r([room(Name, Num, List)|T], NumPlayers) :- 
        (grab_length_r(room(Name, Num, List), NumPlayers) -> nl, write('Goal Room Known: '), write(Name); check_length_r(T, NumPlayers)).
grab_length_r(room(Name,Num,List), NumPlayers) :- 
        room(Name,Num,List), X is NumPlayers - 1, length(List, X).


% ensures only one suspect holds the -1 flag, repesenting nobody has the card    
only_neg_suspect(NumPlayers):- 
        findall(person(X,Y,Z),person(_,-1,_),L), length(L,1).

% ensures that length of DontHold is equal to the number of opponents in the game, repesenting nobody has the card
not_held_suspect(NumPlayers):- 
        findall(person(Name,Num,List), person(_,_,_), R), check_length_s(R, NumPlayers).

% returns true if numplayers is correct length
check_length_s([], NumPlayers) :- 
        false.

check_length_s([person(Name, Num, List)|T], NumPlayers) :- 
        (grab_length_s(person(Name,Num,List), NumPlayers) -> nl, write('Goal Suspect Known: '), write(Name);check_length_s(T, NumPlayers)).

grab_length_s(person(Name,Num,List), NumPlayers) :- 
        person(Name,Num,List), X is NumPlayers - 1, length(List, X).


% %%%%%% PRINT ACCUSATION

% prints accusaton in case where all accused cards are -1
print_accusation(NumPlayers):-
		findall(card(X,-1,Z),card(_,-1,_),List),
		(length(List,3) -> acc_list_neg; 
		write('')).

acc_list_neg:- write(' '), nl, write('Accuse the Folowing Cards'), nl,
		findall(card(X,-1,Z),card(X,-1,Z),AccList), 
		maplist(writeln, AccList), nl.



% %%%%% CURRENT GAME HISTORY

% prints out the history of card information that we know
history :- nl,
		writeln('Current Card Information: '),
			findall(card(X,Y,Z), card(X,Y,Z), AllCards), maplist(writeln, AllCards), nl,
		writeln('Current Player Information: '),
			findall(player(N, T), player(N, T), AllPlayers), maplist(writeln, Allplayers), nl,
		writeln('Previous Suggestions: '),
			findall(suggestion(P,X,Y,Z), suggestion(P,X,Y,Z), AllSuggestions), maplist(writeln, AllSuggestions).



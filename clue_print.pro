
% Indicate that the given argument was invalid in some way.
invalid_command :- 
		writeln('Invalid command! Please try again.').

% prints out the list of available weapons and corresponding abbreviation
print_weapons :-       
		writeln('"k". - knife'),
		writeln('"c". - candlestick'),
		writeln('"r". - revolver'),
		writeln('"ro". - rope'),
		writeln('"l". - lead pipe'),
		writeln('"w". - wrench').
		
% prints out the list of rooms and corresponding abbreviation
print_rooms :-		
		writeln('"k". - kitchen'),
		writeln('"b". - ballroom'),
		writeln('"c". - conservatory'),
		writeln('"bi". - billiard room'),
		writeln('"l". - library'),
		writeln('"s". - study'),
		writeln('"h". - hall'),
		writeln('"lo". - lounge'),
		writeln('"d". - dining room').
		
% prints a list of all game characters with corresponding abbreviation
print_characters :- 
		writeln('"s". - Miss Scarlett'),
		writeln('"m". - Col. Mustard'),  
		writeln('"w". - Mrs. White'), 
		writeln('"g". - Mr. Green'), 
		writeln('"p". - Mrs. Peacock'), 
		writeln('"pl". Prof. Plum').
		
% prints out the list of cards and corresponding abbreviation		
print_cards :-
		writeln('"s". - suspect card'),
		writeln('"w". - weapon card'), 
		writeln('"r". - room card').
		
% Print the list of available menu commands.	
print_commands :-
		writeln('"next"    		- finish the turn.'),
        writeln('"record"  		- record a card shown to you.'),
        writeln('"suggest" 		- record a suggestion.'),
        writeln('"history" 		- list the database of events.'),
		writeln('"suggestions" 	- list all the suggestions.'),
		writeln('"cards" 		- list all the cards.'),
		writeln('"players" 		- list all the players.'),
		writeln('"accuse"  		- check if an accusation can be made.'),
        writeln('"restart"   	- clears all current game information.'),
		writeln('"hint"   		- provides a suggestion hint.'),
		writeln('"current"   	- shows who the current player is.'),
		writeln('"quit" 	 	- end game and stop the program.').
		
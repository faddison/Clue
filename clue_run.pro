:- compile(clue_db).
:- compile(clue_print).
:- compile(clue_accuse).
:- compile(clue_suggest).
:- compile(clue_record).
:- compile(clue_core).

% %%%%% START GAME

% test method to bypass manual player instantiation
cluetest0 :-  
        reset_all,
		setup,
        add_cards,
		assert(player(1, 'Miss Scarlett')),
		assert(player(2, 'Mr. Green')),
		assert(player(3, 'Mrs. Peacock')),
		assert(self('Mr. Green')),
		begin_game(3).
		
% test method 1
cluetest1 :-  
        reset_all,
		setup,
        win_condition1,
		assert(player(1, 'Miss Scarlett')),
		assert(player(2, 'Mr. Green')),
		assert(player(3, 'Mrs. Peacock')),
		assert(self('Mr. Green')),
		begin_game(3).

% test method 2	
cluetest2 :-  
        reset_all,
		setup,
        win_condition2,
		assert(player(1, 'Miss Scarlett')),
		assert(player(2, 'Mr. Green')),
		assert(player(3, 'Mrs. Peacock')),
		assert(self('Mr. Green')),
		begin_game(3).

% main program entry point		
clue :- 
		reset_all,
		setup ,
		add_cards, 
		writeln('Clue Assistant: Version 1'),
		create_players.
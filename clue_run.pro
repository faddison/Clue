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
clue :- reset_all,setup ,add_cards, write('Clue Assistant: Version 1'), nl, create_players.
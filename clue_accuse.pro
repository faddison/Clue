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

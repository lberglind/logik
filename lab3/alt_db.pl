verify(Input) :-
	see(Input), read(T), read(L), read(S), read(F), seen,
	check(T, L, S, [], F).

check(T, L, S, U, F).
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid. %
% (T,L), S |- F %U
% To execute: consult('your_file.pl'). verify('input.txt').
% Literals
%check(_, L, S, [], X) :- ... %check(_, L, S, [], neg(X)) :- ...
% And

checkAllPaths(T, L, [State | Next], U, F) :-
	check(T, L, State, U, F),
	checkAll(T, L, Next, [State | U], F).

checkExistsPath(T, L, [State | Next], U, F) :-
	check(T, L, State, U, F) ;
	checkExistsPath(T, L, Next, [State | U], F).
	
% And
check(T, L, S, [], and(F,G)) :- 
	check(T, L, S, U, F),
	check(T, L, S, U, G).
% Or
check(T, L, S, U, Or(F, G)) ;-
	check(T, L, S, U, F) ;
	check(T, L, S, U, G).

% Atom
check(T, L, S, U, F) :-
	stateHasLabel(L, S, F).
% neg
check(T, L, S, U, neg(F)) :-
	\+ stateHasLabel(L, S, F).

stateHasLabel(L, S, F) :-
	member([S, Labels], L),
	member(F, Labels).
% AX
check(T, L, S, U, ax(F)) :-
	
% EX

% AG
% EG
% EF
% AF

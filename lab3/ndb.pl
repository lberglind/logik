verify(InputFileName) :-
	abolishAll(),
	see(InputFileName),
	read(Adjacencies), read(States), read(State), read(Formula),
	seen,
	assertTransitions(Adjacencies),
	assertStates(States),
	check(State, [], Formula), !,
	abolishAll().
	
assertTransitions([]).

assertTransitions([Head | Tail]) :- 
	assertTransitionsHelper(Head),
	assertTransitions(Tail).

assertTransitionsHelper([Node | [To | _]]) :-
	assertTransition(Node, To).

assertTransition(_, []).
assertTransition(Node, [Head | Tail]) :-
	assertz(transition(Node, Head)),
	assertTransition(Node, Tail).

assertStates([]).
assertStates([Head | Tail]) :-
	assertState(Head),
	assertStates(Tail).

assertState([Node | [State | _]]) :-
	assertz(state(Node, State)). 


checkAllPaths(State, U, Formula) :-
	findall(Next, transition(State, Next), L),
	checkAllPathsH(L, U, Formula).

checkAllPathsH([], _, _).

checkAllPathsH([Head | Tail], [], Formula) :-
	check(Head, [], Formula),
	checkAllPathsH(Tail, [], Formula).

checkAllPathsH([Head | Tail], U, Formula) :-
	check(Head, U, Formula),
	checkAllPathsH(Tail, [Head| U], Formula).

checkExistsPath(State, U, Formula) :-
	findall(Next, transition(State, Next), L),
	checkExistsPathH(L, U, Formula).

checkExistsPathH([], _, _) :- fail.

checkExistsPathH([Head | Tail], U, Formula) :-
	check(Head, U, Formula) ;
	checkExistsPathH(Tail, [Head | U], Formula).

% Atom
check(State, _, Formula) :-
	stateContains(State, Formula).

% Neg
check(State, _, neg(Formula)) :-
	\+ stateContains(State, Formula).

% And
check(State, _, and(F, G)) :-
	check(State, [], F), check(State, [], G).

% Or
check(State, _, or(F, G)) :-
	check(State, [], F) ; check(State, [], G).

% AX
check(State, [], ax(Formula)) :-
	checkAllPaths(State, [], Formula).

% EX
check(State, _, ex(Formula)) :-
	checkExistsPath(State, [], Formula).

% AG
check(State, U, ag(_)) :-
	member(State, U).

check(State, U, ag(Formula)) :-
	check(State, [], Formula),
	checkAllPaths(State, [State | U], ag(Formula)).

% EG
check(State, U, eg(_)) :-
	member(State, U).
check(State, U, eg(Formula)) :-
	\+ member(State, U),
	check(State, [], Formula),
	checkExistsPath(State, [State | U], eg(Formula)).

% EF
check(State, U, ef(Formula)) :-
	\+ member(State, U),
	check(State, [], Formula).

check(State, U, ef(Formula)) :-
	\+ member(State, U),
	checkExistsPath(State, [State | U], ef(Formula)).

% AF
check(State, U, af(Formula)) :-
	\+ member(State, U),
	check(State, [], Formula).
check(State, U, af(Formula)) :-
	\+ member(State, U),
	checkAllPaths(State, [State | U], af(Formula)).

stateContains(Node, Formula) :-
	state(Node, L),
	member(Formula, L).

abolishAll() :- abolish(transition/2), abolish(state/2).

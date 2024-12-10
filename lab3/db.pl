check(InputFileName) :-
	see(InputFileName),
	read(Adjacencies), read(States),
	seen,
	assertTransition(Adjacencies).
	
assertTransitions([]).

assertTransitions([Head | Tail]) :- 
	write("Head: "), write(Head), write(", Tail: "), write(Tail), write("\n"),
	assertTransitionsHelper(Head),
	assertTransitions(Tail).

assertTransitionsHelper([Node | [To | _]]) :-
	write("Node: "), write(Node), write("\n"),
	write("To: "), write(To), write("\n"),
	assertTransition(Node, To).

assertTransition(_, []).
assertTransition(Node, [Head | Tail]) :-
	write("Assert Node: "), write(Node), write(", Head: "), write(Head), 
	write("\n"),
	assertz(transition(Node, Head)),
	assertTransition(Node, Tail).

assertStates([]).
assertStates([Head | Tail]) :-
	assertState(Head),
	assertStates(Tail).

assertState([Node | [State | Tail]]) :-
	assertz(state(Node, State)). 

ex(Node, Formula) :-
	once(x(Node,Formula)).
x(Node, Formula) :-
	transition(Node, Next),
	stateContains(Next, Formula).

ax(Node, Formula) :-
	\+once(\+x(Node, Formula)).
%x(Node, Formula) :-
%	transition(Node, Next),
%	stateContains(Next, Formula).

ef(Node, Formula) :-
	once(f(Node, [], Formula)).

af(Node, Formula) :-
	\+once(\+f(Node, [], Formula)).
f(Node, U, Formula) :-
	write(Node), write("\n"),
	\+member(Node, U),
	stateContains(Node, Formula) ;
	(transition(Node, Next), f(Next, [Node | U], Formula)).

eg(Node, U, Formula) :- true.


stateContains(Node, Formula) :-
	state(Node, L),
	write(L), write("\n"),
	member(Formula, L).


check(InputFileName) :-
	see(InputFileName),
	read(Adjacencies), read(States),
	seen,
	assertTransition(Adjacencies).
	
assertTransitions([]).

assertTransitions([Head | Tail]) :- 
	%write("Head: "), write(Head), write(", Tail: "), write(Tail), write("\n"),
	assertTransitionsHelper(Head),
	assertTransitions(Tail).

assertTransitionsHelper([Node | [To | _]]) :-
	%write("Node: "), write(Node), write("\n"),
	%write("To: "), write(To), write("\n"),
	assertTransition(Node, To).

assertTransition(_, _).
assertTransition(Node, [Head | Tail]) :-
	%write("Assert Node: "), write(Node), write(", Head: "), write(Head), 
	%write("\n"),
	assertz(transition(Node, Head)),
	assertTransition(Node, Tail).

assertStates([]).
assertStates([Head | Tail]) :-
	assertState(Head),
	assertStates(Tail).

assertState([Node | [State | Tail]]) :-
	assertz(state(Node, State)). 

axTest(Node, Formula) :-
	ax(Node, Formula).
ax(Node, Formula) :-
	transition(Node, Next),
	%call(stateContains
	stateContains(Next, Formula).

%ax_helper(Node, Formula) :-


stateContains(Node, Formula) :-
	state(Node, L),
	member(Formula, L).


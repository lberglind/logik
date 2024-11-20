neg(neg(imp(p,neg(p)))).
neg(p).

and(p, q).

%row(1,neg(neg(imp(p,neg(p))))).

parse([Row, Formula, Rule]) :- 
	Rule,
	valid(Row, Formula, Rule).

valid(Row, Formula, Rule(Rr)) :-
	assertz(row(Row,Formula)).

valid(Row, Formula, premise) :-
	assertz(row(Row,Formula)).
premise.

negnegel(Formula, Rr) :-
	row(Rr, neg(neg(L))),
	L == Formula.

boxParse([[Row, Formula, assumption], RefList) :-
	assertz(boxBegin(Row, Formula)).

boxParse([[Row, Formula, Rule]|Tail], RefList) :-
	valid(Row, Formula, Rule),
	assertz(row(Row, Formula), Ref),
	boxParse(Tail, [Ref|RefList]).

boxParse([Row, Formula, Rule]) :- 



negnegint(Row, P) :-
	row(Row,L),
	neg(neg(L)) == P.

%negnegel(Row, P) :-
%	row(Row,neg(neg(_))),
%	neg(neg(P)).

copy(Row, P) :-
	row(Row,L),
	L == P.

andint(Row1,Row2,P) :-
	row(Row1,A),
	row(Row2,B),
	and(A,B) == P.

andel1(Row, P) :-
	row(Row, and(L,_)),
	L == P.

andel2(Row, P) :-
	row(Row, and(_,L)),
	L == P.

orint1(Row, P) :-
	row(Row, L),
	or(L,_) == P.

orint2(Row, P) :-
	row(Row, L),
	or(_,L) == P.

%orel(Row, Interval1, Interval2, P) :-
%	false.

%impint(Interval, P) :-
%	false.

impel(Row1, Row2, P) :-
	row(Row1,A),
	row(Row2,imp(B,C)),
	A == B,
	C == P.

%negint(Interval, P) :-
%	false.

%negel(Row1, Row2, P) :-
%	false.

%contel(Row1, P) :-
%	false.


%mt(Row1, Row2, P) :-
%	false.

%pbc(Interval, P) :-
%	false.

%lem(P) :-
%	false.

%negnegel(Row, P) :-
%	row(Row,neg(neg(_))),
%	row(1,neg(neg(L))),
%	L == P.




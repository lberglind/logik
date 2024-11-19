% En lista av premisser (vänsta delen av sekventen)
%[neg(neg(imp(p, neg(p))))].

% Målet (högra delen av sekventen).
%neg(p).

% Beviset
%[
%    [1, neg(neg(imp(p,neg(p)))),        premise     ],
%    [2, imp(p, neg(p)),                 negnegel(1) ],
%    [
%        [3, p,                          assumption  ],
%        [4, neg(p),                     impel(3,2)  ],
%        [5, cont,                       negel(3,4)  ]
%    ],
%    [6, neg(p),                         negint(3,5) ]
%].

verify(InputFileName) :- 
    see(InputFileName),
    read(Prems), read(Goal), read(Proof),
    seen,
    valid_proof(Prems, Goal, Proof).

valid_proof(Prems, Goal, Proof) :-
    last(Proof, Goal),
    check_steps(Prems, Goal, Proof, Proof).

check_steps(_, _, [], _).

%check_steps(Prems, Goal, [Line|[]], Proof) :-
%    (checkPremise(Line, Prems) ;
%    checkRule(Line, Proof) ;
%    box(Prems, Line, Proof)),
%    Line == [_, Goal, _].

check_steps(Prems, Goal, [Line|Rest], Proof) :-
    (checkPremise(Line, Prems) ;
    checkRule(Line, Proof) ;
    box(Prems, Line, Proof)),
    check_steps(Prems, Goal, Rest, Proof).



% Premise rule
checkPremise([_, X, premise], Prems) :-
    member(X, Prems).

% And introduction rule
checkRule([LineNum, and(X, Y), andint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A, X, _], Proof),
    member([B, Y, _], Proof).

% Or introduction 1
checkRule([LineNum, or(X, _), orint1(A)], Proof) :-
    LineNum > A,
    member([A, X, _], Proof).

% Or introduction 2
checkRule([LineNum, or(_, Y), orint2(B)], Proof) :-
    LineNum > B,
    member([B, Y, _], Proof).

% Implication introduction
checkRule([LineNum, imp(X, Y), impint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([[A, X, assumption]|Box], Proof),
    boxLast([[A,X,_]|Box], Y, B).

% Negation introduction
checkRule([LineNum, neg(X), negint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([[A, X, assumption]|Box], Proof),
    boxLast([[A,X,_]|Box], cont, B).

% And elimination 1
checkRule([LineNum, X, andel1(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, and(X,_), _], Proof).

% And elimination 2
checkRule([LineNum, Y, andel2(B)], Proof) :-
    checkLines(LineNum, B),
    member([B, and(_,Y), _], Proof).

% Implication elimination
checkRule([LineNum, X, impel(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A,Y,_], Proof),
    member([B, imp(Y,X), _], Proof).

% Or elimination
checkRule([LineNum, X, orel(A, B, C, D, E)], Proof) :-
    checkLines(LineNum, A, B, C, D, E),
    member([A, or(U,V), _], Proof),
    member([[B, U, assumption]|Box], Proof),
    boxLast([[B,U,_]|Box], X, C),
    member([[D, V, assumption]|Box2], Proof),
    boxLast([[D,V,_]|Box2], X, E).

% Negation elimination
checkRule([LineNum, cont, negel(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A,X,_], Proof),
    member([B, neg(X), _], Proof).

% Falsum elimination
checkRule([LineNum, _, negel(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, cont, _], Proof).

% double negation introduction  negnegint
checkRule([LineNum, neg(neg(X)), negnegint(A)], Proof) :-
    checkLines(LineNum, A),
    member([A,X,_], Proof).

% double negation elimination negnegel
checkRule([LineNum, X, negnegel(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, neg(neg(X)), _], Proof).

% MT
checkRule([LineNum, neg(X), mt(A,B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A, imp(X, Y), _], Proof),
    member([B, neg(Y), _], Proof).

% PBC
checkRule([LineNum, X, pbc(A,B)], Proof) :-
    checkLines(LineNum, A, B),
    member([[A, neg(X), _]|Box], Proof),
    boxLast([[A, neg(X), _]|Box], cont, B).

% Copy
checkRule([LineNum, X, copy(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, X, _], Proof).

% LEM
checkRule([_, or(X, neg(X)), lem],_).


checkLines(Num, A) :-
    Num > A.
checkLines(Num, A, B) :-
    Num > A,
    Num > B.
checkLines(Num, A, B, C, D, E) :-
    Num > A,
    Num > B,
    Num > C,
    Num > D,
    Num > E.
box(_, [BoxStart|_], _) :-
    BoxStart = [_,_,assumption].

box(Prems, [BoxStart|BoxTail], Proof) :-
    BoxStart = [_ , _, assumption],
    append([BoxStart|BoxTail], Proof, ProofWBox),
    check_steps(Prems, _, BoxTail, ProofWBox).




%check_rule(_, LineNum, Formula, impel(LineA, LineB), Proof) :-
%    formula_at(LineA, imp(Ant, Formula), Proof),
%    formula_at(LineB, Ant, Proof).

% Base case for checking last row of box
boxLast([[RowB, VarY, _]], VarY, RowB).

boxLast([_|T], VarY, RowB) :-
    boxLast(T, VarY, RowB).

% Traverse to last element and check if it is the same as Goal

last([[_, Goal, Rule]], Goal) :-
    Rule \= assumption.

last([_|Rest], Goal) :-
    last(Rest, Goal).

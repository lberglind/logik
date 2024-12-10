% Read input file, and check the proof

verify(InputFileName) :- 
    see(InputFileName),
    read(Prems), read(Goal), read(Proof),
    seen,
    validProof(Prems, Goal, Proof),
    write(Proof | '\n').

validProof(Prems, Goal, Proof) :-
    last(Proof, Goal),
    checkSteps(Prems, Goal, Proof, Proof).

% Base step
checkSteps(_, _, [], _).

% Recursively go through every row of the proof from top to bottom and check what Rule is used
% and if it is correct.
checkSteps(Prems, Goal, [Line|Rest], Proof) :-
    (checkPremise(Line, Prems) ;
    checkRule(Line, Proof) ;
    newBox(Prems, Line, Proof)),
    checkSteps(Prems, Goal, Rest, Proof).


% Check box
newBox(Prems, [BoxStart|BoxTail], Proof) :-
    BoxStart = [_ , _, assumption],
    append([BoxStart|BoxTail], Proof, ProofWBox),
    checkSteps(Prems, _, BoxTail, ProofWBox).


% Traverse to last element and check if it is the same as Goal
last([[_, Goal, Rule]], Goal) :-
    Rule \= assumption.

last([_|Rest], Goal) :-
    last(Rest, Goal).

%Traverse to last element and check if it has the correct ending according to rules
boxLast([[RowB, VarY, _]], VarY, RowB).

boxLast([_|T], VarY, RowB) :-
    boxLast(T, VarY, RowB).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Premise rule, premise
checkPremise([_, X, premise], Prems) :-
    member(X, Prems).

% And introduction, andint
checkRule([LineNum, and(X, Y), andint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A, X, _], Proof),
    member([B, Y, _], Proof).

% Or introduction 1, orint1
checkRule([LineNum, or(X, _), orint1(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, X, _], Proof).

% Or introduction 2, orint2
checkRule([LineNum, or(_, Y), orint2(B)], Proof) :-
    checkLines(LineNum, B),
    member([B, Y, _], Proof).

% Implication introduction, impint
checkRule([LineNum, imp(X, Y), impint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([[A, X, assumption]|Box], Proof),
    boxLast([[A,X,_]|Box], Y, B).

% Negation introduction, negint
checkRule([LineNum, neg(X), negint(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([[A, X, assumption]|Box], Proof),
    boxLast([[A,X,_]|Box], cont, B).

% And elimination 1, andel1
checkRule([LineNum, X, andel1(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, and(X,_), _], Proof).

% And elimination 2, andel2
checkRule([LineNum, Y, andel2(B)], Proof) :-
    checkLines(LineNum, B),
    member([B, and(_,Y), _], Proof).

% Implication elimination, impel
checkRule([LineNum, X, impel(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A,Y,_], Proof),
    member([B, imp(Y,X), _], Proof).

% Or elimination, orel
checkRule([LineNum, X, orel(A, B, C, D, E)], Proof) :-
    checkLines(LineNum, A, B, C, D, E),
    member([A, or(U,V), _], Proof),
    member([[B, U, assumption]|Box], Proof),
    boxLast([[B,U,_]|Box], X, C),
    member([[D, V, assumption]|Box2], Proof),
    boxLast([[D,V,_]|Box2], X, E).

% Negation elimination, negel
checkRule([LineNum, cont, negel(A, B)], Proof) :-
    checkLines(LineNum, A, B),
    member([A,X,_], Proof),
    member([B, neg(X), _], Proof).

% Falsum elimination, contel
checkRule([LineNum, _, contel(A)], Proof) :-
    checkLines(LineNum, A),
    member([A, cont, _], Proof).

% double negation introduction,  negnegint
checkRule([LineNum, neg(neg(X)), negnegint(A)], Proof) :-
    checkLines(LineNum, A),
    member([A,X,_], Proof).

% double negation elimination, negnegel
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



% Check so no rule calls for rows that are defined after the current row
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





verify(Input) :-
        see(Input), 
        read(V), read(L), read(S), read(F), 
        seen, 
        check(V, L, S, [], F), !.

%check_all_states Går igenom alla tillstånd i en lista och kontrollerar att F gäller

% Faktum
check_all_states(_, _, [], _, _).

% Hanterar fall när U inte är tom.
check_all_states(V, L, [H|T], U, X) :-
        check(V, L, H, U, X),
        check_all_states(V, L, T, [H|U], X).

% Hanterar fall när U är tom.
check_all_states(V, L, [H|T], [], X) :-
        check(V, L, H, [], X),
        check_all_states(V, L, T, [], X).

% check_existing Går igenom en lista och returnerar true om F gäller i minst ett tillstånd.
% Faktum
check_existing(_, _, [], _, _) :- fail.

% Hanterar fall när U inte är tom.
check_existing(V, L, [H|T], U, X) :-
        check(V, L, H, U, X);
        check_existing(V, L, T, [H|U], X).
        
% Hanterar fall när U är tom.
check_existing(V, L, [H|T], [], X) :-
        check(V, L, H, [], X);
        check_existing(V, L, T, [], X).



%% Literals
% p
check(_, L, S, [], X) :- 
        member([S, Ls], L),
        member(X, Ls).

% neg p
check(_, L, S, [], neg(X)) :-
        member([S, Ls], L),
        \+member(X, Ls).




% And
check(V, L, S, [], and(F,G)) :- 
        check(V, L, S, [], F),
        check(V, L, S, [], G).

% Or
check(V, L, S, [], or(F,G)) :- 
        check(V, L, S, [], F);
        check(V, L, S, [], G).


% AX (Alla nästa tillstånd)
check(V, L, S, [], ax(F)) :-
        member([S, Ls], V),
        check_all_states(V, L, Ls, [], F).

% EX (Det finns ett nästa tillstånd)
check(V, L, S, [], ex(F)) :-
        member([S, Ls], V),
        check_existing(V, L, Ls, [], F).

%AG (Alltid globalt)
% AG1, S är i U
check(_, _, S, U, ag(_)) :-
        member(S, U).

% AG2, S är INTE i U
check(V, L, S, U, ag(F)) :-
        \+ member(S, U),
        check(V, L, S, [], F),
        member([S, Ls], V),
        check_all_states(V, L, Ls, [S|U], ag(F)).

%EG (Det finns en väg där alltid F gäller)
% EG1
check(_, _, S, U, eg(_)) :-
        member(S, U).

% EG2
check(V, L, S, U, eg(F)) :- 
        \+ member(S, U),
        check(V, L, S, [], F),
        member([S, Ls], V),
        check_existing(V, L, Ls, [S|U], eg(F)).


% EF (Det finns en väg där F gäller någon gång)
%  EF1
check(V, L, S, U, ef(F)) :- 
        \+ member(S, U),
        check(V, L, S, [], F).

% EF2
check(V, L, S, U, ef(F)) :- 
        \+ member(S, U),
        member([S, Ls], V),
        check_existing(V, L, Ls, [S|U], ef(F)).

%AF (Alla vägar leder till F någon gång)
% AF1
check(V, L, S, U, af(F)) :-
        \+ member(S, U),
        check(V, L, S, [], F).

% AF2
check(V, L, S, U, af(F)) :- 
        \+ member(S, U),
        member([S, Ls], V),
        check_all_states(V, L, Ls, [S|U], af(F)).

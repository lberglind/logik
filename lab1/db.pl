
%Betrakta denna fråga till ett Prologsystem:
%
%?- T=f(a,Y,Z), T=f(X,X,b).
%
%Vilka bindningar presenteras som resultat?
%
%T = f(a, a, b),
%Y = X, X = a,
%Z = b.
%
%
%Ge en kortfattad förklaring till ditt svar!
%
%f(a,Y,Z) definierar att index 0 ska vara a men Y och Z är inte definierade än.
%f(X,X,b) definierar att index 3 är b samt att index 0 och 1 har samma värde.
%Eftersom den första delen av frågan redan definierat index 0 till a måste således index 1 också vara a.
%Därför blir T = f(a, a, b).
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

appendEl(X, [], [X]).
appendEl(X, [H | T], [H | Y]) :-
    appendEl(X, T, Y).

nth(N,L,E) :- nth(1,N,L,E).
nth(N,N,[H|_],H).
nth(K,N,[_|T],H) :- K1 is K+1, nth(K1,N,T,H).

subset([], []).
subset([H|T], [H|R]) :- subset(T, R).
subset([_|T], R) :- subset(T, R).

select(X,[X|T],T).
select(X,[Y|T],[Y|R]) :- select(X,T,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%list([]).
%list([H|T]) :- list(T).

remove_duplicates([], []).
remove_duplicates([], _, []).

remove_duplicates(T, E) :-
    remove_duplicates(T,[],E).

remove_duplicates([H|T], L, [H|E]) :-
    \+ member(H, L),
    remove_duplicates(T, [H|L], E). 

remove_duplicates([H|T], L, E) :-
    member(H, L),
    remove_duplicates(T, L, E).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

partstring(A, L, F) :-
    partstring_helper(A, F, 0), 
    length(F, L), 
    L =\= 0.

partstring_helper([], [], _).
partstring_helper([_|T], F, 0) :-
    partstring_helper(T, F, 0). % Hoppa över element

partstring_helper([H|T], [H|F], _) :-
    partstring_helper(T, F, 1). % Ta element

partstring_helper([_|_], F, 1) :-
    partstring_helper([], F, 0). % Avbryt partstring. det vi får ut i F är klart.

partstrings(List, L, F) :- append(_, L2, List), append(F, _, L2), length(F,L), F \= []. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edge(a,b).
edge(a,d).
edge(a,g).
edge(b,c).
edge(b,h).
edge(c,d).
edge(d,g).
edge(e,c).
edge(e,i).
edge(f,d).
edge(g,f).
edge(h,e).



% Om Start och slutnoden är samma så är listan över alla noder endast Start-noden.
path(X, X, [X]).

% Kör traverse och lägg till en visited lista []
path(A, B, Path) :-
    traverse(A, B, Path, []).

% Basfall. Om Start o slut är samm punkt så lägger vi till den punkten i path.
traverse(X, X, [X], _).

% Traversera genom lista. Om inte en nod redan är besökt läggs den till i visited listan och
% vi kör traverse från den noden.
traverse(A, B, [A|Path], Visited) :-
    edge(A,X),
    \+member(X, Visited),
    traverse(X, B, Path, [A|Visited]).



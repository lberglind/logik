%Since the "check" predicate isn't written consecutive, I use "discontiguous". 
%"check" has the predicate "ax", "ag" and "af" inbetween it's instances.
%Thereof the problem can otherwise be solved by moving thoose predicates down after "check" instead.
:- discontiguous check/5.                   

verify(Input):-
    see(Input), read(Trans), read(Labels), read(CurrState), read(Formula), seen,
    check(Trans, Labels, CurrState, [], Formula).
    % check(T, L, S, U, F)
    % T - The transitions in form of adjacency lists
    % L - The Labeling
    % S - Current state
    % U - Currently recorded states
    % F - CTL Formula to check.
    %
    % Should evaluate to true if the sequent below is valid.
    %
    % (T,L), S |- F
    % U
    % To execute: consult('your_file.pl'). verify('input.txt').

%----------------------------------------------------------------------------------
% And
check(Trans, Labels, CurrState, [], and(F,G)):-
    check(Trans, Labels, CurrState, [], F),
    check(Trans, Labels, CurrState, [], G), !.
%-----------------------------------------------------------------------------------
% Or
check(Trans, Labels, CurrState, [], or(F,G)):-
    check(Trans, Labels, CurrState, [], F) ;
    check(Trans, Labels, CurrState, [], G), !.

%-----------------------------------------------------------------------------------
% AX
check(Trans, Labels, CurrState, [], ax(F)):-   %Saves all the next states for this current state,
    member([CurrState, Neighbors], Trans),     %then and checks them all one by one for formula F
    ax(Trans, Labels, Neighbors, [], F), !.
  
ax(Trans, Labels, [S0|[]], [], F):-            %Checks all the next states with formula F
    check(Trans, Labels, S0, [], F), !.

ax(Trans, Labels, [S0|Tail], [], F):-
    check(Trans, Labels, S0, [], F),
    ax(Trans, Labels, Tail, [], F), !.
%-----------------------------------------------------------------------------------
% EX
check(Trans, Labels, CurrState, [], ex(F)):-   %With member checks every next state of the current state.
    member([CurrState, Neighbors], Trans),
    member(S0, Neighbors),
    check(Trans, Labels, S0, [], F), !.
%-----------------------------------------------------------------------------------
% AG
check(_, _, CurrState, PrevState, ag(_)):-
    member(CurrState, PrevState), !.

check(Trans, Labels, CurrState, PrevState, ag(F)):-
    \+ member(CurrState, PrevState),
    check(Trans, Labels, CurrState, [], F),
    member([CurrState, Neighbors], Trans),                  
    ag(Trans, Labels, Neighbors, [CurrState|PrevState], F), !.

ag(Trans, Labels, [S0|[]], PrevState, F):-                  
    check(Trans, Labels, S0, PrevState, ag(F)), !.             
                                                            
ag(Trans, Labels, [S0|Tail], PrevState, F):-                
    check(Trans, Labels, S0, PrevState, ag(F)),             
    ag(Trans, Labels, Tail, PrevState, F), !.
%-----------------------------------------------------------------------------------
% EG
check(_, _, CurrState, PrevState, eg(_)):-
    member(CurrState, PrevState), !.

check(Trans, Labels, CurrState, PrevState, eg(F)):-
    \+ member(CurrState, PrevState),
    check(Trans, Labels, CurrState, [], F),
    member([CurrState, Neighbors], Trans),
    member(S0, Neighbors),
    check(Trans, Labels, S0, [CurrState|PrevState], eg(F)), !.
%-----------------------------------------------------------------------------------
% EF
check(Trans, Labels, CurrState, PrevState, ef(F)):-         %Checks this state for the formula F,
    \+ member(CurrState, PrevState),                        %because then EF is accurate and the recursion ends here.
    check(Trans, Labels, CurrState, [], F), !.
    
check(Trans, Labels, CurrState, PrevState, ef(F)):-         %Saves the next states of the current state, then one by one 
    \+ member(CurrState, PrevState),                        %checks the labels for that state by callin the previous predicate for EF.
    member([CurrState, Neighbors], Trans),
    member(S0, Neighbors),
    check(Trans, Labels, S0, [CurrState|PrevState], ef(F)), !.
%-----------------------------------------------------------------------------------
% AF
check(Trans, Labels, CurrState, PrevState, af(F)):-         %First checks if we've been in this state. Then checks this state for
    \+ member(CurrState, PrevState),                        %the formula F, because then AF is accurate and the recursion ends here.
    check(Trans, Labels, CurrState, [], F), !.
    
check(Trans, Labels, CurrState, PrevState, af(F)):-         %First checks if we've been in this state. Then Saves all the 
    \+ member(CurrState, PrevState),                        %next states of the current state, then sends all next states
    member([CurrState, Neighbors], Trans),                  %in the form of a list to check that AF applies for every state.
    af(Trans, Labels, Neighbors, [CurrState|PrevState], F), !.

af(Trans, Labels, [S0|[]], PrevState, F):-                  %The "af" predicate gets a list of all the neighbor states for
    check(Trans, Labels, S0, PrevState, af(F)), !.             %the state that we where in before getting here. It then sends them
                                                            %to the AF-check predicates one by one (Thereof checking every neighbor
af(Trans, Labels, [S0|Tail], PrevState, F):-                %state if AF is valid in it and then if all the neighbor states own
    check(Trans, Labels, S0, PrevState, af(F)),             %neighbors are valid with AF).
    af(Trans, Labels, Tail, PrevState, F), !.
%-----------------------------------------------------------------------------------
% Literals

check(_, Labels, CurrState, [], X):-                        %Checks if current state has the Labels X
    member([CurrState, Values], Labels),
    member(X, Values), !.

check(_, Labels, CurrState, [], neg(X)):-                   %Checks if current state does not have the Labels X
    \+ check(_, Labels, CurrState, [], X), !.
%-----------------------------------------------------------------------------------

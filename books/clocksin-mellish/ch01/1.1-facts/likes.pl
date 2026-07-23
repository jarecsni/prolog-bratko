% likes.pl — the cumulative knowledge base for C&M chapter 1.
%
% Introduced here at §1.1 (facts) and queried by every later section:
%   §1.2 questions       ?- likes(john, mary).
%   §1.3 variables       ?- likes(mary, X).
%   §1.4 conjunctions    ?- likes(mary, X), likes(john, X).
%   §1.5 rules           adds clauses on top of these facts.
%
% Facts only at this stage — no rules until §1.5. Read declaratively:
% "likes(A, B)" states the relation "A likes B", nothing about how it runs.

likes(mary, food).
likes(mary, wine).
likes(john, wine).
likes(john, mary).

translate(Number, Word) :-
    Number = 1, Word = one;
    Number = 2, Word = two;
    Number = 3, Word = three.

% more idiomatic, simpler - direct matching
translate(1, one).
translate(2, two).
translate(3, three).

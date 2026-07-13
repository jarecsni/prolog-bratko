% Define some date facts
date(1, may, 2001).
date(15, may, 2001).
date(30, may, 2001).
date(5, june, 2001).

% Query to unify date pattern
% ?- date(D, may, 2001) = date(D1, may, Y1).

vertical(seg(point(X, _), point(X, _))).
horizontal(seg(point(_, Y), point(_, Y))).

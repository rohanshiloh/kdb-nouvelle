/ B1 · destructuring assignment (4.1)
/<< Pattern matching, type checks, filter functions and the pattern
/<< conditional are new in 4.1 (Changes in 4.1, "Pattern matching";
/<< release notes 2024.02.02). Before 4.1 none of these lines parse as shown.
/ a list pattern
(b;c):(2;3)
b
c
(b;c):2 3 4
/ an empty item matches anything; a constant must match exactly
(1b;;x):(1b;`anything;1 2 3)
x
/ a failed match assigns nothing at all
y:`untouched
(1b;y):(0b;3 2 1)
y
/ dictionary patterns match by key; other keys are ignored
([four:d]):`one`two`three`four`five!1 2 3 4 5
d
([low:l;high:h]):`low`high!42 98
l,h
/ a table pattern matches by column
([]x2:e):([]1 2;3 4;5 6)
e
/ ! and flip are the only operators allowed in a pattern
(m!n):1 2!"ab"
n
(flip([px;sz])):([]px:1 2;sz:3 4)
sz
/ assign into one index
v:1 2 3
(v[1]):40
v
/ the match returns the whole value, filters included
a:(r;:1+):1 2
a
r

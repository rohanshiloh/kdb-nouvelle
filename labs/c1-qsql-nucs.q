/ C1 · qSQL tightened (4.0 · 4.1)
t:([]a:1 2 3;b:10 20 30;c:`x`y`x)
/ a column named like a group is a parse error (4.0); a repeated column is renamed
select a,b by a from t
select a,b by g:a from t
select a,a by c from t
/ aggregates over a by clause agree for atoms (4.0)
first max select count 1b by x1 from ([]1 2 3;3 3 3)
/ lj needs a keyed table on the right (4.0)
t lj ([]c:`x`y;d:1 2)
t lj ([c:`x`y]d:1 2)
/ update … by on a dictionary is an error, not ignored (4.1 2024.04.29)
dd:`a`b!1 2
update a by b from dd
/ value inside exec reads globals, not the caller's locals (4.1)
a:0
{a:1;exec value"2*a" from ([]``)}[]

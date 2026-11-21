/ C1 · qSQL tightened (4.0 · 4.1)
/<< What each line did before the change, per the release notes.
t:([]a:1 2 3;b:10 20 30;c:`x`y`x)
/ a column named like a group is a parse error (4.0); a repeated column is renamed
select a,b by a from t
/< — a column named like a group was renamed automatically; now a parse error (NUC, 4.0 2019.11.04)
select a,b by g:a from t
select a,a by c from t
/ aggregates over a by clause agree for atoms (4.0)
first max select count 1b by x1 from ([]1 2 3;3 3 3)
/< 3
/ lj needs a keyed table on the right (4.0)
t lj ([]c:`x`y;d:1 2)
/< — the right argument was not checked for a key (NUC, 4.0 2019.11.04)
t lj ([c:`x`y]d:1 2)
/ update … by on a dictionary is an error, not ignored (4.1 2024.04.29)
dd:`a`b!1 2
update a by b from dd
/< — the by clause was ignored (NUC, 4.1 2024.04.29)
/ value inside exec reads globals, not the caller's locals (4.1)
a:0
{a:1;exec value"2*a" from ([]``)}[]
/< 2
/ the safe form: refer to the local directly, or pass it in; no string to evaluate
{a:1;exec 2*a from ([]``)}[]

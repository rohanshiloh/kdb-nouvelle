/ B4 · mistakes that are now caught when the code is read (4.1)
/<< What each line did before 4.1, per the release notes.
/ each line below was accepted, or did something odd, before 4.1
([]a::e)
/< — amended the global a, with an implicit column name (NUC, 4.1 2024.02.02)
f:{[x+y]x}
/< — accepted; now 'nyi when compiled (4.1 2024.03.12)
():1
/< — accepted; now 'match (4.1 2024.03.12)
do:1
/< — accepted; now 'assign at parse time (NUC, 4.1 2025.11.25)
{ if[a;1 2]:3 4 }
/< — accepted; now 'assign at parse time (NUC, 4.1 2025.11.25)
{x}[;1]
/< — a projection; now 'rank (4.1 2021.12.07)

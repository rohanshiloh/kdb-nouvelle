/ A2 · dictionaries as arguments (4.1 · KDB-X)
/ .Q.id sanitises dictionary keys (4.1 2024.09.13)
.Q.id[`b`b1``in!2 3 4 5]
/ xcol renames and xcols reorders the keys of a dictionary (KDB-X 2026.10.23)
([a:`c;b:`d]) xcol ([a:10;b:20])
`c xcols ([a:1;b:2;c:3])
/ casting a dictionary whose values are all strings (fixed KDB-X 2026.10.02)
"J"$([a:"1";b:"2"])
/ settings that used to be lists or flags are now dictionaries
type .Q.lim[]

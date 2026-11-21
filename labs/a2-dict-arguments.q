/ A2 · dictionaries as arguments (4.1 · KDB-X)
/<< Each line uses something added after 4.1 shipped.
/ .Q.id sanitises dictionary keys (4.1 2024.09.13)
.Q.id[`b`b1``in!2 3 4 5]
/< — new: .Q.id on dictionaries (4.1 2024.09.13)
/ xcol renames and xcols reorders the keys of a dictionary (KDB-X 2026.10.23)
([a:`c;b:`d]) xcol ([a:10;b:20])
/< — new: xcol with a dictionary (KDB-X 2026.10.23)
`c xcols ([a:1;b:2;c:3])
/< — new: xcols with a dictionary (KDB-X 2026.10.23)
/ casting a dictionary whose values are all strings (fixed KDB-X 2026.10.02)
"J"$([a:"1";b:"2"])
/< — wrong result when every value was a string (fixed KDB-X 2026.10.02)
/ settings that used to be lists or flags are now dictionaries
type .Q.lim[]
/< — .Q.lim was not a dictionary before KDB-X 2026.04.10 (NUC)

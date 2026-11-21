/ E1 · loading relative to a file (KDB-X) and one-shot queries with a timeout (4.0)
/<< What each line did before the change, per the release notes.
/ labs/inc/outer.q loads inner.q from its own folder with \l .:inner.q
\l labs/inc/outer.q
/< — new: \l .:path is relative to the loading file (KDB-X 2026.04.01)
outerSaw
/ a one-shot query with a 500 ms timeout: first to a port nobody listens on
`::[(":localhost:5999";500);"1+1"]
/ then to a port that accepts the connection but never answers (this process, busy asking)
\p 5998
`::[(":localhost:5998";500);"1+1"]
\p 0
/< — new: a one-shot query with a timeout (4.0 2020.03.09)
/ handles are now a sorted list (4.1 2024.07.08)
type .z.H
/< — new: .z.H (4.0 2020.06.01); a sorted list since 4.1 2024.07.08

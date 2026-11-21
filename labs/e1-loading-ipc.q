/ E1 · loading relative to a file (KDB-X) and one-shot queries with a timeout (4.0)
/ labs/inc/outer.q loads inner.q from its own folder with \l .:inner.q
\l labs/inc/outer.q
outerSaw
/ a one-shot query with a 500 ms timeout, to a port nobody listens on
`::[(":localhost:5999";500);"1+1"]
/ handles are now a sorted list (4.1 2024.07.08)
type .z.H

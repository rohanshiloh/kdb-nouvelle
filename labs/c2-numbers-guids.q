/ C2 · numbers, casts, bytes and guids (4.x · KDB-X)
/<< What each line did before the change, per the release notes.
/ out of range or divide by zero gives null on every platform (KDB-X 2026.10.15)
3i div 0i
/< — 0i on ARM, 0Ni elsewhere (NUC, KDB-X 2026.10.15)
/ overflowing string-to-time casts give null (2026.10.23, also 4.1)
"U"$"71582789:00"
/< — a wrapped value, not null (KDB-X 2026.10.23)
"N"$"106751D23:47:16.9"
/< — a wrapped value, not null (4.1 2026.10.23)
/ short parsing no longer clamps (4.1 2021)
"H"$"99999"
/< 0Wh
/ the seed of a sorted scan is honoured, and */ on bytes is right (2026.05.01)
0&/`s#1 2 3
/< — the seed 0 was ignored for a sorted list (wrong since 3.1; fixed 2026.05.01)
0x01*/0x01020304
/< — a wrong result (wrong since 3.3; fixed 2026.05.01)
/ bytes: vs, sv and ss
0x0203 sv 0x0203 vs "x"$til 6
/< — new: vs and sv on byte vectors (4.1 2021.09.03)
0x01020304 ss 0x0203
/< — new: ss on bytes (KDB-X 2026.04.01)
10h$.Q.atob "aGVsbG8="
/< — new: .Q.atob (4.1 2025.11.25)
/ guids can be ordered (KDB-X 2026.10.15)
g:3?0Ng
(min g)~first asc g
/< — not supported: min, max, & and | on guids arrived in KDB-X 2026.10.15
max 0Ng,g
/< — not supported before KDB-X 2026.10.15
/ the reference count is a long (KDB-X 2026.10.02)
type -16!til 3
/< -6h

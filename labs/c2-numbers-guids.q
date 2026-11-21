/ C2 · numbers, casts, bytes and guids (4.x · KDB-X)
/ out of range or divide by zero gives null on every platform (KDB-X 2026.10.15)
3i div 0i
/ overflowing string-to-time casts give null (2026.10.23, also 4.1)
"U"$"71582789:00"
"N"$"106751D23:47:16.9"
/ short parsing no longer clamps (4.1 2021)
"H"$"99999"
/ the seed of a sorted scan is honoured, and */ on bytes is right (2026.05.01)
0&/`s#1 2 3
0x01*/0x01020304
/ bytes: vs, sv and ss
0x0203 sv 0x0203 vs "x"$til 6
0x01020304 ss 0x0203
10h$.Q.atob "aGVsbG8="
/ guids can be ordered (KDB-X 2026.10.15)
g:3?0Ng
(min g)~first asc g
max 0Ng,g
/ the reference count is a long (KDB-X 2026.10.02)
type -16!til 3

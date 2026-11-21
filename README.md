# Beyond 3.x — Syntax & Semantics

*New Grammar for an Old Language*

The syntax q gained from kdb+ 4.0 to KDB-X (dictionary literals, pattern matching, filter functions, modules) and the changes that break old code. Every claim is a lab, run on KDB-X beside what KX's release notes say it did before (labs/before/), or beside a real kdb+ 4.x run if you have a licence.

**Read it:** https://rohanshiloh.github.io/kdb-nouvelle/

## Layout

```
index.html          the document, built by build.py (served by GitHub Pages)
src/                its sources: body.html (prose), _head/_style/_extra/_script
build.py            src/ + labs/ + out/  ->  index.html
labs/               one script per lab, a1-…q to m4-…q, and run.q, the runner
run-labs.sh         runs every lab on each q, writes out/, rebuilds index.html
out/                transcripts: <lab>.4x.txt, <lab>.x.txt, test-<module>.x.txt
mod/tick/           three KDB-X modules: tick.cfg, tick.check, tick.pubsub (+ tests)
tickx.q             KX's tick.q brought forward onto tick.pubsub and tick.check
feedx.q             replays Datagen's synthetic trades and quotes into tickx.q
schema/dg.q         tickx.q's schema, taken from Datagen
setup.sh            fetches kdb-tick into vendor/ and installs kx.test
```

## Run the labs

```sh
./setup.sh                                     # once: vendor/kdb-tick, ~/.kx/mod/kx/test.q
Q4=~/q4/m64/q QX=~/.kx/bin/q ./run-labs.sh     # all labs on both, plus module tests
Q4=… QX=… ./run-labs.sh b2                     # just the labs whose name starts b2
QX=~/.kx/bin/q labs/m4-pubsub.sh               # the tickerplant lab (several processes)
```

`Q4` is kdb+ 4.0 or 4.1 and `QX` is KDB-X; leave either out and its column stays "not yet run". Each run rewrites `out/` and `index.html`; commit both.

The labs need these KDB-X modules on the search path: `kx.os` and `kx.datagen.capmkts` (from KDB-X or KX's GitHub) and `kx.test` (installed by `setup.sh`). `run-labs.sh` adds this repository's `mod/` to `QPATH`.

## Publish

GitHub → Settings → Pages → *Deploy from a branch* → `main` / `(root)`. The `.nojekyll` file makes Pages serve the files as they are.

## Modules

| Module | What it is |
|---|---|
| `tick.cfg` | typed configuration: a dictionary literal of defaults, overridden by `TICK_<NAME>` and `-name`, parsed to each default's type |
| `tick.check` | filter functions for patterns and parameter lists: `table`, `schema`, `sym`, `ts`, `nonull`, `positive`, `between` |
| `tick.pubsub` | KX's `u.q` as a module, line for line, with its changes marked |

Tests use KX's Unit Test module (`kx.test`) and follow Data Intellect's layout of code and tests in one directory per module.

`vendor/` (KX's kdb-tick) is fetched, not committed.

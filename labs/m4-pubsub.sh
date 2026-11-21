#!/bin/sh
# M4 · the tickerplant on modules. Starts tickx.q, the vanilla r.q and the
# Datagen feed on ports 5710/5711, lets them run, asks them questions with
# labs/m4-pubsub.q, then stops them.   QX=~/.kx/bin/q  labs/m4-pubsub.sh
set -u
cd "$(dirname "$0")/.."
: "${QX:?set QX to your KDB-X q}"
export QPATH="$PWD/mod${QPATH:+:$QPATH}"
mkdir -p out log
"$QX" tickx.q dg ./log -p 5710 </dev/null >out/m4-tp.log   2>&1 & TP=$!
sleep 3
"$QX" vendor/tick/r.q :5710 -p 5711 </dev/null >out/m4-rdb.log  2>&1 & RDB=$!
sleep 1
"$QX" feedx.q :5710                </dev/null >out/m4-feed.log 2>&1 & FEED=$!
sleep 8
"$QX" labs/run.q labs/m4-pubsub.q -q </dev/null >out/m4-pubsub.x.txt 2>&1
kill $FEED $RDB $TP 2>/dev/null
echo "x  m4-pubsub (process logs in out/m4-*.log)"
python3 build.py

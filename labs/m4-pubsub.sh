#!/bin/sh
# M4 · the tickerplant on modules. Starts tickx.q, the vanilla r.q and the
# Datagen feed on ports 5710/5711, waits for the feed to finish, asks them
# questions with labs/m4-pubsub.q, checks every row arrived, then stops them.
#   QX=~/.kx/bin/q  labs/m4-pubsub.sh
#
# Diagnostics: stale processes on 5710/5711 are stopped first; each process is
# waited for by port, not by a fixed sleep; the feed's log is checked for
# trapped errors; labs/inc/m4-verify.q compares rows sent, logged and held.
# Exits 1 if anything failed.
set -u
cd "$(dirname "$0")/.."
: "${QX:?set QX to your KDB-X q}"
export QPATH="$PWD/mod${QPATH:+:$QPATH}"
mkdir -p out log
rm -f log/dg2*                                    # a fresh log, so the counts start at zero
fail=0

# anything left on our ports from an earlier run would answer in place of ours
for p in 5710 5711; do
  pid=$(lsof -ti tcp:$p -sTCP:LISTEN 2>/dev/null)
  [ -n "$pid" ] && { echo "stopping stale process $pid on $p"; kill $pid; sleep 1; }
done

stop() { kill ${FEED:-} ${RDB:-} ${TP:-} 2>/dev/null; }
up() {  # up <port> <name> <log> : wait up to 10s for a process to listen
  i=0
  until nc -z localhost "$1" 2>/dev/null; do
    i=$((i+1)); [ $i -gt 50 ] && { echo "$2 did not start on $1; see $3:"; tail -5 "$3"; stop; exit 1; }
    sleep 0.2
  done
  echo "$2 up on $1"
}

"$QX" tickx.q dg ./log -p 5710 </dev/null >out/m4-tp.log   2>&1 & TP=$!
up 5710 tickerplant out/m4-tp.log
"$QX" vendor/tick/r.q :5710 -p 5711 </dev/null >out/m4-rdb.log  2>&1 & RDB=$!
up 5711 rdb out/m4-rdb.log
"$QX" feedx.q ::5710               </dev/null >out/m4-feed.log 2>&1 & FEED=$!

# the feed prints "end of data" when it is done, or ERROR if its timer trapped
i=0
until grep -q "end of data\|ERROR" out/m4-feed.log 2>/dev/null; do
  i=$((i+1)); [ $i -gt 120 ] && { echo "feed did not finish in 60s; see out/m4-feed.log"; fail=1; break; }
  sleep 0.5
done
if grep -q ERROR out/m4-feed.log; then echo "feed error:"; sed -n '/ERROR/,$p' out/m4-feed.log; fail=1; fi
sleep 1                                           # let the last messages through

"$QX" labs/run.q labs/m4-pubsub.q -q </dev/null >out/m4-pubsub.x.txt 2>&1

# rows sent = the totals the feed announced (it sends all of them unless it stopped)
set -- $(sed -n 's/^feedx: \([0-9]*\) trades, \([0-9]*\) quotes.*/\1 \2/p' out/m4-feed.log)
if [ $# -eq 2 ]; then
  "$QX" labs/inc/m4-verify.q "$1" "$2" -q </dev/null >out/m4-verify.txt 2>&1 || fail=1
  cat out/m4-verify.txt
else
  echo "feed never announced its totals; see out/m4-feed.log"; fail=1
fi

stop
echo "x  m4-pubsub (process logs in out/m4-*.log)"
python3 build.py
[ $fail -eq 0 ] && echo "m4: all checks passed" || echo "m4: CHECKS FAILED"
exit $fail

#!/bin/sh
# kdb-nouvelle : run every lab on each q you have, then rebuild the page.
#
#   Q4=~/q4/m64/q  QX=~/.kx/bin/q  ./run-labs.sh          # all labs
#   Q4=...  QX=...  ./run-labs.sh b1                        # labs whose name starts b1
#
# Q4 is kdb+ 4.0 or 4.1, QX is KDB-X. Either may be left out; its column then
# stays "not yet run". Module labs (m*) and tests run on KDB-X only.
# Output lands in out/<lab>.4x.txt and out/<lab>.x.txt; build.py reads them.
set -u
cd "$(dirname "$0")"
mkdir -p out
export QPATH="$PWD/mod${QPATH:+:$QPATH}"     # so `use` finds tick.cfg, tick.check, tick.pubsub
only="${1:-}"

run() {  # run <q binary> <lab file> <out file>
  "$1" labs/run.q "$2" -q </dev/null >"$3" 2>&1 || true
}

for f in labs/[a-z][0-9]-*.q; do
  n=$(basename "$f" .q)
  case "$n" in "$only"*) ;; *) continue ;; esac
  case "$n" in
    m*) [ -n "${QX:-}" ] && [ "$n" != m4-pubsub ] && run "$QX" "$f" "out/$n.x.txt" && echo "x  $n" ;;
    *)  [ -n "${Q4:-}" ] && run "$Q4" "$f" "out/$n.4x.txt" && echo "4x $n"
        [ -n "${QX:-}" ] && run "$QX" "$f" "out/$n.x.txt"  && echo "x  $n" ;;
  esac
done

# unit tests for the modules (KX Unit Test module, kx.test)
if [ -n "${QX:-}" ] && { [ -z "$only" ] || [ "$only" = test ]; }; then
  for t in mod/tick/*/test/run.q; do
    m=$(basename "$(dirname "$(dirname "$t")")")
    "$QX" "$t" -q </dev/null >"out/test-$m.x.txt" 2>&1 || true
    echo "x  test-$m"
  done
fi

# the tickerplant lab needs several processes: see labs/m4-pubsub.sh
python3 build.py

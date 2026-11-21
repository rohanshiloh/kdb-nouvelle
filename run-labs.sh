#!/bin/sh
# kdb-nouvelle : run every lab on each q you have, then rebuild the page.
#
#   Q4=~/q4/m64/q  QX=~/.kx/bin/q  ./run-labs.sh          # all labs
#   Q4=...  QX=...  ./run-labs.sh b1                        # labs whose name starts b1
#
# Q4 is kdb+ 4.0 or 4.1, QX is KDB-X. Either may be left out; its column then
# stays "not yet run". Module labs (m*) and tests run on KDB-X only.
# Output lands in out/<lab>.4x.txt and out/<lab>.x.txt; build.py reads them.
#
# Diagnostics: each q is checked before any lab runs (a licence or startup
# failure stops here, not as a page of errors); every transcript's header names
# the q build and a hash of the lab file; the run ends with a table of errors
# per transcript and lines changed since the previous run.
set -u
cd "$(dirname "$0")"
mkdir -p out/.prev
export QPATH="$PWD/mod${QPATH:+:$QPATH}"     # so `use` finds tick.cfg, tick.check, tick.pubsub
only="${1:-}"
SUM=out/.prev/summary
: >"$SUM"

preflight() {  # preflight <name> <q binary>
  r=$(printf '%s\n' '-1 "ok ",string .z.K;exit 0' | "$2" -q 2>&1 | tail -1)
  case "$r" in
    ok*) echo "$1 = $2 (q ${r#ok })" ;;
    *)   echo "$1 = $2 did not start:"; echo "  $r"; exit 1 ;;
  esac
}
[ -z "${Q4:-}${QX:-}" ] && { echo "set Q4 and/or QX"; exit 1; }
[ -n "${Q4:-}" ] && preflight Q4 "$Q4"
[ -n "${QX:-}" ] && preflight QX "$QX"

body() { grep -v '^/ .* · lab [0-9a-f]*$' "$1"; }   # a transcript without its header line

note() {  # note <out file> : errors in it, and lines changed since the last run
  e=$(grep -c "^'" "$1")
  p="out/.prev/$(basename "$1")"
  if [ -f "$p" ]; then c=$(body "$p" | diff - "$1.b" 2>/dev/null | grep -c '^>'); else c=new; fi
  printf '%-28s %6s %8s\n' "$(basename "$1" .txt)" "$e" "$c" >>"$SUM"
}

run() {  # run <out file> <q binary> <q args...>
  o=$1; shift
  [ -f "$o" ] && cp "$o" "out/.prev/$(basename "$o")"
  "$@" -q </dev/null >"$o" 2>&1 || true
  body "$o" >"$o.b"; note "$o"; rm -f "$o.b"
}

for f in labs/[a-z][0-9]-*.q; do
  n=$(basename "$f" .q)
  case "$n" in "$only"*) ;; *) continue ;; esac
  case "$n" in
    m4-pubsub) ;;                                   # several processes: labs/m4-pubsub.sh
    m*) [ -n "${QX:-}" ] && run "out/$n.x.txt" "$QX" labs/run.q "$f" && echo "x  $n" ;;
    *)  [ -n "${Q4:-}" ] && run "out/$n.4x.txt" "$Q4" labs/run.q "$f" && echo "4x $n"
        [ -n "${QX:-}" ] && run "out/$n.x.txt" "$QX" labs/run.q "$f"  && echo "x  $n" ;;
  esac
done

# unit tests for the modules (KX Unit Test module, kx.test)
if [ -n "${QX:-}" ] && { [ -z "$only" ] || [ "$only" = test ]; }; then
  for t in mod/tick/*/test/run.q; do
    m=$(basename "$(dirname "$(dirname "$t")")")
    run "out/test-$m.x.txt" "$QX" "$t" && echo "x  test-$m"
  done
fi

echo
printf '%-28s %6s %8s\n' transcript errors changed
cat "$SUM"
echo "errors: lines starting ' (most labs show errors on purpose)"
echo "changed: lines new or different since the previous run (new: first run)"
echo
# the tickerplant lab needs several processes: see labs/m4-pubsub.sh
python3 build.py

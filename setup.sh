#!/bin/sh
# kdb-nouvelle : fetch what this repository uses but does not redistribute.
# Run once from the repository root:   ./setup.sh
#   vendor/          KxSystems/kdb-tick (tick.q, tick/u.q, tick/r.q), unmodified,
#                    for the diff against tickx.q and the vanilla RDB in lab M4
#   ~/.kx/mod/kx/    KX's Unit Test module (kx.test), used by the module tests
# Datagen (kx.datagen.capmkts) and kx.os come with KDB-X; see README if missing.
set -e
cd "$(dirname "$0")"
tmp=$(mktemp -d)
git clone -q --depth 1 https://github.com/KxSystems/kdb-tick "$tmp/kdb-tick"
mkdir -p vendor/tick log out
cp "$tmp/kdb-tick/tick.q" vendor/
cp "$tmp/kdb-tick/tick/u.q" "$tmp/kdb-tick/tick/r.q" vendor/tick/
if [ ! -f "$HOME/.kx/mod/kx/test.q" ]; then
  git clone -q --depth 1 https://github.com/KxSystems/unit-test "$tmp/unit-test"
  mkdir -p "$HOME/.kx/mod/kx"
  cp "$tmp/unit-test/test.q" "$HOME/.kx/mod/kx/"
  echo "installed kx.test into ~/.kx/mod/kx/"
fi
rm -rf "$tmp"
chmod +x run-labs.sh labs/m4-pubsub.sh
echo "ready: vendor/tick.q, vendor/tick/u.q, vendor/tick/r.q"

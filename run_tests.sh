#!/usr/bin/env bash
# hagukumi 育み — run the constitutional-gate + agent test suites.
# Exits non-zero on any failure (deploy-gate friendly).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
CLASSPATH_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/hagukumi-classpath.XXXXXX")"
trap 'rm -rf "$CLASSPATH_ROOT"' EXIT
ln -s "$ROOT" "$CLASSPATH_ROOT/hagukumi"
rc=0

BB_CP="$CLASSPATH_ROOT"

run_cljc() {
  local ns="$1"
  echo "==> hagukumi [cljc] $ns"
  ( cd "$ROOT" && bb -cp "$BB_CP" -e \
    "(require (quote clojure.test) (quote $ns))(let [r (clojure.test/run-tests (quote $ns))](System/exit (if (zero? (+ (:fail r) (:error r))) 0 1)))" ) || rc=1
}

run_cljc "hagukumi.methods.test-charter-gates"
run_cljc "hagukumi.methods.test-agent"
run_cljc "hagukumi.cells.test-state-machines"

if [[ $rc -eq 0 ]]; then
  echo "==> hagukumi: ALL GREEN"
else
  echo "==> hagukumi: FAILURES (rc=$rc)" >&2
fi
exit $rc

#!/bin/bash
# Run the standalone examples with Xcelium (no uvm_unit, no UVM).
# Usage:
#   ./run.sh                  # all examples
#   ./run.sh 02_methods.sv    # one example
#   ./run.sh +DEBUG_SV_ENUM_OBJ

cd "$(dirname "$0")"

if ! command -v xrun >/dev/null 2>&1; then
    echo "xrun not found. See README.md for Xcelium, Questa, and VCS commands." >&2
    exit 1
fi

files=()
xrun_args=()
for a in "$@"; do
    case "$a" in
        *.sv) files+=("$a") ;;
        *)    xrun_args+=("$a") ;;
    esac
done
if [ ${#files[@]} -eq 0 ]; then
    files=(01_basic.sv 02_methods.sv 03_randomize.sv 04_extend.sv)
fi

fail=0
for src in "${files[@]}"; do
    echo "========== $src =========="
    if xrun -sv -timescale 1ns/1ns -incdir .. "$src" "${xrun_args[@]}"; then
        echo "PASS $src"
    else
        echo "FAIL $src"
        fail=1
    fi
done

rm -rf xcelium.d xrun.history xrun.log tr_db.log
exit "$fail"

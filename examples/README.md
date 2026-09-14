# Examples

Standalone programs that compile against `sv_enum_obj` only. They do not use
uvm_unit or UVM.

| File | Shows |
|---|---|
| `01_basic.sv` | Declare a type, holders vs singletons, lookup, iteration, `is` / `is_in` |
| `02_methods.sv` | Attach methods to enumerators (holder delegates via `_init_obj()`) |
| `03_randomize.sv` | `randomize()` and constraints on the public `value` member |
| `04_extend.sv` | `DECL_SV_ENUM_OBJ_EXTEND` from another package, plus a value override |

## Run

From this directory. The library is `../`.

Xcelium:

```
xrun -sv -timescale 1ns/1ns -incdir ../ 01_basic.sv
```

All examples:

```
./run.sh
```

Questa:

```
vlog -sv -incdir ../ 01_basic.sv
vsim -c top -do "run -all; quit -f"
```

VCS:

```
vcs -sverilog -timescale=1ns/1ns -incdir ../ 01_basic.sv -R
```

`+DEBUG_SV_ENUM_OBJ` prints enumerator registrations and overrides.

The tests under `../unit_tests/` need [uvm_unit](https://github.com/cquickstad/uvm_unit). These examples do not.

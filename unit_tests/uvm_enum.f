-timescale 1ps/1ps
-linedebug
-parseinfo macro
-xmallerror
-nowarn NODNTW:DSEMEL:DSEM2009:RNDXCELON:SRCDEPR:SAWSTP:WARSEV:TSNSPK:OLDURR:SPDUSD:UNOPCH
-sv
-newperf
-plusperf
-enable_cb_access
-disable_var_opt_core
-uvmnoautocompile
-uvmnocdnsextra
-uvmnoloaddpi
-64
-sv_lib $UVM_HOME/lib/64bit/libuvmdpi.so
-access rwc
+UVM_NO_RELNOTES
-uvmhome $UVM_UNIT_HOME/uvm_unit-uvm-1.2

+define+SV_ENUM_OBJ_UVM

-incdir ../
-incdir $UVM_UNIT_HOME
-incdir $UVM_UNIT_HOME/uvm_unit-uvm-1.2/src

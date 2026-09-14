// -------------------------------------------------------------
//    Copyright 2026 Chad Quickstad
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------

// Methods on enumerators, delegated from the holder. No UVM.

`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;

`DECL_SV_ENUM_OBJ_BEGIN(op)
    // Holder must sync the cached singleton, then delegate.
    virtual function int calc(int a, int b);
        _init_obj();
        return _obj.calc(a, b);
    endfunction
`DECL_SV_ENUM_OBJ_END

`DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(op, add)
    virtual function int calc(int a, int b);
        return a + b;
    endfunction
`DECL_SV_ENUM_OBJ_ENUMERATOR_END

`DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(op, mul)
    virtual function int calc(int a, int b);
        return a * b;
    endfunction
`DECL_SV_ENUM_OBJ_ENUMERATOR_END

`DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(op, sub)
    virtual function int calc(int a, int b);
        return a - b;
    endfunction
`DECL_SV_ENUM_OBJ_ENUMERATOR_END

function automatic void check(bit ok, string msg);
    if (!ok) $fatal(1, "FAIL: %s", msg);
endfunction

module top;
    initial begin
        op holder = new();

        check(add::get().calc(6, 7) == 13, "add singleton");
        check(mul::get().calc(6, 7) == 42, "mul singleton");
        check(sub::get().calc(6, 7) == -1, "sub singleton");

        holder.set_first();
        repeat (holder.num()) begin
            $display("%s(6, 7) = %0d", holder.name(), holder.calc(6, 7));
            holder.increment();
        end

        holder.set(mul::get());
        check(holder.calc(6, 7) == 42, "holder delegates to mul");
        check(holder.randomize() with {value == add::value();}, "randomize add");
        check(holder.calc(6, 7) == 13, "holder delegates after randomize");

        $display("PASS");
        $finish;
    end
endmodule

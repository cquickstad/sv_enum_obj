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

// Holders vs singletons, lookup, iteration, comparison. No UVM.

`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;

`DECL_SV_ENUM_OBJ(color)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, red)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, green)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, blue)

function automatic void check(bit ok, string msg);
    if (!ok) $fatal(1, "FAIL: %s", msg);
endfunction

module top;
    initial begin
        color singleton;
        color holder;

        singleton = red::get();
        check(singleton.is_singleton(), "red::get() is a singleton");
        check(!singleton.is_holder(), "red::get() is not a holder");
        check(singleton.name() == "red", "name");
        check(singleton.full_name() == "color.red", "full_name");
        check(red::value() == 0, "red::value()");
        check(green::value() == 1, "green::value()");
        check(blue::value() == 2, "blue::value()");
        $display("singleton %s = %0d",
            singleton.full_name(), singleton.get_value());

        holder = new();
        check(holder.is_holder(), "new() is a holder");
        check(!holder.is_singleton(), "new() is not a singleton");
        check(holder.is(red::get()), "holder defaults to the first enumerator");
        $display("holder starts as %s", holder.name());

        holder.set(green::get());
        check(holder.name() == "green", "set()");
        holder.set_by_name("blue");
        check(holder.name() == "blue", "set_by_name");
        holder.set_by_value(0);
        check(holder.is(red::get()), "set_by_value");
        check(color::get_by_name("green").is(green::get()), "get_by_name");
        check(color::get_by_value(2).is(blue::get()), "get_by_value");

        $display("%0d colors:", holder.num());
        holder.set_first();
        forever begin
            $display("  %s : %0d", holder.name(), holder.get_value());
            if (holder.is_last()) break;
            holder.increment();
        end

        check(green::get().is(green::get()), "is() same");
        check(!green::get().is(blue::get()), "is() different");
        check(green::get().is_in({green::get(), blue::get()}), "is_in hit");
        check(!red::get().is_in({green::get(), blue::get()}), "is_in miss");

        $display("PASS");
        $finish;
    end
endmodule

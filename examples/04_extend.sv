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

// Extend a type from another package without modifying it. No UVM.

`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;

package original_pkg;
    import sv_enum_obj_pkg::*;
    `DECL_SV_ENUM_OBJ(color)
    `DECL_SV_ENUM_OBJ_ENUMERATOR(color, red)
    `DECL_SV_ENUM_OBJ_ENUMERATOR(color, green)
endpackage

package later_pkg;
    import sv_enum_obj_pkg::*;
    `DECL_SV_ENUM_OBJ_EXTEND(extended_color, original_pkg::color)
    `DECL_SV_ENUM_OBJ_ENUMERATOR(extended_color, blue)
    `DECL_SV_ENUM_OBJ_ENUMERATOR(extended_color, crimson, original_pkg::red::value())
endpackage

function automatic void check(bit ok, string msg);
    if (!ok) $fatal(1, "FAIL: %s", msg);
endfunction

module top;
    initial begin
        original_pkg::color oc = new();
        later_pkg::extended_color ec = new();
        string onames[$];
        string enames[$];

        // Touch the new enumerators so the package is not optimized away.
        check(later_pkg::blue::value() == 2, "blue encoding");
        check(later_pkg::crimson::value() == original_pkg::red::value(),
            "crimson overrides red's encoding");

        onames = oc.names();
        enames = ec.names();
        $display("original names: %p", onames);
        $display("extended names: %p", enames);

        check(oc.num() == 2, "original has 2 enumerators");
        check(ec.num() == 3, "extended has 3 enumerators");
        check(onames[0] == "red" && onames[1] == "green", "original names");
        check(enames[0] == "crimson" && enames[1] == "green" &&
            enames[2] == "blue", "extended names");

        check(original_pkg::color::get_by_value(0).name() == "red",
            "original value 0 is still red");
        check(later_pkg::extended_color::get_by_value(0).name() == "crimson",
            "extended value 0 is crimson");

        oc.set_by_name("red");
        check(oc.name() == "red", "original set_by_name red");

        ec.set(later_pkg::blue::get());
        check(ec.name() == "blue", "extended set blue");
        // oc.set_by_name("blue") would $fatal: blue is not in original_pkg::color.

        $display("PASS");
        $finish;
    end
endmodule

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

// Randomize the holder; constrain the public `value` member. No UVM.

`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;

`DECL_SV_ENUM_OBJ(color)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, red)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, green)
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, blue)

class item;
    rand color favorite;
    rand color disliked;
    constraint colors_c {
        favorite.value inside {red::value(), green::value()};
        disliked.value != favorite.value;
    }
    function new();
        favorite = new();
        disliked = new();
    endfunction
endclass

function automatic void check(bit ok, string msg);
    if (!ok) $fatal(1, "FAIL: %s", msg);
endfunction

module top;
    initial begin
        color c = new();
        item it = new();
        int seen_red, seen_blue;

        repeat (20) begin
            check(c.randomize() with {value != green::value();},
                "holder randomize");
            check(c.name() != "green", "green excluded");
            $display("random color: %s", c.name());
            if (c.is(red::get())) seen_red++;
            if (c.is(blue::get())) seen_blue++;
        end
        check(seen_red > 0, "never got red");
        check(seen_blue > 0, "never got blue");

        repeat (8) begin
            check(it.randomize(), "item randomize");
            check(it.favorite.is_in({red::get(), green::get()}),
                "favorite in {red, green}");
            check(!it.disliked.is(it.favorite), "disliked != favorite");
            $display("item favorite=%s disliked=%s",
                it.favorite.name(), it.disliked.name());
        end

        $display("PASS");
        $finish;
    end
endmodule

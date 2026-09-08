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



//------------------------------------------------------------------------------
// sv_enum_obj
//
// Object-based enumerations for SystemVerilog.
//
// Native `enum` values are integers. This library represents each enumerator
// as a singleton class and provides a separate *holder* instance of the enum
// type that is randomizable.  Using an object-oriented approach allows:
// * attaching methods to the type and its values.
// * extending the enum with more values without modifying the original code.
// * modifying/replacing an enum value without modifying the original code.
//
// Two kinds of object share the same static type (e.g. `color`):
//
//   Holder:     color c = new();          // mutable, randomizable
//   Singleton:  color c = red::get();     // identity of one enumerator
//
// Use holders when you need to randomize, assign, or change the current value.
// Use singletons (`red::get()`, `color::get_by_value(0)`, ...) as immutable
// identities for comparison, factory lookups, and static queries
// (`red::value()`, `red::full_name()`, ...).
//
//   if (c.is_holder())     c.set(green::get());   // OK
//   if (c.is_singleton())  /* set_* and randomize() fatal */
//
// Constraints from outside the object must name the public `value` member:
//   my_color.randomize() with {
//       value inside {red::value(), green::value()};
//   }
//
// Plusarg: +DEBUG_SV_ENUM_OBJ enables registration/override traces.
//------------------------------------------------------------------------------


virtual class sv_enum_obj_base `ifdef UVM_POST_VERSION_1_1 extends uvm_object `endif ;

`ifdef UVM_POST_VERSION_1_1
    function new(string name);
        super.new(name);
    endfunction
`endif

    // Enables registration/override traces that print at "static"
    // initialization time.
    static protected bit _debug = $test$plusargs("DEBUG_SV_ENUM_OBJ");

    // Needed to return a queue of strings out the left-hand side of functions.
    typedef string _string_q[$];

    // True when this handle is a mutable wrapper (`new` of the enum type).
    pure virtual function bit is_holder();

    // True when this handle is a per-enumerator singleton (`::get()`).
    pure virtual function bit is_singleton();

    // Canonical singleton for the current numeric value (holders resolve first).
    // Follows overrides to the final enumerator.
    pure virtual function sv_enum_obj_base get_singleton();
    pure virtual function string name();
    pure virtual function _string_q get_names();
    pure virtual function string base_name();

    // Set the value held by this holder to the enumerator referenced by the
    // indicated name.  If an overridden name is supplied, then the new
    // enumerator is set, not the old.
    //
    // Fatals if `n` is not the name of a registered enumerator.
    //
    // Call enum_type::names() or enum_instance.get_names() to get the set of
    // registered enumerator names.
    pure virtual function void set_by_name(string n);

    // Set the value held by this holder to the enumerator referenced by the
    // indicated int value.  Performs a static cast of the int to the SCALAR_T.
    // Fatals the result of the cast does not map to a registered value.
    pure virtual function void set_by_int(int v);

    // Set the value held by this holder to the first enumerator to be declared
    // for the type.
    pure virtual function void set_first();

    // Set the value held by this holder to the last enumerator to be declared
    // for the type.
    pure virtual function void set_last();

    // The number of enumerators in the enumeration
    pure virtual function int get_num();

    // "Type.enumerator", e.g. "color.red". Follows override to the final name.
    pure virtual function string get_full_name();

    // Returns the static cast of the current value to int.
    // Fatals on X/Z or if SCALAR_T is wider than int.
    pure virtual function int get_int_value();

    // When the base enumeration object is instantiated as a holder, the
    // increment and decrement methods cycle through all of the values/
    // enumerations of the set.
    // Progression is in declaration order.
    // Incrementing at the end will wrap to the beginning.
    // Decrementing at the beginning will wrap to the beginning.
    pure virtual function void increment();
    pure virtual function void decrement();

    // Reports whether the enumerator being held is the first one in the set.
    // (Declaration order.)
    pure virtual function bit is_first();

    // Reports whether the enumerator being held is the last one in the set.
    // (Declaration order.)
    pure virtual function bit is_last();

    // Same enumerator identity? Null `other` is false (not a fatal)
    function bit is(sv_enum_obj_base other);
        return (other != null) && (get_singleton() == other.get_singleton());
    endfunction
endclass

virtual class sv_enum_obj#(type SCALAR_T=int) extends sv_enum_obj_base;
    // Used to return a queue out the left-hand-side of functions.
    typedef SCALAR_T _scalar_t_q[$];

    // Randomization target. Must stay public so external constraints can
    // write `obj.value inside { ... }` — SV has no other hook for that.
    // After poking `.value` directly, the next getter calls `_init_obj()`
    // and refreshes the cached singleton. Prefer `set_by_value()` / `set()`
    // when not inside a constraint.
    rand SCALAR_T value;

    function new( `ifdef UVM_POST_VERSION_1_1 string name="sv_enum_obj" `endif );
        super.new( `ifdef UVM_POST_VERSION_1_1 name `endif );
        _init_randomizable_value();
    endfunction

    // WARNING: When inheriting from an enum object, post_randomize() must call
    //          super.post_randomize() (or _init_obj() directly) or the cached
    //          internal object will go stale after randomize()!

    virtual function bit is_holder(); return 1; endfunction
    virtual function bit is_singleton(); return 0; endfunction

    // Set the value held by this holder to the the enumerator referenced by
    // the indicated value (the *current* enumerator after any overrides).
    //
    // Fatals if `v` is not a registered enumerator.
    //
    // Call enum_type::values() or enum_instance.get_values() to get the set of
    // registered enumerator values.
    virtual function void set_by_value(SCALAR_T v);
        value = v;
        _init_obj();
    endfunction

    // Set the value held by this holder to the enumerator referenced by the
    // indicated int value.  Performs a static cast of the int to the SCALAR_T.
    // Fatals the result of the cast does not map to a registered value.
    virtual function void set_by_int(int v);
        SCALAR_T tmp = SCALAR_T'(v);
        if (int'(tmp) != v) begin
            `ifdef INCA $stacktrace; `endif
            $fatal(1,{"SV ENUM OBJECT FATAL: ", base_name(),
                ".set_by_int(): int value ", $sformatf("%0d", v),
                " could not be converted to SCALAR_T."});
            return;
        end
        set_by_value(tmp);
    endfunction

    // Getter for value
    pure virtual function SCALAR_T get_value();

    // Return a queue of all of the registered values
    pure virtual function _scalar_t_q get_values();

    // Returns the largest value of all of the registered enumerations
    pure virtual function SCALAR_T get_max_value();

    // Returns the least value of all of the registered enumerations
    pure virtual function SCALAR_T get_min_value();

    // Returns the value that the next registered value will take should
    // enumerator be added.  If no enumerators are registered, then the value
    // starts at zero.  If there are one or more gaps in the set of enumerator
    // values, then the least open value is selected.
    pure virtual function SCALAR_T get_next_unused_value();

    // Returns the static cast of the current value to int.
    // Fatals on X/Z or if SCALAR_T is wider than int.
    virtual function int get_int_value();
        SCALAR_T tmp = get_value();
        if ($isunknown(tmp)) begin
            $fatal(1, {"SV ENUM OBJECT FATAL: get_int_value() must not be ",
                "called on ", get_full_name(), " because the value (",
                $sformatf("'b%0b", tmp), ") contains unknown (X/Z) values ",
                "that cannot be represented by an 'int' type."});
        end
        if ($bits(SCALAR_T) > $bits(int)) begin
            $fatal(1, {"SV ENUM OBJECT FATAL: get_int_value() must not be ",
                "called on ", get_full_name(), " because the value type ",
                "requires more bits (",
                $sformatf("%0d", $bits(SCALAR_T)), ") than can be ",
                "stored in an 'int' (",
                $sformatf("%0d", $bits(int)), ")."});
        end
        return int'(tmp);
    endfunction

    // If you implement your own methods for the base class, then you should
    // call _init_obj before referencing the cached singleton '_obj'.
    //
    // For example:
    //     `DECL_SV_ENUM_OBJ_BEGIN(op)
    //         virtual function int calc(int a, int b);
    //             _init_obj();
    //             return _obj.calc(a, b);
    //         endfunction
    //     `DECL_SV_ENUM_OBJ_END
    //
    //     `DECL_SV_ENUM_OBJ_INST_BEGIN(op, add)
    //         virtual function int calc(int a, int b);
    //             return a + b;
    //         endfunction
    //     `DECL_SV_ENUM_OBJ_INST_END
    //
    //     `DECL_SV_ENUM_OBJ_INST_BEGIN(op, sub)
    //         virtual function int calc(int a, int b);
    //             return a - b;
    //         endfunction
    //     `DECL_SV_ENUM_OBJ_INST_END
    //
    // The implementation of _init_obj() is handled for you by the macros.
    // The implementation resolves a new singleton '_obj' after 'value' is
    // changed.
    protected pure virtual function void _init_obj();

    // Called by the constructor so that a valid value exists after the holder
    // is holding a valid enumerated type after allocation.
    protected pure virtual function void _init_randomizable_value();
endclass

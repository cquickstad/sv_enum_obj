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



`ifndef __SV_ENUM_OBJ_MACROS_SV__
`define __SV_ENUM_OBJ_MACROS_SV__

`define _SV_ENUM_OBJ_TYPE_STATICS \
        \
        protected static SCALAR_T _values[$]; \
        protected static SCALAR_T _two_value_values[$]; \
        protected static string _names[$]; \
        \
        protected static enum_obj_t _registry_value[SCALAR_T]; \
        protected static enum_obj_t _registry_name[string]; \
        \
        protected static string _extended_by = ""; \
        \
        protected static function enum_obj_t _lookup_by_value(SCALAR_T v); \
            _lookup_by_value = null; \
            if ($isunknown(v)) begin \
                foreach (_registry_name[n]) begin \
                    enum_obj_t e = _registry_name[n]; \
                    if (e.get_value() === v) begin \
                        _lookup_by_value = e; \
                        break; \
                    end \
                end \
            end else begin \
                if (_registry_value.exists(v)) begin \
                    _lookup_by_value = _registry_value[v]; \
                end \
            end \
        endfunction \
        \
        static function enum_obj_t get_by_value(SCALAR_T v); \
            get_by_value = _lookup_by_value(v); \
            if (get_by_value == null) begin \
                `ifdef XCELIUM $stacktrace; `endif \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                    $sformatf("%0s has no enumeration for value %p",\
                        _base_name, v)}); \
            end \
        endfunction \
        \
        static function enum_obj_t get_by_name(string n); \
            if (!_registry_name.exists(n)) begin \
                `ifdef XCELIUM $stacktrace; `endif \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                    $sformatf("%0s has no enumeration for name '%0s'",\
                        _base_name, n)}); \
                return null; \
            end \
            return _registry_name[n]; \
        endfunction \
        \
        protected static function int _num(); \
            return _values.size(); \
        endfunction \
        protected static function SCALAR_T _max_value(); \
            SCALAR_T q[$] = _two_value_values.max(); \
            if (q.size() > 0) return q[0]; \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, ".max_value: ", \
                $sformatf("Failed to find max value for '%0s' among values %p", \
                    _base_name, _values)}); \
        endfunction \
        protected static function SCALAR_T _min_value(); \
            SCALAR_T q[$] = _two_value_values.min(); \
            if (q.size() > 0) return q[0]; \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, ".min_value: ", \
                $sformatf("Failed to find min value for '%0s' among values %p", \
                    _base_name, _values)}); \
        endfunction \
        protected static function SCALAR_T _next_unused_value(); \
            enum_obj_t e; \
            SCALAR_T candidate, max; \
            if (_two_value_values.size() == 0) return '0; \
            candidate = _min_value(); \
            max = _max_value(); \
            forever begin \
                e = _lookup_by_value(candidate); \
                if (e == null) return candidate; \
                if (candidate === max) break; \
                candidate++; \
            end \
            candidate = max + SCALAR_T'(1); \
            e = _lookup_by_value(candidate); \
            if (e == null) return candidate; \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, \
                ".next_unused_value: There are no more available ", \
                "values in the type space."}); \
        endfunction

`define _SV_ENUM_OBJ_TYPE_VIRTUAL_METHODS_THAT_REFERENCE_STATICS \
        virtual function void set_by_name(string n); \
            set_by_value(get_by_name(n).get_value()); \
        endfunction \
        virtual function _string_q names(); return _names; endfunction \
        virtual function _scalar_t_q get_values(); return _values; endfunction \
        virtual function SCALAR_T max_value(); return _max_value(); endfunction \
        virtual function SCALAR_T min_value(); return _min_value(); endfunction \
        virtual function SCALAR_T next_unused_value(); return _next_unused_value(); endfunction \
        virtual function int num(); return _values.size(); endfunction \
        virtual function enum_obj_t next(); \
            SCALAR_T v = get_value(); \
            int i, qi[$] = _values.find_first_index() with (item === v); \
            if (qi.size() == 0) begin \
                `ifdef XCELIUM $stacktrace; `endif \
                $fatal(1, $sformatf("SV ENUM OBJECT FATAL: Unexpected: value %p not in values: %p", v, _values)); \
            end \
            i = qi[0] + 1; \
            if (i >= _values.size()) i = 0; \
            return get_by_value(_values[i]); \
        endfunction \
        virtual function enum_obj_t prev(); \
            SCALAR_T v = get_value(); \
            int i, qi[$] = _values.find_first_index() with (item === v); \
            if (qi.size() == 0) begin \
                `ifdef XCELIUM $stacktrace; `endif \
                $fatal(1, $sformatf("SV ENUM OBJECT FATAL: Unexpected: value %p not in values: %p", v, _values)); \
            end \
            i = qi[0] - 1; \
            if (i < 0) i = _values.size() - 1; \
            return get_by_value(_values[i]); \
        endfunction \
        virtual function enum_obj_t first(); \
            if (_values.size() == 0) $fatal(1, "SV ENUM OBJECT FATAL: Unexpected: empty enum"); \
            return get_by_value(_values[0]); \
        endfunction \
        virtual function enum_obj_t last(); \
            if (_values.size() == 0) $fatal(1, "SV ENUM OBJECT FATAL: Unexpected: empty enum"); \
            return get_by_value(_values[_values.size() - 1]); \
        endfunction \
        virtual function bit is_first(); \
            return is(first()); \
        endfunction \
        virtual function bit is_last(); \
            return is(last()); \
        endfunction \
        \
        // NOTE: randomization cannot work with X/Z. \
        //       Just as with native enums, randomization should ignore unknowns. \
        constraint value_must_exist_c {value inside {_two_value_values};} \
        protected virtual function void _init_obj(); \
            if ((_obj == null) || (_resolved_value !== value)) begin \
                _obj = get_by_value(value); \
                _resolved_value = value; \
            end \
        endfunction \
        function void post_randomize(); _init_obj(); endfunction \
        \
        // Only the ENUM_OBJ_TYPE is used as a wrapper for randomization.  The \
        // children must not call _initialize_value() because they are \
        // created before min_value() can be called (before anything is in \
        // _values). \
        protected virtual function void _initialize_value(); \
            if (_values.size() > 0) begin \
                value = _values[0]; \
                _init_obj(); \
            end \
        endfunction

// =============================================================================
// DECL_SV_ENUM_OBJ_BEGIN / END  — declare the enum *type* (holder class)
//
//   `DECL_SV_ENUM_OBJ(color, bit[2:0])
//     equivalent to BEGIN + empty body + END
//
// Put extra virtual methods that every enumerator should implement in the
// BEGIN...END body. Holder implementations must `_init_obj()` then delegate
// to `_obj` so randomization still picks the right singleton:
//
//   `DECL_SV_ENUM_OBJ_BEGIN(op)
//       virtual function int calc(int a, int b);
//           _init_obj();
//           return _obj.calc(a, b);
//       endfunction
//   `DECL_SV_ENUM_OBJ_END
//
// Then implement `calc` on each `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN` class.
// =============================================================================
`define DECL_SV_ENUM_OBJ_BEGIN(ENUM_OBJ_TYPE, SCALAR_TYPE=int) \
    \
    class ENUM_OBJ_TYPE extends sv_enum_obj#(SCALAR_TYPE); \
        \
        typedef ENUM_OBJ_TYPE enum_obj_t; \
        protected static string _base_name = `"ENUM_OBJ_TYPE`"; \
        \
        protected enum_obj_t _obj; \
        \
        `_SV_ENUM_OBJ_TYPE_STATICS \
        \
        `ifdef SV_ENUM_OBJ_UVM \
        `uvm_object_utils_begin(ENUM_OBJ_TYPE) \
            `uvm_field_int(value, UVM_ALL_ON) \
        `uvm_object_utils_end \
        `endif \
        function new(`ifdef SV_ENUM_OBJ_UVM string name=`"ENUM_OBJ_TYPE`" `endif); \
            super.new(`ifdef SV_ENUM_OBJ_UVM name `endif); \
        endfunction \
        \
        virtual function void set(enum_obj_t rhs); \
            set_by_value(rhs.get_value()); \
        endfunction \
        virtual function void set_first(); set(first()); endfunction \
        virtual function void set_last(); set(last()); endfunction \
        \
        virtual function sv_enum_obj_base get_singleton(); _init_obj(); return _obj.get_singleton(); endfunction \
        virtual function string name(); _init_obj(); return _obj.name(); endfunction \
        virtual function string base_name(); _init_obj(); return _obj.base_name(); endfunction \
        virtual function string full_name(); _init_obj(); return _obj.full_name(); endfunction \
        virtual function SCALAR_T get_value(); _init_obj(); return _obj.get_value(); endfunction \
        virtual function void increment(); \
            set(next()); \
        endfunction \
        virtual function void decrement(); \
            set(prev()); \
        endfunction \
        protected SCALAR_T _resolved_value; \
        `_SV_ENUM_OBJ_TYPE_VIRTUAL_METHODS_THAT_REFERENCE_STATICS

`define DECL_SV_ENUM_OBJ_END \
    endclass


`define DECL_SV_ENUM_OBJ(ENUM_OBJ_TYPE, SCALAR_TYPE=int) \
    `DECL_SV_ENUM_OBJ_BEGIN(ENUM_OBJ_TYPE, SCALAR_TYPE) \
    `DECL_SV_ENUM_OBJ_END

// =============================================================================
// DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN / END  — one enumerator (singleton class)
//
//   `DECL_SV_ENUM_OBJ_ENUMERATOR(color, red)        // encoding = next_unused_value()
//   `DECL_SV_ENUM_OBJ_ENUMERATOR(color, violet, 3)  // explicit encoding
//
// Declare INST macros *after* the matching DECL_SV_ENUM_OBJ[_BEGIN].
// Registration order is declaration order (static initializers).
//
// Override: a later INST with an already-used encoding (value) replaces the
// label in `names()`, redirects `::get()` / `get_by_value()` to the new
// singleton, and chains `name()` of the earlier INST to the final name.
//
// Duplicate *names* with different values are fatal.
// Duplicate names with the same value are begrudgingly allowed.
// (Duplicate names require defining each in a different package.)
//
// Do not `new()`, `randomize()`, or `set_*()` a singleton. Use `ENUM::get()`.
// =============================================================================
`define DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE=_next_unused_value()) \
    \
    class ENUM extends ENUM_OBJ_TYPE; \
        \
        protected static string _name = `"ENUM`"; \
        protected static string _full_name = {_base_name, ".", _name}; \
        protected static SCALAR_T _value = ENUM_VALUE; \
        protected static enum_obj_t _singleton; // Set by registration \
        static function enum_obj_t get(); \
            // Can't simply return singleton, because this value may have an \
            // override. \
            return get_by_value(_value); \
        endfunction \
        \
        protected static bit _side_effect = _register(); \
        protected static function bit _register(); \
            enum_obj_t e; \
            ENUM new_me = new(); \
            if (_extended_by != "") begin \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                    _name, " was added to ", _base_name, " *after* ", \
                    _extended_by, " was declared to extend ", _base_name, \
                    ".  Therefore, ", _name, \
                    " will be unexpectedly missing from ", _extended_by, \
                    ".  Include and declaration orders are important. ", \
                    _extended_by, " must be declared after ", _name, "."}); \
            end \
            _singleton = new_me; \
            if (_name inside {_names}) begin \
                if (_value === _registry_name[_name].get_value()) begin \
                    `ifdef VCS \
                    $display({"SV ENUM OBJECT CAUTION: An enumerator's ", \
                        "name (", _base_name, ".", _name, \
                        ") matched another ", \
                        "enumerator's name (", \
                        _registry_name[_name].full_name(), \
                        "). This is allowable because the values match ", \
                        "(value=", $sformatf("%0p", _value), "). ", \
                        "The enumerators are in different packages, ", \
                        "because it is not possible to declare two classes ", \
                        "of the same name in the same package."}); \
                    `else \
                    $display({"SV ENUM OBJECT CAUTION: An enumerator's ", \
                        "name (", _base_name, ".", _name, ", handle=", \
                        $sformatf("%0x", _singleton), \
                        ") matched another ", \
                        "enumerator's name (", \
                        _registry_name[_name].full_name(), ", handle=", \
                        $sformatf("%0x", _registry_name[_name]), \
                        "). This is allowable because the values match ", \
                        "(value=", $sformatf("%p", _value), "). ", \
                        "The enumerators are in different packages, ", \
                        "because it is not possible to declare two classes ", \
                        "of the same name in the same package."}); \
                    `endif \
                end else begin \
                    `ifdef VCS \
                    $fatal(1, {"SV ENUM OBJECT FATAL: An enumerator's ", \
                        "name (", _base_name, ".", _name, ", value=", \
                        $sformatf("%0p", _value), ") matched another ", \
                        "enumerator's name (", \
                        _registry_name[_name].full_name(), ", value=", \
                        $sformatf("%0p", _registry_name[_name].get_value()), \
                        "). This is not allowed because the values do not ", \
                        "match. Note that the enumerators are in different ", \
                        "packages, because it is not possible to declare ", \
                        "two classes of the same name in the same package."}); \
                    `else \
                    $fatal(1, {"SV ENUM OBJECT FATAL: An enumerator's ", \
                        "name (", _base_name, ".", _name, ", handle=", \
                        $sformatf("%0x", _singleton), ", value=", \
                        $sformatf("%0p", _value), ") matched another ", \
                        "enumerator's name (", \
                        _registry_name[_name].full_name(), ", handle=", \
                        $sformatf("%0x", _registry_name[_name]), \
                        ", value=", \
                        $sformatf("%0p", _registry_name[_name].get_value()), \
                        "). This is not allowed because the values do not ", \
                        "match. Note that the enumerators are in different ", \
                        "packages, because it is not possible to declare ", \
                        "two classes of the same name in the same package."}); \
                    `endif \
                end \
            end \
            e = _lookup_by_value(_value); \
            if (e != null) begin \
                enum_obj_t prev_enum = e; \
                string prev_name = prev_enum.name(); \
                // Replace the name, keeping the order the same: \
                int qi[$] = _names.find_first_index() with (item == prev_name); \
                string qs[$]; \
                _names[qi[0]] = _name; \
                if (_debug) begin \
                    `ifdef VCS \
                    $display("SV ENUM SINGLETON OVERRIDE: %0s.%0s -> %0s.%0s (value=%0p)", \
                        _base_name, prev_name, \
                        _base_name, _name, _value); \
                    `else \
                    $display("SV ENUM SINGLETON OVERRIDE: %0s.%0s(handle=%0x) -> %0s.%0s(handle=%0x) (value=%p)", \
                        _base_name, prev_name, prev_enum, \
                        _base_name, _name, _singleton, _value); \
                    `endif \
                end \
                // Support multiple overrides of the same value. All of the \
                // names should alias to the last override. \
                foreach (_registry_name[n]) begin \
                    if (_registry_name[n] == _registry_name[prev_name]) qs.push_back(n); \
                end \
                foreach (qs[i]) _registry_name[qs[i]] = _singleton; \
            end else begin \
                if (_debug) begin \
                    `ifdef VCS \
                    $display("SV ENUM SINGLETON REGISTERED: %0s.%0s (value=%0p)", \
                        _base_name, _name, _value); \
                    `else \
                    $display("SV ENUM SINGLETON REGISTERED: %0s.%0s (value=%p)", \
                        _base_name, _name, _value); \
                    `endif \
                end \
                _values.push_back(_value); \
                if (!$isunknown(_value)) _two_value_values.push_back(_value); \
                _names.push_back(_name); \
            end \
            if (!$isunknown(_value)) _registry_value[_value] = _singleton; \
            _registry_name[_name] = _singleton; \
            return 1; \
        endfunction \
        \
        static function SCALAR_T value(); \
            return _value; \
        endfunction \
        function new(); \
            super.new( `ifdef SV_ENUM_OBJ_UVM _name `endif ); \
            if ((_singleton != null) && (this != _singleton)) begin \
                `ifdef XCELIUM $stacktrace; `endif \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", full_name(), \
                    ": Attempted to create more than one singleton. Call '", \
                    _name, "::get()' or '", _base_name, \
                    "::get_by_value(<value>)' instead."}); \
            end \
            super.value = _value; // Allows .compare() to work using uvm field macro \
        endfunction \
        \
        virtual function bit is_holder(); return 0; endfunction \
        virtual function bit is_singleton(); return 1; endfunction \
        \
        function void pre_randomize(); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: Singleton enum-object ", \
                full_name(), " must not be randomized because its ", \
                "value cannot change!  Perhaps you intended ", \
                "to call randomize() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set_by_value(SCALAR_T v); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: set_by_value() must not be ", \
                "called on singleton enum-object ", full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set_by_name() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set(enum_obj_t rhs); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: set() must not be ", \
                "called on singleton enum-object ", full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set_by_name(string n); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: set_by_name() must not be ", \
                "called on singleton enum-object ", full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set_by_name() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void increment(); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: increment() must not be ", \
                "called on singleton enum-object ", full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call increment() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void decrement(); \
            `ifdef XCELIUM $stacktrace; `endif \
            $fatal(1, {"SV ENUM OBJECT FATAL: decrement() must not be ", \
                "called on singleton enum-object ", full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call decrement() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        protected virtual function void _init_obj(); _obj = null; endfunction \
        \
        virtual function sv_enum_obj_base get_singleton(); \
            return get_by_value(_value); \
        endfunction \
        virtual function string name(); \
            return _name; \
        endfunction \
        virtual function string base_name(); \
            return _base_name; \
        endfunction \
        virtual function string full_name(); \
            return _full_name; \
        endfunction \
        virtual function SCALAR_T get_value(); \
            return value(); \
        endfunction \
        virtual function _string_q names(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling names() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return {}; \
        endfunction \
        virtual function _scalar_t_q get_values(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling get_values() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return {}; \
        endfunction \
        virtual function SCALAR_T max_value(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling max_value() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return '0; \
        endfunction \
        virtual function SCALAR_T min_value(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling min_value() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return '0; \
        endfunction \
        virtual function SCALAR_T next_unused_value(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling next_unused_value() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return '0; \
        endfunction \
        virtual function int num(); \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                "Avoid calling num() on the singleton ", \
                "enumerator. Call only on an instance of the holder ", \
                "instead."}); \
            return -1; \
        endfunction \

`define DECL_SV_ENUM_OBJ_ENUMERATOR_END \
    endclass

`define DECL_SV_ENUM_OBJ_ENUMERATOR(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE=_next_unused_value()) \
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE) \
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END


// =============================================================================
// DECL_SV_ENUM_OBJ_EXTEND[_BEGIN/_END]
//
// New enum *type* with its own registries, seeded from BASE.
// BASE is left unchanged.
//
//   `DECL_SV_ENUM_OBJ(animal)
//   `DECL_SV_ENUM_OBJ_ENUMERATOR(animal, dog)
//
//   `DECL_SV_ENUM_OBJ_EXTEND(my_animal, animal)
//   `DECL_SV_ENUM_OBJ_ENUMERATOR(my_animal, cat)
//
// In the above example:
//  * animal contains only dog.
//  * my_animal contains both dog and cat.
//
// =============================================================================

`define DECL_SV_ENUM_OBJ_EXTEND_BEGIN(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    class ENUM_OBJ_TYPE extends BASE_ENUM_OBJ_TYPE; \
        protected static string _base_name = `"ENUM_OBJ_TYPE`"; \
        typedef BASE_ENUM_OBJ_TYPE parent_enum_obj_t; \
        \
        `_SV_ENUM_OBJ_TYPE_STATICS \
        \
        // Seed from BASE before any INST in this package registers. \
        protected static int _num_names_imported_from_base = _import_from_base(); \
        protected static function bit _import_from_base(); \
            _values = parent_enum_obj_t::_values; \
            _two_value_values = parent_enum_obj_t::_two_value_values; \
            _names = parent_enum_obj_t::_names; \
            _registry_value = parent_enum_obj_t::_registry_value; \
            _registry_name = parent_enum_obj_t::_registry_name; \
            parent_enum_obj_t::_extended_by = _base_name; \
            return _registry_name.size(); \
        endfunction \
        \
        `ifdef SV_ENUM_OBJ_UVM \
        `uvm_object_utils(ENUM_OBJ_TYPE) \
        function new(string name=`"ENUM_OBJ_TYPE`"); \
            super.new(name); \
        endfunction \
        `endif \
        \
        // Must overwrite the parent's virtual methods that reference statics \
        // that are re-implemented in this object because, although they have \
        // the same name, they are new/different implementations/instances \
        `_SV_ENUM_OBJ_TYPE_VIRTUAL_METHODS_THAT_REFERENCE_STATICS

`define DECL_SV_ENUM_OBJ_EXTEND_END \
    endclass

`define DECL_SV_ENUM_OBJ_EXTEND(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    `DECL_SV_ENUM_OBJ_EXTEND_BEGIN(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    `DECL_SV_ENUM_OBJ_EXTEND_END

`endif // __SV_ENUM_OBJ_MACROS_SV__

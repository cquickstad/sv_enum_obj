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
        protected static string _names[$]; \
        \
        protected static enum_obj_t _registry_value[SCALAR_T]; \
        protected static enum_obj_t _registry_name[string]; \
        \
        static function enum_obj_t get_by_value(SCALAR_T v); \
            if (!_registry_value.exists(v)) begin \
                $stacktrace; \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                    $sformatf("%0s has no enumeration for value 'h%0x",\
                        _base_name, v)}); \
                return null; \
            end \
            return _registry_value[v]; \
        endfunction \
        \
        static function enum_obj_t get_by_name(string n); \
            if (!_registry_name.exists(n)) begin \
                $stacktrace; \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", \
                    $sformatf("%0s has no enumeration for name '%0s'",\
                        _base_name, n)}); \
                return null; \
            end \
            return _registry_name[n]; \
        endfunction \
        \
        static function int num(); \
            return _values.size(); \
        endfunction \
        static function _scalar_t_q values(); \
            return _values; \
        endfunction \
        static function _string_q names(); \
            return _names; \
        endfunction \
        static function enum_obj_t first(); \
            return _registry_value[_values[0]]; \
        endfunction \
        static function enum_obj_t last(); \
            return _registry_value[_values[_values.size()-1]]; \
        endfunction \
        static function SCALAR_T max_value(); \
            SCALAR_T q[$] = _values.max(); \
            if (q.size() > 0) return q[0]; \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, ".max_value: ", \
                $sformatf("Failed to find max value for '%0s' among values %p", \
                    _base_name, _values)}); \
        endfunction \
        static function SCALAR_T min_value(); \
            SCALAR_T q[$] = _values.min(); \
            if (q.size() > 0) return q[0]; \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, ".min_value: ", \
                $sformatf("Failed to find min value for '%0s' among values %p", \
                    _base_name, _values)}); \
        endfunction \
        static function SCALAR_T next_unused_value(); \
            SCALAR_T candidate, max; \
            if (_values.size() == 0) return '0; \
            candidate = min_value(); \
            max = max_value(); \
            forever begin \
                if (!(candidate inside {_values})) return candidate; \
                if (candidate == max) break; \
                candidate++; \
            end \
            candidate = max + SCALAR_T'(1); \
            if (!(candidate inside {_values})) return candidate; \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _base_name, \
                ".next_unused_value: There are no more available ", \
                "values in the type space."}); \
        endfunction \
        static function string enum_type_name(); \
            return _base_name; \
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
// Then implement `calc` on each `DECL_SV_ENUM_OBJ_INST_BEGIN` class.
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
        `ifdef UVM_PKG_SV \
        `uvm_object_utils_begin(ENUM_OBJ_TYPE) \
            `uvm_field_int(value, UVM_ALL_ON) \
        `uvm_object_utils_end \
        `endif \
        function new(`ifdef UVM_PKG_SV string name=`"ENUM_OBJ_TYPE`" `endif); \
            super.new(`ifdef UVM_PKG_SV name `endif); \
        endfunction \
        \
        virtual function void set(enum_obj_t rhs); \
            set_by_value(rhs.get_value()); \
        endfunction \
        virtual function void set_by_name(string n); \
            set_by_value(get_by_name(n).get_value()); \
        endfunction \
        \
        virtual function sv_enum_obj_base get_singleton(); _init_obj(); return _obj.get_singleton(); endfunction \
        virtual function enum_obj_t get_``ENUM_OBJ_TYPE``_singleton(); _init_obj(); return _obj.get_``ENUM_OBJ_TYPE``_singleton(); endfunction \
        virtual function string get_enum_name(); _init_obj(); return _obj.get_enum_name(); endfunction \
        virtual function string get_enum_type_name(); _init_obj(); return _obj.get_enum_type_name(); endfunction \
        virtual function _string_q get_names(); return _names; endfunction \
        virtual function string get_full_name(); _init_obj(); return _obj.get_full_name(); endfunction \
        virtual function SCALAR_T get_value(); _init_obj(); return _obj.get_value(); endfunction \
        virtual function _scalar_t_q get_values(); return _values; endfunction \
        virtual function SCALAR_T get_max_value(); return max_value(); endfunction \
        virtual function SCALAR_T get_min_value(); return min_value(); endfunction \
        virtual function SCALAR_T get_next_unused_value(); return next_unused_value(); endfunction \
        virtual function int get_num(); return _values.size(); endfunction \
        virtual function enum_obj_t get_next(); _init_obj(); return _obj.get_next(); endfunction \
        virtual function enum_obj_t get_prev(); _init_obj(); return _obj.get_prev(); endfunction \
        virtual function enum_obj_t get_first(); _init_obj(); return _obj.get_first(); endfunction \
        virtual function enum_obj_t get_last(); _init_obj(); return _obj.get_last(); endfunction \
        protected SCALAR_T _resolved_value; \
        protected virtual function void _init_obj(); \
            if ((_obj == null) || (_resolved_value !== value)) begin \
                _obj = get_by_value(value); \
                _resolved_value = value; \
            end \
        endfunction \
        \
        // protected virtual function void _set_override(enum_obj_t new_type_singleton); \
        // endfunction \
        \
        constraint value_must_exist_c {value inside {_values};} \
        function void post_randomize(); _init_obj(); endfunction \
        \
        // Only the ENUM_OBJ_TYPE is used as a wrapper for randomization.  The \
        // children must not call _init_randomizable_value() because they are \
        // created before get_min_value() can be called (before anything is in \
        // _values). \
        protected virtual function void _init_randomizable_value(); \
            if (_values.size() > 0) begin \
                value = _values[0]; \
                _init_obj(); \
            end \
        endfunction

`define DECL_SV_ENUM_OBJ_END \
    endclass


`define DECL_SV_ENUM_OBJ(ENUM_OBJ_TYPE, SCALAR_TYPE=int) \
    `DECL_SV_ENUM_OBJ_BEGIN(ENUM_OBJ_TYPE, SCALAR_TYPE) \
    `DECL_SV_ENUM_OBJ_END

// =============================================================================
// DECL_SV_ENUM_OBJ_INST_BEGIN / END  — one enumerator (singleton class)
//
//   `DECL_SV_ENUM_OBJ_INST(color, red)           // encoding = next_unused_value()
//   `DECL_SV_ENUM_OBJ_INST(color, violet, 3)     // explicit encoding
//
// Declare INST macros *after* the matching DECL_SV_ENUM_OBJ[_BEGIN].
// Registration order is declaration order (static initializers).
//
// Override: a later INST with an already-used encoding replaces the label in
// `names()`, redirects `::get()` / `get_by_value()` to the new singleton, and
// chains `name()` / `full_name()` of the earlier INST to the final name.
//
// Duplicate *names* with different encodings are fatal.
//
// Do not `new()`, `randomize()`, or `set_*()` a singleton. Use `ENUM::get()`.
// =============================================================================
`define DECL_SV_ENUM_OBJ_INST_BEGIN(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE=next_unused_value()) \
    \
    class ENUM extends ENUM_OBJ_TYPE; \
        \
        protected static string _name = `"ENUM`"; \
        protected static string _full_name = {_base_name, ".", _name}; \
        protected static SCALAR_T _value = ENUM_VALUE; \
        // protected static enum_obj_t _override = null; \
        protected static enum_obj_t _singleton; // Set by registration \
        static function enum_obj_t get(); \
            if (_registry_value.exists(_value)) begin \
                return _registry_value[_value]; \
            end \
            $fatal(1, {"SV ENUM OBJECT FATAL: ", _name, "::get() was called ", \
                "but '", _full_name, "' was not registered with '", \
                _base_name, "'"}); \
        endfunction \
        \
        // protected virtual function void _set_override(enum_obj_t new_type_singleton); \
        //     _override = new_type_singleton; \
        // endfunction \
        \
        static bit _side_effect = _register(); \
        static function bit _register(); \
            ENUM new_me = new(); \
            _singleton = new_me; \
            // if (_name inside {_names}) begin \
            //     $fatal(1, {"SV ENUM OBJECT FATAL: An enumerator's name ", \
            //         "(", _base_name, ".", _name, ") matched another ", \
            //         "enumerator's name (probably from another package ", \
            //         "because it is not possible to declare ", \
            //         "two classes of the same name)."}); \
            //     return 0; \
            // end \
            if (_value inside {_values}) begin \
                enum_obj_t prev_enum = _registry_value[_value]; \
                string prev_name = prev_enum.get_enum_name(); \
                // Replace the name, keeping the order the same: \
                int qi[$] = _names.find_first_index() with (item == prev_name); \
                _names[qi[0]] = _name; \
                if (_debug) begin \
                    $display("SV ENUM SINGLETON OVERRIDE: %0s.%0s(handle=%0x) -> %0s.%0s(handle=%0x) (value=%p)", \
                        _base_name, prev_name, prev_enum, \
                        _base_name, _name, _singleton, _value); \
                end \
                // prev_enum._set_override(_singleton); // "protected," but can call _set_override() because prev_enum is the same type. \
                _registry_name[prev_name] = _singleton; \
            end else begin \
                if (_debug) begin \
                    $display("SV ENUM SINGLETON REGISTERED: %0s.%0s(handle=%0x) (value=%p)", \
                        _base_name, _name, _singleton, _value); \
                end \
                _values.push_back(_value); \
                _names.push_back(_name); \
            end \
            _registry_value[_value] = _singleton; \
            _registry_name[_name] = _singleton; \
        endfunction \
        \
        static function SCALAR_T value(); \
            return _value; \
        endfunction \
        static function string name(); \
            return _registry_value[_value].get_enum_name(); \
        endfunction \
        static function string full_name(); \
            return _registry_value[_value].get_full_name(); \
        endfunction \
        static function enum_obj_t next(); \
            int qi[$] = _values.find_first_index() with (item == _value); \
            int i = qi[0] + 1; \
            if (i >= _values.size()) i = 0; \
            return _registry_value[_values[i]]; \
        endfunction \
        static function enum_obj_t prev(); \
            int qi[$] = _values.find_first_index() with (item == _value); \
            int i = qi[0] - 1; \
            if (i <= 0) i = _values.size() - 1; \
            return _registry_value[_values[i]]; \
        endfunction \
        \
        function new(); \
            super.new( `ifdef UVM_PKG_SV _name `endif ); \
            if ((_singleton != null) && (this != _singleton)) begin \
                $stacktrace; \
                $fatal(1, {"SV ENUM OBJECT FATAL: ", get_full_name(), \
                    ": Attempted to create more than one singleton. Call '", \
                    _name, "::get()' or '", _base_name, \
                    "::get_by_value(<value>)' instead."}); \
            end \
        endfunction \
        \
        virtual function bit is_holder(); return 0; endfunction \
        virtual function bit is_singleton(); return 1; endfunction \
        \
        function void pre_randomize(); \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: Singleton enum-object ", \
                get_full_name(), " must not be randomized because its ", \
                "value cannot change!  Perhaps you intended ", \
                "to call randomize() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set_by_value(SCALAR_T v); \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: set_by_value() must not be ", \
                "called on singleton enum-object ", get_full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set_by_name() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set(enum_obj_t rhs); \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: set() must not be ", \
                "called on singleton enum-object ", get_full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        virtual function void set_by_name(string n); \
            $stacktrace; \
            $fatal(1, {"SV ENUM OBJECT FATAL: set_by_name() must not be ", \
                "called on singleton enum-object ", get_full_name(), \
                " because its value cannot change!  Perhaps you intended ", \
                "to call set_by_name() on the parent '", _base_name, \
                "' type of object instead."}); \
        endfunction \
        \
        protected virtual function void _init_obj(); _obj = null; endfunction \
        \
        virtual function sv_enum_obj_base get_singleton(); \
            return _registry_value[_value]; \
        endfunction \
        virtual function enum_obj_t get_``ENUM_OBJ_TYPE``_singleton(); \
            return _registry_value[_value]; \
        endfunction \
        virtual function string get_enum_name(); \
            return _name; \
        endfunction \
        virtual function string get_enum_type_name(); \
            return _base_name; \
        endfunction \
        virtual function string get_full_name(); \
            return _full_name; \
        endfunction \
        // Get the next enumerator singleton \
        virtual function enum_obj_t get_next(); \
            return next(); \
        endfunction \
        virtual function enum_obj_t get_prev(); \
            return prev(); \
        endfunction \
        virtual function enum_obj_t get_first(); \
            return first(); \
        endfunction \
        virtual function enum_obj_t get_last(); \
            return last(); \
        endfunction \
        virtual function SCALAR_T get_value(); \
            return value(); \
        endfunction \
        virtual function SCALAR_T get_max_value(); \
            return max_value(); \
        endfunction \
        virtual function SCALAR_T get_min_value(); \
            return min_value(); \
        endfunction \
        virtual function SCALAR_T get_next_unused_value(); \
            return next_unused_value(); \
        endfunction

`define DECL_SV_ENUM_OBJ_INST_END \
    endclass

`define DECL_SV_ENUM_OBJ_INST(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE=next_unused_value()) \
    `DECL_SV_ENUM_OBJ_INST_BEGIN(ENUM_OBJ_TYPE, ENUM, ENUM_VALUE) \
    `DECL_SV_ENUM_OBJ_INST_END

`endif // __SV_ENUM_OBJ_MACROS_SV__


// =============================================================================
// DECL_SV_ENUM_OBJ_EXTEND[_BEGIN/_END]
//
// New enum *type* in this package, with its own registries, seeded from BASE.
// BASE is left unchanged. Do not `import` BASE under the same simple name as
// ENUM_OBJ_TYPE (name collision). Pass the qualified type: foo::animal.
//
//   package bar;
//       import sv_enum_obj_pkg::*;
//       `DECL_SV_ENUM_OBJ_EXTEND(animal, foo::animal)
//       `DECL_SV_ENUM_OBJ_INST(animal, dog)
//   endpackage
//
// Copied encodings keep the parent's singleton handles, so
//   bar::animal::get_by_name("cat") == foo::cat::get()
// Overriding a copied encoding in this package updates only *this* type's
// maps. It does not call _set_override on the parent singleton (foo is safe).
// That last part requires the $cast guard in _register — see INST note below.
// =============================================================================

`define DECL_SV_ENUM_OBJ_EXTEND_BEGIN(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    class ENUM_OBJ_TYPE extends BASE_ENUM_OBJ_TYPE; \
        static string _base_name = `"ENUM_OBJ_TYPE`"; \
        typedef BASE_ENUM_OBJ_TYPE parent_enum_obj_t; \
        \
        `_SV_ENUM_OBJ_TYPE_STATICS \
        \
        // Seed from BASE before any INST in this package registers. \
        static bit _imported_from_base = _import_from_base(); \
        static function bit _import_from_base(); \
            SCALAR_T vs[$] = parent_enum_obj_t::values(); \
            string   ns[$] = parent_enum_obj_t::names(); \
            foreach (vs[i]) begin \
                enum_obj_t h = parent_enum_obj_t::get_by_value(vs[i]); \
                _values.push_back(vs[i]); \
                _names.push_back(ns[i]); \
                _registry_value[vs[i]] = h; \
                _registry_name[ns[i]]  = h; \
            end \
            return 1; \
        endfunction \
        \
        `ifdef UVM_PKG_SV \
        `uvm_object_utils(ENUM_OBJ_TYPE) \
        function new(string name=`"ENUM_OBJ_TYPE`"); \
            super.new(name); \
        endfunction \
        `endif \
        \
        // Must overwrite the parent's _init_obj() because get_by_value is \
        // static and needs to access this object's registry copied in from \
        // the _SV_ENUM_OBJ_TYPE_STATICS macro, not the  parent's copy from \
        // the same _SV_ENUM_OBJ_TYPE_STATICS macro.  Otherwise, the \
        // 'EXTEND'ed object will interfere/corrupt original parent's \
        // (BASE_ENUM_OBJ_TYPE) set of enumerators. \
        protected virtual function void _init_obj(); \
            if ((_obj == null) || (_resolved_value !== value)) begin \
                _obj = get_by_value(value); \
                _resolved_value = value; \
            end \
        endfunction \
        \
        // Must overwrite the parent's virtual methods that reference statics \
        // that are re-implemented in this object because, although they have \
        // the same name, they are new/different implementations/instances \
        virtual function _string_q get_names(); return _names; endfunction \
        virtual function _scalar_t_q get_values(); return _values; endfunction \
        virtual function int get_num(); return _values.size(); endfunction \
        virtual function SCALAR_T get_max_value(); return max_value(); endfunction \
        virtual function SCALAR_T get_min_value(); return min_value(); endfunction \
        virtual function SCALAR_T get_next_unused_value(); return next_unused_value(); endfunction \
        virtual function void set_by_name(string n); \
            set_by_value(get_by_name(n).get_value()); \
        endfunction \
        // virtual function enum_obj_t get_next(); return next(); endfunction \
        // virtual function enum_obj_t get_prev(); return prev(); endfunction \
        // virtual function enum_obj_t get_first(); return first(); endfunction \
        // virtual function enum_obj_t get_last(); return last(); endfunction \
        constraint value_must_exist_c {value inside {_values};}

`define DECL_SV_ENUM_OBJ_EXTEND_END \
    endclass

`define DECL_SV_ENUM_OBJ_EXTEND(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    `DECL_SV_ENUM_OBJ_EXTEND_BEGIN(ENUM_OBJ_TYPE, BASE_ENUM_OBJ_TYPE) \
    `DECL_SV_ENUM_OBJ_EXTEND_END

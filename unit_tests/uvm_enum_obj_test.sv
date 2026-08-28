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



// Import unit test framework (See https://github.com/cquickstad/uvm_unit)
`include "uvm_unit.svh"

// Import the code to test
`include "sv_enum_obj_pkg.sv"
import uvm_pkg::*;
import uvm_unit_pkg::*;
import sv_enum_obj_pkg::*;


`DECL_SV_ENUM_OBJ_BEGIN(opcode)
    virtual function int calc(int a, int b);
        _init_obj();
        return _obj.calc(a, b);
    endfunction
`DECL_SV_ENUM_OBJ_END
`DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, add)
    virtual function int calc(int a, int b); return a + b; endfunction
`DECL_SV_ENUM_OBJ_INST_END
`DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, sub)
    virtual function int calc(int a, int b); return a - b; endfunction
`DECL_SV_ENUM_OBJ_INST_END


`DECL_SV_ENUM_OBJ_EXTEND(bad_opcode, opcode)
`DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, bad_add, add::value())
    virtual function int calc(int a, int b); return a - b; endfunction
`DECL_SV_ENUM_OBJ_INST_END
`DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, bad_sub, sub::value())
    virtual function int calc(int a, int b); return a + b; endfunction
`DECL_SV_ENUM_OBJ_INST_END
`DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, third_op)
    virtual function int calc(int a, int b); return 0; endfunction
`DECL_SV_ENUM_OBJ_INST_END


`RUN_PHASE_TEST(test_factory_override_of_holder_object)
    opcode oc, oc2;
    set_type_override_by_type(opcode::get_type(), bad_opcode::get_type());
    oc = opcode::type_id::create("oc", this);
    oc2 = opcode::type_id::create("oc2", this);
    `ASSERT_STR_EQ(oc.get_type_name(), "bad_opcode");
    oc.set_by_name("add");
    `ASSERT_STR_EQ(oc.get_enum_name(), "bad_add")
    `ASSERT_EQ(oc.calc(2, 3), -1)
    oc2.set_by_name("sub");
    `ASSERT_FALSE(oc.compare(oc2))
    oc.set_by_name("bad_sub");
    `ASSERT_TRUE(oc.compare(oc2))
    `ASSERT_TRUE($cast(oc2, oc.clone()))
    `ASSERT_STR_EQ(oc2.get_enum_name(), "bad_sub")
    `ASSERT_EQ(oc.calc(2, 3), 5)
    `ASSERT_STR_EQ(oc.get_type_name(), "bad_opcode");
    `ASSERT_TRUE(oc.compare(oc2))
`END_RUN_PHASE_TEST


`RUN_PHASE_TEST(test_uvm_compare_methods_of_singletons)
    opcode a = sub::get();
    opcode b = add::get();
    `ASSERT_FALSE_LOG(a.compare(b), {a.get_enum_name(), " same as ", b.get_enum_name()})
    b = sub::get();
    `ASSERT_TRUE_LOG(b.compare(a), {b.get_enum_name(), " different from ", a.get_enum_name()})
`END_RUN_PHASE_TEST

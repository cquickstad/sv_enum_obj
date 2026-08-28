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
`include "sv_test.svh"

// Import the code to test
`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;


// Define an object-based enum for testing
`DECL_SV_ENUM_OBJ(color, bit[2:0])
`DECL_SV_ENUM_OBJ_INST(color, red) // 0
`DECL_SV_ENUM_OBJ_INST(color, green) // 1
`DECL_SV_ENUM_OBJ_INST(color, blue) // 2
`DECL_SV_ENUM_OBJ_INST(color, purple) // 3
`DECL_SV_ENUM_OBJ_INST(color, violet, 3) // Test overriding a value
`DECL_SV_ENUM_OBJ_INST(color, indigo, 3) // Test double-overriding a value


`SV_TEST(test_sv_enum_static_methods)
    `ASSERT_EQ(red::value(), 0)
    `ASSERT_EQ(green::value(), 1)
    `ASSERT_EQ(blue::value(), 2)
    `ASSERT_EQ(purple::value(), 3)
    `ASSERT_EQ(violet::value(), 3)

    `ASSERT_STR_EQ(red::name(), "red")
    `ASSERT_STR_EQ(green::name(), "green")
    `ASSERT_STR_EQ(blue::name(), "blue")
    `ASSERT_STR_EQ(purple::name(), "indigo") // Double override!
    `ASSERT_STR_EQ(violet::name(), "indigo") // Override!
    `ASSERT_STR_EQ(indigo::name(), "indigo")

    `ASSERT_STR_EQ(red::full_name(), "color.red")
    `ASSERT_STR_EQ(green::full_name(), "color.green")
    `ASSERT_STR_EQ(blue::full_name(), "color.blue")
    `ASSERT_STR_EQ(purple::full_name(), "color.indigo") // Double override!
    `ASSERT_STR_EQ(violet::full_name(), "color.indigo") // Override!
    `ASSERT_STR_EQ(indigo::full_name(), "color.indigo")
`END_SV_TEST


`SV_TEST(test_sv_enum_methods)
    sv_enum_obj_base e;
    color c;

    c = red::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 0)
    `ASSERT_EQ(c.get_value(), 0)
    `ASSERT_STR_EQ(e.get_enum_name(), "red")
    `ASSERT_STR_EQ(e.get_full_name(), "color.red")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())
    `ASSERT_TRUE($cast(c, e.get_singleton()))
    `ASSERT_EQ(e.get_singleton(), c.get_color_singleton())
    e = c.get_singleton();
    c = c.get_color_singleton();
    `ASSERT_STR_EQ(e.get_enum_name(), "red")
    `ASSERT_STR_EQ(c.get_enum_name(), "red")


    c = green::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 1)
    `ASSERT_EQ(c.get_value(), 1)
    `ASSERT_STR_EQ(e.get_enum_name(), "green")
    `ASSERT_STR_EQ(e.get_full_name(), "color.green")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = blue::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 2)
    `ASSERT_EQ(c.get_value(), 2)
    `ASSERT_STR_EQ(e.get_enum_name(), "blue")
    `ASSERT_STR_EQ(e.get_full_name(), "color.blue")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = purple::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.get_enum_name(), "indigo") // Double override!
    `ASSERT_STR_EQ(e.get_full_name(), "color.indigo") // Double override!
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = violet::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.get_enum_name(), "indigo") // Override
    `ASSERT_STR_EQ(e.get_full_name(), "color.indigo") // Override
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = indigo::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.get_enum_name(), "indigo") // Override
    `ASSERT_STR_EQ(e.get_full_name(), "color.indigo") // Override
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())
`END_SV_TEST


`SV_TEST(test_sv_enum_factory)
    `ASSERT_EQ(red::get(), color::get_by_value(0))
    `ASSERT_EQ(green::get(), color::get_by_value(1))
    `ASSERT_EQ(blue::get(), color::get_by_value(2))
    `ASSERT_EQ(indigo::get(), color::get_by_value(3))

    `ASSERT_TRUE_LOG(red::get() == color::get_by_name("red"), "mismatch red")
    `ASSERT_TRUE_LOG(green::get() == color::get_by_name("green"), "mismatch green")
    `ASSERT_TRUE_LOG(blue::get() == color::get_by_name("blue"), "mismatch blue")
    `ASSERT_TRUE_LOG(indigo::get() == color::get_by_name("indigo"), "mismatch indigo")

    `ASSERT_EQ(indigo::get(), purple::get())
    `ASSERT_EQ(indigo::get(), violet::get())
`END_SV_TEST


`SV_TEST(test_sv_enum_helpers)
    `ASSERT_EQ(color::max_value(), 3)
    `ASSERT_EQ(color::min_value(), 0)
    `ASSERT_EQ(color::next_unused_value(), 4)
    `ASSERT_AP_EQ_STR(color::values(), "'{'h0, 'h1, 'h2, 'h3}")
    `ASSERT_AP_EQ_STR(color::names(), "'{\"red\", \"green\", \"blue\", \"indigo\"}")
`END_SV_TEST


`SV_TEST(test_sv_enum_setters)
    color c = new();
    `ASSERT_TRUE(c.is_holder())
    `ASSERT_FALSE(c.is_singleton())

    c.set(green::get());
    `ASSERT_STR_EQ(c.get_enum_name(), "green")
    c.set_by_value(3);
    `ASSERT_STR_EQ(c.get_enum_name(), "indigo")
    c.set_by_name("blue");
    `ASSERT_STR_EQ(c.get_enum_name(), "blue")
    `ASSERT_EQ(c.get_value(), 2)
    `ASSERT_EQ(c.value, 2)
    c.set(purple::get());
    `ASSERT_STR_EQ(c.get_enum_name(), "indigo")
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_EQ(c.value, 3)

    // Bypassing the setter (not recommended)
    // (randomization sets 'value', but runs pre/post_randomize())
    c.value = 1;
    `ASSERT_STR_EQ(c.get_enum_name(), "green")
    `ASSERT_TRUE(c.is(green::get()))
`END_SV_TEST


`SV_TEST(test_sv_enum_set_membership)
    color a = new(), b = new(), c = new();
    a.set(green::get());
    b.set(blue::get());
    c.set(green::get());
    `ASSERT_TRUE(a.get_singleton() inside {b.get_singleton(), c.get_singleton()})
    `ASSERT_TRUE(a.get_singleton() inside {blue::get(), green::get()})
    a.set(red::get());
    `ASSERT_FALSE(a.get_singleton() inside {b.get_singleton(), c.get_singleton()})
    `ASSERT_FALSE(a.get_singleton() inside {blue::get(), green::get()})
`END_SV_TEST



// Define a class that can be used to randomize several of our object-based
// enums with constraints.
class item;
    rand color favorite, not_favorite;
    constraint color_c {
        favorite.value inside {red::value(), green::value()};
        !(not_favorite.value inside {red::value(), green::value()});
    }

    function new();
        favorite = new();
        not_favorite = new();
    endfunction

    virtual function string str();
        return {"ITEM: favorite:", favorite.get_full_name(), " not_favorite:", not_favorite.get_full_name()};
    endfunction

endclass

`SV_TEST(test_sv_enum_randomization_from_item)
    item i = new();
    repeat (1_000) begin
        `ASSERT_TRUE(i.randomize())
        `ASSERT_TRUE(i.favorite.get_value() inside {red::value(), green::value()})
        `ASSERT_FALSE(i.not_favorite.get_value() inside {red::value(), green::value()})
    end
`END_SV_TEST


class favorite_color extends color;
    constraint favorite_c {value inside {red::value(), green::value()};}
endclass


`SV_TEST(test_sv_enum_randomization_from_extension)
    favorite_color fc = new();
    `ASSERT_TRUE(fc.is_holder())
    `ASSERT_FALSE(fc.is_singleton())
    repeat (1_000) begin
        `ASSERT_TRUE(fc.randomize())
        `ASSERT_TRUE(fc.get_value() inside {red::value(), green::value()})
    end
`END_SV_TEST




// Define an EXTENDED object-based enum for testing
`DECL_SV_ENUM_OBJ_BEGIN(op)
    // The parent type must implement a pass-through to the contained singleton.
    virtual function int calc(int a, int b);
        _init_obj();
        return _obj.calc(a, b);
    endfunction
`DECL_SV_ENUM_OBJ_END

`DECL_SV_ENUM_OBJ_INST_BEGIN(op, add)
    virtual function int calc(int a, int b);
        return a + b;
    endfunction
`DECL_SV_ENUM_OBJ_INST_END

`DECL_SV_ENUM_OBJ_INST_BEGIN(op, sub)
    virtual function int calc(int a, int b);
        return a - b;
    endfunction
`DECL_SV_ENUM_OBJ_INST_END



`SV_TEST(test_sv_enum_with_user_methods)
    op my_op = new();
    repeat (100) begin
        int a = $urandom_range(0, 100);
        int b = $urandom_range(0, 100);
        int c;
        `ASSERT_TRUE(my_op.randomize())
        c = my_op.calc(a, b);
        case (my_op.get_enum_name())
            "add": `ASSERT_EQ(c, (a + b))
            "sub": `ASSERT_EQ(c, (a - b))
            default: `ASSERT_TRUE_LOG(0, {"unexpected op: ", my_op.get_enum_name()})
        endcase
        $display("%0s.calc(%0d, %0d) = %0d", my_op.get_enum_name(), a, b, c);
    end
`END_SV_TEST

`SV_TEST(test_sv_enum_passthrough_methods)
    op my_op = new();
    my_op.value = 0;
    `ASSERT_EQ(my_op.get_value(), 0)
    `ASSERT_STR_EQ(my_op.get_full_name(), "op.add")
    `ASSERT_EQ(my_op.get_min_value(), 0)
    `ASSERT_EQ(my_op.get_max_value(), 1)
    `ASSERT_EQ(my_op.get_next_unused_value(), 2)
    my_op.value = 1;
    `ASSERT_EQ(my_op.get_value(), 1)
    `ASSERT_STR_EQ(my_op.get_full_name(), "op.sub")
    `ASSERT_EQ(my_op.get_min_value(), 0)
    `ASSERT_EQ(my_op.get_max_value(), 1)
    `ASSERT_EQ(my_op.get_next_unused_value(), 2)
`END_SV_TEST



// Test enum without a zero value
`DECL_SV_ENUM_OBJ(animal)
`DECL_SV_ENUM_OBJ_INST(animal, fox, 9)
`DECL_SV_ENUM_OBJ_INST(animal, cat, 1000)
`DECL_SV_ENUM_OBJ_INST(animal, horse, 99)
`SV_TEST(test_sv_enum_no_zero_value)
    animal pet = new();
    // TEST IS NOT SETTING (OR RANDOMIZING) 'pet.value' ON PURPOSE TO TEST THE
    // INITIAL VALUE OF 'value'.
    `ASSERT_EQ(pet.get_value(), 9)
    `ASSERT_STR_EQ(pet.get_full_name(), "animal.fox")
    `ASSERT_EQ(pet.get_min_value(), 9)
    `ASSERT_EQ(pet.get_max_value(), 1000)
    `ASSERT_EQ(pet.get_next_unused_value(), 10)
`END_SV_TEST

`SV_TEST(test_sv_enum_next)
    animal pet = new();
    `ASSERT_STR_EQ(pet.get_enum_name(), "fox")
    pet = pet.get_next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "cat")
    pet = pet.get_next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "horse")
    pet = pet.get_next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "fox") // Wrap

    pet = fox::next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "cat")
    pet = cat::next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "horse")
    pet = horse::next();
    `ASSERT_STR_EQ(pet.get_enum_name(), "fox") // Wrap
`END_SV_TEST

`SV_TEST(test_sv_enum_associative_array_index)
    int aa[animal];
    aa[fox::get()] = 123;
    `ASSERT_TRUE(aa.exists(fox::get()));
    foreach (aa[i]) begin
        `ASSERT_STR_EQ(i.get_enum_name(), "fox")
        `ASSERT_EQ(aa[i], 123)
    end
`END_SV_TEST



// Test next_unused_value() with all values used except a gap in the middle.
`DECL_SV_ENUM_OBJ(value_gap_enum, reg[1:0])
`DECL_SV_ENUM_OBJ_INST(value_gap_enum, value_zero, 0)
// `DECL_SV_ENUM_OBJ_INST(value_gap_enum, value_one, 1) // 1 is missing
`DECL_SV_ENUM_OBJ_INST(value_gap_enum, value_two, 2)
`DECL_SV_ENUM_OBJ_INST(value_gap_enum, value_three, 3)
`SV_TEST(test_sv_enum_next_unused_value)
    value_gap_enum e = new();
    `ASSERT_EQ(e.get_next_unused_value(), 1)
`END_SV_TEST




`SV_TEST(test_sv_enum_is_method)
    color c = new();
    animal a = new();

    red r;
    fox f;
    `ASSERT_TRUE($cast(r, red::get()))
    `ASSERT_TRUE($cast(f, fox::get()))

    `ASSERT_TRUE(f.is(f))
    `ASSERT_TRUE(r.is(r))
    `ASSERT_TRUE(r.is(red::get()))

    c.set_by_name("red");
    a.set_by_name("cat");
    `ASSERT_TRUE(c.is(r))
    `ASSERT_FALSE(c.is(f))

    `ASSERT_FALSE(a.is(f))

    // null case
    `ASSERT_FALSE(a.is(null))
`END_SV_TEST


// Test extending the original enum-obj from another package.
// Here is the "original" that the next package will extend:
package original_pkg;
    `DECL_SV_ENUM_OBJ_BEGIN(animal, logic [3:0])
        virtual function int get_num_legs();
            _init_obj();
            return _obj.get_num_legs();
        endfunction
        virtual function bit can_ride();
            _init_obj();
            return _obj.can_ride();
        endfunction
    `DECL_SV_ENUM_OBJ_END


    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, bird, 4'b0000)
        virtual function int get_num_legs(); return 2; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_INST_END

    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, horse, 4'b0001)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 1; endfunction
    `DECL_SV_ENUM_OBJ_INST_END

    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, dog, 4'b0010)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_INST_END

    // Implement some functionality in the original package that uses the enum.
    function automatic string explain_all_animals();
        animal a = new();
        a.set(a.get_first());
        explain_all_animals = "";
        repeat (animal::num()) begin
            explain_all_animals = {explain_all_animals, "\n", explain_animal(a)};
            a.set(a.get_next());
        end
    endfunction

    function automatic string explain_animal(animal a);
        int legs;
        string ride;
        legs = a.get_num_legs();
        ride = a.can_ride() ? "may" : "may not";
        return $sformatf("The %0s has %0d legs and you %0s ride it.",
            a.get_enum_name(), legs, ride);
    endfunction
endpackage

// The subsequent package represents another project extending and modifying
// the functionality in the original project without touching the original code.
package subsequent_pkg;
    import original_pkg::*;

    // Add new animals from another package
    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, deer, 4'b0011)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_INST_END

    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, elephant, 4'b0100)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 1; endfunction
    `DECL_SV_ENUM_OBJ_INST_END

    // Override an animal from another package.
    // Reduce the number of legs on the dog. Sorry pooch.
    `DECL_SV_ENUM_OBJ_INST_BEGIN(animal, maimed_dog, 4'b0010)
        virtual function int get_num_legs(); return 3; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_INST_END
endpackage

`SV_TEST(test_sv_enum_packaged_and_extended_animals)
    // Interesting. If you don't do something with the second package, Xcelium
    // will optimize it away and you never see the extensions.
    int tmp = subsequent_pkg::maimed_dog::value();

    // subsequent_pkg has modified original_pkg without changing it's code:
    string s = original_pkg::explain_all_animals();
    `ASSERT_STR_EQ(s,
        {"\nThe bird has 2 legs and you may not ride it.",
         "\nThe horse has 4 legs and you may ride it.",
         "\nThe maimed_dog has 3 legs and you may not ride it.",
         "\nThe deer has 4 legs and you may not ride it.",
         "\nThe elephant has 4 legs and you may ride it."})

`END_SV_TEST


// Test constraints that use methods of the enum object:
class item_with_constraint_that_uses_enum_methods;

    rand original_pkg::animal a;
    rand int payload;

    constraint c {
        // PROBLEM: a's object handle is not set to point to
        //          the correct singleton type until
        //          post_randomize(). The methods simply don't
        //          work until after the correct object is
        //          determined.  Remember that randomization
        //          involves a.value directly.
        //
        // if (a.can_ride()) {
        //     payload == a.get_num_legs() * 100;
        // } else {
        //     payload == 5;
        // }
        //
        // WORKAROUND: use a helper function to lookup the
        //             singleton and use the methods:
        payload == payload_helper_function(a.value);
    }

    function new();
        a = new();
    endfunction

    virtual function int payload_helper_function(int a_value);
        original_pkg::animal tmp = original_pkg::animal::get_by_value(a_value);
        return (tmp.can_ride()) ? tmp.get_num_legs() * 100 : 5;
    endfunction
endclass

`SV_TEST(test_sv_enum_constraints_with_methods)
    bit can_ride_seen = 0;
    bit cannot_ride_seen = 0;
    item_with_constraint_that_uses_enum_methods i = new();
    repeat (20) begin
        `ASSERT_TRUE(i.randomize())
        if (i.a.can_ride()) begin
            `ASSERT_EQ(i.payload, i.a.get_num_legs() * 100)
        end else begin
            `ASSERT_EQ(i.payload, 5)
        end
        can_ride_seen |= i.a.can_ride();
        cannot_ride_seen |= !i.a.can_ride();
    end
    `ASSERT_TRUE(can_ride_seen)
    `ASSERT_TRUE(cannot_ride_seen)
`END_SV_TEST


// Test extending and using an enum object in a second package, but the first
// package is left alone. The additions and changes are only visible in the
// second package:
package first_pkg;
    `DECL_SV_ENUM_OBJ_BEGIN(opcode)
        virtual function int calc(int a, int b);
            _init_obj();
            return _obj.calc(a, b);
        endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, add)
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, sub)
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_END
endpackage

package second_pkg;
    `DECL_SV_ENUM_OBJ_EXTEND(opcode, first_pkg::opcode)
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, shift_left)
        virtual function int calc(int a, int b); return a << b; endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, sub, first_pkg::sub::value())
        virtual function int calc(int a, int b); return (a > b) ? (a - b) : (b - a); endfunction
    `DECL_SV_ENUM_OBJ_END
endpackage

`SV_TEST(test_sv_enum_extended_in_another_package_without_changing_the_original)
    first_pkg::opcode opc1 = new();
    second_pkg::opcode opc2 = new();
    string s1[$] = first_pkg::opcode::names();
    string s2[$] = second_pkg::opcode::names();
    `ASSERT_AP_EQ_STR(s1, "'{\"add\", \"sub\"}")

    // Same name for "sub", but it's really a different one in a different package
    `ASSERT_AP_EQ_STR(s2, "'{\"add\", \"sub\", \"shift_left\"}")

    opc1.set(first_pkg::sub::get());
    `ASSERT_STR_EQ(opc1.get_enum_name(), "sub")
    `ASSERT_EQ(opc1.calc(2, 3), -1)

    // Same name for "sub", but it's really a different one in a different package
    opc2.set_by_name("sub");
    `ASSERT_STR_EQ(opc2.get_enum_name(), "sub")
    `ASSERT_EQ(opc2.calc(2, 3), 1) // Original overridden with absolute value
`END_SV_TEST


// Test overriding an enum in a single package (the base name and enum names
// must be different because they are classes in the same namespace).
package one_single_pkg;
    `DECL_SV_ENUM_OBJ_BEGIN(opcode)
        virtual function int calc(int a, int b);
            _init_obj();
            return _obj.calc(a, b);
        endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, add)
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(opcode, sub)
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_END

    `DECL_SV_ENUM_OBJ_EXTEND(bad_opcode, opcode)
    `DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, bad_add, add::value())
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, bad_sub, sub::value())
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_END
    `DECL_SV_ENUM_OBJ_INST_BEGIN(bad_opcode, third_op)
        virtual function int calc(int a, int b); return 0; endfunction
    `DECL_SV_ENUM_OBJ_END
endpackage

`SV_TEST(test_sv_enum_extended_in_the_same_package_without_changing_the_original)
    one_single_pkg::opcode good = new();
    one_single_pkg::bad_opcode bad = new();
    string s1[$] = one_single_pkg::opcode::names();
    string s2[$] = one_single_pkg::bad_opcode::names();
    `ASSERT_AP_EQ_STR(s1, "'{\"add\", \"sub\"}")
    `ASSERT_AP_EQ_STR(s2, "'{\"bad_add\", \"bad_sub\", \"third_op\"}")
    s1 = good.get_names();
    s2 = bad.get_names();
    `ASSERT_AP_EQ_STR(s1, "'{\"add\", \"sub\"}")
    `ASSERT_AP_EQ_STR(s2, "'{\"bad_add\", \"bad_sub\", \"third_op\"}")
    `ASSERT_EQ(good.num(), 2)
    `ASSERT_EQ(bad.num(), 3)

    good.set_by_name("sub");
    `ASSERT_STR_EQ(good.get_enum_name(), "sub")
    `ASSERT_EQ(good.calc(2, 3), -1)

    bad.set_by_name("sub");
    `ASSERT_STR_EQ(bad.get_enum_name(), "bad_sub")
    `ASSERT_EQ(bad.calc(2, 3), 5)

    bad.set_by_name("third_op");
    `ASSERT_STR_EQ(bad.get_enum_name(), "third_op")
    `ASSERT_EQ(bad.calc(2, 3), 0)

    `ASSERT_AP_EQ_STR(bad.get_values(), "'{0, 1, 2}")
    `ASSERT_EQ(bad.get_num(), 3)
    `ASSERT_EQ(bad.get_max_value(), 2)
    `ASSERT_EQ(bad.get_next_unused_value(), 3)

    `ASSERT_TRUE(bad.randomize() with {value == 2;})

    bad.set(one_single_pkg::add::get());
    `ASSERT_STR_EQ(bad.get_enum_name(), "bad_add")
    bad.set(bad.get_next());
    `ASSERT_STR_EQ(bad.get_enum_name(), "bad_sub")
    bad.set(bad.get_next());
    `ASSERT_STR_EQ(bad.get_enum_name(), "third_op")
    bad.set(bad.get_prev());
    `ASSERT_STR_EQ(bad.get_enum_name(), "bad_sub")
    bad.set(bad.get_first());
    `ASSERT_STR_EQ(bad.get_enum_name(), "bad_add")
    bad.set(bad.get_last());
    `ASSERT_STR_EQ(bad.get_enum_name(), "third_op")

    // Wrap cases
    `ASSERT_EQ(one_single_pkg::third_op::next(), one_single_pkg::bad_add::get())
    `ASSERT_EQ(one_single_pkg::bad_add::prev(), one_single_pkg::third_op::get())

    good.set_by_name("sub");
    `ASSERT_EQ(good.get_next(), one_single_pkg::add::get())
    bad.set_by_name("sub");
    bad.set(bad.get_next());
    `ASSERT_STR_EQ(bad.get_enum_name(), "third_op")
`END_SV_TEST

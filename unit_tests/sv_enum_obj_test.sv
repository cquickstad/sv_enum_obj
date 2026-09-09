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
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, red) // 0
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, green) // 1
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, blue) // 2
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, purple) // 3
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, violet, 3) // Test overriding a value
`DECL_SV_ENUM_OBJ_ENUMERATOR(color, indigo, 3) // Test double-overriding a value


`SV_TEST(test_sv_enum_static_methods)
    `ASSERT_EQ(red::value(), 0)
    `ASSERT_EQ(green::value(), 1)
    `ASSERT_EQ(blue::value(), 2)
    `ASSERT_EQ(purple::value(), 3)
    `ASSERT_EQ(violet::value(), 3)
`END_SV_TEST


`SV_TEST(test_sv_enum_methods)
    sv_enum_obj_base e;
    color c;

    c = red::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 0)
    `ASSERT_EQ(c.get_value(), 0)
    `ASSERT_STR_EQ(e.name(), "red")
    `ASSERT_STR_EQ(e.full_name(), "color.red")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())
    `ASSERT_TRUE($cast(c, e.get_singleton()))
    e = c.get_singleton();
    `ASSERT_STR_EQ(e.name(), "red")
    `ASSERT_STR_EQ(c.name(), "red")


    c = green::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 1)
    `ASSERT_EQ(c.get_value(), 1)
    `ASSERT_STR_EQ(e.name(), "green")
    `ASSERT_STR_EQ(e.full_name(), "color.green")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = blue::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 2)
    `ASSERT_EQ(c.get_value(), 2)
    `ASSERT_STR_EQ(e.name(), "blue")
    `ASSERT_STR_EQ(e.full_name(), "color.blue")
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = purple::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.name(), "indigo") // Double override!
    `ASSERT_STR_EQ(e.full_name(), "color.indigo") // Double override!
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = violet::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.name(), "indigo") // Override
    `ASSERT_STR_EQ(e.full_name(), "color.indigo") // Override
    `ASSERT_FALSE(e.is_holder())
    `ASSERT_TRUE(e.is_singleton())

    c = indigo::get();
    e = c;
    `ASSERT_EQ(e.get_int_value(), 3)
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_STR_EQ(e.name(), "indigo") // Override
    `ASSERT_STR_EQ(e.full_name(), "color.indigo") // Override
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

    `ASSERT_STR_EQ(color::get_by_name("violet").name(), "indigo")
    `ASSERT_STR_EQ(color::get_by_name("purple").name(), "indigo")
`END_SV_TEST


`SV_TEST(test_sv_enum_traverse_using_base)
    color c = new();
    sv_enum_obj_base b = c;
    b.set_first();
    `ASSERT_TRUE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "red")
    b.increment();
    `ASSERT_FALSE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "green")
    b.increment();
    `ASSERT_FALSE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "blue")
    b.increment();
    `ASSERT_FALSE(b.is_first()) `ASSERT_TRUE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "indigo")
    b.increment();
    `ASSERT_TRUE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "red")
    b.set_last();
    `ASSERT_FALSE(b.is_first()) `ASSERT_TRUE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "indigo")
    b.decrement();
    `ASSERT_FALSE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "blue")
    b.decrement();
    `ASSERT_FALSE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "green")
    b.decrement();
    `ASSERT_TRUE(b.is_first()) `ASSERT_FALSE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "red")
    b.decrement();
    `ASSERT_FALSE(b.is_first()) `ASSERT_TRUE(b.is_last())
    `ASSERT_STR_EQ(b.name(), "indigo")
`END_SV_TEST


`SV_TEST(test_sv_enum_helpers)
    color c = new();
    `ASSERT_EQ(c.max_value(), 3)
    `ASSERT_EQ(c.min_value(), 0)
    `ASSERT_EQ(c.next_unused_value(), 4)
    `ASSERT_AP_EQ_STR(c.get_values(), "'{'h0, 'h1, 'h2, 'h3}")
    `ASSERT_AP_EQ_STR(c.names(), "'{\"red\", \"green\", \"blue\", \"indigo\"}")
`END_SV_TEST


`SV_TEST(test_sv_enum_setters)
    color c = new();
    `ASSERT_TRUE(c.is_holder())
    `ASSERT_FALSE(c.is_singleton())

    c.set(green::get());
    `ASSERT_STR_EQ(c.name(), "green")
    c.set_by_value(3);
    `ASSERT_STR_EQ(c.name(), "indigo")
    c.set_by_int(3);
    `ASSERT_STR_EQ(c.name(), "indigo")
    c.set_by_name("blue");
    `ASSERT_STR_EQ(c.name(), "blue")
    `ASSERT_EQ(c.get_value(), 2)
    `ASSERT_EQ(c.value, 2)
    c.set(purple::get());
    `ASSERT_STR_EQ(c.name(), "indigo")
    `ASSERT_EQ(c.get_value(), 3)
    `ASSERT_EQ(c.value, 3)

    // Bypassing the setter (not recommended)
    // (randomization sets 'value', but runs pre/post_randomize())
    c.value = 1;
    `ASSERT_STR_EQ(c.name(), "green")
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
        return {"ITEM: favorite:", favorite.full_name(), " not_favorite:", not_favorite.full_name()};
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

`DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(op, add)
    virtual function int calc(int a, int b);
        return a + b;
    endfunction
`DECL_SV_ENUM_OBJ_ENUMERATOR_END

`DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(op, sub)
    virtual function int calc(int a, int b);
        return a - b;
    endfunction
`DECL_SV_ENUM_OBJ_ENUMERATOR_END



`SV_TEST(test_sv_enum_with_user_methods)
    op my_op = new();
    repeat (100) begin
        int a = $urandom_range(0, 100);
        int b = $urandom_range(0, 100);
        int c;
        `ASSERT_TRUE(my_op.randomize())
        c = my_op.calc(a, b);
        case (my_op.name())
            "add": `ASSERT_EQ(c, (a + b))
            "sub": `ASSERT_EQ(c, (a - b))
            default: `ASSERT_TRUE_LOG(0, {"unexpected op: ", my_op.name()})
        endcase
        $display("%0s.calc(%0d, %0d) = %0d", my_op.name(), a, b, c);
    end
`END_SV_TEST

`SV_TEST(test_sv_enum_passthrough_methods)
    op my_op = new();
    my_op.value = 0;
    `ASSERT_EQ(my_op.get_value(), 0)
    `ASSERT_STR_EQ(my_op.full_name(), "op.add")
    `ASSERT_EQ(my_op.min_value(), 0)
    `ASSERT_EQ(my_op.max_value(), 1)
    `ASSERT_EQ(my_op.next_unused_value(), 2)
    my_op.value = 1;
    `ASSERT_EQ(my_op.get_value(), 1)
    `ASSERT_STR_EQ(my_op.full_name(), "op.sub")
    `ASSERT_EQ(my_op.min_value(), 0)
    `ASSERT_EQ(my_op.max_value(), 1)
    `ASSERT_EQ(my_op.next_unused_value(), 2)
`END_SV_TEST



// Test enum without a zero value
`DECL_SV_ENUM_OBJ(animal)
`DECL_SV_ENUM_OBJ_ENUMERATOR(animal, fox, 9)
`DECL_SV_ENUM_OBJ_ENUMERATOR(animal, cat, 1000)
`DECL_SV_ENUM_OBJ_ENUMERATOR(animal, horse, 99)
`SV_TEST(test_sv_enum_no_zero_value)
    animal pet = new();
    // TEST IS NOT SETTING (OR RANDOMIZING) 'pet.value' ON PURPOSE TO TEST THE
    // INITIAL VALUE OF 'value'.
    `ASSERT_EQ(pet.get_value(), 9)
    `ASSERT_STR_EQ(pet.full_name(), "animal.fox")
    `ASSERT_EQ(pet.min_value(), 9)
    `ASSERT_EQ(pet.max_value(), 1000)
    `ASSERT_EQ(pet.next_unused_value(), 10)
`END_SV_TEST

`SV_TEST(test_sv_enum_next)
    animal pet = new();
    `ASSERT_STR_EQ(pet.name(), "fox")
    pet = pet.next(); // Warning! pet is now an immutable singleton! (Prefer pet.increment() instead)
    `ASSERT_STR_EQ(pet.name(), "cat")
    pet = pet.next(); // Warning! pet is now an immutable singleton! (Prefer pet.increment() instead)
    `ASSERT_STR_EQ(pet.name(), "horse")
    pet = pet.next(); // Warning! pet is now an immutable singleton! (Prefer pet.increment() instead)
    `ASSERT_STR_EQ(pet.name(), "fox") // Wrap

    pet = new();
    pet.set(fox::get());
    pet.set(pet.next());
    `ASSERT_STR_EQ(pet.name(), "cat")
    pet.set(pet.next());
    `ASSERT_STR_EQ(pet.name(), "horse")
    pet.set(pet.next());
    `ASSERT_STR_EQ(pet.name(), "fox") // Wrap

    pet = new();
    pet.set(fox::get());
    pet.increment();
    `ASSERT_STR_EQ(pet.name(), "cat")
    pet.increment();
    `ASSERT_STR_EQ(pet.name(), "horse")
    pet.increment();
    `ASSERT_STR_EQ(pet.name(), "fox") // Wrap
`END_SV_TEST

`SV_TEST(test_sv_enum_associative_array_index)
    int aa[animal];
    aa[fox::get()] = 123;
    `ASSERT_TRUE(aa.exists(fox::get()));
    foreach (aa[i]) begin
        `ASSERT_STR_EQ(i.name(), "fox")
        `ASSERT_EQ(aa[i], 123)
    end
`END_SV_TEST



// Test next_unused_value() with all values used except a gap in the middle.
`DECL_SV_ENUM_OBJ(value_gap_enum, reg[1:0])
`DECL_SV_ENUM_OBJ_ENUMERATOR(value_gap_enum, value_zero, 0)
// `DECL_SV_ENUM_OBJ_ENUMERATOR(value_gap_enum, value_one, 1) // 1 is missing
`DECL_SV_ENUM_OBJ_ENUMERATOR(value_gap_enum, value_two, 2)
`DECL_SV_ENUM_OBJ_ENUMERATOR(value_gap_enum, value_three, 3)
`SV_TEST(test_sv_enum_next_unused_value)
    value_gap_enum e = new();
    `ASSERT_EQ(e.next_unused_value(), 1)
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


    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, bird, 4'b0000)
        virtual function int get_num_legs(); return 2; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, horse, 4'b0001)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 1; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, dog, 4'b0010)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    // Implement some functionality in the original package that uses the enum.
    function automatic string explain_all_animals();
        animal a = new();
        a.set(a.first());
        explain_all_animals = "";
        repeat (a.num()) begin
            explain_all_animals = {explain_all_animals, "\n", explain_animal(a)};
            a.increment();
        end
    endfunction

    function automatic string explain_animal(animal a);
        int legs;
        string ride;
        legs = a.get_num_legs();
        ride = a.can_ride() ? "may" : "may not";
        return $sformatf("The %0s has %0d legs and you %0s ride it.",
            a.name(), legs, ride);
    endfunction
endpackage

// The subsequent package represents another project extending and modifying
// the functionality in the original project without touching the original code.
// WARNING: THIS IS AN EXAMPLE OF MONKEY-PATCHING. THIS TECHNIQUE IS A LAST-RESORT.
package subsequent_pkg;
    import original_pkg::*;

    // WARNING!!!
    //
    // THIS IS AN EXAMPLE OF MONKEY-PATCHING.
    // THIS TECHNIQUE IS A LAST-RESORT.

    // Add new animals from another package
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, deer, 4'b0011)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, elephant, 4'b0100)
        virtual function int get_num_legs(); return 4; endfunction
        virtual function bit can_ride(); return 1; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    // Override an animal from another package.
    // Reduce the number of legs on the dog. Sorry pooch.
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(animal, maimed_dog, 4'b0010)
        virtual function int get_num_legs(); return 3; endfunction
        virtual function bit can_ride(); return 0; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
endpackage

`SV_TEST(test_sv_enum_packaged_and_extended_animals)
    // Interesting. If you don't do something with the second package, Xcelium
    // will optimize it away and you never see the extensions.
    int tmp = subsequent_pkg::maimed_dog::value();

    // subsequent_pkg has modified original_pkg without changing it's code:
    string s = original_pkg::explain_all_animals();
    // subsequent_pkg monkey-patched the original_pkg
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
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, add)
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, sub)
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
endpackage

package second_pkg;
    // This is object-oriented inheritance and should be preferred over
    // the monkey-patching approach.
    `DECL_SV_ENUM_OBJ_EXTEND(opcode, first_pkg::opcode)
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, shift_left)
        virtual function int calc(int a, int b); return a << b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, sub, first_pkg::sub::value())
        virtual function int calc(int a, int b); return (a > b) ? (a - b) : (b - a); endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
endpackage

`SV_TEST(test_sv_enum_extended_in_another_package_without_changing_the_original)
    first_pkg::opcode opc1 = new();
    second_pkg::opcode opc2 = new();
    string s1[$] = opc1.names();
    string s2[$] = opc2.names();
    `ASSERT_AP_EQ_STR(s1, "'{\"add\", \"sub\"}")

    // Same name for "sub", but it's really a different one in a different package
    `ASSERT_AP_EQ_STR(s2, "'{\"add\", \"sub\", \"shift_left\"}")

    opc1.set(first_pkg::sub::get());
    `ASSERT_STR_EQ(opc1.name(), "sub")
    `ASSERT_EQ(opc1.calc(2, 3), -1)

    // Same name for "sub", but it's really a different one in a different package
    opc2.set_by_name("sub");
    `ASSERT_STR_EQ(opc2.name(), "sub")
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
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, add)
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(opcode, sub)
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END

    `DECL_SV_ENUM_OBJ_EXTEND(bad_opcode, opcode)
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(bad_opcode, bad_add, add::value())
        virtual function int calc(int a, int b); return a - b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(bad_opcode, bad_sub, sub::value())
        virtual function int calc(int a, int b); return a + b; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
    `DECL_SV_ENUM_OBJ_ENUMERATOR_BEGIN(bad_opcode, third_op)
        virtual function int calc(int a, int b); return 0; endfunction
    `DECL_SV_ENUM_OBJ_ENUMERATOR_END
endpackage

`SV_TEST(test_sv_enum_extended_in_the_same_package_without_changing_the_original)
    one_single_pkg::opcode good = new();
    one_single_pkg::bad_opcode bad = new();
    string s1[$] = good.names();
    string s2[$] = bad.names();
    `ASSERT_AP_EQ_STR(s1, "'{\"add\", \"sub\"}")
    `ASSERT_AP_EQ_STR(s2, "'{\"bad_add\", \"bad_sub\", \"third_op\"}")

    `ASSERT_EQ(good.num(), 2)
    `ASSERT_EQ(bad.num(), 3)

    good.set_by_name("sub");
    `ASSERT_STR_EQ(good.name(), "sub")
    `ASSERT_EQ(good.calc(2, 3), -1)

    bad.set_by_name("sub");
    `ASSERT_STR_EQ(bad.name(), "bad_sub")
    `ASSERT_EQ(bad.calc(2, 3), 5)

    bad.set_by_name("third_op");
    `ASSERT_STR_EQ(bad.name(), "third_op")
    `ASSERT_EQ(bad.calc(2, 3), 0)

    `ASSERT_AP_EQ_STR(bad.get_values(), "'{0, 1, 2}")
    `ASSERT_EQ(bad.num(), 3)
    `ASSERT_EQ(bad.max_value(), 2)
    `ASSERT_EQ(bad.next_unused_value(), 3)

    `ASSERT_TRUE(bad.randomize() with {value == 2;})

    bad.set(one_single_pkg::add::get());
    `ASSERT_STR_EQ(bad.name(), "bad_add")
    bad.increment();
    `ASSERT_STR_EQ(bad.name(), "bad_sub")
    bad.increment();
    `ASSERT_STR_EQ(bad.name(), "third_op")
    bad.decrement();
    `ASSERT_STR_EQ(bad.name(), "bad_sub")
    bad.set(bad.first());
    `ASSERT_STR_EQ(bad.name(), "bad_add")
    bad.set(bad.last());
    `ASSERT_STR_EQ(bad.name(), "third_op")

    // Wrap cases
    bad.set(one_single_pkg::third_op::get());
    `ASSERT_EQ(bad.next(), one_single_pkg::bad_add::get())
    good = one_single_pkg::sub::get();
    `ASSERT_EQ(good.next(), one_single_pkg::add::get())

    good = one_single_pkg::bad_add::get();
    `ASSERT_EQ(good.prev(), one_single_pkg::third_op::get())
    good = one_single_pkg::add::get();
    `ASSERT_EQ(good.prev(), one_single_pkg::sub::get())

    // 1 -> 0 case
    good = one_single_pkg::sub::get();
    `ASSERT_EQ(good.prev(), one_single_pkg::add::get())
    good = one_single_pkg::bad_sub::get();
    `ASSERT_EQ(good.prev(), one_single_pkg::bad_add::get())

    // size()-2 -> size()-1 case
    good = one_single_pkg::bad_sub::get();
    `ASSERT_EQ(good.next(), one_single_pkg::third_op::get())

    good = new();
    good.set_by_name("sub");
    `ASSERT_EQ(good.next(), one_single_pkg::add::get())
    bad.set_by_name("sub");
    bad.set(bad.next());
    `ASSERT_STR_EQ(bad.name(), "third_op")
`END_SV_TEST



`DECL_SV_ENUM_OBJ(four_value_enum, reg[3:0])
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_value_enum, enum_value_0x, 3'b00x)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_value_enum, enum_value_1x, 3'b01x)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_value_enum, enum_value_xx, 3'b0xx)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_value_enum, enum_value_zx, 3'b0zx)

`DECL_SV_ENUM_OBJ_EXTEND(ext_four_value_enum, four_value_enum)
`DECL_SV_ENUM_OBJ_ENUMERATOR(ext_four_value_enum, enum_value_zzz, 3'bzzz)

`SV_TEST(test_sv_enum_four_value)
    four_value_enum e = new();
    ext_four_value_enum ee = new();

    e.set(enum_value_xx::get());
    e.set(e.last());
    `ASSERT_STR_EQ(e.name(), "enum_value_zx")
    e.set(e.first());
    `ASSERT_STR_EQ(e.name(), "enum_value_0x")
    repeat (3) begin
        `ASSERT_STR_EQ(e.name(), "enum_value_0x")
        `ASSERT_EQ(e.get_value(), 3'b00x)
        e.set(e.next());
        `ASSERT_STR_EQ(e.name(), "enum_value_1x")
        `ASSERT_EQ(e.get_value(), 3'b01x)
        e.set(e.next());
        `ASSERT_STR_EQ(e.name(), "enum_value_xx")
        `ASSERT_EQ(e.get_value(), 3'b0xx)
        e.set(e.next());
        `ASSERT_STR_EQ(e.name(), "enum_value_zx")
        `ASSERT_EQ(e.get_value(), 3'b0zx)
        e.set(e.next());
    end

    e = enum_value_zx::get();
    `ASSERT_EQ(e.next(), enum_value_0x::get())
    e = enum_value_0x::get();
    `ASSERT_EQ(e.prev(), enum_value_zx::get())

    e = enum_value_0x::get(); `ASSERT_EQ(e.get_value(), 3'b00x)
    e = enum_value_1x::get(); `ASSERT_EQ(e.get_value(), 3'b01x)
    e = enum_value_xx::get(); `ASSERT_EQ(e.get_value(), 3'b0xx)
    e = enum_value_zx::get(); `ASSERT_EQ(e.get_value(), 3'b0zx)

    e = new();
    e.set(enum_value_zx::get());
    `ASSERT_EQ(e.get_singleton(), enum_value_zx::get())

    // When unknowns are in all of the values, max_value() and min_value() will
    // $fatal because no max or min can be determined.
    // `ASSERT_EQ(e.max_value(), 3'b000)
    // `ASSERT_EQ(e.min_value(), 3'b000)
    `ASSERT_EQ(e.next_unused_value(), 3'b000)

    `ASSERT_EQ(enum_value_0x::value(), 3'b00x)
    `ASSERT_EQ(enum_value_1x::value(), 3'b01x)
    `ASSERT_EQ(enum_value_xx::value(), 3'b0xx)
    `ASSERT_EQ(enum_value_zx::value(), 3'b0zx)

    e.set(enum_value_0x::get()); `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_0x")
    e.set(enum_value_1x::get()); `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_1x")
    e.set(enum_value_xx::get()); `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_xx")
    e.set(enum_value_zx::get()); `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_zx")

    ee.set(enum_value_zzz::get());
    `ASSERT_STR_EQ(ee.name(), "enum_value_zzz")
    `ASSERT_EQ(ee.get_value(), 3'bzzz)
    `ASSERT_EQ(enum_value_zzz::value(), 3'bzzz)

`END_SV_TEST

`SV_TEST(test_sv_enum_increment_decrement)
    four_value_enum e = new();
    ext_four_value_enum ee = new();

    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_xx")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_zx")
    `ASSERT_FALSE(e.is_first()) `ASSERT_TRUE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.increment();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_xx")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())

    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_zx")
    `ASSERT_FALSE(e.is_first()) `ASSERT_TRUE(e.is_last())
    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_xx")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(e.is_first()) `ASSERT_FALSE(e.is_last())
    e.decrement();
    `ASSERT_STR_EQ(e.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(e.is_first()) `ASSERT_FALSE(e.is_last())


    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_xx")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_zx")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "ext_four_value_enum.enum_value_zzz")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_TRUE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.increment();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())

    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "ext_four_value_enum.enum_value_zzz")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_TRUE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_zx")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_xx")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_1x")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "four_value_enum.enum_value_0x")
    `ASSERT_TRUE(ee.is_first()) `ASSERT_FALSE(ee.is_last())
    ee.decrement();
    `ASSERT_STR_EQ(ee.full_name(), "ext_four_value_enum.enum_value_zzz")
    `ASSERT_FALSE(ee.is_first()) `ASSERT_TRUE(ee.is_last())

`END_SV_TEST


`DECL_SV_ENUM_OBJ(enum_foo)
`DECL_SV_ENUM_OBJ_ENUMERATOR(enum_foo, foo_a, 1)
`DECL_SV_ENUM_OBJ_ENUMERATOR(enum_foo, foo_a_override, 1)

`DECL_SV_ENUM_OBJ_EXTEND(ext_enum_foo, enum_foo)
// `DECL_SV_ENUM_OBJ_ENUMERATOR(enum_foo, foo_b, 1) // $fatal's after ext_enum_foo

`SV_TEST(test_sv_enum_extend_after_override)
    ext_enum_foo f = new();
    f.set_by_value(1);
    `ASSERT_STR_EQ(f.name(), "foo_a_override")
    f.set_by_int(1);
    `ASSERT_STR_EQ(f.name(), "foo_a_override")
    f.set_by_name("foo_a");
    `ASSERT_STR_EQ(f.name(), "foo_a_override")
`END_SV_TEST


`DECL_SV_ENUM_OBJ(four_val_multiple_override_enum, logic)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_multiple_override_enum, four_val_multiple_override_X, 1'bX)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_multiple_override_enum, four_val_multiple_override_X2, 1'bX)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_multiple_override_enum, four_val_multiple_override_X3, 1'bX)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_multiple_override_enum, four_val_multiple_override_X4, 1'bX)

`SV_TEST(test_sv_enum_four_val_multiple_override)
    four_val_multiple_override_enum x = new();
    x.set_by_value(1'bX);
    `ASSERT_STR_EQ(x.name(), "four_val_multiple_override_X4")
    `ASSERT_EQ(x.get_singleton(), four_val_multiple_override_X4::get())
    `ASSERT_EQ(four_val_multiple_override_X::get(), four_val_multiple_override_X4::get())
    `ASSERT_EQ(four_val_multiple_override_X2::get(), four_val_multiple_override_X4::get())
    `ASSERT_EQ(four_val_multiple_override_X3::get(), four_val_multiple_override_X4::get())
    x = four_val_multiple_override_enum::get_by_value(1'bX);
    `ASSERT_EQ(x, four_val_multiple_override_X4::get())
`END_SV_TEST


`DECL_SV_ENUM_OBJ(four_val_rand_enum, logic)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_rand_enum, four_val_rand_enum_EXX, 1'bX)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_rand_enum, four_val_rand_enum_ZEE, 1'bZ)
// Now let ONE and ZERO take values from next_unused_value(), which will also
// test min_value() and max_value() while 4-state unknown values are in play.
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_rand_enum, four_val_rand_enum_ZERO)
`DECL_SV_ENUM_OBJ_ENUMERATOR(four_val_rand_enum, four_val_rand_enum_ONE)


`SV_TEST(test_sv_enum_four_val_rand)
    four_val_rand_enum x = new();
    int count[logic];
    `ASSERT_EQ(four_val_rand_enum_ZERO::value(), 1'b0)
    `ASSERT_EQ(four_val_rand_enum_ONE::value(), 1'b1)
    repeat (100) begin
        `ASSERT_TRUE(x.randomize())
        `ASSERT_TRUE(x.get_value() inside {1'b0, 1'b1})
        if (!count.exists(x.get_value())) count[x.get_value()] = 1;
        else count[x.get_value()] = count[x.get_value()] + 1;
    end
    `ASSERT_GT(count[1'b0], 0)
    `ASSERT_GT(count[1'b1], 0)
`END_SV_TEST

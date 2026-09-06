# sv_enum_obj
### An object-oriented alternative to SystemVerilog's native enumerated types.
## SystemVerilog's Enums
The SystemVerilog language (IEEE Std 1800™-2023), like most other languages, offers enumerated types.  For example:
```
typedef enum {
    red,
    green,
    blue
} color;
```
### Advantages
Enumerated types can be defined with an 'enum base type' and the individual name declarations can be assigned integral numerical values. This, along with static type casting, makes enums an attractive solution for assigning meaning to signal values, allowing programmers to feel good about eliminating Magic Number code smells. For example:
```
typedef enum logic [1:0] {
    OKAY = 2'b00,
    EXOKAY = 2'b01,
    SLVERR = 2'b10,
    DECERR = 2'b11
} xRESP_t;

function xRESP_t decode_xRESP(logic [1:0] field);
    return xRESP_t'(field);
endfunction
```
Additionally, SystemVerilog's randomization works natively with enumerated types, making them indispensable in the test-bench.  For example:
```
class axi_item extends uvm_sequence_item;
    ...
    rand xRESP_t xRESP;
    constraint xRESP_c {xRESP inside {OKAY, EXOKAY};}
    ...
endclass
```
Finally, SystemVerilog offers built-in methods for enums, such as `.name()`, which returns the string representation of the value.  For example:
```
function void check_for_error(xRESP_t xRESP);
    if (!(xRESP inside {OKAY, EXOKAY})) begin
        `uvm_error("XRESP_ERROR", {"The following error occurred: ",
            xRESP.name()})
    end
endfunction
```
### Problems
Upon encountering an enum in another package such as a Verification IP (VIP), one finds that they are stuck with that definition. This is because enum definitions are fixed and cannot be changed or expanded. For example, if someone used a software package with `typedef enum {red, green, blue} color;` defined it would be impossible for them to add `purple` or override `red` to `crimson`.  This violates the 'O' in the SOLID design principles -- the Open-closed principle, which states that _"software entities should be open for extension, but closed for modification."_  This is a major hurdle to reuse. It is not uncommon for a project to need to tweak a behavior or add an opcode to a field that was left with "reserved" space.

Additionally, using SystemVerilog enums tends to lead to several code smells:
- **Switch/Case Statements** - Switch/case statements (or equivalent if/else chains) are almost always a missed opportunity to use polymorphism. They create a dependency fan-out problem that can be solved with a polymorphic abstract base class interface.
- **Primitive Obsession** - Primitive obsession is the use of primitives (e.g. integers, booleans, strings, or arrays) instead of small objects for simple tasks. In particular, enums are really just fancy integers. Often, functionality related to the enum gets scattered around the codebase, often being duplicated. This leads to other code smells and maintainability problems.
- **Shotgun Surgery** - Shotgun surgery is when making a fix or modification to a single concept requires making changes in many different places around the codebase.  It's a sign that the concept was not properly abstracted. A simple concept change suddenly becomes complex in implementation. Some of the needed points of change can be forgotten, leading to bugs.

Verification engineers that use enums are often not using the best tool for the job.

### Solution
All of these problems can be overcome by using objects instead of enums.  However, most digital logic verification engineers find it difficult to give up the advantages that come built-in with SystemVerilog's enums. Furthermore, they often lack the time or skill to develop the object-oriented solution and end up developing code that is hard to maintain and difficult to reuse.

**sv_enum_obj** is the library that provides the solution.  It...
- implements the following advantages that enums have natively:
    - named encodings
    - iteration
    - string name
    - randomization (using a holder/wrapper)
    - optional UVM field automation
- provides macros to declare classes that represent enumerated types with a similar number of lines of code to the native enums (when not including custom method definitions).
- allows methods to be added to the objects so that all of those switch/case statements can be solved with polymorphism. All of that code scattered around the codebase can be consolidated into an object that encapsulates the concept being abstracted.
- allows new enum-objects to be easily added. Downstream projects can reuse your code without requiring intrusive changes. New enumerators can be added to the enumeration. Existing enumerators can be overridden.

Note that sv_enum_obj does not or cannot address the following aspects of SystemVerilog's native enums:
- sv_enum_obj is not synthesizable; not for RTL or wires.
- sv_enum_obj is not a drop-in replacement for native enums.
- sv_enum_obj cannot natively be used in `inside {red, blue}` type statements; users must use `.value` or `get_singleton()` instead.
- sv_enum_obj cannot natively be used as case items, in packed packing, or with implicit integral conversion.
- Constraints cannot call the polymorphic methods you add to sv_enum_obj without a side-effect-free helper.

## Compatibility

The library itself does not require UVM. When UVM is present, factory
registration, `create()`, field automation, `compare()`, and type
overrides are compiled in.

| Piece | Tested | Notes |
|---|---|---|
| Simulator | Cadence Xcelium (`xrun`) |  |
| UVM | Accellera UVM 1.2 |  |
| UVM 1.1d / IEEE 1800.2-2020 / 1800.2-2023 | Not tested | APIs used are the stable `uvm_object` / factory subset; expected to work, not guaranteed |

UVM is detected with `` `ifdef UVM_POST_VERSION_1_1 ``.

## How To Use
### Declaration
Instead of
```
typedef enum {
    red,
    green,
    blue
} color;
```
write
```
`include "sv_enum_obj_pkg.sv"
import sv_enum_obj_pkg::*;

`DECL_SV_ENUM_OBJ(color)
`DECL_SV_ENUM_OBJ_INST(color, red)
`DECL_SV_ENUM_OBJ_INST(color, green)
`DECL_SV_ENUM_OBJ_INST(color, blue)
```
The line `` `DECL_SV_ENUM_OBJ(color)`` will declare the following classes:
- `class color extends sv_enum_obj#(int);` - The base class for the enumerated type, which can also be instantiated as a wrapper/holder class for randomization purposes. (The scalar value type defaults `int` when left unspecified.) When used as a randomization wrapper class for itself, it contains both the scalar `value` (as `rand`) and a private internally managed handle to the singleton object representation associated with the `value`. A randomization wrapper is needed because SystemVerilog's randomization engine only works on built-in types and it cannot create a class instance, nor can constraints be written to do so.

The line `` `DECL_SV_ENUM_OBJ_INST(color, blue)`` will declare the following class:
- `class blue extends color;` - Represents the `blue` enumerator and has a scalar value of `2` (`red` was `0` and `green` was `1`) that can be retrieved with the `get_value()` method or the `blue::value()` static method.

The `red`, `green`, and `blue` enumerators are singleton classes that may be used directly. They are immutable and a fatal will result from attempting to change them or `new()` them (use `::get()` instead). Where randomization is required, the `color` wrapper/holder class should be created with `new()`, after which `.randomize()` may be called and the `value` member referenced from constraints.  The `color` class may also be used as a handle to any of the immutable singleton enumerators.  You may use the `is_holder()` and `is_singleton()` methods to determine what is being pointed to by the handle and avoid triggering a fatal error.

Adding the `+DEBUG_SV_ENUM_OBJ` plusarg to the command line will cause the library to print enumerator registrations and overrides.
---

### Allocation
The classes representing the individual enumerators are singletons and should never be `new()`ed or `created()`ed:

`red my_red = new(); // BAD!!! Will $fatal()`

Instead, a handle to the singleton for any enumerator may be retrieved with `::get()`:

`red my_red = red::get(); // Good. Get the singleton. There can be only one!`

The base class can be a handle to any of the child enumerators:

`color c = red::get();`

Just be sure not to try and change an immutable singleton:
```
color c = red::get();
c.set_by_value(2); // BAD!!! Will $fatal()
```

If the base class is allocated with `new()` (or `create()` if you're using UVM), then the object is mutable. It can be set to any of the enumerated values or randomized.

```
color c = new();
bit success = c.randomize(); // Good. Mutable.
c.set_by_value(2); // Good. Mutable.
c.set_by_name("red"); // Good. Mutable.
c.set(green::get()); // Good. Mutable.
```

If UVM is not imported into your environment, then use `new()`, but if you are using UVM, call `create()` instead:
```
color c = color::type_id::create("c");
```

Factory overrides are possible for any new base/wrapper object derived from `color`.

```
`DECL_SV_ENUM_OBJ_EXTEND(my_extended_color, color)
`DECL_SV_ENUM_OBJ_INST(my_extended_color, magenta)
`DECL_SV_ENUM_OBJ_INST(my_extended_color, turquoise)
`DECL_SV_ENUM_OBJ_INST(my_extended_color, periwinkle)
...
set_type_override_by_type(color::get_type(), my_extended_color::get_type())
...
color c = color::type_id::create("c"); // Actually creates my_extended_color
c.set_by_name("turquoise"); // Good: "turquoise" available to my_extended_color
c.set_by_name("red"); // Good: "red" inherited from parent, color.
...
color c = new();
c.set_by_name("turquoise"); // BAD!!! $fatal() because turquoise belongs to my_extended_color
```

---
### Randomization
Instead of
```
color c;
bit success = std::randomize(c) with {c != green;};
```
write
```
color c = new();
bit success = c.randomize() with {value != green::value();};
```
---
### Randomization/Constraints in an Object
Instead of
```
class item extends uvm_object;
    ...
    rand color c;
    constraint color_c {c != green;}
    ...
endclass
```
write
```
class item extends uvm_object;
    ...
    rand color c;
    constraint color_c {c.value != green::value();}
    ...
    function new(string name="item");
        super.new(name);
        ...
        c = color::type_id::create("c");
    endfunction
    ...
endclass
```
_(Remember that if a class handle members are declared as `rand`, and are not `null` when `.randomize()` is called on the class, SystemVerilog will follow the handles and also call `.randomize()` on those classes.  In other words, calling `item.randomize()` in the above example, will also cause `item.c.randomize()` to be called.  The order of operations: `item.pre_randomize()` is called; `c.pre_randomize()` is called; `item` is randomized; `c` is randomized; `item.post_randomize()` is called; `c.post_randomize()` is called.)_

_(Remember that SystemVerilog randomization cannot select unknown values.  If you register an enumeration with unknown values, randomization will not succeed.)_
---
### Accessing the Scalar Representation
Instead of
```
color c = blue;
int i = int'(c);
```
write
```
color c = new();
c.set_by_value(blue::value());
int i = c.get_value();
```
or
```
blue b = blue::get();
int i = b.get_value();
```
or simply
```
int i = blue::value();
```
---
### Converting a Scalar to the Enumeration
Instead of
```
color c = color'(2);
```
write
```
color c = new();
c.set_by_value(2); // c is holding a mutable wrapper object holding blue
```
or
```
color c = color::get_by_value(2); // c is pointing to the blue immutable singleton
```
---
### Converting a String to the Enumeration
Instead of
```
color c;
bit success = uvm_enum_wrapper#(color)::from_name("blue", c);
```
write
```
color c = new();
c.set_by_name("blue"); // c is holding a mutable wrapper object holding blue
```
or
```
color c = new();
c.set(blue::get()); // c is holding a mutable wrapper object holding blue
```
or
```
color c = color::get_by_name("blue"); // c is pointing to the blue immutable singleton
```
---
### Comparing enums
Instead of
```
color a = green;
color b = green;
color c = blue;

assert(a == b);
assert(a != c);
```
write
```
color a = new();
color b = new();
color c = new();

a.set(green::get());
b.set(green::get());
c.set(blue::get());

assert(a.is(b));
assert(!a.is(c));
```
or
```
color a = green::get();
color b = green::get();
color c = blue::get();

assert(a.is(b));
assert(!a.is(c));
```
---
### Testing Set Membership
Instead of
```
color a = green;
assert(a inside {green, blue});

a = red;
assert(!(a inside {green, blue}));
```
write
```
color a = new();
color b = new();
color c = new();

b.set(green::get());
c.set(blue::get());
a.set(green::get());
assert(a.get_singleton() inside {b.get_singleton(), c.get_singleton()});

a.set(red::get());
assert(!a.get_singleton() inside {b.get_singleton(), c.get_singleton()});
```
or
```
color a = new();

a.set(green::get());
assert(a.get_singleton() inside ({green::get(), blue::get()}));

a.set(red::get());
assert(!a.get_singleton() inside ({green::get(), blue::get()}));
```
or
```
assert(green::get() inside ({green::get(), blue::get()}))
assert(green::value() inside {green::value(), blue::value()})
```
---
### Testing Range
Instead of
```
color a = green;
assert(a inside {[red:blue]});
```
write
```
color a = green::get();
assert(a.get_value() inside {[red::value(), blue::value()]});
```
---
### Built-In Enum Methods
Instead of
```
color c = green;
c = c.next();
$display("%0s is after green", c.name());
```
write
```
color c = green::next();
$display("%0s is after green", c.name());
```
or
```
color c = new();
c.set(green::get());
c.set(c.get_next());
$display("%0s is after green", c.name());
```
_Note that iteration order for `prev`/`next` is declaration order (same as native SV), not `value` order._
---
### Adding Methods
Instead of
```
typedef enum logic [3:0] {
    bird = 4'b0000,
    horse = 4'b0001,
    dog = 4'b0010
} animal;

function int get_num_legs(animal a);
    case (a)
        bird: get_num_legs = 2;
        horse, dog: get_num_legs = 4;
        default: `uvm_fatal("UNDEFINED_LEGS", "Number of legs undefined")
    endcase
endfunction

function bit can_ride(animal a);
    case (a)
        bird, dog: can_ride = 0;
        horse: can_ride = 1;
        default: `uvm_fatal("UNDEFINED_RIDEABILITY", "Undefined rideability")
    endcase
endfunction

function void explain_all_animals();
    animal a;
    a = a.first();
    repeat (a.num()) begin
        explain_animal(a);
        a = a.next();
    end
endfunction

function void explain_animal(animal a);
    int legs;
    string ride;
    legs = get_num_legs(a);
    ride = can_ride(a) ? "may" : "may not";
    $display("The %0s has %0d legs and you %0s ride it.",
        a.name(), legs, ride);
endfunction
```
write
```
`DECL_SV_ENUM_OBJ_BEGIN(animal, logic [3:0])

    // NOTE: When implementing methods that can be called on the base class you
    //       must sync the internal object to the current value and then pass
    //       the method call through to the held object from the base-class,
    //       which is also doubling as the holder/wrapper.

    virtual function int get_num_legs();
        _init_obj(); // Syncs the internal object to the 'value' member.
        return _obj.get_num_legs(); // Pass-through
    endfunction

    virtual function bit can_ride();
        _init_obj(); // Syncs the internal object to the 'value' member.
        return _obj.can_ride(); // Pass-through
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
        a.name(), legs, ride);
endfunction
```
To illustrate how extendable the class-based solution is, as you project grows, more animals can be added simply by declaring them.

This illustrates the _dependency inversion principle_ (the D in SOLID). Both `explain_animal()` and the individual animals depend on the `animal` base class.
```
`DECL_SV_ENUM_OBJ_INST_BEGIN(animal, deer, 4'b0011)
    virtual function int get_num_legs(); return 4; endfunction
    virtual function bit can_ride(); return 0; endfunction
`DECL_SV_ENUM_OBJ_INST_END

`DECL_SV_ENUM_OBJ_INST_BEGIN(animal, elephant, 4'b0100)
    virtual function int get_num_legs(); return 4; endfunction
    virtual function bit can_ride(); return 1; endfunction
`DECL_SV_ENUM_OBJ_INST_END
```
Even existing enumerator singletons can be overridden with polymorphism and the sv_enum_obj's built-in registry. By simply declaring them with the same value, they replace the previously declared/registered enumerator:
```
`DECL_SV_ENUM_OBJ_INST_BEGIN(animal, maimed_dog, 4'b0010)
    virtual function int get_num_legs(); return 3; endfunction
    virtual function bit can_ride(); return 0; endfunction
`DECL_SV_ENUM_OBJ_INST_END
```

_Note that the UVM Factory cannot be used to override individual enumerator singletons. Use the above technique instead._

---
### Extending Another Package or Project
Be careful how you extend code from another package.  The macros easily allow "monkey-patching."  This is generally considered a last-resort technique because it is implicit, order-dependent, and easy to break later.  An example of monkey-patching:
```
package original_pkg;
    `DECL_SV_ENUM_OBJ(color)
    `DECL_SV_ENUM_OBJ_INST(color, red)
endpackage
...
package later_pkg;
    // This monkey-patches a new enumerator into original_pkg, affecting all
    // other code referencing/using the enumeration in the original_pkg.
    // This is unexpected!
    // AVOID THIS!!! LAST RESORT ONLY!!!
    `DECL_SV_ENUM_OBJ_INST(original_pkg::color, blue)
endpackage
```

Avoid monkey-patching by using the 'O' (Open-Closed Principle) in SOLID.  Extend the original class using polymorphism:
```
package original_pkg;
    `DECL_SV_ENUM_OBJ(color)
    `DECL_SV_ENUM_OBJ_INST(color, red)
endpackage
...
package later_pkg;
    `DECL_SV_ENUM_OBJ_EXTEND(extended_color, original_pkg::color)
    `DECL_SV_ENUM_OBJ_INST(extended_color, blue)
endpackage
```
In the above example `red` stays a child of `color` and `color` has no references to the new `blue` color.  `extended_color` picks up `red` from its parent `color` and then `blue` is added to it.  (Note that `blue` is a child of `extended_color`, but `red` remains a child of `color`.)

How can `blue` be used in existing code without monkey-patching? This is where the importance of writing good code comes into play--specifically avoiding falling into the "new is glue" trap that causes the violation of S, O, and D in SOLID.  When writing code that needs to create an enumerated base class, don't call `new()` and instead use something like a Factory Design Pattern or a Builder Design Pattern.

Users of UVM can go ahead and use UVM's factory, which should already be familiar. (Although if UVM is not imported into your environment, you are not forced to use it.)  For example:
```
// Wherever original_pkg::color::type_id::create() is called, the factory will
// provide a new instance of extended_color instead:
set_type_override_by_type(original_pkg::color::get_type(),
                          later_pkg::extended_color::get_type());
```
_Note that the UVM Factory cannot be used to override individual enumerator singletons. Instead use DECL_SV_ENUM_OBJ_INST to declare a new enumerator, but specify the `value` of the enumerator you wish to override._

---
### Indexing Into an Associative Array
Instead of
```
int aa[animal];
aa[dog] = 123;
assert(aa.exists(dog));
foreach (aa[a]) begin
    $display("Animal %0s was a key to look-up value %0d", a.name(), aa[a]);
end
```
write
```
int aa[animal];
aa[bird::get()] = 123;
assert(aa.exists(bird::get()));
foreach (aa[i]) begin
    $display("Animal %0s was a key to look-up value %0d", i.name(), aa[i]);
end
```

---
### Complex Constraints
You may find that you want to write a constraint that references the methods of the enumerated type object.  Unfortunately the SystemVerilog LRM has the following restrictions:
* "Functions that appear in constraint expressions shall be automatic (or preserve no state information) and have no side effects."
* "Function calls in passive constraints are executed an unspecified number of times (at least once) in an unspecified order."

Therefore, you cannot write a constraint that creates the correct child type of the enumerated object, then references the methods of the enumerated type object.
For example, you might want to write a constraint like this:
```
class item extends uvm_object;
    rand animal a;
    rand int payload;
    constraint c {
        // ERROR: a.object is not created with the correct
        //        type until post_randomize(). The methods
        //        simply don't work until then.
        if (a.can_ride()) {
            payload == a.get_num_legs() * 100;
        } else {
            payload == 5;
        }
    }
    `uvm_object_utils(item)
    function new(string name="item");
        super.new(name);
    endfunction
endclass
```
Instead, because of the quoted SystemVerilog limitations, you must write helper functions that have no side effects:
```
class item extends uvm_object;
    rand animal a;
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

    `uvm_object_utils(item)

    function new(string name="item");
        super.new(name);
        a = animal::type_id::create("a");
    endfunction

    virtual function int payload_helper_function(int a_value);
        animal tmp = animal::get_by_value(a_value);
        return (tmp.can_ride()) ? tmp.get_num_legs() * 100 : 5;
    endfunction
endclass
```
This is annoying, adding another layer of complexity, but it works around a major and obvious limitation of SystemVerilog: randomization does not support creating objects.

// a type can be of type, T, {}, (), [], num, string, bool, u64, i64, etc.
type Vehicle: {} = {
  wheels: num,
  make: string,
  model: string,
  
  pub fn new(wheels: num, make: string, model: string) Vehicle {
    return Vehicle{
      wheels, 
      make, 
      model, 
    };
  }
};

// three different ways to make a vehicle
let x = Vehicle { 4, 'Toyota', 'Prius' };
let y = Vehicle.new(4, 'Toyota', 'Prius');
let z = { 4, 'Toyota', 'Prius' };
// z's type is not immediately inferred. It is anonymous until first usage with a type.

// types can have base implementations
type Drive: () = drive(self: Vehicle, direction: string) {
  // drive that vehicle
};
// types can force implementation by the implementer.
type Drive: () = drive(self: Vehicle, direction: string);

// if we provide a base implementation the type doesn't need to specify the method, it can just be used
type Vehicle: {} + Drive = {
  wheels: num,
  make: string,
  model: string,
};

let x = Vehicle { 2, 'Honda', 'Rebel 300' };
x.drive("North");

// self is a special method parameter. It binds to the object. If an object implements multiple of the same method or properties.
type AutoPilot: () = drive(self: Vehicle, direction: string) {
  // implementation
};
type Drive: () = drive(self: Vehicle, direction: string) {
  // implementation
};

type Vehicle: {} + Drive + AutoPilot = {
  wheels: num,
  make: string,
  model: string,
};

let x = Vehicle { 2, 'Honda', 'Rebel 300' };
x.drive("North"); // uh-oh, which one!?!?!

// it is said that this invocation has been namespaced!
Drive.drive(x, "North"); 
// or
AutoPilot.drive(x, "West");

// which implementation of this looks the best? are there properties that can be reflected upon an object, such as len?
// this composition is powerful, we can alias a type as well without modifying. 
type DatabaseID: u64 = self;

// we can limit to a range, to match database lengths. again how should this be done?
type NameField: string = self[0..25];

// const means the variable is assigned once, and then not modifiable.

const x = 5;
const y = [5,2];

x = 3 + 3; // not allowed
y.push(3); // not allowed, many programming languages do allow this to const objects or arrays.
y[0] = 1; // not allowed

// we need a way to express constness when passing arguments to functions.
type AutoPilot: () = drive(self: &Vehicle, direction: string) {
  self.wheels = 5; // Not allowed!
};

// any value passed to a parameter with * is said to be mutable.
type Drive: () = drive(self: *Vehicle, direction: string) {
  self.wheels = 6;
};

// Note:: this NEVER needs to treated as a pointer. No need to dereference or reference anything. The mutability with * in ttlang is not related to references!
// readonly with & is also not related to references. There are no references in ttlang

// This interface allows us to know very clearly if a function intends to mutate the value.

const ford = Vehicle {4, 'Ford', 'F150' };
AutoPilot.drive(ford, "North"); // not allowed!

// The "ford" variable is const, and therefore, we do not want anything modifying its internals.

// TT lang has no garbage collector, which means we need to follow the ownership rules to clearly insert free's, const, and let help us in controlling the mutability.

const x = 5;
const y = x;

// scalar types in almost every language are cloned.
// complex types (), {}, [], and string are moved. Changing ownership.

const prius = Vehicle {4, 'Toyota', 'Prius' };
// do something with prius.
// now going to set it to a modifyable let.
let modifiable_prius = prius; // move has happened here!
prius.reverse(); // uh-oh. not allowed!

// For performance reasons, we don't want to copy objects all the time, but in order to avoid using a garbage collector, we need to know who maintains control of the object, so we know when to free it after it has been dropped from the scope.
//
// This is probably the hardest concept to get coming from another language, but it is the most powerful in terms of performance and optimizations that can be applied to programs.

// use the keyword copy, when we want to assign the variable the same value. This duplicates the object instead of moving. Be concsious of copies!

const honda = Vehicle{ 4, 'Honda', 'Civic' }; 
const civic = copy honda;
AutoPilot.drive(honda, "South"); // allowed now, two objects exist in memory.

// extension methods can be added to existing types, by using self
type Num: self + () = toString(self: num) string {
  // implementation
}
const num_string = 5.toString();

// as an exercise, let us create the map function.
type [T]: self + () = map(self: [T], func: (x: *T) void) [T] {
  let new_array: [T] = [];
  for (let val in self) {
    new_arry.push(func(val));
  }
  return new_array;
}

// we are extending all arrays of type T `[T]`. T is the ultimate super class, it can be of any type.
// the input array is not modifiable. Allowing for optimizations and additional safety.
// this extension function is called map. `map(self: [T], func: (x: *T));`
// map takes itself as the first argument, and a function as the second argument.

const to_increment = [1,2,3,4];
const incremented = to_increment.map((x) { 
  x = x + 1; 
  return x;
});

// scalar values are copied, so x is modifiable, as its constness is not determined by `to_increment`
// T was mentioned to be the ultimate super class before. In many languages T is used for generic. Here, T means any type, but we can't make any decisions about T, T could even be a function.

// we need to be able to express readonly usages. From our previous declaration of map.

let to_increment = [1,2,3,4];
const incremented = to_increment.map((x) { 
  x = x + 1; 
  return x;
});

to_increment.push(5); // uh-oh to_increment was moved in map.

// we want to pass a read only version of to_increment
type [T]: self + () = map(self: &[T], func: (x: *T) void) [T] {}
// so to sum up.
// T is owned.
// & is readonly.
// * is modifiable

// * is coercable to &
// T is coercable to & or *.


// we can pass a read only version of a modifiable object
let vehicle = { 4, "Infiniti", "G5" };
Writer.log(vehicle); // it would be ridiculous to pass ownership or copy when printing to the console.

// writer would should look like this.
type Writer: {} = {
  pub fn log(self: &{}, &toString) {

  } 
} 

// when defining types, we need to think about what their intention is.
// below is some very strange typing.
type writer: &{} = { // silly
  // {} ownership silly
  pub fn log(self: {}, &T) {} 
}
// from that example, calling writer.log() will take ownership of self, but self is a readonly non owned version of an {}. This is not allowed! It would be silly to take ownership within the call to log, making Writer suddenly unavailable, unless it returned itself.

// it is silly to make a readonly version of a type that we intend to be an actual object in memory. So we do not allow modifiability types in definitions.
type writer: &Writer = { // silly
  pub fn log(self: &{}, &T) {

  } 
} 

// here is the builder pattern in ttlang.
type CommandBuilder: {} = {
  options: [string] = [],
  shorts: [?string] = [],
  messages: [?string] = [],
  vals: [?string] = [],
  pub fn new() CommandBuilder {
    return {}; // options and shorts, has a default value of an empty array, no need to specify.
  }  
  pub fn option(self: *CommandBuilder, option: &string, short: ?&string) CommandBuilder {
    self.options.push(option);
    self.shorts.push(short);
    self.messages.push(null);
    return self;
  }
  pub fn required(self: *CommandBuilder, option: &string, message: &string, short: ?&string) CommandBuilder {
    self.options.push(option);
    self.shorts.push(short);
    self.messages.push(message);
    return self;
  }
  pub fn parse(self: *CommandBuilder, args: &[&char]) !void {
    // loop through args, setting the values, and throwing an error if required isn't provided
  }
}

let program = CommandBuilder.new() // owned CommandBuilder here
  .option("--clean") // mutable borrow here
  .option("--build", "-b"); // moved owned CommandBuilder here

const parsed = program.parse()!;




// [T] is coercable, so a readonly version of the array, is allowed, since self defines the array as being readonly.
// this is why the final declaration for map, looks as follows.
type [T]: self + () = map(self: &[T], func: (x: *T)) [T];
// finally,
// this type declaration is extending self of type `[T]`, by adding a function `()`.
// the map function `...map(self...` is callable on any array of type `[T]` that is either const or let.
// it uses that array as readonly `...self: &[T]...`
// this function, takes another function `...func: (x: *T)...`
// the passed in function `func` is invoked with the same type `T` and is mutable within the function. that function is void as the return type is not specified. `...(x: *T) void...` is also valid.
// the map function returns an owned instance of an array [T].

// In other languages one might see something like T: where T implements toString

// best way to alias A to toString?
type [A]: self, () = concat(self: [A], sep: string, func: (x: *A) void) [A] {

}



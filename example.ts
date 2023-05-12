// a type has a type, {}, (), num, string, bool, u64, i64, etc.
type Vehicle: {} = {
  wheels: num,
  make: string,
  model: string,
  
  pub fn new(wheels: num, make: string, model: string) Car {
    return Vehicle{
      wheels, 
      make, 
      model, 
    };
  }
};

// two different ways to make a car
let x = Vehicle { 4, 'Toyota', 'Prius' };
let y = Vehicle.new(4, 'Toyota', 'Prius');


// types can have base implementations
type Drive: () = drive(self: Vehicle, direction: string) {
  // drive that vehicle
};
// types can be force implementation by the implementer.
type Drive: () = drive(self: Vehicle, direction: string);

// if we provide a base implementation the type doesn't need to specify the method, it can just be used
type Vehicle: {}, Drive = {
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

type Vehicle: {}, Drive, AutoPilot = {
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

// we need a way to express constness when passing arguments to functions.
type AutoPilot: () = drive(self: Vehicle, direction: string) {
  self.wheels = 5; // Not allowed!
};

// any value passed to a parameter with * is said to be mutable.
type Drive: () = drive(self: *Vehicle, direction: string) {
  self.wheels = 6;
};

// Note:: this NEVER need to treated it as a pointer. No need to dereference or reference anything. The mutability with * in ttlang is not related to references.

// This interface allows us to know very clearly if a function intends to mutate the value.

const ford = Vehicle {4, 'Ford', 'F150' };
Drive.drive(ford, "North"); // not allowed!

// The "ford" is const, and therefore, we do not want anything modifying its internals.

// TT lang has no garbage collector, which means we need to know when to clean up memory, const, and let help us in controlling the mutability. Thus, introducing lifetimes.

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

// use the keyword copy, when we want to assign the variable the same value, duplicating the object, and preventing a move.
const honda = Vehicle{ 4, 'Honda', 'Civic' }; 
const civic = copy honda;
AutoPilot.drive(honda, "South"); // allowed now, two objects exist in memory.

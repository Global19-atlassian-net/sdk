// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*@testedFeatures=inference*/
library test;

class A {
  B b;
}

class B {
  C get c => null;
  void set c(C value) {}
}

class C {}

class D extends C {}

class E extends C {}

// Inferred type: A
var a = new A();

// Inferred type: C
var x = a.b.c;

// Inferred type: C
var y = a.b.c ??= new D();

test() {
  // Verify the types of x and y by trying to assign to them.
  x = new C();
  x = new E();
  x = new B();
  //  ^^^^^^^
  // [analyzer] STATIC_TYPE_WARNING.INVALID_ASSIGNMENT
  //      ^
  // [cfe] A value of type 'B' can't be assigned to a variable of type 'C'.
  y = new C();
  y = new E();
  y = new B();
  //  ^^^^^^^
  // [analyzer] STATIC_TYPE_WARNING.INVALID_ASSIGNMENT
  //      ^
  // [cfe] A value of type 'B' can't be assigned to a variable of type 'C'.
}

main() {}

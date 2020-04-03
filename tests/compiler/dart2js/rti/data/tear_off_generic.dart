// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

/*strong.class: A:direct,explicit=[A.T],needsArgs*/
/*omit.class: A:*/
class A<T> {
  /*strong.member: A.m:*/
  /*omit.member: A.m:*/
  void m(T t) {}

  /*member: A.f:*/
  void f(int t) {}
}

main() {
  new A<int>().m is void Function(int);
  new A<int>().f is void Function(int);
}

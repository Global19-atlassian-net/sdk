// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.6

typedef ContravariantUse<T> = Function(T);

typedef InvariantUse<T> = T Function(T);

class Empty {}

class A<T> {}

class B<T> extends A<Function(T)> {}

class Bc<T> extends A<ContravariantUse<T>> {}

class Bi<T> extends A<InvariantUse<T>> {}

class C<T> implements A<Function(T)> {}

class Cc<T> implements A<ContravariantUse<T>> {}

class Ci<T> implements A<InvariantUse<T>> {}

class D<T> = Object with A<Function(T)>;

class Dc<T> = Object with A<ContravariantUse<T>>;

class Di<T> = Object with A<InvariantUse<T>>;

class E<T> = A<Function(T)> with Empty;

class Ec<T> = A<ContravariantUse<T>> with Empty;

class Ei<T> = A<InvariantUse<T>> with Empty;

class F<T> extends Object with A<Function(T)> {}

class Fc<T> extends Object with A<ContravariantUse<T>> {}

class Fi<T> extends Object with A<InvariantUse<T>> {}

class G<T> extends A<Function(T)> with Empty {}

class Gc<T> extends A<ContravariantUse<T>> with Empty {}

class Gi<T> extends A<InvariantUse<T>> with Empty {}

class Hff<T> extends A<Function(Function(T))> {}

class Hfc<T> extends A<Function(ContravariantUse<T>)> {}

class Hcf<T> extends A<ContravariantUse<Function(T)>> {}

class Hcc<T> extends A<ContravariantUse<ContravariantUse<T>>> {}

class Hii<T> extends A<InvariantUse<InvariantUse<T>>> {}

class Iafc<T> extends A<A<Function(ContravariantUse<T>)>> {}

class Iacf<T> extends A<A<ContravariantUse<Function(T)>>> {}

class Ifac<T> extends A<Function(A<ContravariantUse<T>>)> {}

class Ifca<T> extends A<Function(ContravariantUse<A<T>>)> {}

class Icaf<T> extends A<ContravariantUse<A<Function(T)>>> {}

class Icfa<T> extends A<ContravariantUse<Function(A<T>)>> {}

class Jfff<T> extends A<Function(Function(Function(T)))> {}

class Jffc<T> extends A<Function(Function(ContravariantUse<T>))> {}

class Jfcf<T> extends A<Function(ContravariantUse<Function(T)>)> {}

class Jfcc<T> extends A<Function(ContravariantUse<ContravariantUse<T>>)> {}

class Jcff<T> extends A<ContravariantUse<Function(Function(T))>> {}

class Jcfc<T> extends A<ContravariantUse<Function(ContravariantUse<T>)>> {}

class Jccf<T> extends A<ContravariantUse<ContravariantUse<Function(T)>>> {}

class Jccc<T>
    extends A<ContravariantUse<ContravariantUse<ContravariantUse<T>>>> {}

main() {}

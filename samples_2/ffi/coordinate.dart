// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'dart:ffi';

/// Sample struct for dart:ffi library.
class Coordinate extends Struct {
  @Double()
  double x;

  @Double()
  double y;

  Pointer<Coordinate> next;
}

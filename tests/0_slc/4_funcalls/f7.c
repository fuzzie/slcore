//
// f7.c: this file is part of the SL toolchain.
//
// Copyright (C) 2009 The SL project.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 3
// of the License, or (at your option) any later version.
//
// The complete GNU General Public Licence Notice can be found as the
// `COPYING' file in the root directory.
//

#include <svp/testoutput.h>
#include <svp/compiler.h>

int a;

noinline int* foo() { return &a; }

sl_def(t_main, void)
{
  int *p = foo();
  output_int(&a - p, 1); 
  output_char('\n', 1);
}
sl_enddef

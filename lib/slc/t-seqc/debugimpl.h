// debugimpl.h: this file is part of the utcc project.
//
// Copyright (C) 2008 The CSA group.
//
// $Id$
//
#ifndef UTC_SEQ_C_DEBUGIMPL_H
# define UTC_SEQ_C_DEBUGIMPL_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define d_putchar(X) do { fputc(X, stdout); fflush(stdout); } while(0)
#define d_abort() exit(1)
#define d_nop() (void)feof(stdout)

#define __gen_divmod(T, DividendMod, DivisorResult)			\
  do {									\
    T __gen_divmod_dividend = (DividendMod), __gen_divmod_divisor = (DivisorResult);	\
    T __gen_divmod_mod = __gen_divmod_dividend % __gen_divmod_divisor,	\
      __gen_divmod_res = __gen_divmod_dividend / __gen_divmod_divisor;	\
    (DividendMod) = __gen_divmod_mod;						\
    (DivisorResult) = __gen_divmod_res;						\
  } while(0)

#define d_divmodu64(DividendMod, DivisorResult) __gen_divmod(uint64_t, DividendMod, DivisorResult)
#define d_divmods64(DividendMod, DivisorResult) __gen_divmod(int64_t, DividendMod, DivisorResult)
#define d_divmodu32(DividendMod, DivisorResult) __gen_divmod(uint32_t, DividendMod, DivisorResult)
#define d_divmods32(DividendMod, DivisorResult) __gen_divmod(int32_t, DividendMod, DivisorResult)



#endif // ! UTC_SEQ_C_DEBUGIMPL_H
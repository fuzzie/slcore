/*-
 * Copyright (c) 1990, 1993
 *	The Regents of the University of California.  All rights reserved.
 * Copyright (c) 2010 The SL project.
 *
 * This code is derived from software contributed to Berkeley by
 * Chris Torek.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD: src/lib/libc/stdio/printfcommon.h,v 1.4.2.1 2009/08/03 08:13:06 kensmith Exp $
 */

/*
 * This file defines common routines used by both printf and wprintf.
 * You must define CHAR to either char or wchar_t prior to including this.
 */


#ifndef NO_FLOATING_POINT

#include <sys/types.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include "floatio.h"

// FIXME: buf in gdtoa, using "simple" version from dtoa_simple.c
#define	dtoa		dtoa_simple
#define	freedtoa	__freedtoa
#include "gdtoa/gdtoa.h"

#include "stdio/mtstdio.h"

#define	DEFPREC		6

static int exponent(CHAR *, int, CHAR);

#endif /* !NO_FLOATING_POINT */

static CHAR	*__ujtoa(uintmax_t, CHAR *, int, int, const char *);
static CHAR	*__ultoa(u_long, CHAR *, int, int, const char *);

#if 0 // no iostate
#define NIOV 8
struct io_state {
	FILE *fp;
	struct __suio uio;	/* output information: summary */
	struct __siov iov[NIOV];/* ... and individual io vectors */
};

static inline void
io_init(struct io_state *iop, FILE *fp)
{

	iop->uio.uio_iov = iop->iov;
	iop->uio.uio_resid = 0;
	iop->uio.uio_iovcnt = 0;
	iop->fp = fp;
}

/*
 * WARNING: The buffer passed to io_print() is not copied immediately; it must
 * remain valid until io_flush() is called.
 */
static inline int
io_print(struct io_state *iop, const CHAR * restrict ptr, int len)
{

	iop->iov[iop->uio.uio_iovcnt].iov_base = (char *)ptr;
	iop->iov[iop->uio.uio_iovcnt].iov_len = len;
	iop->uio.uio_resid += len;
	if (++iop->uio.uio_iovcnt >= NIOV)
		return (__sprint(iop->fp, &iop->uio));
	else
		return (0);
}
#endif

#define io_state __sl_FILE
static inline int
io_print(FILE *f, const CHAR * restrict ptr, int len)
{
    __write(f, ptr, len);
    return 0;
}

/*
 * Choose PADSIZE to trade efficiency vs. size.  If larger printf
 * fields occur frequently, increase PADSIZE and make the initialisers
 * below longer.
 */
#define	PADSIZE	16		/* pad chunk size */
static const CHAR blanks[PADSIZE] =
{' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
static const CHAR zeroes[PADSIZE] =
{'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'};

/*
 * Pad with blanks or zeroes. 'with' should point to either the blanks array
 * or the zeroes array.
 */
static inline int
io_pad(struct io_state *iop, int howmany, const CHAR * restrict with)
{
	int n;

	while (howmany > 0) {
		n = (howmany >= PADSIZE) ? PADSIZE : howmany;
		if (io_print(iop, with, n))
			return (-1);
		howmany -= n;
	}
	return (0);
}

/*
 * Print exactly len characters of the string spanning p to ep, truncating
 * or padding with 'with' as necessary.
 */
static inline int
io_printandpad(struct io_state *iop, const CHAR *p, const CHAR *ep,
	       int len, const CHAR * restrict with)
{
	int p_len;

	p_len = ep - p;
	if (p_len > len)
		p_len = len;
	if (p_len > 0) {
		if (io_print(iop, p, p_len))
			return (-1);
	} else {
		p_len = 0;
	}
	return (io_pad(iop, len - p_len, with));
}

#if 0 // no iostate
static inline int
io_flush(struct io_state *iop)
{
	return (__sprint(iop->fp, &iop->uio));
}
#endif

/*
 * Convert an unsigned long to ASCII for printf purposes, returning
 * a pointer to the first character of the string representation.
 * Octal numbers can be forced to have a leading zero; hex numbers
 * use the given digits.
 */
static CHAR *
__ultoa(u_long val, CHAR *endp, int base, int octzero, const char *xdigs)
{
	CHAR *cp = endp;
	long sval;

	/*
	 * Handle the three cases separately, in the hope of getting
	 * better/faster code.
	 */
	switch (base) {
	case 10:
		if (val < 10) {	/* many numbers are 1 digit */
			*--cp = to_char(val);
			return (cp);
		}
		/*
		 * On many machines, unsigned arithmetic is harder than
		 * signed arithmetic, so we do at most one unsigned mod and
		 * divide; this is sufficient to reduce the range of
		 * the incoming value to where signed arithmetic works.
		 */
		if (val > LONG_MAX) {
#if defined(__slc_arch_leon2mt__) && defined(__slc_os_fpga__)
		    uint32_t d, m;
		    __divmodu_uint32_t(val, 10, &d, &m);
#else
		    u_long d, m;
		    d = val / 10;
		    m = val % 10;
#endif
			*--cp = to_char(m);
			sval = d;
		} else
			sval = val;
		do {
#if defined(__slc_arch_leon2mt__) && defined(__slc_os_fpga__)
		    int32_t d, m;
		    __divmods_int32_t(sval, 10, &d, &m);
#else
		    long d, m;
		    d = sval / 10;
		    m = sval % 10;
#endif
			*--cp = to_char(m);
			sval = d;
		} while (sval != 0);
		break;

	case 8:
		do {
			*--cp = to_char(val & 7);
			val >>= 3;
		} while (val);
		if (octzero && *cp != '0')
			*--cp = '0';
		break;

	case 16:
		do {
			*--cp = xdigs[val & 15];
			val >>= 4;
		} while (val);
		break;

	default:			/* oops */
		abort();
	}
	return (cp);
}

/* Identical to __ultoa, but for intmax_t. */
static CHAR *
__ujtoa(uintmax_t val, CHAR *endp, int base, int octzero, const char *xdigs)
{
	CHAR *cp = endp;
	intmax_t sval;

	/* quick test for small values; __ultoa is typically much faster */
	/* (perhaps instead we should run until small, then call __ultoa?) */
	if (val <= ULONG_MAX)
		return (__ultoa((u_long)val, endp, base, octzero, xdigs));
	switch (base) {
	case 10:
		if (val < 10) {
			*--cp = to_char(val);
			return (cp);
		}
		if (val > INTMAX_MAX) {
#if defined(__slc_arch_leon2mt__) && defined(__slc_os_fpga__)
		    int32_t d, m;
		    __divmods_int32_t(sval, 10, &d, &m);
#else
		    long d, m;
		    d = sval / 10;
		    m = sval % 10;
#endif
			*--cp = to_char(m);
			sval = d;
		} else
			sval = val;
		do {
#if defined(__slc_arch_leon2mt__) && defined(__slc_os_fpga__)
		    int32_t d, m;
		    __divmods_int32_t(sval, 10, &d, &m);
#else
		    long d, m;
		    d = sval / 10;
		    m = sval % 10;
#endif
			*--cp = to_char(m);
			sval = d;
		} while (sval != 0);
		break;

	case 8:
		do {
			*--cp = to_char(val & 7);
			val >>= 3;
		} while (val);
		if (octzero && *cp != '0')
			*--cp = '0';
		break;

	case 16:
		do {
			*--cp = xdigs[val & 15];
			val >>= 4;
		} while (val);
		break;

	default:
		abort();
	}
	return (cp);
}

#ifndef NO_FLOATING_POINT

static int
exponent(CHAR *p0, int exp, CHAR fmtch)
{
	CHAR *p, *t;
	CHAR expbuf[MAXEXPDIG];

	p = p0;
	*p++ = fmtch;
	if (exp < 0) {
		exp = -exp;
		*p++ = '-';
	}
	else
		*p++ = '+';
	t = expbuf + MAXEXPDIG;
	if (exp > 9) {
		do {
#if defined(__slc_arch_leon2mt__) && defined(__slc_os_fpga__)
		    int32_t d, m;
		    __divmods_int32_t(exp, 10, &d, &m);
#else
		    long d, m;
		    d = exp / 10;
		    m = exp % 10;
#endif
			*--t = to_char(m);
			exp = d;
		} while (exp > 9);
		*--t = to_char(exp);
		for (; t < expbuf + MAXEXPDIG; *p++ = *t++);
	}
	else {
		/*
		 * Exponents for decimal floating point conversions
		 * (%[eEgG]) must be at least two characters long,
		 * whereas exponents for hexadecimal conversions can
		 * be only one character long.
		 */
		if (fmtch == 'e' || fmtch == 'E')
			*p++ = '0';
		*p++ = to_char(exp);
	}
	return (p - p0);
}

#endif /* !NO_FLOATING_POINT */

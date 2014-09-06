
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


#include <stdlib.h>

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

typedef _Decimal128 D128;

/*******************************
#ifdef __MINGW64__
typedef _Decimal128 D128 __attribute__ ((aligned(8)));
#else
typedef _Decimal128 D128;
#endif
********************************/

int  _is_nan(D128 x) {
     if(x == x) return 0;
     return 1;
}

int  _is_inf(D128 x) {
     if(x != x) return 0; /* NaN  */
     if(x == 0.0DL) return 0; /* Zero */
     if(x/x != x/x) {
       if(x < 0.0DL) return -1;
       else return 1;
     }
     return 0; /* Finite Real */
}

int  _is_neg_zero(D128 x) {
     char * buffer;

     if(x != 0.0DL) return 0;

     Newx(buffer, 2, char);
     sprintf(buffer, "%.0f", (double)x);

     if(strcmp(buffer, "-0")) {
       Safefree(buffer);
       return 0;
     }

     Safefree(buffer);
     return 1;
}

SV *  _is_nan_NV(pTHX_ SV * x) {
      if(SvNV(x) == SvNV(x)) return newSViv(0);
      return newSViv(1);
}

SV *  _is_inf_NV(pTHX_ SV * x) {
      if(SvNV(x) != SvNV(x)) return 0; /* NaN  */
      if(SvNV(x) == 0.0) return newSViv(0); /* Zero */
      if(SvNV(x)/SvNV(x) != SvNV(x)/SvNV(x)) {
        if(SvNV(x) < 0.0) return newSViv(-1);
        else return newSViv(1);
      }
      return newSVnv(0); /* Finite Real */
}

SV *  _is_neg_zero_NV(pTHX_ SV * x) {
      char * buffer;

      if(SvNV(x) != 0.0) return newSViv(0);

      Newx(buffer, 2, char);

      sprintf(buffer, "%.0f", (double)SvNV(x));

      if(strcmp(buffer, "-0")) {
        Safefree(buffer);
        return newSViv(0);
      }

      Safefree(buffer);
      return newSViv(1);
}

D128 _get_inf(int sign) {
     if(sign < 0) return -1.0DL/0.0DL;
     return 1.0DL/0.0DL;
}

D128 _get_nan(void) {
     D128 inf = _get_inf(1);
     return inf/inf;
}

SV * _DEC128_MAX(pTHX) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in DEC128_MAX() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 9999999999999999e369DL;


     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * _DEC128_MIN(pTHX) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in DEC128_MIN() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 1e-398DL;


     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}


SV * NaND128(pTHX) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in NaND128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = _get_nan();

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * InfD128(pTHX_ int sign) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in InfD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = _get_inf(sign);

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * ZeroD128(pTHX_ int sign) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in ZeroD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 0.0DL;
     if(sign < 0) *d128 *= -1;

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UnityD128(pTHX_ int sign) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in UnityD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 1.0DL;
     if(sign < 0) *d128 *= -1;

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Exp10(pTHX_ int power) {
     D128 * d128;
     SV * obj_ref, * obj;

     if(power < -398 || power > 384)
       croak("Argument supplied to Exp10 function (%d) is out of allowable range", power);

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in Exp10() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 1.0DL;
     if(power < 0) {
       while(power) {
         *d128 *= 0.1DL;
         power++;
       }
     }
     else {
       while(power) {
         *d128 *= 10.0DL;
         power--;
       }
     }

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * _testvalD128(pTHX_ int sign) {
     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _testvalD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = 9307199254740993e-15DL;

     if(sign < 0) *d128 *= -1;

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * _MEtoD128(pTHX_ char * mantissa, SV * exponent) {

     D128 * d128;
     SV * obj_ref, * obj;
     int exp = (int)SvIV(exponent), i;
     char * ptr;
     long double man;

     man = strtold(mantissa, &ptr);

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in MEtoD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = (D128)man;
     if(exp < 0) {
       for(i = 0; i > exp; --i) *d128 *= 0.1DL;
     }
     else {
       for(i = 0; i < exp; ++i) *d128 *= 10.0DL;
     }

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * NVtoD128(pTHX_ SV * x) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in NVtoD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = (D128)SvNV(x);

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UVtoD128(pTHX_ SV * x) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in UVtoD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = (D128)SvUV(x);

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * IVtoD128(pTHX_ SV * x) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in IVtoD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = (D128)SvIV(x);

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * PVtoD128(pTHX_ char * x) {
     D128 * d128;
     long double temp;
     char * ptr;
     SV * obj_ref, * obj;

     temp = strtold(x, &ptr);

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in PVtoD128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     *d128 = (D128)temp;

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * STRtoD128(pTHX_ char * x) {
#ifdef STRTOD128_AVAILABLE
     D128 * d128;
     char * ptr;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in STRtoD128() function");

     *d128 = strtod128(x, &ptr);

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
#else
     croak("The strtod128() function has not been made available");
#endif
}

int  have_strtod128(void) {
#ifdef STRTOD128_AVAILABLE
     return 1;
#else
     return 0;
#endif
}

SV * D128toNV(pTHX_ SV * d128) {
     return newSVnv((NV)(*(INT2PTR(D128*, SvIV(SvRV(d128))))));
}

void LDtoD128(pTHX_ SV * d128, SV * ld) {
     if(sv_isobject(d128) && sv_isobject(ld)) {
       const char *h1 = HvNAME(SvSTASH(SvRV(d128)));
       const char *h2 = HvNAME(SvSTASH(SvRV(ld)));
       if(strEQ(h1, "Math::Decimal128") && strEQ(h2, "Math::LongDouble")) {
         *(INT2PTR(D128 *, SvIV(SvRV(d128)))) = (D128)*(INT2PTR(long double *, SvIV(SvRV(ld))));
       }
       else croak("Invalid object supplied to Math::Decimal128::LDtoD128");
     }
     else croak("Invalid argument supplied to Math::Decimal128::LDtoD128");
}

void D128toLD(pTHX_ SV * ld, SV * d128) {
     if(sv_isobject(d128) && sv_isobject(ld)) {
       const char *h1 = HvNAME(SvSTASH(SvRV(d128)));
       const char *h2 = HvNAME(SvSTASH(SvRV(ld)));
       if(strEQ(h1, "Math::Decimal128") && strEQ(h2, "Math::LongDouble")) {
         *(INT2PTR(long double *, SvIV(SvRV(ld)))) = (long double)*(INT2PTR(D128 *, SvIV(SvRV(d128))));
       }
       else croak("Invalid object supplied to Math::Decimal128::D128toLD");
     }
     else croak("Invalid argument supplied to Math::Decimal128::D128toLD");
}

void DESTROY(pTHX_ SV *  rop) {
     Safefree(INT2PTR(D128 *, SvIV(SvRV(rop))));
}

void _assignME(pTHX_ SV * a, char * mantissa, SV * c) {
     char * ptr;
     long double man;
     int exp = (int)SvIV(c), i;

     man = strtold(mantissa, &ptr);

     *(INT2PTR(D128 *, SvIV(SvRV(a)))) = (D128)man;

     if(exp < 0) {
       for(i = 0; i > exp; --i) *(INT2PTR(D128 *, SvIV(SvRV(a)))) *= 0.1DL;
     }
     else {
       for(i = 0; i < exp; ++i) *(INT2PTR(D128 *, SvIV(SvRV(a)))) *= 10.0DL;
     }
}

void assignPV(pTHX_ SV * a, char * str) {
     char * ptr;
     long double man = strtold(str, &ptr);

     *(INT2PTR(D128 *, SvIV(SvRV(a)))) = (D128)man;
}

void assignNaN(pTHX_ SV * a) {

     if(sv_isobject(a)) {
       const char * h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) {
          *(INT2PTR(D128 *, SvIV(SvRV(a)))) = _get_nan();
       }
       else croak("Invalid object supplied to Math::Decimal128::assignNaN function");
     }
     else croak("Invalid argument supplied to Math::Decimal128::assignNaN function");
}

void assignInf(pTHX_ SV * a, int sign) {

     if(sv_isobject(a)) {
       const char * h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) {
          *(INT2PTR(D128 *, SvIV(SvRV(a)))) = _get_inf(sign);
       }
       else croak("Invalid object supplied to Math::Decimal128::assignInf function");
     }
     else croak("Invalid argument supplied to Math::Decimal128::assignInf function");
}

SV * _overload_add(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_add() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);

    if(SvUOK(b)) {
      *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) + SvUV(b);
      return obj_ref;
    }

    if(SvIOK(b)) {
      *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) + SvIV(b);
      return obj_ref;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) + *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return obj_ref;
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_add function");
    }
    croak("Invalid argument supplied to Math::Decimal128::_overload_add function");
}

SV * _overload_mul(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_mul() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);

    if(SvUOK(b)) {
      *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) * SvUV(b);
      return obj_ref;
    }

    if(SvIOK(b)) {
      *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) * SvIV(b);
      return obj_ref;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) * *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return obj_ref;
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_mul function");
    }
    croak("Invalid argument supplied to Math::Decimal128::_overload_mul function");
}

SV * _overload_sub(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_sub() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);

    if(SvUOK(b)) {
      if(third == &PL_sv_yes) *d128 = SvUV(b) - *(INT2PTR(D128 *, SvIV(SvRV(a))));
      else *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) - SvUV(b);
      return obj_ref;
    }

    if(SvIOK(b)) {
      if(third == &PL_sv_yes) *d128 = SvIV(b) - *(INT2PTR(D128 *, SvIV(SvRV(a))));
      else *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) - SvIV(b);
      return obj_ref;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) - *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return obj_ref;
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_sub function");
    }

    if(third == &PL_sv_yes) {
      *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) * -1.0DL;
      return obj_ref;
    }

    croak("Invalid argument supplied to Math::Decimal128::_overload_sub function");
}

SV * _overload_div(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_div() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);

    if(SvUOK(b)) {
      if(third == &PL_sv_yes) *d128 = SvUV(b) / *(INT2PTR(D128 *, SvIV(SvRV(a))));
      else *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) / SvUV(b);
      return obj_ref;
    }

    if(SvIOK(b)) {
      if(third == &PL_sv_yes) *d128 = SvIV(b) / *(INT2PTR(D128 *, SvIV(SvRV(a))));
      else *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) / SvIV(b);
      return obj_ref;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a)))) / *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return obj_ref;
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_div function");
    }
    croak("Invalid argument supplied to Math::Decimal128::_overload_div function");
}

SV * _overload_add_eq(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(SvUOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) += SvUV(b);
      return a;
    }
    if(SvIOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) += SvIV(b);
      return a;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *(INT2PTR(D128 *, SvIV(SvRV(a)))) += *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Decimal128::_overload_add_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Decimal128::_overload_add_eq function");
}

SV * _overload_mul_eq(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(SvUOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) *= SvUV(b);
      return a;
    }
    if(SvIOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) *= SvIV(b);
      return a;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *(INT2PTR(D128 *, SvIV(SvRV(a)))) *= *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Decimal128::_overload_mul_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Decimal128::_overload_mul_eq function");
}

SV * _overload_sub_eq(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(SvUOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) -= SvUV(b);
      return a;
    }
    if(SvIOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) -= SvIV(b);
      return a;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *(INT2PTR(D128 *, SvIV(SvRV(a)))) -= *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Decimal128::_overload_sub_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Decimal128::_overload_sub_eq function");
}

SV * _overload_div_eq(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(SvUOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) /= SvUV(b);
      return a;
    }
    if(SvIOK(b)) {
      *(INT2PTR(D128 *, SvIV(SvRV(a)))) /= SvIV(b);
      return a;
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        *(INT2PTR(D128 *, SvIV(SvRV(a)))) /= *(INT2PTR(D128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Decimal128::_overload_div_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Decimal128::_overload_div_eq function");
}

SV * _overload_equiv(pTHX_ SV * a, SV * b, SV * third) {

     if(SvUOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == SvUV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == SvIV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Decimal128")) {
         if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::Decimal128::_overload_equiv function");
     }
     croak("Invalid argument supplied to Math::Decimal128::_overload_equiv function");
}

SV * _overload_not_equiv(pTHX_ SV * a, SV * b, SV * third) {

     if(SvUOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) != SvUV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) != SvIV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Decimal128")) {
         if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(0);
         return newSViv(1);
       }
       croak("Invalid object supplied to Math::Decimal128::_overload_not_equiv function");
     }
     croak("Invalid argument supplied to Math::Decimal128::_overload_not_equiv function");
}

SV * _overload_lt(pTHX_ SV * a, SV * b, SV * third) {

     if(SvUOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < SvUV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < SvIV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Decimal128")) {
         if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::Decimal128::_overload_lt function");
     }
     croak("Invalid argument supplied to Math::Decimal128::_overload_lt function");
}

SV * _overload_gt(pTHX_ SV * a, SV * b, SV * third) {

    if(SvUOK(b)) {
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > SvUV(b)) return newSViv(1);
      return newSViv(0);
    }

    if(SvIOK(b)) {
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > SvIV(b)) return newSViv(1);
      return newSViv(0);
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
        return newSViv(0);
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_gt function");
    }
    croak("Invalid argument supplied to Math::Decimal128::_overload_gt function");
}

SV * _overload_lte(pTHX_ SV * a, SV * b, SV * third) {

     if(SvUOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) <= SvUV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) <= SvIV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Decimal128")) {
         if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) <= *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::Decimal128::_overload_lte function");
     }
     croak("Invalid argument supplied to Math::Decimal128::_overload_lte function");
}

SV * _overload_gte(pTHX_ SV * a, SV * b, SV * third) {

     if(SvUOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) >= SvUV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) >= SvIV(b)) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Decimal128")) {
         if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) >= *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::Decimal128::_overload_gte function");
     }
     croak("Invalid argument supplied to Math::Decimal128::_overload_gte function");
}

SV * _overload_spaceship(pTHX_ SV * a, SV * b, SV * third) {

    if(SvUOK(b)) {
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > SvUV(b)) return newSViv(1);
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < SvUV(b)) return newSViv(-1);
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == SvUV(b)) return newSViv(0);
      return &PL_sv_undef; /* Math::Decimal128 object (1st arg) is a nan */
    }

    if(SvIOK(b)) {
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > SvIV(b)) return newSViv(1);
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < SvIV(b)) return newSViv(-1);
      if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == SvIV(b)) return newSViv(0);
      return &PL_sv_undef; /* Math::Decimal128 object (1st arg) is a nan */
    }

    if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128")) {
        if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) < *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(-1);
        if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) > *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(1);
        if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) == *(INT2PTR(D128 *, SvIV(SvRV(b))))) return newSViv(0);
        return &PL_sv_undef; /* it's a nan */
      }
      croak("Invalid object supplied to Math::Decimal128::_overload_spaceship function");
    }
    croak("Invalid argument supplied to Math::Decimal128::_overload_spaceship function");
}

SV * _overload_copy(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_copy() function");

     *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a))));

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");
     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * D128toD128(pTHX_ SV * a) {
     D128 * d128;
     SV * obj_ref, * obj;

     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) {

         Newx(d128, 1, D128);
         if(d128 == NULL) croak("Failed to allocate memory in D128toD128() function");

         *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a))));

         obj_ref = newSV(0);
         obj = newSVrv(obj_ref, "Math::Decimal128");
         sv_setiv(obj, INT2PTR(IV,d128));
         SvREADONLY_on(obj);
         return obj_ref;
       }
       croak("Invalid object supplied to Math::Decimal128::D128toD128 function");
     }
     croak("Invalid argument supplied to Math::Decimal128::D128toD128 function");
}

SV * _overload_true(pTHX_ SV * a, SV * b, SV * third) {

     if(_is_nan(*(INT2PTR(D128 *, SvIV(SvRV(a)))))) return newSViv(0);
     if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) != 0.0DL) return newSViv(1);
     return newSViv(0);
}

SV * _overload_not(pTHX_ SV * a, SV * b, SV * third) {
     if(_is_nan(*(INT2PTR(D128 *, SvIV(SvRV(a)))))) return newSViv(1);
     if(*(INT2PTR(D128 *, SvIV(SvRV(a)))) != 0.0DL) return newSViv(0);
     return newSViv(1);
}

SV * _overload_abs(pTHX_ SV * a, SV * b, SV * third) {

     D128 * d128;
     SV * obj_ref, * obj;

     Newx(d128, 1, D128);
     if(d128 == NULL) croak("Failed to allocate memory in _overload_abs() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Decimal128");

     sv_setiv(obj, INT2PTR(IV,d128));
     SvREADONLY_on(obj);

     *d128 = *(INT2PTR(D128 *, SvIV(SvRV(a))));
     if(_is_neg_zero(*d128) || *d128 < 0 ) *d128 *= -1.0DL;
     return obj_ref;
}

SV * _overload_inc(pTHX_ SV * p, SV * second, SV * third) {
     SvREFCNT_inc(p);
     *(INT2PTR(D128 *, SvIV(SvRV(p)))) += 1.0DL;
     return p;
}

SV * _overload_dec(pTHX_ SV * p, SV * second, SV * third) {
     SvREFCNT_inc(p);
     *(INT2PTR(D128 *, SvIV(SvRV(p)))) -= 1.0DL;
     return p;
}

SV * _itsa(pTHX_ SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) return newSVuv(128);
     }
     return newSVuv(0);
}

SV * is_NaND128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128"))
         return newSViv(_is_nan(*(INT2PTR(D128 *, SvIV(SvRV(b))))));
     }
     croak("Invalid argument supplied to Math::Decimal128::is_NaND128 function");
}

SV * is_InfD128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128"))
         return newSViv(_is_inf(*(INT2PTR(D128 *, SvIV(SvRV(b))))));
     }
     croak("Invalid argument supplied to Math::Decimal128::is_InfD128 function");
}

SV * is_ZeroD128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
      const char *h = HvNAME(SvSTASH(SvRV(b)));
      if(strEQ(h, "Math::Decimal128"))
         if (_is_neg_zero(*(INT2PTR(D128 *, SvIV(SvRV(b)))))) return newSViv(-1);
         if (*(INT2PTR(D128 *, SvIV(SvRV(b)))) == 0.0DL) return newSViv(1);
         return newSViv(0);
     }
     croak("Invalid argument supplied to Math::Decimal128::is_ZeroD128 function");
}

void _D128toME(pTHX_ SV * a) {
     dXSARGS;
     D128 t;
     char * buffer;
     int count = 0;

     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) {
          t = *(INT2PTR(D128 *, SvIV(SvRV(a))));
          if(_is_nan(t) || _is_inf(t) || t == 0.0DL) {
            EXTEND(SP, 2);
            ST(0) = sv_2mortal(newSVnv(t));
            ST(1) = sv_2mortal(newSViv(0));
            XSRETURN(2);
          }

          /* At this stage we know the arg is not a D128 infinity/0, but on powerpc it might be a
             long double that's outside the allowable range */
#if defined(__powerpc__) || defined(_ARCH_PPC) || defined(_M_PPC) || defined(__PPCGECKO__) || defined(__PPCBROADWAY__)
          if((long double)t > LDBL_MAX ||
             (long double)t < -LDBL_MAX) {
            count = 150;
            t *= 1e-150DL; /* (long double)t should now be in range */
          }

          if((long double)t <  LDBL_MIN * 128.0L &&
             (long double)t > -LDBL_MIN * 128.0L) {
            count = -150;
            t *= 1e150DL; /* (long double)t should now be in range */
          }
#endif
          Newx(buffer, 32, char);
          if(buffer == NULL)croak("Couldn't allocate memory in _D128toME");
          sprintf(buffer, "%.15Le", (long double)t);
          EXTEND(SP, 3);
          ST(0) = sv_2mortal(newSVpv(buffer, 0));
          ST(1) = &PL_sv_undef;
          ST(2) = sv_2mortal(newSViv(count)); /* count will be added to the exponent in D128toME() perl sub. */
          Safefree(buffer);
          XSRETURN(3);
       }
       else croak("Invalid object supplied to Math::Decimal128::D128toME function");
     }
     else croak("Invalid argument supplied to Math::Decimal128::D128toME function");
}

/* Replaced by newer rendition (above) that caters for the case that the long double
   has the same exponent range as the double - eg. powerpc "double-double arithmetic".
void _D128toME(pTHX_ SV * a) {
     dXSARGS;
     D128 t;
     char * buffer;

     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Decimal128")) {
          EXTEND(SP, 2);
          t = *(INT2PTR(D128 *, SvIV(SvRV(a))));
          if(_is_nan(t) || _is_inf(t) || t == 0.0DL) {
            ST(0) = sv_2mortal(newSVnv(t));
            ST(1) = sv_2mortal(newSViv(0));
            XSRETURN(2);
          }

          Newx(buffer, 32, char);
          sprintf(buffer, "%.15Le", (long double)t);
          ST(0) = sv_2mortal(newSVpv(buffer, 0));
          ST(1) = &PL_sv_undef;
          Safefree(buffer);
          XSRETURN(2);
       }
       else croak("Invalid object supplied to Math::Decimal128::D128toME function");
     }
     else croak("Invalid argument supplied to Math::Decimal128::D128toME function");
}
*/

void _c2ld(pTHX_ char * mantissa) { /* convert using %.15Le */
     dXSARGS;
     long double man;
     char *ptr, *buffer;

     man = strtold(mantissa, &ptr);
     Newx(buffer, 32, char);
     sprintf(buffer, "%.15Le", man);

     ST(0) = sv_2mortal(newSVpv(buffer, 0));
     Safefree(buffer);
     XSRETURN(1);
}

void _c2d(pTHX_ char * mantissa) { /* convert using %.15e */
     dXSARGS;
     double man;
     char *ptr, *buffer;

     man = strtod(mantissa, &ptr);
     Newx(buffer, 32, char);
     sprintf(buffer, "%.15e", man);

     ST(0) = sv_2mortal(newSVpv(buffer, 0));
     Safefree(buffer);
     XSRETURN(1);
}

SV * _wrap_count(pTHX) {
     return newSVuv(PL_sv_count);
}

SV * _get_xs_version(pTHX) {
     return newSVpv(XS_VERSION, 0);
}
MODULE = Math::Decimal128	PACKAGE = Math::Decimal128

PROTOTYPES: DISABLE


SV *
_is_nan_NV (x)
	SV *	x
CODE:
  RETVAL = _is_nan_NV (aTHX_ x);
OUTPUT:  RETVAL

SV *
_is_inf_NV (x)
	SV *	x
CODE:
  RETVAL = _is_inf_NV (aTHX_ x);
OUTPUT:  RETVAL

SV *
_is_neg_zero_NV (x)
	SV *	x
CODE:
  RETVAL = _is_neg_zero_NV (aTHX_ x);
OUTPUT:  RETVAL

SV *
_DEC128_MAX ()
CODE:
  RETVAL = _DEC128_MAX (aTHX);
OUTPUT:  RETVAL


SV *
_DEC128_MIN ()
CODE:
  RETVAL = _DEC128_MIN (aTHX);
OUTPUT:  RETVAL


SV *
NaND128 ()
CODE:
  RETVAL = NaND128 (aTHX);
OUTPUT:  RETVAL


SV *
InfD128 (sign)
	int	sign
CODE:
  RETVAL = InfD128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
ZeroD128 (sign)
	int	sign
CODE:
  RETVAL = ZeroD128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
UnityD128 (sign)
	int	sign
CODE:
  RETVAL = UnityD128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
Exp10 (power)
	int	power
CODE:
  RETVAL = Exp10 (aTHX_ power);
OUTPUT:  RETVAL

SV *
_testvalD128 (sign)
	int	sign
CODE:
  RETVAL = _testvalD128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
_MEtoD128 (mantissa, exponent)
	char *	mantissa
	SV *	exponent
CODE:
  RETVAL = _MEtoD128 (aTHX_ mantissa, exponent);
OUTPUT:  RETVAL

SV *
NVtoD128 (x)
	SV *	x
CODE:
  RETVAL = NVtoD128 (aTHX_ x);
OUTPUT:  RETVAL

SV *
UVtoD128 (x)
	SV *	x
CODE:
  RETVAL = UVtoD128 (aTHX_ x);
OUTPUT:  RETVAL

SV *
IVtoD128 (x)
	SV *	x
CODE:
  RETVAL = IVtoD128 (aTHX_ x);
OUTPUT:  RETVAL

SV *
PVtoD128 (x)
	char *	x
CODE:
  RETVAL = PVtoD128 (aTHX_ x);
OUTPUT:  RETVAL

SV *
STRtoD128 (x)
	char *	x
CODE:
  RETVAL = STRtoD128 (aTHX_ x);
OUTPUT:  RETVAL

int
have_strtod128 ()


SV *
D128toNV (d128)
	SV *	d128
CODE:
  RETVAL = D128toNV (aTHX_ d128);
OUTPUT:  RETVAL

void
LDtoD128 (d128, ld)
	SV *	d128
	SV *	ld
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	LDtoD128(aTHX_ d128, ld);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
D128toLD (ld, d128)
	SV *	ld
	SV *	d128
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	D128toLD(aTHX_ ld, d128);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
DESTROY (rop)
	SV *	rop
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	DESTROY(aTHX_ rop);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
_assignME (a, mantissa, c)
	SV *	a
	char *	mantissa
	SV *	c
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_assignME(aTHX_ a, mantissa, c);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
assignPV (a, str)
	SV *	a
	char *	str
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	assignPV(aTHX_ a, str);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
assignNaN (a)
	SV *	a
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	assignNaN(aTHX_ a);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
assignInf (a, sign)
	SV *	a
	int	sign
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	assignInf(aTHX_ a, sign);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_add_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_mul_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sub_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_div_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_not_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_not_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_lt (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_gt (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_lte (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_gte (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_spaceship (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_spaceship (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_copy (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_copy (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
D128toD128 (a)
	SV *	a
CODE:
  RETVAL = D128toD128 (aTHX_ a);
OUTPUT:  RETVAL

SV *
_overload_true (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_true (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_not (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_not (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_abs (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_abs (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_inc (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = _overload_inc (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
_overload_dec (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = _overload_dec (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

SV *
is_NaND128 (b)
	SV *	b
CODE:
  RETVAL = is_NaND128 (aTHX_ b);
OUTPUT:  RETVAL

SV *
is_InfD128 (b)
	SV *	b
CODE:
  RETVAL = is_InfD128 (aTHX_ b);
OUTPUT:  RETVAL

SV *
is_ZeroD128 (b)
	SV *	b
CODE:
  RETVAL = is_ZeroD128 (aTHX_ b);
OUTPUT:  RETVAL

void
_D128toME (a)
	SV *	a
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_D128toME(aTHX_ a);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
_c2ld (mantissa)
	char *	mantissa
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_c2ld(aTHX_ mantissa);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
_c2d (mantissa)
	char *	mantissa
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_c2d(aTHX_ mantissa);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_wrap_count ()
CODE:
  RETVAL = _wrap_count (aTHX);
OUTPUT:  RETVAL


SV *
_get_xs_version ()
CODE:
  RETVAL = _get_xs_version (aTHX);
OUTPUT:  RETVAL




#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#if defined SvTRUE_nomg_NN
#define SWITCH_ARGS SvTRUE_nomg_NN(third)
#else
#define SWITCH_ARGS third==&PL_sv_yes
#endif

/*************************************************************************************
   In certain situations SvIVX and SvUVX cause crashes on mingw-w64 x64 builds.
   Behaviour varies with different versions of perl, different versions of gcc
   and different versions of mingw-runtime.
   I've just taken a blanket approach - I don't think the minimal gain in
   performance offered by SvIVX/SvUVX over SvIV/SvUV justifies going to much trouble.
   Hence we define the following:
*************************************************************************************/
#ifdef __MINGW64__
#define M_D128_SvIV SvIV
#define M_D128_SvUV SvUV
#else
#define M_D128_SvIV SvIVX
#define M_D128_SvUV SvUVX
#endif

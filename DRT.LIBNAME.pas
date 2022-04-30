unit DRT.LIBNAME;

interface
{$IFDEF ANDROID32}
const
  libdrt = 'libdrt.android32.a';

  _PU = '';
{$ENDIF ANDROID32}
{$IFDEF ANDROID64}
const
  libdrt = 'libdrt.android64.a';

  _PU = '';
{$ENDIF ANDROID64}
{$IFDEF LINUX}
const
  libdrt = 'Libdrt.linux64.a';
  _PU = '';
{$ENDIF LINUX}
{$IFDEF WIN64}
const
{$IFDEF AVX2}
  libdrt = 'drt.x64.avx2.dll';
{$ELSE}
  libdrt = 'drt.x64.sse2.dll';
{$ENDIF}
  _PU = '';
{$ENDIF WIN64}
{$IFDEF WIN32}
const
{$IFDEF AVX2}
  libdrt = 'drt.win32.avx2.dll';
{$ELSE}
  libdrt = 'drt.win32.sse2.dll';
{$ENDIF}
  _PU = '';
{$ENDIF WIN32}
  {$EXTERNALSYM libdrt}
  {$EXTERNALSYM _PU}

implementation

end.

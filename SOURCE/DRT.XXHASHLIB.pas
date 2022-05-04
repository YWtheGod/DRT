//remove this to use SSE2 only
{$DEFINE AVX2}


unit DRT.XXHASHLIB;

interface
uses DRT.LIBNAME;
const
  XXH_VERSION_MAJOR = 0;
  XXH_VERSION_MINOR = 8;
  XXH_VERSION_RELEASE = 1;
  XXH_VERSION_NUMBER = XXH_VERSION_MAJOR *10000 + XXH_VERSION_MINOR *100 + XXH_VERSION_RELEASE;
  XXH3_SECRET_DEFAULT_SIZE = 192;
  XXH3_INTERNALBUFFER_SIZE =256;
type
  XXH_errorcode = (XXH_OK=0,XXH_ERROR);

  XXH32_hash_t = Cardinal;
  PXXH32_hash_t = ^XXH32_hash_t;
  XXH32_canonical_t = array[0..sizeof(XXH32_hash_t)-1] of byte;
  XXH32_state_t = record
    total_len_32,large_len : XXH32_hash_t;
    v,mem32 : array[0..3] of XXH32_hash_t;
    memsize,reserved : XXH32_hash_t
  end;
  PXXH32_state_t = ^XXH32_state_t;

  XXH64_hash_t = UINT64;
  PXXH64_hash_t = ^XXH64_hash_t;
  XXH64_canonical_t = array[0..sizeof(XXH64_hash_t)-1] of byte;
  XXH64_state_t = record
    total_len : XXH64_hash_t;
    v, mem64 : array[0..3] of XXH64_hash_t;
    memsize,reserved32reserved32 : XXH32_hash_t;
    reserved64 : XXH64_hash_t;
  end;
  PXXH64_state_t = ^XXH64_state_t;

  XXH128_hash_t = record
    low64,high64 : XXH64_hash_t;
  end;
  PXXH128_hash_t = ^XXH128_hash_t;
  XXH128_canonical_t = array[0..sizeof(XXH128_hash_t)-1] of byte;
  XXH3_state_t = record
    acc : array[0..7] of XXH64_hash_t;
    customSecret : array[0..XXH3_SECRET_DEFAULT_SIZE-1] of byte;
    buffer : array[0..XXH3_INTERNALBUFFER_SIZE-1] of byte;
    buffersize,useSeed : XXH32_hash_t;
    nbStripesSoFar : NativeInt;
    totalLen : XXH64_hash_t;
    nbStripesPerBlock,secretLimit : NativeInt;
    seed, reserved64 : XXH64_hash_t;
    extSecret : Pointer;
  end;
  PXXH3_state_t = ^XXH3_state_t;

  function XXH_versionNumber:Cardinal;
  cdecl; external libdrt name _PU+'XXH_versionNumber';

  //XXH_PUBLIC_API XXH32_hash_t XXH32(const void* input, size_t length, XXH32_hash_t seed);
  function XXH32(input : Pointer; length : NativeInt; seed : XXH32_hash_t):
    XXH32_hash_t;
  cdecl; external libdrt name _PU+'XXH32';


  //XXH_PUBLIC_API XXH32_state_t* XXH32_createState(void);
  function XXH32_createState : PXXH32_state_t;
  cdecl; external libdrt name _PU+'XXH32_createState';

  //XXH_PUBLIC_API XXH_errorcode  XXH32_freeState(XXH32_state_t* statePtr);
  function XXH32_freeState(statePtr : PXXH32_state_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH32_freeState';


  //XXH_PUBLIC_API void XXH32_copyState(XXH32_state_t* dst_state, const XXH32_state_t* src_state);
  procedure XXH32_copyState(dst_state,src_state:PXXH32_state_t); cdecl;
  cdecl; external libdrt name _PU+'XXH32_copyState';


  //XXH_PUBLIC_API XXH_errorcode XXH32_reset  (XXH32_state_t* statePtr, XXH32_hash_t seed);
  function XXH32_reset(var state:XXH32_state_t; seed:XXH32_hash_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH32_reset';


  //XXH_PUBLIC_API XXH_errorcode XXH32_update (XXH32_state_t* statePtr, const void* input, size_t length);
  function XXH32_update(var state:XXH32_state_t;input:Pointer;length:NativeInt)
    : XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH32_update';


  //XXH_PUBLIC_API XXH32_hash_t  XXH32_digest (const XXH32_state_t* statePtr);
  function XXH32_digest(var state:XXH32_state_t):XXH32_hash_t;
  cdecl; external libdrt name _PU+'XXH32_digest';


  //XXH_PUBLIC_API void XXH32_canonicalFromHash(XXH32_canonical_t* dst, XXH32_hash_t hash);
  procedure XXH32_canonicalFromHash(var dst:XXH32_canonical_t; hash:XXH32_hash_t);
  cdecl; external libdrt name _PU+'XXH32_canonicalFromHash';


  //XXH_PUBLIC_API XXH32_hash_t XXH32_hashFromCanonical(const XXH32_canonical_t* src);
  function XXH32_hashFromCanonical(var src: XXH32_canonical_t): XXH32_hash_t;
  cdecl; external libdrt name _PU+'XXH32_hashFromCanonical';

  //XXH_PUBLIC_API XXH64_hash_t XXH64(const void* input, size_t length, XXH64_hash_t seed);
  function XXH64(input : Pointer; length : NativeInt; seed : XXH64_hash_t):
    XXH64_hash_t;
  cdecl; external libdrt name _PU+'XXH64';


  //XXH_PUBLIC_API XXH64_state_t* XXH64_createState(void);
  function XXH64_createState : PXXH64_state_t;
  cdecl; external libdrt name _PU+'XXH64_createState';

  //XXH_PUBLIC_API XXH_errorcode  XXH64_freeState(XXH64_state_t* statePtr);
  function XXH64_freeState(statePtr : PXXH64_state_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH64_freeState';

  //XXH_PUBLIC_API void XXH64_copyState(XXH64_state_t* dst_state, const XXH64_state_t* src_state);
  procedure XXH64_copyState(dst_state,src_state:PXXH64_state_t);
  cdecl; external libdrt name _PU+'XXH64_copyState';

  //XXH_PUBLIC_API XXH_errorcode XXH64_reset  (XXH64_state_t* statePtr, XXH64_hash_t seed);
  function XXH64_reset(var state:XXH64_state_t; seed:XXH64_hash_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH64_reset';

  //XXH_PUBLIC_API XXH_errorcode XXH64_update (XXH64_state_t* statePtr, const void* input, size_t length);
  function XXH64_update(var state:XXH64_state_t;input:Pointer;length:NativeInt)
    : XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH64_update';

  //XXH_PUBLIC_API XXH64_hash_t  XXH64_digest (const XXH64_state_t* statePtr);
  function XXH64_digest(var state:XXH64_state_t):XXH64_hash_t;
  cdecl; external libdrt name _PU+'XXH64_digest';

  //XXH_PUBLIC_API void XXH64_canonicalFromHash(XXH64_canonical_t* dst, XXH64_hash_t hash);
  procedure XXH64_canonicalFromHash(var dst:XXH64_canonical_t; hash:XXH64_hash_t);
  cdecl; external libdrt name _PU+'XXH64_canonicalFromHash';

  //XXH_PUBLIC_API XXH64_hash_t XXH64_hashFromCanonical(const XXH64_canonical_t* src);
  function XXH64_hashFromCanonical(var src: XXH64_canonical_t): XXH64_hash_t;
  cdecl; external libdrt name _PU+'XXH64_hashFromCanonical';

  //XXH_PUBLIC_API XXH128_hash_t XXH3_128bits(const void* data, size_t len);
  function XXH3_128bits(data : Pointer; len : NativeInt):XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH3_128bits';

  //XXH_PUBLIC_API XXH128_hash_t XXH3_128bits_withSeed(const void* data, size_t len, XXH64_hash_t seed);
  function XXH3_128bits_withSeed(data : Pointer; len : NativeInt; seed :
    XXH64_hash_t):XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH3_128bits_withSeed';

  //XXH_PUBLIC_API XXH128_hash_t XXH3_128bits_withSecret(const void* data, size_t len, const void* secret, size_t secretSize);
  function XXH3_128bits_withSecret(data : Pointer; len : NativeInt; secret :
    Pointer; secretSize: NativeInt):XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH3_128bits_withSecret';

  //XXH_PUBLIC_API XXH_errorcode XXH3_128bits_reset(XXH3_state_t* statePtr);
  function XXH3_128bits_reset(var state : XXH3_state_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_128bits_reset';

  //XXH_PUBLIC_API XXH_errorcode XXH3_128bits_reset_withSeed(XXH3_state_t* statePtr, XXH64_hash_t seed);
  function XXH3_128bits_reset_withSeed(var state : XXH3_state_t; seed :
    XXH64_hash_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_128bits_reset_withSeed';

  //XXH_PUBLIC_API XXH_errorcode XXH3_128bits_reset_withSecret(XXH3_state_t* statePtr, const void* secret, size_t secretSize);
  function XXH3_128bits_reset_withSecret(var state : XXH3_state_t; secret :
    Pointer; secretSize:NativeInt):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_128bits_reset_withSecret';

  //XXH_PUBLIC_API XXH_errorcode XXH3_128bits_update (XXH3_state_t* statePtr, const void* input, size_t length);
  function XXH3_128bits_update(var state : XXH3_state_t; input : Pointer; length
    : NativeInt):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_128bits_update';

  //XXH_PUBLIC_API XXH128_hash_t XXH3_128bits_digest (const XXH3_state_t* statePtr);
  function XXH3_128bits_digest(var state : XXH3_state_t):XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH3_128bits_digest';

  //XXH_PUBLIC_API int XXH128_isEqual(XXH128_hash_t h1, XXH128_hash_t h2);
  function XXH128_isEqual(h1,h2 : XXH128_hash_t):integer;
  cdecl; external libdrt name _PU+'XXH128_isEqual';

  //XXH_PUBLIC_API int XXH128_cmp(const void* h128_1, const void* h128_2);
  function XXH128_cmp(h1,h2 : Pointer):integer;
  cdecl; external libdrt name _PU+'XXH128_cmp';

  //XXH_PUBLIC_API void XXH128_canonicalFromHash(XXH128_canonical_t* dst, XXH128_hash_t hash);
  procedure XXH128_canonicalFromHash(var dst:XXH128_canonical_t; hash :
    XXH128_hash_t);
  cdecl; external libdrt name _PU+'XXH128_canonicalFromHash';

  //XXH_PUBLIC_API XXH128_hash_t XXH128_hashFromCanonical(const XXH128_canonical_t* src);
  function XXH128_hashFromCanonical(var src:XXH128_canonical_t):XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH128_hashFromCanonical';

  //XXH_PUBLIC_API XXH128_hash_t XXH128(const void* data, size_t len, XXH64_hash_t seed);
  function XXH128(data : Pointer; len : NativeInt; seed : XXH64_hash_t):
    XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH128';

  //XXH_PUBLIC_API XXH_errorcode XXH3_generateSecret(void* secretBuffer, size_t secretSize, const void* customSeed, size_t customSeedSize);
  function XXH3_generateSecret(secretBuffer:Pointer; secretSize : NativeInt;
    customSeed : Pointer; customSeedSize : NativeInt):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_generateSecret';

  //XXH_PUBLIC_API void XXH3_generateSecret_fromSeed(void* secretBuffer, XXH64_hash_t seed);
  procedure XXH3_generateSecret_fromSeed(secretBuffer : Pointer; seed :
    XXH64_hash_t);
  cdecl; external libdrt name _PU+'XXH3_generateSecret_fromSeed';

  //XXH_PUBLIC_API XXH64_hash_t
  //XXH3_64bits_withSecretandSeed(const void* data, size_t len,
  //                              const void* secret, size_t secretSize,
  //                              XXH64_hash_t seed);
  function XXH3_64bits_withSecretandSeed(data : Pointer; len : NativeInt; secret
    : Pointer; secretSize : NativeInt; seed : XXH64_hash_t):XXH64_hash_t;
  cdecl; external libdrt name _PU+'XXH3_64bits_withSecretandSeed';

  //XXH_PUBLIC_API XXH128_hash_t
  //XXH3_128bits_withSecretandSeed(const void* data, size_t len,
  //                               const void* secret, size_t secretSize,
  //                               XXH64_hash_t seed64);
  function XXH3_128bits_withSecretandSeed(data : Pointer; len : NativeInt;
    secret : Pointer; secretSize : NativeInt; seed : XXH64_hash_t):
    XXH128_hash_t;
  cdecl; external libdrt name _PU+'XXH3_128bits_withSecretandSeed';

  //XXH_PUBLIC_API XXH_errorcode
  //XXH3_64bits_reset_withSecretandSeed(XXH3_state_t* statePtr,
  //                                    const void* secret, size_t secretSize,
  //                                    XXH64_hash_t seed64);
  function XXH3_64bits_reset_withSecretandSeed(var state : XXH3_state_t; secret
    : Pointer; secretSize : NativeInt; seed64 : XXH64_hash_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_64bits_reset_withSecretandSeed';

  //XXH_PUBLIC_API XXH_errorcode
  //XXH3_128bits_reset_withSecretandSeed(XXH3_state_t* statePtr,
  //                                     const void* secret, size_t secretSize,
  //                                     XXH64_hash_t seed64);
  function XXH3_128bits_reset_withSecretandSeed(var state : XXH3_state_t; secret
    : Pointer; secretSize : NativeInt; seed64 : XXH64_hash_t):XXH_errorcode;
  cdecl; external libdrt name _PU+'XXH3_128bits_reset_withSecretandSeed';

procedure XXH3_INITSTATE(var XXH3_state : XXH3_state_t); inline;

implementation
procedure XXH3_INITSTATE(var XXH3_state : XXH3_state_t); inline;
begin
  XXH3_state.seed := 0;
end;

end.

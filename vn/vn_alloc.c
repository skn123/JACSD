#include "vn_lib.h"

#ifdef VN_TEST
int main(int argc VN_VAR_UNUSED, char *argv[] VN_VAR_UNUSED)
{
  const vn_integer m = MkInt(3);
  const vn_integer n = MkInt(2);
  const vn_integer act = MkInt(1);
  vn_integer ldA = MkInt(0);
  vn_real *const A = VN_ALLOC2(vn_real, m, n, &ldA, act);
  VN_SYSI_CALL(printf("ldA: %lld\n", (long long)ldA) <= 0);
  vn_free(A);
  return EXIT_SUCCESS;
}
#else /* !VN_TEST */
void *vn_alloc1(const vn_integer m, const size_t szT, vn_integer *const ldA, const vn_integer act)
{
  return vn_alloc2(m, MkInt(1), szT, ldA, act);
}

void *vn_alloc2(const vn_integer m, const vn_integer n, const size_t szT, vn_integer *const ldA, const vn_integer act)
{
  VN_ASSERT(m >= MkInt(0));
  VN_ASSERT(n >= MkInt(0));
  void *ret = NULL;
  vn_integer ld_ = MkInt(0);

  // align to page size, if possible
  const long page_sz = sysconf(_SC_PAGESIZE);
  const size_t algnB = (size_t)((page_sz <= 0L) ? 0UL : (unsigned long)((page_sz >= VN_ALIGN_BYTES) ? ((page_sz % VN_ALIGN_BYTES) ? (long)VN_ALIGN_BYTES : page_sz) : (long)VN_ALIGN_BYTES));

  if ((m > MkInt(0)) && (n > MkInt(0)) && szT && algnB) {
    if ((szT <= algnB) && !(algnB % szT)) {
      const vn_integer noe = (vn_integer)(algnB / szT);
      const vn_integer rem = m % noe;
      if (rem)
        ld_ = m + (noe - rem);
      else
        ld_ = m;
    }
    else
      ld_ = m;
    if (act) {
      const size_t siz = ld_ * (n * szT);
      if (labs(act) == MkInt(1)) {
        VN_SYSI_CALL(posix_memalign(&ret, algnB, siz));
#ifndef NDEBUG
        VN_SYSP_CALL(ret);
#endif /* !NDEBUG */
      }
#ifdef __AVX512PF__
      else if (labs(act) == MkInt(2)) {
        VN_SYSI_CALL(hbw_check_available());
        VN_SYSI_CALL(hbw_posix_memalign(&ret, algnB, siz));
#ifndef NDEBUG
        VN_SYSP_CALL(ret);
        VN_SYSI_CALL(hbw_verify_memory_region(ret, siz, ((act < MkInt(0)) ? HBW_TOUCH_PAGES : 0)));
#endif /* !NDEBUG */
      }
#endif /* __AVX512PF__ */
      else
        goto LdA;
      if (ret && (act < MkInt(0)))
        (void)memset(ret, 0, siz);
    }
  }

 LdA:
  if (ldA)
    *ldA = ld_;
  return ret;
}

void vn_free(const void *const ptr)
{
#ifdef __AVX512PF__
  if (!hbw_verify_memory_region((void*)ptr, 1u, 0)) {
    hbw_free((void*)ptr);
    return;
  }
#endif /* __AVX512PF__ */
  free((void*)ptr);
}

void vn_freep(const void **const pptr)
{
  if (pptr) {
    vn_free(*pptr);
    *pptr = (const void*)NULL;
  }
}
#endif /* ?VN_TEST */

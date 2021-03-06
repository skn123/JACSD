#ifdef USE_X64
! Intel Ivy Bridge, Haswell
INTEGER, PARAMETER :: L1D_kB = 32
INTEGER, PARAMETER :: L1D_CLS_B = 64
INTEGER, PARAMETER :: L2D_kB = 256
INTEGER, PARAMETER :: VEC_LEN_b = 256
INTEGER, PARAMETER :: MAX_TPC = 2
#endif

#ifdef USE_X100
! Intel KNC (x100)
INTEGER, PARAMETER :: L1D_kB = 32
INTEGER, PARAMETER :: L1D_CLS_B = 64
INTEGER, PARAMETER :: L2D_kB = 512
INTEGER, PARAMETER :: VEC_LEN_b = 512
INTEGER, PARAMETER :: MAX_TPC = 4
#endif

#ifdef USE_X200
! Intel KNL (x200)
INTEGER, PARAMETER :: L1D_kB = 32
INTEGER, PARAMETER :: L1D_CLS_B = 64
INTEGER, PARAMETER :: L2D_kB = 512
INTEGER, PARAMETER :: VEC_LEN_b = 512
INTEGER, PARAMETER :: MAX_TPC = 4
#endif

INTEGER, PARAMETER :: VEC_BYTES = (VEC_LEN_b / 8)
INTEGER, PARAMETER :: I_VEC_LEN = (VEC_BYTES / IWP)
INTEGER, PARAMETER :: I_CL1_LEN = (L1D_CLS_B / IWP)
INTEGER, PARAMETER :: L_VEC_LEN = (VEC_BYTES / LWP)
INTEGER, PARAMETER :: L_CL1_LEN = (L1D_CLS_B / LWP)
INTEGER, PARAMETER :: S_VEC_LEN = (VEC_BYTES / 4)
INTEGER, PARAMETER :: S_CL1_LEN = (L1D_CLS_B / 4)
INTEGER, PARAMETER :: D_VEC_LEN = (VEC_BYTES / 8)
INTEGER, PARAMETER :: D_CL1_LEN = (L1D_CLS_B / 8)
INTEGER, PARAMETER :: C_VEC_LEN = (S_VEC_LEN / 2)
INTEGER, PARAMETER :: C_CL1_LEN = (S_CL1_LEN / 2)
INTEGER, PARAMETER :: Z_VEC_LEN = (D_VEC_LEN / 2)
INTEGER, PARAMETER :: Z_CL1_LEN = (D_CL1_LEN / 2)
! Assume L1 data cache line size >= vector length.
INTEGER, PARAMETER :: CL1_VEC  = (L1D_CLS_B / VEC_BYTES)   ! > 0

#ifndef USE_GNU
! Align allocatable arrays to a multiple of cache line size.
INTEGER, PARAMETER :: MALIGN_B = L1D_CLS_B
#else
INTEGER, PARAMETER :: MALIGN_B = VEC_BYTES
#endif
INTEGER, PARAMETER :: PAGESZ_B = (4 * 1024)

INTEGER, PARAMETER :: L1D_B = (L1D_kB * 1024)
INTEGER, PARAMETER :: I_L1D = (L1D_B / IWP)
INTEGER, PARAMETER :: L_L1D = (L1D_B / LWP)
INTEGER, PARAMETER :: S_L1D = (L1D_B / 4)
INTEGER, PARAMETER :: D_L1D = (L1D_B / 8)
INTEGER, PARAMETER :: C_L1D = (S_L1D / 2)
INTEGER, PARAMETER :: Z_L1D = (D_L1D / 2)

INTEGER, PARAMETER :: L2D_B = (L2D_kB * 1024)
INTEGER, PARAMETER :: I_L2D = (L2D_B / IWP)
INTEGER, PARAMETER :: L_L2D = (L2D_B / LWP)
INTEGER, PARAMETER :: S_L2D = (L2D_B / 4)
INTEGER, PARAMETER :: D_L2D = (L2D_B / 8)
INTEGER, PARAMETER :: C_L2D = (S_L2D / 2)
INTEGER, PARAMETER :: Z_L2D = (D_L2D / 2)

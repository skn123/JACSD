PROGRAM CORTHO
  USE, INTRINSIC :: ISO_C_BINDING
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY: OUTPUT_UNIT, ERROR_UNIT
  USE BIO
  IMPLICIT NONE

  INTEGER, PARAMETER :: WP = QX_WP
  ! Max file name length.
  INTEGER, PARAMETER :: FNL = 255
  REAL(KIND=WP), PARAMETER :: Q_ZERO = 0.0_WP, Q_ONE = 1.0_WP
  COMPLEX(KIND=WP), PARAMETER :: X_ZERO = (Q_ZERO,Q_ZERO), X_ONE=(Q_ONE,Q_ZERO)
  CHARACTER(LEN=2), PARAMETER :: ACT = 'RO'

  COMPLEX, ALLOCATABLE :: U(:,:)
  COMPLEX(KIND=WP), ALLOCATABLE :: xU(:,:), xC(:,:)

  CHARACTER(LEN=FNL) :: FN
  INTEGER :: M, N, I, J, INFO
  REAL(KIND=WP) :: CNF

  CALL READCL(FN, M, N, INFO)
  IF (INFO .NE. 0) THEN
     WRITE (ERROR_UNIT,'(I2)',ADVANCE='NO') INFO
     FLUSH(ERROR_UNIT)
     ERROR STOP ' READCL'
  END IF

  ALLOCATE(U(M,N))

  I = -1
  CALL BIO_OPEN(I, TRIM(FN), ACT, INFO)
  IF (INFO .NE. 0) ERROR STOP 'BIO_OPEN'
  CALL BIO_READ_C2(I, M, N, U, INFO)
  IF (INFO .NE. 0) ERROR STOP 'BIO_READ_C2'
  CALL BIO_CLOSE(I, INFO)
  IF (INFO .NE. 0) ERROR STOP 'BIO_CLOSE'

  ALLOCATE(xU(M,N))

  !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(I,J)
  DO J = 1, N
     DO I = 1, M
        xU(I,J) = U(I,J)
     END DO
  END DO
  !$OMP END PARALLEL DO

  DEALLOCATE(U)
  ALLOCATE(xC(N,N))

  ! Compute || U^H U - I ||_F
#ifndef NDEBUG
  WRITE (OUTPUT_UNIT,'(A)',ADVANCE='NO') '|| U^H U - I ||_F ='
  FLUSH(OUTPUT_UNIT)
#endif
  CNF = SQRT(PXGEMM(M, N, xU, M, xC, N))
  WRITE (OUTPUT_UNIT,1) CNF
  FLUSH(OUTPUT_UNIT)

  DEALLOCATE(xC)
  DEALLOCATE(xU)

1 FORMAT(ES16.9E2)

CONTAINS

  REAL(KIND=WP) FUNCTION PXGEMM(M, N, U, LDU, C, LDC)
    IMPLICIT NONE

    INTEGER, INTENT(IN) :: M, N, LDU, LDC
    COMPLEX(KIND=WP), INTENT(IN) :: U(LDU,N)
    COMPLEX(KIND=WP), INTENT(INOUT) :: C(LDC,N)

    REAL(KIND=WP) :: CNF, RE, IM
    INTEGER :: I, J, L

    !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(I,J,L)
    DO J = 1, N
       DO L = 1, N
          C(L,J) = X_ZERO
          DO I = 1, M
             C(L,J) = C(L,J) + CONJG(U(I,L)) * U(I,J)
          END DO
          IF (L .EQ. J) C(L,J) = C(L,J) - X_ONE
       END DO
    END DO
    !$OMP END PARALLEL DO

    CNF = Q_ZERO
    !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(I,J,RE,IM) REDUCTION(+:CNF)
    DO J = 1, N
       DO I = 1, N
          RE = REAL(C(I,J))
          IM = AIMAG(C(I,J))
          CNF = CNF + RE*RE + IM*IM
       END DO
    END DO
    !$OMP END PARALLEL DO

    PXGEMM = CNF
  END FUNCTION PXGEMM

  SUBROUTINE READCL(FN, M, N, INFO)
    IMPLICIT NONE

    CHARACTER(LEN=*), INTENT(OUT) :: FN
    INTEGER, INTENT(OUT) :: M, N, INFO

    CHARACTER(LEN=FNL) :: ARG
    INTEGER :: TMP

    INFO = 0
    IF (COMMAND_ARGUMENT_COUNT() .NE. 3) ERROR STOP 'cortho.exe FN M N'

    CALL GET_COMMAND_ARGUMENT(1, ARG, TMP, INFO)
    IF (INFO .NE. 0) THEN
       INFO = -1
       RETURN
    END IF
    FN = TRIM(ARG)
    IF (LEN_TRIM(FN) .LE. 0) THEN
       INFO = 1
       RETURN
    END IF

    CALL GET_COMMAND_ARGUMENT(2, ARG, TMP, INFO)
    IF (INFO .NE. 0) THEN
       INFO = -2
       RETURN
    END IF
    READ (ARG,*) M
    IF (M .LE. 0) THEN
       INFO = 2
       RETURN
    END IF

    CALL GET_COMMAND_ARGUMENT(3, ARG, TMP, INFO)
    IF (INFO .NE. 0) THEN
       INFO = -3
       RETURN
    END IF
    READ (ARG,*) N
    IF (N .LE. 0) THEN
       INFO = 3
       RETURN
    END IF
  END SUBROUTINE READCL
END PROGRAM CORTHO

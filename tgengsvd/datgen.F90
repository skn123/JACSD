MODULE DATGEN
  USE SEED
  IMPLICIT NONE

  INTEGER, PARAMETER, PRIVATE :: WP = QX_WP
  REAL(KIND=WP), PARAMETER, PRIVATE :: D_ZERO = 0.0_WP, D_ONE = 1.0_WP
  COMPLEX(KIND=WP), PARAMETER, PRIVATE :: Z_ZERO = (D_ZERO, D_ZERO), Z_ONE = (D_ONE, D_ZERO)

CONTAINS

  SUBROUTINE DGENDAT(N, ISEED, QS_F, QS_G, QL_X, QF, DF, QG, DG, QX, DX, QWORK, INFO)
    IMPLICIT NONE

    INTEGER, INTENT(IN) :: N, ISEED(4)
    REAL(KIND=WP), INTENT(IN) :: QS_F(N), QS_G(N), QL_X(N)
    DOUBLE PRECISION, INTENT(OUT) :: DF(N,N), DG(N,N), DX(N,N)
    REAL(KIND=WP), INTENT(OUT) :: QF(N,N), QG(N,N), QX(N,N), QWORK(3*N)
    INTEGER, INTENT(OUT) :: INFO

    INTEGER :: P, Q
    EXTERNAL :: QGEMM, QLAGSY, QLAROR

    INFO = 0

    IF (N .LT. 0) THEN
       INFO = -1
       RETURN
    END IF
    CALL SEEDOK(ISEED, INFO)
    IF (INFO .NE. 0) THEN
       INFO = -2
       RETURN
    END IF

    CALL QLAGSY(N, N-1, QL_X, QX, N, ISEED, QWORK, INFO)
    IF (INFO .NE. 0) RETURN
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,QX,DX) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          DX(P,Q) = DBLE(QX(P,Q))
       END DO
    END DO
    !$OMP END PARALLEL DO

    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,QF,QS_F) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, Q-1
          QF(P,Q) = D_ZERO
       END DO
       QF(Q,Q) = QS_F(Q)
       DO P = Q+1, N
          QF(P,Q) = D_ZERO
       END DO
    END DO
    !$OMP END PARALLEL DO

    CALL QLAROR('L', 'N', N, N, QF, N, ISEED, QWORK, INFO)
    IF (INFO .NE. 0) RETURN

    CALL QGEMM('N', 'N', N, N, N, D_ONE, QF, N, QX, N, D_ZERO, QG, N)
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,QG,DF) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          DF(P,Q) = DBLE(QG(P,Q))
       END DO
    END DO
    !$OMP END PARALLEL DO

    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,QG,QS_G) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, Q-1
          QG(P,Q) = D_ZERO
       END DO
       QG(Q,Q) = QS_G(Q)
       DO P = Q+1, N
          QG(P,Q) = D_ZERO
       END DO
    END DO
    !$OMP END PARALLEL DO

    CALL QLAROR('L', 'N', N, N, QG, N, ISEED, QWORK, INFO)
    IF (INFO .NE. 0) RETURN

    CALL QGEMM('N', 'N', N, N, N, D_ONE, QG, N, QX, N, D_ZERO, QF, N)
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,QF,DG) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          DG(P,Q) = DBLE(QF(P,Q))
       END DO
    END DO
    !$OMP END PARALLEL DO
  END SUBROUTINE DGENDAT

  SUBROUTINE ZGENDAT(N, ISEED, QS_F, QS_G, QL_X, XF, ZF, XG, ZG, XX, ZX, XWORK, INFO)
    IMPLICIT NONE

    INTEGER, INTENT(IN) :: N, ISEED(4)
    REAL(KIND=WP), INTENT(IN) :: QS_F(N), QS_G(N), QL_X(N)
    DOUBLE COMPLEX, INTENT(OUT) :: ZF(N,N), ZG(N,N), ZX(N,N)
    COMPLEX(KIND=WP), INTENT(OUT) :: XF(N,N), XG(N,N), XX(N,N), XWORK(3*N)
    INTEGER, INTENT(OUT) :: INFO

    INTEGER :: P, Q
    EXTERNAL :: XGEMM, XLAGHE, XLAROR

    INFO = 0

    IF (N .LT. 0) THEN
       INFO = -1
       RETURN
    END IF
    CALL SEEDOK(ISEED, INFO)
    IF (INFO .NE. 0) THEN
       INFO = -2
       RETURN
    END IF

    CALL XLAGHE(N, N-1, QL_X, XX, N, ISEED, XWORK, INFO)
    IF (INFO .NE. 0) RETURN
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,XX,ZX) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          ZX(P,Q) = DCMPLX(DBLE(REAL(XX(P,Q))), DBLE(AIMAG(XX(P,Q))))
       END DO
    END DO
    !$OMP END PARALLEL DO

    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,XF,QS_F) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, Q-1
          XF(P,Q) = Z_ZERO
       END DO
       XF(Q,Q) = QS_F(Q)
       DO P = Q+1, N
          XF(P,Q) = Z_ZERO
       END DO
    END DO
    !$OMP END PARALLEL DO

    CALL XLAROR('L', 'N', N, N, XF, N, ISEED, XWORK, INFO)
    IF (INFO .NE. 0) RETURN

    CALL XGEMM('N', 'N', N, N, N, Z_ONE, XF, N, XX, N, Z_ZERO, XG, N)
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,XG,ZF) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          ZF(P,Q) = DCMPLX(DBLE(REAL(XG(P,Q))), DBLE(AIMAG(XG(P,Q))))
       END DO
    END DO
    !$OMP END PARALLEL DO

    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,XG,QS_G) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, Q-1
          XG(P,Q) = Z_ZERO
       END DO
       XG(Q,Q) = QS_G(Q)
       DO P = Q+1, N
          XG(P,Q) = Z_ZERO
       END DO
    END DO
    !$OMP END PARALLEL DO

    CALL XLAROR('L', 'N', N, N, XG, N, ISEED, XWORK, INFO)
    IF (INFO .NE. 0) RETURN

    CALL XGEMM('N', 'N', N, N, N, Z_ONE, XG, N, XX, N, Z_ZERO, XF, N)
    !$OMP PARALLEL DO DEFAULT(NONE) SHARED(N,XF,ZG) PRIVATE(P,Q)
    DO Q = 1, N
       DO P = 1, N
          ZG(P,Q) = DCMPLX(DBLE(REAL(XF(P,Q))), DBLE(AIMAG(XF(P,Q))))
       END DO
    END DO
    !$OMP END PARALLEL DO
  END SUBROUTINE ZGENDAT

END MODULE DATGEN

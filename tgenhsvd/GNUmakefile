ifndef COMPILER
COMPILER=gnu
endif # !COMPILER
include ../$(COMPILER).mk
MKFS=GNUmakefile ../$(COMPILER).mk

.PHONY: all help clean

all: dgenhsvd.exe zgenhsvd.exe derrhsvd.exe zerrhsvd.exe svalserr.exe gentxt.exe

help:
	@echo "gmake [COMPILER=gnu|x64|x64x|x200] [NDEBUG=0|1|2|3|4|5] [ABI=ilp64|lp64] [all|clean|help]"

dgenhsvd.exe: dgenhsvd.F90 bio.mod seed.mod lamgen.mod indeff.mod datgen.mod $(MKFS)
	$(FC) $(FFLAGS) dgenhsvd.F90 bio.o seed.o lamgen.o indeff.o datgen.o -o$@ -L.. -lqxblas$(WP)$(ABI)$(DEBUG) $(LDFLAGS)

zgenhsvd.exe: zgenhsvd.F90 bio.mod seed.mod lamgen.mod indeff.mod datgen.mod $(MKFS)
	$(FC) $(FFLAGS) zgenhsvd.F90 bio.o seed.o lamgen.o indeff.o datgen.o -o$@ -L.. -lqxblas$(WP)$(ABI)$(DEBUG) $(LDFLAGS)

derrhsvd.exe: derrhsvd.F90 binio.mod $(MKFS)
	$(FC) $(FFLAGS) derrhsvd.F90 binio.o -o$@ $(LDFLAGS)

zerrhsvd.exe: zerrhsvd.F90 binio.mod $(MKFS)
	$(FC) $(FFLAGS) zerrhsvd.F90 binio.o -o$@ $(LDFLAGS)

svalserr.exe: svalserr.F90 bio.mod $(MKFS)
	$(FC) $(FFLAGS) svalserr.F90 bio.o -o$@ $(LDFLAGS)

gentxt.exe: gentxt.F90 $(MKFS)
	$(FC) $(FFLAGS) gentxt.F90 -o$@ $(LDFLAGS)

bio.o bio.mod: bio.F90 $(MKFS)
	$(FC) $(FFLAGS) -c bio.F90

seed.o seed.mod: seed.F90 $(MKFS)
	$(FC) $(FFLAGS) -c seed.F90

lamgen.o lamgen.mod: lamgen.F90 seed.mod $(MKFS)
	$(FC) $(FFLAGS) -c lamgen.F90

indeff.o indeff.mod: indeff.F90 $(MKFS)
	$(FC) $(FFLAGS) -c indeff.F90

datgen.o datgen.mod: datgen.F90 seed.mod indeff.mod $(MKFS)
	$(FC) $(FFLAGS) -c datgen.F90

binio.o binio.mod: binio.F90 ../vn/vn_binio_f.mod $(MKFS)
	$(FC) $(FFLAGS) -c binio.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.optrpt
	-$(RM) *.opt.yaml
	-$(RM) *__genmod.*
	-$(RM) *.dSYM

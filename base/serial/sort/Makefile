include ../../../Make.inc

#
# The object files
#
BOBJS=psi_lcx_mod.o psi_alcx_mod.o psi_acx_mod.o
IOBJS=psb_m_hsort_impl.o psb_m_isort_impl.o psb_m_msort_impl.o psb_m_qsort_impl.o
LOBJS=psb_e_hsort_impl.o psb_e_isort_impl.o psb_e_msort_impl.o psb_e_qsort_impl.o
SOBJS=psb_s_hsort_impl.o psb_s_isort_impl.o psb_s_msort_impl.o psb_s_qsort_impl.o
DOBJS=psb_d_hsort_impl.o psb_d_isort_impl.o psb_d_msort_impl.o psb_d_qsort_impl.o
COBJS=psb_c_hsort_impl.o psb_c_isort_impl.o psb_c_msort_impl.o psb_c_qsort_impl.o
ZOBJS=psb_z_hsort_impl.o psb_z_isort_impl.o psb_z_msort_impl.o psb_z_qsort_impl.o

OBJS=$(BOBJS) $(SOBJS)  $(DOBJS)  $(COBJS)  $(ZOBJS)  $(IOBJS) $(LOBJS) 

#
# Where the library should go, and how it is called. 
# Note that we are regenerating most of libsparker.a on the fly. 
LIBDIR=../..
INCDIR=../..
MODDIR=../../modules
FINCLUDES=$(FMFLAG). $(FMFLAG)$(MODDIR) $(FMFLAG)$(INCDIR) 
LIBFILE=$(LIBDIR)/$(LIBNAME)

#
# No change should be needed below 
#


default: lib

lib: $(OBJS)
	$(AR) $(LIBDIR)/$(LIBNAME) $(OBJS)
	$(RANLIB) $(LIBDIR)/$(LIBNAME)

# A bit excessive, but safe
$(OBJS): $(MODDIR)/psb_base_mod.o
$(IOBJS) $(LOBJS) $(SOBJS)  $(DOBJS)  $(COBJS)  $(ZOBJS): $(BOBJS) 
clean: cleanobjs

veryclean: cleanobjs

cleanobjs:
	/bin/rm -f $(OBJS) *$(.mod)


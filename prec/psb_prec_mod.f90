!!$ 
!!$              Parallel Sparse BLAS  version 2.2
!!$    (C) Copyright 2006/2007/2008
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the PSBLAS group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$  

module psb_prec_mod
  use psb_prec_type

  interface psb_precbld
    subroutine psb_sprecbld(a,desc_a,prec,info,upd)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_sspmat_type), intent(in), target  :: a
      type(psb_desc_type), intent(in), target    :: desc_a
      type(psb_sprec_type), intent(inout)        :: prec
      integer, intent(out)                       :: info
      character, intent(in),optional             :: upd
    end subroutine psb_sprecbld
    subroutine psb_dprecbld(a,desc_a,prec,info,upd)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_dspmat_type), intent(in), target  :: a
      type(psb_desc_type), intent(in), target    :: desc_a
      type(psb_dprec_type), intent(inout)        :: prec
      integer, intent(out)                       :: info
      character, intent(in),optional             :: upd
    end subroutine psb_dprecbld
    subroutine psb_cprecbld(a,desc_a,prec,info,upd)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_cspmat_type), intent(in), target  :: a
      type(psb_desc_type), intent(in), target    :: desc_a
      type(psb_cprec_type), intent(inout)        :: prec
      integer, intent(out)                       :: info
      character, intent(in),optional             :: upd
    end subroutine psb_cprecbld
    subroutine psb_zprecbld(a,desc_a,prec,info,upd)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_zspmat_type), intent(in), target  :: a
      type(psb_desc_type), intent(in), target    :: desc_a
      type(psb_zprec_type), intent(inout)        :: prec
      integer, intent(out)                       :: info
      character, intent(in),optional             :: upd
    end subroutine psb_zprecbld
  end interface

  interface psb_precinit
    subroutine psb_sprecinit(prec,ptype,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_sprec_type), intent(inout)    :: prec
      character(len=*), intent(in)           :: ptype
      integer, intent(out)                   :: info
    end subroutine psb_sprecinit
    subroutine psb_dprecinit(prec,ptype,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_dprec_type), intent(inout)    :: prec
      character(len=*), intent(in)           :: ptype
      integer, intent(out)                   :: info
    end subroutine psb_dprecinit
    subroutine psb_cprecinit(prec,ptype,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_cprec_type), intent(inout)    :: prec
      character(len=*), intent(in)           :: ptype
      integer, intent(out)                   :: info
    end subroutine psb_cprecinit
    subroutine psb_zprecinit(prec,ptype,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_zprec_type), intent(inout)    :: prec
      character(len=*), intent(in)           :: ptype
      integer, intent(out)                   :: info
    end subroutine psb_zprecinit
  end interface

  interface psb_precset
    subroutine psb_sprecseti(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_sprec_type), intent(inout)    :: prec
      integer                                :: what, val 
      integer, intent(out)                   :: info
    end subroutine psb_sprecseti
    subroutine psb_sprecsets(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_sprec_type), intent(inout)    :: prec
      integer                                :: what
      real(psb_spk_)                       :: val 
      integer, intent(out)                   :: info
    end subroutine psb_sprecsets
    subroutine psb_dprecseti(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_dprec_type), intent(inout)    :: prec
      integer                                :: what, val 
      integer, intent(out)                   :: info
    end subroutine psb_dprecseti
    subroutine psb_dprecsetd(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_dprec_type), intent(inout)    :: prec
      integer                                :: what
      real(psb_dpk_)                       :: val 
      integer, intent(out)                   :: info
    end subroutine psb_dprecsetd
    subroutine psb_cprecseti(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_cprec_type), intent(inout)    :: prec
      integer                                :: what, val 
      integer, intent(out)                   :: info
    end subroutine psb_cprecseti
    subroutine psb_cprecsets(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_cprec_type), intent(inout)    :: prec
      integer                                :: what
      real(psb_spk_)                       :: val 
      integer, intent(out)                   :: info
    end subroutine psb_cprecsets
    subroutine psb_zprecseti(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_zprec_type), intent(inout)    :: prec
      integer                                :: what, val 
      integer, intent(out)                   :: info
    end subroutine psb_zprecseti
    subroutine psb_zprecsetd(prec,what,val,info)
      use psb_base_mod
      use psb_prec_type
      implicit none
      type(psb_zprec_type), intent(inout)    :: prec
      integer                                :: what
      real(psb_dpk_)                       :: val 
      integer, intent(out)                   :: info
    end subroutine psb_zprecsetd
  end interface


  interface psb_precaply
    subroutine psb_sprc_aply(prec,x,y,desc_data,info,trans,work)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_sprec_type), intent(in)  :: prec
      real(psb_spk_),intent(in)       :: x(:)
      real(psb_spk_),intent(inout)    :: y(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
      real(psb_spk_),intent(inout), optional, target :: work(:)
    end subroutine psb_sprc_aply
    subroutine psb_sprc_aply1(prec,x,desc_data,info,trans)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_sprec_type), intent(in)  :: prec
      real(psb_spk_),intent(inout)    :: x(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
    end subroutine psb_sprc_aply1
    subroutine psb_dprc_aply(prec,x,y,desc_data,info,trans,work)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_dprec_type), intent(in)  :: prec
      real(psb_dpk_),intent(in)       :: x(:)
      real(psb_dpk_),intent(inout)    :: y(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
      real(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_dprc_aply
    subroutine psb_dprc_aply1(prec,x,desc_data,info,trans)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_dprec_type), intent(in)  :: prec
      real(psb_dpk_),intent(inout)    :: x(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
    end subroutine psb_dprc_aply1
    subroutine psb_cprc_aply(prec,x,y,desc_data,info,trans,work)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_cprec_type), intent(in)  :: prec
      complex(psb_spk_),intent(in)    :: x(:)
      complex(psb_spk_),intent(inout) :: y(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
      complex(psb_spk_),intent(inout), optional, target :: work(:)
    end subroutine psb_cprc_aply
    subroutine psb_cprc_aply1(prec,x,desc_data,info,trans)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_cprec_type), intent(in)  :: prec
      complex(psb_spk_),intent(inout) :: x(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
    end subroutine psb_cprc_aply1
    subroutine psb_zprc_aply(prec,x,y,desc_data,info,trans,work)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_zprec_type), intent(in)  :: prec
      complex(psb_dpk_),intent(in)    :: x(:)
      complex(psb_dpk_),intent(inout) :: y(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
      complex(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_zprc_aply
    subroutine psb_zprc_aply1(prec,x,desc_data,info,trans)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)    :: desc_data
      type(psb_zprec_type), intent(in)  :: prec
      complex(psb_dpk_),intent(inout) :: x(:)
      integer, intent(out)              :: info
      character(len=1), optional        :: trans
    end subroutine psb_zprc_aply1
  end interface


  interface psb_bjac_aply
    subroutine psb_sbjac_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type), intent(in)   :: desc_data
      type(psb_sprec_type), intent(in)  :: prec
      real(psb_spk_),intent(in)       :: x(:)
      real(psb_spk_),intent(inout)    :: y(:)
      real(psb_spk_),intent(in)       :: alpha,beta
      character(len=1)                  :: trans
      real(psb_spk_),target           :: work(:)
      integer, intent(out)              :: info
    end subroutine psb_sbjac_aply
    subroutine psb_dbjac_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type), intent(in)   :: desc_data
      type(psb_dprec_type), intent(in)  :: prec
      real(psb_dpk_),intent(in)       :: x(:)
      real(psb_dpk_),intent(inout)    :: y(:)
      real(psb_dpk_),intent(in)       :: alpha,beta
      character(len=1)                  :: trans
      real(psb_dpk_),target           :: work(:)
      integer, intent(out)              :: info
    end subroutine psb_dbjac_aply
    subroutine psb_cbjac_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type), intent(in)    :: desc_data
      type(psb_cprec_type), intent(in)   :: prec
      complex(psb_spk_),intent(in)     :: x(:)
      complex(psb_spk_),intent(inout)  :: y(:)
      complex(psb_spk_),intent(in)     :: alpha,beta
      character(len=1)                   :: trans
      complex(psb_spk_),target         :: work(:)
      integer, intent(out)               :: info
    end subroutine psb_cbjac_aply
    subroutine psb_zbjac_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type), intent(in)    :: desc_data
      type(psb_zprec_type), intent(in)   :: prec
      complex(psb_dpk_),intent(in)     :: x(:)
      complex(psb_dpk_),intent(inout)  :: y(:)
      complex(psb_dpk_),intent(in)     :: alpha,beta
      character(len=1)                   :: trans
      complex(psb_dpk_),target         :: work(:)
      integer, intent(out)               :: info
    end subroutine psb_zbjac_aply
  end interface

  interface psb_ilu_fct
    subroutine psb_silu_fct(a,l,u,d,info,blck)
      use psb_base_mod
      integer, intent(out)                ::     info
      type(psb_sspmat_type),intent(in)    :: a
      type(psb_sspmat_type),intent(inout) :: l,u
      type(psb_sspmat_type),intent(in), optional, target :: blck
      real(psb_spk_), intent(inout)     ::  d(:)
    end subroutine psb_silu_fct
    subroutine psb_dilu_fct(a,l,u,d,info,blck)
      use psb_base_mod
      integer, intent(out)                ::     info
      type(psb_dspmat_type),intent(in)    :: a
      type(psb_dspmat_type),intent(inout) :: l,u
      type(psb_dspmat_type),intent(in), optional, target :: blck
      real(psb_dpk_), intent(inout)     ::  d(:)
    end subroutine psb_dilu_fct
    subroutine psb_cilu_fct(a,l,u,d,info,blck)
      use psb_base_mod
      integer, intent(out)                ::     info
      type(psb_cspmat_type),intent(in)    :: a
      type(psb_cspmat_type),intent(inout) :: l,u
      type(psb_cspmat_type),intent(in), optional, target :: blck
      complex(psb_spk_), intent(inout)     ::  d(:)
    end subroutine psb_cilu_fct
    subroutine psb_zilu_fct(a,l,u,d,info,blck)
      use psb_base_mod
      integer, intent(out)                ::     info
      type(psb_zspmat_type),intent(in)    :: a
      type(psb_zspmat_type),intent(inout) :: l,u
      type(psb_zspmat_type),intent(in), optional, target :: blck
      complex(psb_dpk_), intent(inout)     ::  d(:)
    end subroutine psb_zilu_fct
  end interface

  interface psb_bjac_bld
    subroutine psb_sbjac_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_sspmat_type), intent(in), target :: a
      type(psb_sprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_sbjac_bld
    subroutine psb_dbjac_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_dspmat_type), intent(in), target :: a
      type(psb_dprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_dbjac_bld
    subroutine psb_cbjac_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_cspmat_type), intent(in), target :: a
      type(psb_cprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_cbjac_bld
    subroutine psb_zbjac_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_zspmat_type), intent(in), target :: a
      type(psb_zprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_zbjac_bld
  end interface

  interface psb_diagsc_bld
    subroutine psb_sdiagsc_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_sspmat_type), intent(in), target :: a
      type(psb_sprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_sdiagsc_bld
    subroutine psb_ddiagsc_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_dspmat_type), intent(in), target :: a
      type(psb_dprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_ddiagsc_bld
    subroutine psb_cdiagsc_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_cspmat_type), intent(in), target :: a
      type(psb_cprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_cdiagsc_bld
    subroutine psb_zdiagsc_bld(a,desc_a,p,upd,info)
      use psb_base_mod
      use psb_prec_type
      integer, intent(out)                      :: info
      type(psb_zspmat_type), intent(in), target :: a
      type(psb_zprec_type), intent(inout)    :: p
      type(psb_desc_type), intent(in)           :: desc_a
      character, intent(in)                     :: upd
    end subroutine psb_zdiagsc_bld
  end interface

  interface psb_gprec_aply
    subroutine psb_sgprec_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)   :: desc_data
      type(psb_sprec_type), intent(in) :: prec
      real(psb_spk_),intent(in)      :: x(:)
      real(psb_spk_),intent(inout)   :: y(:)
      real(psb_spk_),intent(in)      :: alpha,beta
      character(len=1)                 :: trans
      real(psb_spk_),target          :: work(:)
      integer, intent(out)             :: info
    end subroutine psb_sgprec_aply
    subroutine psb_dgprec_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)   :: desc_data
      type(psb_dprec_type), intent(in) :: prec
      real(psb_dpk_),intent(in)      :: x(:)
      real(psb_dpk_),intent(inout)   :: y(:)
      real(psb_dpk_),intent(in)      :: alpha,beta
      character(len=1)                 :: trans
      real(psb_dpk_),target          :: work(:)
      integer, intent(out)             :: info
    end subroutine psb_dgprec_aply
    subroutine psb_cgprec_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)     :: desc_data
      type(psb_cprec_type), intent(in)   :: prec
      complex(psb_spk_),intent(in)     :: x(:)
      complex(psb_spk_),intent(inout)  :: y(:)
      complex(psb_spk_),intent(in)     :: alpha,beta
      character(len=1)                   :: trans
      complex(psb_spk_),target         :: work(:)
      integer, intent(out)               :: info
    end subroutine psb_cgprec_aply
    subroutine psb_zgprec_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_base_mod
      use psb_prec_type
      type(psb_desc_type),intent(in)     :: desc_data
      type(psb_zprec_type), intent(in)   :: prec
      complex(psb_dpk_),intent(in)     :: x(:)
      complex(psb_dpk_),intent(inout)  :: y(:)
      complex(psb_dpk_),intent(in)     :: alpha,beta
      character(len=1)                   :: trans
      complex(psb_dpk_),target         :: work(:)
      integer, intent(out)               :: info
    end subroutine psb_zgprec_aply
  end interface

end module psb_prec_mod

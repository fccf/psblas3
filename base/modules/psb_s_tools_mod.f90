!!$ 
!!$              Parallel Sparse BLAS  version 3.0
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        CNRS-IRIT, Toulouse
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
Module psb_s_tools_mod


  interface  psb_geall
    subroutine psb_salloc(x, desc_a, info, n, lb)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      implicit none
      real(psb_spk_), allocatable, intent(out) :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_salloc
    subroutine psb_sallocv(x, desc_a,info,n)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      real(psb_spk_), allocatable, intent(out)       :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_sallocv
    subroutine psb_salloc_vect(x, desc_a,info,n)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_s_vect_type), intent(out)  :: x
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_salloc_vect
    subroutine psb_salloc_vect_r2(x, desc_a,info,n,lb)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_s_vect_type), allocatable, intent(out)  :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_salloc_vect_r2
  end interface


  interface psb_geasb
    subroutine psb_sasb(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_spk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_sasb
    subroutine psb_sasbv(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_spk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_sasbv
    subroutine psb_sasb_vect(x, desc_a, info,mold, scratch)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_desc_type), intent(in)      ::  desc_a
      type(psb_s_vect_type), intent(inout) :: x
      integer, intent(out)                 ::  info
      class(psb_s_base_vect_type), intent(in), optional :: mold
      logical, intent(in), optional        :: scratch
    end subroutine psb_sasb_vect
    subroutine psb_sasb_vect_r2(x, desc_a, info,mold, scratch)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_desc_type), intent(in)      ::  desc_a
      type(psb_s_vect_type), intent(inout) :: x(:)
      integer, intent(out)                 ::  info
      class(psb_s_base_vect_type), intent(in), optional :: mold
      logical, intent(in), optional        :: scratch
    end subroutine psb_sasb_vect_r2
  end interface

  interface psb_sphalo
    Subroutine psb_ssphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      Type(psb_sspmat_type),Intent(in)    :: a
      Type(psb_sspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in),target :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_ssphalo
  end interface


  interface psb_gefree
    subroutine psb_sfree(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      real(psb_spk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)            :: info
    end subroutine psb_sfree
    subroutine psb_sfreev(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      real(psb_spk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)       :: info
    end subroutine psb_sfreev
    subroutine psb_sfree_vect(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_desc_type), intent(in)  ::  desc_a
      type(psb_s_vect_type), intent(inout) :: x
      integer, intent(out)             ::  info
    end subroutine psb_sfree_vect
    subroutine psb_sfree_vect_r2(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      type(psb_desc_type), intent(in)  ::  desc_a
      type(psb_s_vect_type), allocatable, intent(inout) :: x(:)
      integer, intent(out)             ::  info
    end subroutine psb_sfree_vect_r2
  end interface


  interface psb_geins
    subroutine psb_sinsi(m,irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_spk_),intent(inout)           ::  x(:,:)
      integer, intent(in)                ::  irw(:)
      real(psb_spk_), intent(in)       ::  val(:,:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_sinsi
    subroutine psb_sinsvi(m,irw,val,x,desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_spk_),intent(inout)     ::  x(:)
      integer, intent(in)                ::  irw(:)
      real(psb_spk_), intent(in)       ::  val(:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_sinsvi
    subroutine psb_sins_vect(m,irw,val,x,desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      integer, intent(in)              :: m
      type(psb_desc_type), intent(in)  :: desc_a
      type(psb_s_vect_type), intent(inout) :: x
      integer, intent(in)              :: irw(:)
      real(psb_spk_), intent(in)       :: val(:)
      integer, intent(out)             :: info
      integer, optional, intent(in)    :: dupl
    end subroutine psb_sins_vect
    subroutine psb_sins_vect_r2(m,irw,val,x,desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_s_vect_mod
      integer, intent(in)              :: m
      type(psb_desc_type), intent(in)  :: desc_a
      type(psb_s_vect_type), intent(inout) :: x(:)
      integer, intent(in)              :: irw(:)
      real(psb_spk_), intent(in)       :: val(:,:)
      integer, intent(out)             :: info
      integer, optional, intent(in)    :: dupl
    end subroutine psb_sins_vect_r2
  end interface

  interface psb_cdbldext
    Subroutine psb_scdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      Use psb_mat_mod, only : psb_sspmat_type
      integer, intent(in)                     :: novr
      Type(psb_sspmat_type), Intent(in)      :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_scdbldext
  end interface

  interface psb_spall
    subroutine psb_sspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      type(psb_desc_type), intent(in)  :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(out)                :: info
      integer, optional, intent(in)       :: nnz
    end subroutine psb_sspalloc
  end interface

  interface psb_spasb
    subroutine psb_sspasb(a,desc_a, info, afmt, upd, dupl, mold)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_s_base_sparse_mat, psb_sspmat_type
      type(psb_sspmat_type), intent (inout)  :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
      class(psb_s_base_sparse_mat), intent(in), optional :: mold
    end subroutine psb_sspasb
  end interface

  interface psb_spfree
    subroutine psb_sspfree(a, desc_a,info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      type(psb_desc_type), intent(in)       :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(out)                  :: info
    end subroutine psb_sspfree
  end interface


  interface psb_spins
    subroutine psb_sspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      type(psb_desc_type), intent(inout)    :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(in)                   :: nz,ia(:),ja(:)
      real(psb_spk_), intent(in)            :: val(:)
      integer, intent(out)                  :: info
      logical, intent(in), optional         :: rebuild
    end subroutine psb_sspins
    subroutine psb_sspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      type(psb_desc_type), intent(in)       :: desc_ar
      type(psb_desc_type), intent(inout)    :: desc_ac
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(in)                   :: nz,ia(:),ja(:)
      real(psb_spk_), intent(in)            :: val(:)
      integer, intent(out)                  :: info
    end subroutine psb_sspins_2desc
  end interface


  interface psb_sprn
    subroutine psb_ssprn(a, desc_a,info,clear)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_sspmat_type
      type(psb_desc_type), intent(in)       :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(out)                  :: info
      logical, intent(in), optional         :: clear
    end subroutine psb_ssprn 
  end interface


end module psb_s_tools_mod

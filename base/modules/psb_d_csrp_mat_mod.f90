!!$ 
!!$              Parallel Sparse BLAS  version 3.4
!!$    (C) Copyright 2006, 2010, 2015
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
!
! package: psb_d_csr_mat_mod
!
! This module contains the definition of the psb_d_csr_sparse_mat type
! which implements an actual storage format (the CSR in this case) for
! a sparse matrix as well as the related methods (those who are
! specific to the type and could not be defined higher in the
! hierarchy). We are at the bottom level of the inheritance chain.
!
! Please refere to psb_d_base_mat_mod for a detailed description
! of the various methods, and to psb_d_csr_impl for implementation details.
!
module psb_d_csrp_mat_mod

  use psb_d_csr_mat_mod

  !> \namespace  psb_base_mod  \class  psb_d_csr_sparse_mat
  !! \extends psb_d_base_mat_mod::psb_d_base_sparse_mat
  !! 
  !! psb_d_csr_sparse_mat type and the related methods.
  !! This is a very common storage type, and is the default for assembled
  !! matrices in our library
  type, extends(psb_d_csr_sparse_mat) :: psb_d_csrp_sparse_mat

  contains
    procedure, pass(a) :: is_by_rows  => d_csrp_is_by_rows
    procedure, pass(a) :: get_size    => d_csrp_get_size
    procedure, pass(a) :: get_nzeros  => d_csrp_get_nzeros
    procedure, nopass  :: get_fmt     => d_csrp_get_fmt
    procedure, pass(a) :: sizeof      => d_csrp_sizeof
    procedure, pass(a) :: csmm        => psb_d_csrp_csmm
    procedure, pass(a) :: csmv        => psb_d_csrp_csmv
    procedure, pass(a) :: inner_cssm  => psb_d_csrp_cssm
    procedure, pass(a) :: inner_cssv  => psb_d_csrp_cssv
    procedure, pass(a) :: scals       => psb_d_csrp_scals
    procedure, pass(a) :: scalv       => psb_d_csrp_scal
    procedure, pass(a) :: maxval      => psb_d_csrp_maxval
    procedure, pass(a) :: spnmi       => psb_d_csrp_csnmi
    procedure, pass(a) :: rowsum      => psb_d_csrp_rowsum
    procedure, pass(a) :: arwsum      => psb_d_csrp_arwsum
    procedure, pass(a) :: colsum      => psb_d_csrp_colsum
    procedure, pass(a) :: aclsum      => psb_d_csrp_aclsum
    procedure, pass(a) :: reallocate_nz => psb_d_csrp_reallocate_nz
    procedure, pass(a) :: allocate_mnnz => psb_d_csrp_allocate_mnnz
    procedure, pass(a) :: cp_to_coo   => psb_d_cp_csrp_to_coo
    procedure, pass(a) :: cp_from_coo => psb_d_cp_csrp_from_coo
    procedure, pass(a) :: cp_to_fmt   => psb_d_cp_csrp_to_fmt
    procedure, pass(a) :: cp_from_fmt => psb_d_cp_csrp_from_fmt
    procedure, pass(a) :: mv_to_coo   => psb_d_mv_csrp_to_coo
    procedure, pass(a) :: mv_from_coo => psb_d_mv_csrp_from_coo
    procedure, pass(a) :: mv_to_fmt   => psb_d_mv_csrp_to_fmt
    procedure, pass(a) :: mv_from_fmt => psb_d_mv_csrp_from_fmt
    procedure, pass(a) :: csput_a     => psb_d_csrp_csput_a
    procedure, pass(a) :: get_diag    => psb_d_csrp_get_diag
    procedure, pass(a) :: csgetptn    => psb_d_csrp_csgetptn
    procedure, pass(a) :: csgetrow   => psb_d_csrp_csgetrow
    procedure, pass(a) :: get_nz_row  => d_csrp_get_nz_row
    procedure, pass(a) :: reinit      => psb_d_csrp_reinit
    procedure, pass(a) :: trim        => psb_d_csrp_trim
    procedure, pass(a) :: print       => psb_d_csrp_print
    procedure, pass(a) :: free        => d_csrp_free
    procedure, pass(a) :: mold        => psb_d_csrp_mold

  end type psb_d_csrp_sparse_mat

  private :: d_csrp_get_nzeros, d_csrp_free,  d_csrp_get_fmt, &
       & d_csrp_get_size, d_csrp_sizeof, d_csrp_get_nz_row, &
       & d_csrp_is_by_rows

  !> \memberof psb_d_csrp_sparse_mat
  !| \see psb_base_mat_mod::psb_base_reallocate_nz
  interface
    subroutine  psb_d_csrp_reallocate_nz(nz,a) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat
      integer(psb_ipk_), intent(in) :: nz
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
    end subroutine psb_d_csrp_reallocate_nz
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !| \see psb_base_mat_mod::psb_base_reinit
  interface 
    subroutine psb_d_csrp_reinit(a,clear)
      import :: psb_ipk_, psb_d_csrp_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a   
      logical, intent(in), optional :: clear
    end subroutine psb_d_csrp_reinit
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !| \see psb_base_mat_mod::psb_base_trim
  interface
    subroutine  psb_d_csrp_trim(a)
      import :: psb_ipk_, psb_d_csrp_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
    end subroutine psb_d_csrp_trim
  end interface

  
  !> \memberof psb_d_csrp_sparse_mat
  !| \see psb_base_mat_mod::psb_base_mold
  interface 
    subroutine psb_d_csrp_mold(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_base_sparse_mat, psb_long_int_k_
      class(psb_d_csrp_sparse_mat), intent(in)                  :: a
      class(psb_d_base_sparse_mat), intent(inout), allocatable :: b
      integer(psb_ipk_), intent(out)                           :: info
    end subroutine psb_d_csrp_mold
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !| \see psb_base_mat_mod::psb_base_allocate_mnnz
  interface
    subroutine  psb_d_csrp_allocate_mnnz(m,n,a,nz) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat
      integer(psb_ipk_), intent(in) :: m,n
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      integer(psb_ipk_), intent(in), optional :: nz
    end subroutine psb_d_csrp_allocate_mnnz
  end interface

  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_print
  interface
    subroutine psb_d_csrp_print(iout,a,iv,head,ivr,ivc)
      import :: psb_ipk_, psb_d_csrp_sparse_mat
      integer(psb_ipk_), intent(in)               :: iout
      class(psb_d_csrp_sparse_mat), intent(in) :: a   
      integer(psb_ipk_), intent(in), optional     :: iv(:)
      character(len=*), optional        :: head
      integer(psb_ipk_), intent(in), optional     :: ivr(:), ivc(:)
    end subroutine psb_d_csrp_print
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cp_to_coo
  interface 
    subroutine psb_d_cp_csrp_to_coo(a,b,info) 
      import :: psb_ipk_, psb_d_coo_sparse_mat, psb_d_csrp_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      class(psb_d_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_d_cp_csrp_to_coo
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cp_from_coo
  interface 
    subroutine psb_d_cp_csrp_from_coo(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_coo_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      class(psb_d_coo_sparse_mat), intent(in)    :: b
      integer(psb_ipk_), intent(out)               :: info
    end subroutine psb_d_cp_csrp_from_coo
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cp_to_fmt
  interface 
    subroutine psb_d_cp_csrp_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_base_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(in)   :: a
      class(psb_d_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                       :: info
    end subroutine psb_d_cp_csrp_to_fmt
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cp_from_fmt
  interface 
    subroutine psb_d_cp_csrp_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_base_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      class(psb_d_base_sparse_mat), intent(in)   :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_d_cp_csrp_from_fmt
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_mv_to_coo
  interface 
    subroutine psb_d_mv_csrp_to_coo(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_coo_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      class(psb_d_coo_sparse_mat), intent(inout)   :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_d_mv_csrp_to_coo
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_mv_from_coo
  interface 
    subroutine psb_d_mv_csrp_from_coo(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_coo_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      class(psb_d_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_d_mv_csrp_from_coo
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_mv_to_fmt
  interface 
    subroutine psb_d_mv_csrp_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_base_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      class(psb_d_base_sparse_mat), intent(inout)  :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_d_mv_csrp_to_fmt
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_mv_from_fmt
  interface 
    subroutine psb_d_mv_csrp_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_d_base_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(inout)  :: a
      class(psb_d_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                         :: info
    end subroutine psb_d_mv_csrp_from_fmt
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cp_from
  interface 
    subroutine psb_d_csrp_cp_from(a,b)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      type(psb_d_csrp_sparse_mat), intent(in)   :: b
    end subroutine psb_d_csrp_cp_from
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_mv_from
  interface 
    subroutine psb_d_csrp_mv_from(a,b)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(inout)  :: a
      type(psb_d_csrp_sparse_mat), intent(inout) :: b
    end subroutine psb_d_csrp_mv_from
  end interface
  
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csput_a
  interface 
    subroutine psb_d_csrp_csput_a(nz,ia,ja,val,a,imin,imax,jmin,jmax,info,gtl) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      real(psb_dpk_), intent(in)      :: val(:)
      integer(psb_ipk_), intent(in)             :: nz,ia(:), ja(:),&
           &  imin,imax,jmin,jmax
      integer(psb_ipk_), intent(out)            :: info
      integer(psb_ipk_), intent(in), optional   :: gtl(:)
    end subroutine psb_d_csrp_csput_a
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_base_mat_mod::psb_base_csgetptn
  interface 
    subroutine psb_d_csrp_csgetptn(imin,imax,a,nz,ia,ja,info,&
         & jmin,jmax,iren,append,nzin,rscale,cscale)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_), intent(out)                 :: nz
      integer(psb_ipk_), allocatable, intent(inout)  :: ia(:), ja(:)
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax, nzin
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_d_csrp_csgetptn
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csgetrow
  interface 
    subroutine psb_d_csrp_csgetrow(imin,imax,a,nz,ia,ja,val,info,&
         & jmin,jmax,iren,append,nzin,rscale,cscale)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_), intent(out)                 :: nz
      integer(psb_ipk_), allocatable, intent(inout)  :: ia(:), ja(:)
      real(psb_dpk_), allocatable,  intent(inout)    :: val(:)
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax, nzin
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_d_csrp_csgetrow
  end interface

  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csgetblk
  interface 
    subroutine psb_d_csrp_csgetblk(imin,imax,a,b,info,&
       & jmin,jmax,iren,append,rscale,cscale)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_, psb_d_coo_sparse_mat
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      class(psb_d_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_d_csrp_csgetblk
  end interface
    
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cssv
  interface 
    subroutine psb_d_csrp_cssv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(in)          :: alpha, beta, x(:)
      real(psb_dpk_), intent(inout)       :: y(:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_d_csrp_cssv
  end interface
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_cssm
  interface 
    subroutine psb_d_csrp_cssm(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(in)          :: alpha, beta, x(:,:)
      real(psb_dpk_), intent(inout)       :: y(:,:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_d_csrp_cssm
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csmv
  interface 
    subroutine psb_d_csrp_csmv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(in)          :: alpha, beta, x(:)
      real(psb_dpk_), intent(inout)       :: y(:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_d_csrp_csmv
  end interface

  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csmm
  interface 
    subroutine psb_d_csrp_csmm(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(in)          :: alpha, beta, x(:,:)
      real(psb_dpk_), intent(inout)       :: y(:,:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_d_csrp_csmm
  end interface
  
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_maxval
  interface 
    function psb_d_csrp_maxval(a) result(res)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_)         :: res
    end function psb_d_csrp_maxval
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_csnmi
  interface 
    function psb_d_csrp_csnmi(a) result(res)
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_)         :: res
    end function psb_d_csrp_csnmi
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_rowsum
  interface 
    subroutine psb_d_csrp_rowsum(d,a) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(out)              :: d(:)
    end subroutine psb_d_csrp_rowsum
  end interface

  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_arwsum
  interface 
    subroutine psb_d_csrp_arwsum(d,a) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(out)              :: d(:)
    end subroutine psb_d_csrp_arwsum
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_colsum
  interface 
    subroutine psb_d_csrp_colsum(d,a) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(out)              :: d(:)
    end subroutine psb_d_csrp_colsum
  end interface

  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_aclsum
  interface 
    subroutine psb_d_csrp_aclsum(d,a) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(out)              :: d(:)
    end subroutine psb_d_csrp_aclsum
  end interface
    
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_get_diag
  interface 
    subroutine psb_d_csrp_get_diag(a,d,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(in) :: a
      real(psb_dpk_), intent(out)     :: d(:)
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_d_csrp_get_diag
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_scal
  interface 
    subroutine psb_d_csrp_scal(d,a,info,side) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      real(psb_dpk_), intent(in)      :: d(:)
      integer(psb_ipk_), intent(out)            :: info
      character, intent(in), optional :: side
    end subroutine psb_d_csrp_scal
  end interface
  
  !> \memberof psb_d_csrp_sparse_mat
  !! \see psb_d_base_mat_mod::psb_d_base_scals
  interface
    subroutine psb_d_csrp_scals(d,a,info) 
      import :: psb_ipk_, psb_d_csrp_sparse_mat, psb_dpk_
      class(psb_d_csrp_sparse_mat), intent(inout) :: a
      real(psb_dpk_), intent(in)      :: d
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_d_csrp_scals
  end interface
  


contains 

  ! == ===================================
  !
  !
  !
  ! Getters 
  !
  !
  !
  !
  !
  ! == ===================================


  
  function d_csrp_is_by_rows(a) result(res)
    implicit none 
    class(psb_d_csrp_sparse_mat), intent(in) :: a
    logical  :: res
    res = .true.
     
  end function d_csrp_is_by_rows

  
  function d_csrp_sizeof(a) result(res)
    implicit none 
    class(psb_d_csrp_sparse_mat), intent(in) :: a
    integer(psb_long_int_k_) :: res
    res = 8 
    res = res + psb_sizeof_dp  * psb_size(a%val)
    res = res + psb_sizeof_int * psb_size(a%irp)
    res = res + psb_sizeof_int * psb_size(a%ja)
      
  end function d_csrp_sizeof

  function d_csrp_get_fmt() result(res)
    implicit none 
    character(len=5) :: res
    res = 'CSRP'
  end function d_csrp_get_fmt
  
  function d_csrp_get_nzeros(a) result(res)
    implicit none 
    class(psb_d_csrp_sparse_mat), intent(in) :: a
    integer(psb_ipk_) :: res
    res = a%irp(a%get_nrows()+1)-1
  end function d_csrp_get_nzeros

  function d_csrp_get_size(a) result(res)
    implicit none 
    class(psb_d_csrp_sparse_mat), intent(in) :: a
    integer(psb_ipk_) :: res

    res = -1
    
    if (allocated(a%ja)) then 
      res = size(a%ja)
    end if
    if (allocated(a%val)) then 
      if (res >= 0) then 
        res = min(res,size(a%val))
      else 
        res = size(a%val)
      end if
    end if

  end function d_csrp_get_size



  function  d_csrp_get_nz_row(idx,a) result(res)

    implicit none
    
    class(psb_d_csrp_sparse_mat), intent(in) :: a
    integer(psb_ipk_), intent(in)                  :: idx
    integer(psb_ipk_) :: res
    
    res = 0 
 
    if ((1<=idx).and.(idx<=a%get_nrows())) then 
      res = a%irp(idx+1)-a%irp(idx)
    end if
    
  end function d_csrp_get_nz_row



  ! == ===================================
  !
  !
  !
  ! Data management
  !
  !
  !
  !
  !
  ! == ===================================  

  subroutine  d_csrp_free(a) 
    implicit none 

    class(psb_d_csrp_sparse_mat), intent(inout) :: a

    if (allocated(a%irp)) deallocate(a%irp)
    if (allocated(a%ja)) deallocate(a%ja)
    if (allocated(a%val)) deallocate(a%val)
    call a%set_null()
    call a%set_nrows(izero)
    call a%set_ncols(izero)
    
    return

  end subroutine d_csrp_free


end module psb_d_csrp_mat_mod
!!$ 
!!$              Parallel Sparse BLAS  version 3.0
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010, 2012
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
module psb_z_bjacprec

  use psb_z_base_prec_mod
  
  type, extends(psb_z_base_prec_type)   :: psb_z_bjac_prec_type
    integer(psb_ipk_), allocatable                :: iprcparm(:)
    type(psb_zspmat_type), allocatable  :: av(:)
    type(psb_z_vect_type), allocatable  :: dv
  contains
    procedure, pass(prec) :: z_apply_v => psb_z_bjac_apply_vect
    procedure, pass(prec) :: z_apply   => psb_z_bjac_apply
    procedure, pass(prec) :: precbld   => psb_z_bjac_precbld
    procedure, pass(prec) :: precinit  => psb_z_bjac_precinit
    procedure, pass(prec) :: precseti  => psb_z_bjac_precseti
    procedure, pass(prec) :: precsetr  => psb_z_bjac_precsetr
    procedure, pass(prec) :: precsetc  => psb_z_bjac_precsetc
    procedure, pass(prec) :: precfree  => psb_z_bjac_precfree
    procedure, pass(prec) :: precdescr => psb_z_bjac_precdescr
    procedure, pass(prec) :: dump      => psb_z_bjac_dump
    procedure, pass(prec) :: sizeof    => psb_z_bjac_sizeof
    procedure, pass(prec) :: get_nzeros => psb_z_bjac_get_nzeros
  end type psb_z_bjac_prec_type

  private :: psb_z_bjac_sizeof, psb_z_bjac_precdescr, psb_z_bjac_get_nzeros
 

  character(len=15), parameter, private :: &
       &  fact_names(0:2)=(/'None          ','ILU(n)        ',&
       &  'ILU(eps)      '/)

  
  interface  
    subroutine psb_z_bjac_dump(prec,info,prefix,head)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_
      class(psb_z_bjac_prec_type), intent(in) :: prec
      integer(psb_ipk_), intent(out)                    :: info
      character(len=*), intent(in), optional  :: prefix,head
    end subroutine psb_z_bjac_dump
  end interface

  interface  
    subroutine psb_z_bjac_apply_vect(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_
      type(psb_desc_type),intent(in)    :: desc_data
      class(psb_z_bjac_prec_type), intent(inout)  :: prec
      complex(psb_dpk_),intent(in)         :: alpha,beta
      type(psb_z_vect_type),intent(inout)   :: x
      type(psb_z_vect_type),intent(inout)   :: y
      integer(psb_ipk_), intent(out)              :: info
      character(len=1), optional        :: trans
      complex(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_z_bjac_apply_vect
  end interface

  interface
    subroutine psb_z_bjac_apply(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_
      
      type(psb_desc_type),intent(in)    :: desc_data
      class(psb_z_bjac_prec_type), intent(in)  :: prec
      complex(psb_dpk_),intent(in)         :: alpha,beta
      complex(psb_dpk_),intent(inout)      :: x(:)
      complex(psb_dpk_),intent(inout)      :: y(:)
      integer(psb_ipk_), intent(out)              :: info
      character(len=1), optional        :: trans
      complex(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_z_bjac_apply
  end interface
  
  interface
    subroutine psb_z_bjac_precinit(prec,info)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_
      class(psb_z_bjac_prec_type),intent(inout) :: prec
      integer(psb_ipk_), intent(out)                     :: info
    end subroutine psb_z_bjac_precinit
  end interface
  
  interface
    subroutine psb_z_bjac_precbld(a,desc_a,prec,info,upd,amold,afmt,vmold)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_, &
           & psb_zspmat_type, psb_z_base_sparse_mat, psb_z_base_vect_type
      type(psb_zspmat_type), intent(in), target :: a
      type(psb_desc_type), intent(in), target   :: desc_a
      class(psb_z_bjac_prec_type),intent(inout) :: prec
      integer(psb_ipk_), intent(out)                      :: info
      character, intent(in), optional           :: upd
      character(len=*), intent(in), optional    :: afmt
      class(psb_z_base_sparse_mat), intent(in), optional :: amold
      class(psb_z_base_vect_type), intent(in), optional  :: vmold
    end subroutine psb_z_bjac_precbld
  end interface
  
  interface
    subroutine psb_z_bjac_precseti(prec,what,val,info)
      import :: psb_ipk_, psb_desc_type, psb_z_bjac_prec_type, psb_z_vect_type, psb_dpk_
      class(psb_z_bjac_prec_type),intent(inout) :: prec
      integer(psb_ipk_), intent(in)                      :: what 
      integer(psb_ipk_), intent(in)                      :: val 
      integer(psb_ipk_), intent(out)                     :: info
    end subroutine psb_z_bjac_precseti
  end interface
  

contains

  subroutine psb_z_bjac_precdescr(prec,iout)
    
    Implicit None

    class(psb_z_bjac_prec_type), intent(in) :: prec
    integer(psb_ipk_), intent(in), optional    :: iout

    integer(psb_ipk_) :: err_act, nrow, info
    character(len=20)  :: name='z_bjac_precdescr'
    integer(psb_ipk_) :: iout_

    call psb_erractionsave(err_act)

    info = psb_success_
   
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    if (.not.allocated(prec%iprcparm)) then 
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner")
      goto 9999
    end if
    
    write(iout_,*) 'Block Jacobi with: ',&
         &  fact_names(prec%iprcparm(psb_f_type_))
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_z_bjac_precdescr


  function psb_z_bjac_sizeof(prec) result(val)
    class(psb_z_bjac_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0
    if (allocated(prec%dv)) then 
      val = val + (2*psb_sizeof_dp) * prec%dv%get_nrows()
    endif
    if (allocated(prec%av)) then 
      val = val + prec%av(psb_l_pr_)%sizeof()
      val = val + prec%av(psb_u_pr_)%sizeof()
    endif
    return
  end function psb_z_bjac_sizeof

  function psb_z_bjac_get_nzeros(prec) result(val)

    class(psb_z_bjac_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0
    if (allocated(prec%dv)) then 
      val = val + prec%dv%get_nrows()
    endif
    if (allocated(prec%av)) then 
      val = val + prec%av(psb_l_pr_)%get_nzeros()
      val = val + prec%av(psb_u_pr_)%get_nzeros()
    endif
    return
  end function psb_z_bjac_get_nzeros


  subroutine psb_z_bjac_precsetr(prec,what,val,info)

    Implicit None

    class(psb_z_bjac_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    real(psb_dpk_), intent(in)               :: val 
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_bjac_precset'

    call psb_erractionsave(err_act)

    info = psb_success_

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_bjac_precsetr

  subroutine psb_z_bjac_precsetc(prec,what,val,info)

    Implicit None

    class(psb_z_bjac_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    character(len=*), intent(in)             :: val
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_bjac_precset'

    call psb_erractionsave(err_act)

    info = psb_success_

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_bjac_precsetc

  subroutine psb_z_bjac_precfree(prec,info)

    Implicit None

    class(psb_z_bjac_prec_type), intent(inout) :: prec
    integer(psb_ipk_), intent(out)                :: info

    integer(psb_ipk_) :: err_act, i
    character(len=20)  :: name='z_bjac_precfree'

    call psb_erractionsave(err_act)

    info = psb_success_
    if (allocated(prec%av)) then 
      do i=1,size(prec%av) 
        call prec%av(i)%free()
      enddo
      deallocate(prec%av,stat=info)
    end if

    if (allocated(prec%dv)) then 
      call prec%dv%free(info)
      if (info == 0) deallocate(prec%dv,stat=info)
    end if
    if (allocated(prec%iprcparm)) then 
      deallocate(prec%iprcparm,stat=info)
    end if
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return

  end subroutine psb_z_bjac_precfree

end module psb_z_bjacprec

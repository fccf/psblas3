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
module psb_d_nullprec

  use psb_d_base_prec_mod
  
  type, extends(psb_d_base_prec_type) :: psb_d_null_prec_type
  contains
    procedure, pass(prec) :: d_apply_v => psb_d_null_apply_vect
    procedure, pass(prec) :: d_apply   => psb_d_null_apply
    procedure, pass(prec) :: precbld   => psb_d_null_precbld
    procedure, pass(prec) :: precinit  => psb_d_null_precinit
    procedure, pass(prec) :: precseti  => psb_d_null_precseti
    procedure, pass(prec) :: precsetr  => psb_d_null_precsetr
    procedure, pass(prec) :: precsetc  => psb_d_null_precsetc
    procedure, pass(prec) :: precfree  => psb_d_null_precfree
    procedure, pass(prec) :: precdescr => psb_d_null_precdescr
    procedure, pass(prec) :: sizeof    => psb_d_null_sizeof
  end type psb_d_null_prec_type

  private :: psb_d_null_precbld, psb_d_null_precseti,&
       & psb_d_null_precsetr, psb_d_null_precsetc, psb_d_null_sizeof,&
       & psb_d_null_precinit, psb_d_null_precfree, psb_d_null_precdescr
  

  interface
    subroutine psb_d_null_apply_vect(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_d_null_prec_type, psb_d_vect_type, psb_dpk_
      type(psb_desc_type),intent(in)       :: desc_data
      class(psb_d_null_prec_type), intent(inout)  :: prec
      type(psb_d_vect_type),intent(inout)  :: x
      real(psb_dpk_),intent(in)         :: alpha, beta
      type(psb_d_vect_type),intent(inout)  :: y
      integer(psb_ipk_), intent(out)                 :: info
      character(len=1), optional           :: trans
      real(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_d_null_apply_vect
  end interface
  
  interface
    subroutine psb_d_null_apply(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_d_null_prec_type, psb_dpk_
      type(psb_desc_type),intent(in)       :: desc_data
      class(psb_d_null_prec_type), intent(in)  :: prec
      real(psb_dpk_),intent(inout)      :: x(:)
      real(psb_dpk_),intent(in)         :: alpha, beta
      real(psb_dpk_),intent(inout)      :: y(:)
      integer(psb_ipk_), intent(out)                 :: info
      character(len=1), optional           :: trans
      real(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_d_null_apply
  end interface
  
  
contains
  

  subroutine psb_d_null_precinit(prec,info)
    
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precinit'

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
  end subroutine psb_d_null_precinit

  subroutine psb_d_null_precbld(a,desc_a,prec,info,upd,amold,afmt,vmold)
    
    Implicit None
    
    type(psb_dspmat_type), intent(in), target :: a
    type(psb_desc_type), intent(in), target   :: desc_a
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(out)                      :: info
    character, intent(in), optional           :: upd
    character(len=*), intent(in), optional    :: afmt
    class(psb_d_base_sparse_mat), intent(in), optional :: amold
    class(psb_d_base_vect_type), intent(in), optional  :: vmold
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precbld'

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
  end subroutine psb_d_null_precbld

  subroutine psb_d_null_precseti(prec,what,val,info)
    
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    integer(psb_ipk_), intent(in)                      :: val 
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precseti

  subroutine psb_d_null_precsetr(prec,what,val,info)
    
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    real(psb_dpk_), intent(in)               :: val 
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precsetr

  subroutine psb_d_null_precsetc(prec,what,val,info)
    
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    character(len=*), intent(in)             :: val
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precsetc

  subroutine psb_d_null_precfree(prec,info)
    
    Implicit None

    class(psb_d_null_prec_type), intent(inout) :: prec
    integer(psb_ipk_), intent(out)                :: info
    
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='d_null_precset'
    
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
    
  end subroutine psb_d_null_precfree
  

  subroutine psb_d_null_precdescr(prec,iout)
    
    Implicit None

    class(psb_d_null_prec_type), intent(in) :: prec
    integer(psb_ipk_), intent(in), optional    :: iout

    integer(psb_ipk_) :: err_act, nrow, info
    character(len=20)  :: name='d_null_precset'
    integer(psb_ipk_) :: iout_

    call psb_erractionsave(err_act)

    info = psb_success_
   
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    write(iout_,*) 'No preconditioning'

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_d_null_precdescr

  function psb_d_null_sizeof(prec) result(val)

    class(psb_d_null_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0

    return
  end function psb_d_null_sizeof

end module psb_d_nullprec

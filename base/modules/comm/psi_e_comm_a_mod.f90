!   
!                Parallel Sparse BLAS  version 3.5
!      (C) Copyright 2006-2018
!        Salvatore Filippone    
!        Alfredo Buttari      
!   
!    Redistribution and use in source and binary forms, with or without
!    modification, are permitted provided that the following conditions
!    are met:
!      1. Redistributions of source code must retain the above copyright
!         notice, this list of conditions and the following disclaimer.
!      2. Redistributions in binary form must reproduce the above copyright
!         notice, this list of conditions, and the following disclaimer in the
!         documentation and/or other materials provided with the distribution.
!      3. The name of the PSBLAS group or the names of its contributors may
!         not be used to endorse or promote products derived from this
!         software without specific written permission.
!   
!    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
!    BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!    POSSIBILITY OF SUCH DAMAGE.
!   
!    
module psi_e_comm_a_mod
  use psb_desc_mod, only : psb_desc_type, psb_ipk_, psb_mpk_, psb_epk_

  interface psi_swapdata
    subroutine psi_eswapdatam(flag,n,beta,y,desc_a,work,info,data)
      import 
      integer(psb_ipk_), intent(in)         :: flag, n
      integer(psb_ipk_), intent(out)        :: info
      integer(psb_epk_)           :: y(:,:), beta
      integer(psb_epk_),target    :: work(:)
      type(psb_desc_type), target :: desc_a
      integer(psb_ipk_), optional           :: data
    end subroutine psi_eswapdatam
    subroutine psi_eswapdatav(flag,beta,y,desc_a,work,info,data)
      import 
      integer(psb_ipk_), intent(in)         :: flag
      integer(psb_ipk_), intent(out)        :: info
      integer(psb_epk_)           :: y(:), beta 
      integer(psb_epk_),target    :: work(:)
      type(psb_desc_type), target :: desc_a
      integer(psb_ipk_), optional           :: data
    end subroutine psi_eswapdatav
      subroutine psi_eswapidxm(ictxt,icomm,flag,n,beta,y,idx,&
         & totxch,totsnd,totrcv,work,info)
      import 
      integer(psb_ipk_), intent(in)      :: ictxt,icomm,flag, n
      integer(psb_ipk_), intent(out)     :: info
      integer(psb_epk_)        :: y(:,:), beta
      integer(psb_epk_),target :: work(:)
      integer(psb_ipk_), intent(in)      :: idx(:),totxch,totsnd,totrcv
    end subroutine psi_eswapidxm
    subroutine psi_eswapidxv(ictxt,icomm,flag,beta,y,idx,&
         & totxch,totsnd,totrcv,work,info)
      import 
      integer(psb_ipk_), intent(in)      :: ictxt,icomm,flag
      integer(psb_ipk_), intent(out)     :: info
      integer(psb_epk_)        :: y(:), beta
      integer(psb_epk_),target :: work(:)
      integer(psb_ipk_), intent(in)      :: idx(:),totxch,totsnd,totrcv
    end subroutine psi_eswapidxv
  end interface psi_swapdata


  interface psi_swaptran
    subroutine psi_eswaptranm(flag,n,beta,y,desc_a,work,info,data)
      import 
      integer(psb_ipk_), intent(in)         :: flag, n
      integer(psb_ipk_), intent(out)        :: info
      integer(psb_epk_)           :: y(:,:), beta
      integer(psb_epk_),target    :: work(:)
      type(psb_desc_type), target :: desc_a
      integer(psb_ipk_), optional           :: data
    end subroutine psi_eswaptranm
    subroutine psi_eswaptranv(flag,beta,y,desc_a,work,info,data)
      import 
      integer(psb_ipk_), intent(in)         :: flag
      integer(psb_ipk_), intent(out)        :: info
      integer(psb_epk_)           :: y(:), beta
      integer(psb_epk_),target    :: work(:)
      type(psb_desc_type), target :: desc_a
      integer(psb_ipk_), optional           :: data
    end subroutine psi_eswaptranv
    subroutine psi_etranidxm(ictxt,icomm,flag,n,beta,y,idx,&
         & totxch,totsnd,totrcv,work,info)
      import 
      integer(psb_ipk_), intent(in)      :: ictxt,icomm,flag, n
      integer(psb_ipk_), intent(out)     :: info
      integer(psb_epk_)        :: y(:,:), beta
      integer(psb_epk_),target :: work(:)
      integer(psb_ipk_), intent(in)       :: idx(:),totxch,totsnd,totrcv
    end subroutine psi_etranidxm
    subroutine psi_etranidxv(ictxt,icomm,flag,beta,y,idx,&
         & totxch,totsnd,totrcv,work,info)
      import 
      integer(psb_ipk_), intent(in)      :: ictxt,icomm,flag
      integer(psb_ipk_), intent(out)     :: info
      integer(psb_epk_)        :: y(:), beta
      integer(psb_epk_),target :: work(:)
      integer(psb_ipk_), intent(in)      :: idx(:),totxch,totsnd,totrcv
    end subroutine psi_etranidxv
  end interface psi_swaptran

  interface psi_ovrl_upd
    subroutine  psi_eovrl_updr1(x,desc_a,update,info)
      import 
      integer(psb_epk_), intent(inout), target :: x(:)
      type(psb_desc_type), intent(in)          :: desc_a
      integer(psb_ipk_), intent(in)                      :: update
      integer(psb_ipk_), intent(out)                     :: info
    end subroutine psi_eovrl_updr1
    subroutine  psi_eovrl_updr2(x,desc_a,update,info)
      import 
      integer(psb_epk_), intent(inout), target :: x(:,:)
      type(psb_desc_type), intent(in)          :: desc_a
      integer(psb_ipk_), intent(in)                      :: update
      integer(psb_ipk_), intent(out)                     :: info
    end subroutine psi_eovrl_updr2
  end interface psi_ovrl_upd

  interface psi_ovrl_save
    subroutine  psi_eovrl_saver1(x,xs,desc_a,info)
      import 
      integer(psb_epk_), intent(inout) :: x(:)
      integer(psb_epk_), allocatable   :: xs(:)
      type(psb_desc_type), intent(in)  :: desc_a
      integer(psb_ipk_), intent(out)             :: info
    end subroutine psi_eovrl_saver1
    subroutine  psi_eovrl_saver2(x,xs,desc_a,info)
      import 
      integer(psb_epk_), intent(inout) :: x(:,:)
      integer(psb_epk_), allocatable   :: xs(:,:)
      type(psb_desc_type), intent(in)  :: desc_a
      integer(psb_ipk_), intent(out)             :: info
    end subroutine psi_eovrl_saver2
  end interface psi_ovrl_save

  interface psi_ovrl_restore
    subroutine  psi_eovrl_restrr1(x,xs,desc_a,info)
      import 
      integer(psb_epk_), intent(inout)  :: x(:)
      integer(psb_epk_)                 :: xs(:)
      type(psb_desc_type), intent(in)  :: desc_a
      integer(psb_ipk_), intent(out)             :: info
    end subroutine psi_eovrl_restrr1
    subroutine  psi_eovrl_restrr2(x,xs,desc_a,info)
      import 
      integer(psb_epk_), intent(inout) :: x(:,:)
      integer(psb_epk_)                :: xs(:,:)
      type(psb_desc_type), intent(in)  :: desc_a
      integer(psb_ipk_), intent(out)             :: info
    end subroutine psi_eovrl_restrr2
  end interface psi_ovrl_restore

end module psi_e_comm_a_mod


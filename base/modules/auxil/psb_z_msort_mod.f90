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
!
!  Sorting routines
!  References:
!  D. Knuth
!  The Art of Computer Programming, vol. 3
!  Addison-Wesley
!  
!  Aho, Hopcroft, Ullman
!  Data Structures and Algorithms
!  Addison-Wesley
!
module psb_z_msort_mod
  use psb_const_mod


  interface psb_msort_unique
    subroutine psb_zmsort_u(x,nout,dir)
      import 
      complex(psb_dpk_), intent(inout)           :: x(:) 
      integer(psb_ipk_), intent(out)             :: nout
      integer(psb_ipk_), optional, intent(in)    :: dir
    end subroutine psb_zmsort_u
  end interface psb_msort_unique


  interface psb_msort
    subroutine psb_zmsort(x,ix,dir,flag)
      import 
      complex(psb_dpk_), intent(inout)  :: x(:) 
      integer(psb_ipk_), optional, intent(in)    :: dir, flag
      integer(psb_ipk_), optional, intent(inout) :: ix(:)
    end subroutine psb_zmsort
  end interface psb_msort

  interface psi_lmsort_up
    subroutine psi_z_lmsort_up(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_lmsort_up
  end interface psi_lmsort_up
  interface psi_lmsort_dw
    subroutine psi_z_lmsort_dw(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_lmsort_dw
  end interface psi_lmsort_dw
  interface psi_almsort_up
    subroutine psi_z_almsort_up(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_almsort_up
  end interface psi_almsort_up
  interface psi_almsort_dw
    subroutine psi_z_almsort_dw(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_almsort_dw
  end interface psi_almsort_dw
  interface psi_amsort_up
    subroutine psi_z_amsort_up(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_amsort_up
  end interface psi_amsort_up
  interface psi_amsort_dw
    subroutine psi_z_amsort_dw(n,k,l,iret)
      import
      implicit none
      integer(psb_ipk_) :: n, iret
      complex(psb_dpk_)  ::  k(n)
      integer(psb_ipk_) :: l(0:n+1)
    end subroutine psi_z_amsort_dw
  end interface psi_amsort_dw
  
end module psb_z_msort_mod

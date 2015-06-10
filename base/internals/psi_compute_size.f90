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
! Compute maximum data exchange size; small utility for assembly of descriptors.
!
subroutine psi_compute_size(desc_data, index_in, dl_lda, info)

  use psi_mod, psb_protect_name => psi_compute_size
  use psb_const_mod
  use psb_desc_mod
  use psb_error_mod
  use psb_penv_mod
  implicit none

  !     ....scalars parameters....
  integer(psb_ipk_) :: info, dl_lda
  !     .....array parameters....
  integer(psb_ipk_) :: desc_data(:), index_in(:)
  !     ....local scalars....      
  integer(psb_ipk_) :: i,np,me,proc, max_index
  integer(psb_ipk_) :: ictxt, err_act
  !     ...local array...
  integer(psb_ipk_) :: int_err(5)
  integer(psb_ipk_), allocatable :: counter_recv(:), counter_dl(:)

  !     ...parameters
  integer(psb_ipk_) :: debug_level, debug_unit
  character(len=20)  :: name

  name='psi_compute_size'
  call psb_get_erraction(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  info = psb_success_
  ictxt = desc_data(psb_ctxt_)

  call psb_info(ictxt,me,np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  allocate(counter_dl(0:np-1),counter_recv(0:np-1),stat=info)
  if (info /= psb_success_) then 
    call psb_errpush(psb_err_from_subroutine_,name,a_err='Allocate')
    goto 9999      
  end if

  !     ..initialize counters...
  do i=0,np-1
    counter_recv(i)=0
    counter_dl(i)=0
  enddo

  !     ....verify local correctness of halo_in....
  i=1
  do while (index_in(i) /= -1)
    proc=index_in(i)
    if ((proc > np-1).or.(proc < 0)) then
      info = psb_err_invalid_pid_arg_
      int_err(1) = 11
      int_err(2) = proc
      call psb_errpush(info,name,i_err=int_err)
      goto 9999
    endif
    counter_dl(proc)=1

    !        ..update no of elements to receive from proc proc..         
    counter_recv(proc)=counter_recv(proc)+&
         & index_in(i+1)

    i=i+index_in(i+1)+2
  enddo

  !     ...computing max_halo: max halo points to be received from
  !                            same processor
  max_index=0
  dl_lda=0

  do i=0,np-1
    if (counter_recv(i) > max_index) max_index = counter_recv(i)
    if (counter_dl(i) == 1) dl_lda = dl_lda+1
  enddo

  !     computing max global value of dl_lda
  call psb_amx(ictxt, dl_lda)

  if (debug_level>=psb_debug_inner_) then 
    write(debug_unit,*) me,' ',trim(name),': ',dl_lda
  endif

  call psb_erractionrestore(err_act)
  return

9999 call psb_error_handler(ictxt,err_act)

  return

end subroutine psi_compute_size

         


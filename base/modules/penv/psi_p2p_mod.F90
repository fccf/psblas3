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

module psi_p2p_mod
  use psi_penv_mod
  use psi_comm_buffers_mod

  use psi_m_p2p_mod
  use psi_e_p2p_mod
  use psi_s_p2p_mod
  use psi_d_p2p_mod
  use psi_c_p2p_mod
  use psi_z_p2p_mod


  !
  ! Add here interfaces for
  ! LOGICAL scalar/vector/matrix
  ! CHARACTER scalar (use H prefix as in old style Hollerith)
  !
  interface psb_snd
    module procedure psb_lsnds, psb_lsndv, psb_lsndm,&
         & psb_hsnds, psb_lsnds_ec, psb_lsndv_ec, &
         & psb_lsndm_ec, psb_hsnds_ec
  end interface
  interface psb_rcv
    module procedure psb_lrcvs, psb_lrcvv, psb_lrcvm,&
         & psb_hrcvs, psb_lrcvs_ec, psb_lrcvv_ec, &
         & psb_lrcvm_ec, psb_hrcvs_ec
  end interface


contains


  ! !!!!!!!!!!!!!!!!!!!!!!!!
  !
  ! Point-to-point SND
  !
  ! !!!!!!!!!!!!!!!!!!!!!!!!

  subroutine psb_lsnds(ictxt,dat,dst)
    use psi_comm_buffers_mod 
#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat
    integer(psb_mpk_), intent(in)  :: dst
    logical, allocatable :: dat_(:)
    integer(psb_mpk_) :: info 
#if defined(SERIAL_MPI) 
    ! do nothing
#else
    allocate(dat_(1), stat=info)
    dat_(1) = dat
    call psi_snd(ictxt,psb_logical_tag,dst,dat_,psb_mesg_queue)
#endif    
  end subroutine psb_lsnds

  subroutine psb_lsndv(ictxt,dat,dst)
    use psi_comm_buffers_mod 

#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat(:)
    integer(psb_mpk_), intent(in)  :: dst
    logical, allocatable :: dat_(:)
    integer(psb_mpk_) :: info 

#if defined(SERIAL_MPI) 
#else
    allocate(dat_(size(dat)), stat=info)
    dat_(:) = dat(:)
    call psi_snd(ictxt,psb_logical_tag,dst,dat_,psb_mesg_queue)
#endif    

  end subroutine psb_lsndv

  subroutine psb_lsndm(ictxt,dat,dst,m)
    use psi_comm_buffers_mod 

#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat(:,:)
    integer(psb_mpk_), intent(in)  :: dst
    integer(psb_ipk_), intent(in), optional :: m
    logical, allocatable :: dat_(:)
    integer(psb_mpk_) :: info
    integer(psb_ipk_) :: i,j,k,m_,n_

#if defined(SERIAL_MPI) 
#else
    if (present(m)) then 
      m_ = m
    else
      m_ = size(dat,1)
    end if
    n_ = size(dat,2)
    allocate(dat_(m_*n_), stat=info)
    k=1
    do j=1,n_
      do i=1, m_
        dat_(k) = dat(i,j)
        k = k + 1
      end do
    end do
    call psi_snd(ictxt,psb_logical_tag,dst,dat_,psb_mesg_queue)
#endif    
  end subroutine psb_lsndm

  subroutine psb_hsnds(ictxt,dat,dst)
    use psi_comm_buffers_mod 
#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    character(len=*), intent(in)  :: dat
    integer(psb_mpk_), intent(in)  :: dst
    character(len=1), allocatable :: dat_(:)
    integer(psb_mpk_) :: info, l, i
#if defined(SERIAL_MPI) 
    ! do nothing
#else
    l = len(dat) 
    allocate(dat_(l), stat=info)
    do i=1, l
      dat_(i) = dat(i:i)
    end do
    call psi_snd(ictxt,psb_char_tag,dst,dat_,psb_mesg_queue)
#endif    
  end subroutine psb_hsnds

  subroutine psb_lsnds_ec(ictxt,dat,dst)
    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat
    integer(psb_epk_), intent(in)  :: dst
    
    integer(psb_mpk_) :: iictxt, idst 

    iictxt = ictxt
    idst   = dst 
    call psb_snd(iictxt, dat, idst)

  end subroutine psb_lsnds_ec

  subroutine psb_lsndv_ec(ictxt,dat,dst)

    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat(:)
    integer(psb_epk_), intent(in)  :: dst
    
    integer(psb_mpk_) :: iictxt, idst 

    iictxt = ictxt
    idst   = dst 
    call psb_snd(iictxt, dat, idst)

  end subroutine psb_lsndv_ec

  subroutine psb_lsndm_ec(ictxt,dat,dst,m)

    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(in)  :: dat(:,:)
    integer(psb_epk_), intent(in)  :: dst
    
    integer(psb_mpk_) :: iictxt, idst 

    iictxt = ictxt
    idst   = dst 
    call psb_snd(iictxt, dat, idst)

  end subroutine psb_lsndm_ec


  subroutine psb_hsnds_ec(ictxt,dat,dst)

    integer(psb_epk_), intent(in)  :: ictxt
    character(len=*), intent(in)  :: dat
    integer(psb_epk_), intent(in)  :: dst
    
    integer(psb_mpk_) :: iictxt, idst 

    iictxt = ictxt
    idst   = dst 
    call psb_snd(iictxt, dat, idst)

  end subroutine psb_hsnds_ec


  ! !!!!!!!!!!!!!!!!!!!!!!!!
  !
  ! Point-to-point RCV
  !
  ! !!!!!!!!!!!!!!!!!!!!!!!!

  subroutine psb_lrcvs(ictxt,dat,src)
    use psi_comm_buffers_mod 
#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(out)  :: dat
    integer(psb_mpk_), intent(in)  :: src
    integer(psb_mpk_) :: info 
    integer(psb_mpk_) :: status(mpi_status_size)
#if defined(SERIAL_MPI) 
    ! do nothing
#else
    call mpi_recv(dat,1,mpi_logical,src,psb_logical_tag,ictxt,status,info)
    call psb_test_nodes(psb_mesg_queue)
#endif    
  end subroutine psb_lrcvs

  subroutine psb_lrcvv(ictxt,dat,src)
    use psi_comm_buffers_mod 

#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(out)  :: dat(:)
    integer(psb_mpk_), intent(in)  :: src
    integer(psb_mpk_) :: info 
    integer(psb_mpk_) :: status(mpi_status_size)
#if defined(SERIAL_MPI) 
#else
    call mpi_recv(dat,size(dat),mpi_logical,src,psb_logical_tag,ictxt,status,info)
    call psb_test_nodes(psb_mesg_queue)
#endif    

  end subroutine psb_lrcvv

  subroutine psb_lrcvm(ictxt,dat,src,m)
    use psi_comm_buffers_mod 

#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    logical, intent(out)  :: dat(:,:)
    integer(psb_mpk_), intent(in)  :: src
    integer(psb_ipk_), intent(in), optional :: m
    integer(psb_mpk_) :: info ,m_,n_, ld, mp_rcv_type
    integer(psb_ipk_) :: i,j,k
    integer(psb_mpk_) :: status(mpi_status_size)
#if defined(SERIAL_MPI) 
    ! What should we do here?? 
#else
    if (present(m)) then 
      m_ = m
      ld = size(dat,1)
      n_ = size(dat,2)
      call mpi_type_vector(n_,m_,ld,mpi_logical,mp_rcv_type,info)
      if (info == mpi_success) call mpi_type_commit(mp_rcv_type,info)
      if (info == mpi_success) call mpi_recv(dat,1,mp_rcv_type,src,&
           & psb_logical_tag,ictxt,status,info)
      if (info == mpi_success) call mpi_type_free(mp_rcv_type,info)
    else
      call mpi_recv(dat,size(dat),mpi_logical,src,&
           & psb_logical_tag,ictxt,status,info)
    end if
    if (info /= mpi_success) then 
      write(psb_err_unit,*) 'Error in psb_recv', info
    end if
    call psb_test_nodes(psb_mesg_queue)
#endif    
  end subroutine psb_lrcvm


  subroutine psb_hrcvs(ictxt,dat,src)
    use psi_comm_buffers_mod 
#ifdef MPI_MOD
    use mpi
#endif
    implicit none 
#ifdef MPI_H
    include 'mpif.h'
#endif
    integer(psb_mpk_), intent(in)  :: ictxt
    character(len=*), intent(out)  :: dat
    integer(psb_mpk_), intent(in)  :: src
    character(len=1), allocatable :: dat_(:)
    integer(psb_mpk_) :: info, l, i
    integer(psb_mpk_) :: status(mpi_status_size)
#if defined(SERIAL_MPI) 
    ! do nothing
#else
    l = len(dat) 
    allocate(dat_(l), stat=info)
    call mpi_recv(dat_,l,mpi_character,src,psb_char_tag,ictxt,status,info)
    call psb_test_nodes(psb_mesg_queue)
    do i=1, l
      dat(i:i) = dat_(i) 
    end do
    deallocate(dat_)
#endif    
  end subroutine psb_hrcvs


  subroutine psb_lrcvs_ec(ictxt,dat,src)
    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(out) :: dat
    integer(psb_epk_), intent(in)  :: src
    
    integer(psb_mpk_) :: iictxt, isrc 

    iictxt = ictxt
    isrc   = src 
    call psb_rcv(iictxt, dat, isrc)
    
  end subroutine psb_lrcvs_ec

  subroutine psb_lrcvv_ec(ictxt,dat,src)

    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(out) :: dat(:)
    integer(psb_epk_), intent(in)  :: src
    
    integer(psb_mpk_) :: iictxt, isrc 

    iictxt = ictxt
    isrc   = src 
    call psb_rcv(iictxt, dat, isrc)

  end subroutine psb_lrcvv_ec

  subroutine psb_lrcvm_ec(ictxt,dat,src,m)

    integer(psb_epk_), intent(in)  :: ictxt
    logical, intent(out) :: dat(:,:)
    integer(psb_epk_), intent(in)  :: src
    
    integer(psb_mpk_) :: iictxt, isrc 

    iictxt = ictxt
    isrc   = src 
    call psb_rcv(iictxt, dat, isrc)

  end subroutine psb_lrcvm_ec


  subroutine psb_hrcvs_ec(ictxt,dat,src)

    integer(psb_epk_), intent(in)  :: ictxt
    character(len=*), intent(out) :: dat
    integer(psb_epk_), intent(in)  :: src
    
    integer(psb_mpk_) :: iictxt, isrc 

    iictxt = ictxt
    isrc   = src 
    call psb_rcv(iictxt, dat, isrc)

  end subroutine psb_hrcvs_ec

end module psi_p2p_mod

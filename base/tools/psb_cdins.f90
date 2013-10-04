!!$ 
!!$              Parallel Sparse BLAS  version 3.1
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010, 2012, 2013
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
! File: psb_cdins.f90
!
! Subroutine: psb_cdins
!   Takes as input a cloud of points and updates the descriptor accordingly.
!   Note: entries with a row index not belonging to the current process are 
!         ignored (see usage of ila_ as mask in the call to psb_idx_ins_cnv).
! 
! Arguments: 
!    nz       - integer.                       The number of points to insert.
!    ia(:)    - integer                        The row indices of the points.
!    ja(:)    - integer                        The column indices of the points.
!    desc_a   - type(psb_desc_type).         The communication descriptor to be freed.
!    info     - integer.                       Return code.
!    ila(:)   - integer(psb_ipk_), optional              The row indices in local numbering
!    jla(:)   - integer(psb_ipk_), optional              The col indices in local numbering
!
subroutine psb_cdinsrc(nz,ia,ja,desc_a,info,ila,jla)
  use psb_base_mod, psb_protect_name => psb_cdinsrc
  use psi_mod
  implicit none

  !....PARAMETERS...
  Type(psb_desc_type), intent(inout) :: desc_a
  integer(psb_ipk_), intent(in)                :: nz,ia(:),ja(:)
  integer(psb_ipk_), intent(out)               :: info
  integer(psb_ipk_), optional, intent(out)     :: ila(:), jla(:)
  !LOCALS.....

  integer(psb_ipk_) :: ictxt,dectype,mglob, nglob
  integer(psb_ipk_) :: np, me
  integer(psb_ipk_) :: nrow,ncol, err_act
  logical, parameter     :: debug=.false.
  integer(psb_ipk_), parameter     :: relocsz=200
  integer(psb_ipk_), allocatable   :: ila_(:), jla_(:)
  character(len=20)      :: name

  info = psb_success_
  name = 'psb_cdins'
  call psb_erractionsave(err_act)
  
  if (.not.desc_a%is_bld()) then 
    info = psb_err_invalid_cd_state_  
    call psb_errpush(info,name)
    goto 9999
  endif

  ictxt   = desc_a%get_context()
  dectype = desc_a%get_dectype()
  mglob   = desc_a%get_global_rows()
  nglob   = desc_a%get_global_cols()
  nrow    = desc_a%get_local_rows()
  ncol    = desc_a%get_local_cols()

  call psb_info(ictxt, me, np)

  if (nz < 0) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if
  if (nz == 0) return 

  if (size(ia) < nz) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if

  if (size(ja) < nz) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if
  if (present(ila)) then 
    if (size(ila) < nz) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
  end if
  if (present(jla)) then 
    if (size(jla) < nz) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
  end if

  if (present(ila).and.present(jla)) then 
    call desc_a%indxmap%g2l(ia(1:nz),ila(1:nz),info,owned=.true.)
    if (info == psb_success_) &
         & call desc_a%indxmap%g2l_ins(ja(1:nz),jla(1:nz),info,mask=(ila(1:nz)>0))
  else
    if (present(ila).or.present(jla)) then 
      write(psb_err_unit,*) 'Inconsistent call : ',present(ila),present(jla)
    endif
    allocate(ila_(nz),jla_(nz),stat=info)
    if (info /= psb_success_) then 
      info = psb_err_alloc_dealloc_
      call psb_errpush(info,name)
      goto 9999
    end if
    call desc_a%indxmap%g2l(ia(1:nz),ila_(1:nz),info,owned=.true.)
    if (info == psb_success_) then 
      jla_(1:nz) = ja(1:nz)
      call desc_a%indxmap%g2lip_ins(jla_(1:nz),info,mask=(ila_(1:nz)>0))
    end if
    deallocate(ila_,jla_,stat=info)
  end if
  if (info /= psb_success_) goto 9999
  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_cdinsrc

!
! Subroutine: psb_cdinsc
!   Takes as input a list of indices points and updates the descriptor accordingly.
!   The optional argument mask may be used to control which indices are actually
!   used. 
! 
! Arguments: 
!    nz       - integer.                       The number of points to insert.
!    ja(:)    - integer                        The column indices of the points.
!    desc     - type(psb_desc_type).           The communication descriptor 
!    info     - integer.                       Return code.
!    jla(:)   - integer(psb_ipk_), optional    The col indices in local numbering
!    mask(:)  - logical, optional, target
!    lidx(:)  - integer(psb_ipk_), optional    User-defined local col indices
!
subroutine psb_cdinsc(nz,ja,desc,info,jla,mask,lidx)
  use psb_base_mod, psb_protect_name => psb_cdinsc
  use psi_mod
  implicit none

  !....PARAMETERS...
  Type(psb_desc_type), intent(inout)       :: desc
  integer(psb_ipk_), intent(in)            :: nz,ja(:)
  integer(psb_ipk_), intent(out)           :: info
  integer(psb_ipk_), optional, intent(out) :: jla(:)
  logical, optional, target, intent(in)    :: mask(:) 
  integer(psb_ipk_), intent(in), optional  :: lidx(:)


  !LOCALS.....

  integer(psb_ipk_) :: ictxt,dectype,mglob, nglob
  integer(psb_ipk_) :: np, me
  integer(psb_ipk_) :: nrow,ncol, err_act
  logical, parameter     :: debug=.false.
  integer(psb_ipk_), parameter     :: relocsz=200
  integer(psb_ipk_), allocatable   :: ila_(:), jla_(:)
  character(len=20)      :: name
  

  info = psb_success_
  name = 'psb_cdins'
  call psb_erractionsave(err_act)

  if (.not.desc%is_bld()) then 
    info = psb_err_invalid_cd_state_  
    call psb_errpush(info,name)
    goto 9999
  endif

  ictxt   = desc%get_context()
  dectype = desc%get_dectype()
  mglob   = desc%get_global_rows()
  nglob   = desc%get_global_cols()
  nrow    = desc%get_local_rows()
  ncol    = desc%get_local_cols()

  call psb_info(ictxt, me, np)

  if (nz < 0) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if
  if (nz == 0) return 

  if (size(ja) < nz) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if

  if (present(jla)) then 
    if (size(jla) < nz) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
  end if
  if (present(lidx)) then 
    if (size(lidx) < nz) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
  end if
  if (present(mask)) then 
    if (size(mask) < nz) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
  end if

  if (present(jla)) then 
    call desc%indxmap%g2l_ins(ja(1:nz),jla(1:nz),info,mask=mask,lidx=lidx)
  else
    allocate(jla_(nz),stat=info)
    if (info /= psb_success_) then 
      info = psb_err_alloc_dealloc_
      call psb_errpush(info,name)
      goto 9999
    end if
    call desc%indxmap%g2l_ins(ja(1:nz),jla_(1:nz),info,mask=mask,lidx=lidx)
    deallocate(jla_)
  end if

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_cdinsc


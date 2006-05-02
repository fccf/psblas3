
!!$ 
!!$              Parallel Sparse BLAS  v2.0
!!$    (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
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
! Subroutine: psb_zinsvi
!    Insert dense submatrix to dense matrix.
! 
! Parameters: 
!    m       - integer.        Number of rows of submatrix belonging to 
!                              val to be inserted.
!    irw    - integer(:)       Row indices of rows of val (global numbering)
!    val    - complex, dimension(:).   The source dense submatrix.  
!    x       - complex, pointer, dimension(:).   The destination dense matrix.  
!    desc_a  - type(<psb_desc_type>).         The communication descriptor.
!    info    - integer.                       Eventually returns an error code
subroutine psb_zinsvi(m, irw, val, x, desc_a, info, dupl)
  !....insert dense submatrix to dense matrix .....
  use psb_descriptor_type
  use psb_const_mod
  use psb_error_mod
  implicit none

  ! m rows number of submatrix belonging to val to be inserted

  ! ix  x global-row corresponding to position at which val submatrix
  !     must be inserted

  !....parameters...
  integer, intent(in)              ::  m
  integer, intent(in)              ::  irw(:)
  complex(kind(1.d0)), intent(in)  ::  val(:)
  complex(kind(1.d0)),pointer      ::  x(:)
  type(psb_desc_type), intent(in)  ::  desc_a
  integer, intent(out)             ::  info
  integer, optional, intent(in)    ::  dupl

  !locals.....
  integer                :: icontxt,i,loc_row,glob_row,row,k,&
       & loc_rows,loc_cols,iblock, liflag,mglob,err_act, int_err(5), err
  integer                :: nprow,npcol, me ,mypcol,dupl_
  character(len=20)   :: name, char_err

  if(psb_get_errstatus().ne.0) return 
  info=0
  call psb_erractionsave(err_act)
  name = 'psb_dinsvv'

  if (.not.associated(desc_a%glob_to_loc)) then
    info=3110
    call psb_errpush(info,name)
    return
  end if
  if ((.not.associated(desc_a%matrix_data))) then
    int_err(1)=3110
    call psb_errpush(info,name)
    return
  end if

  icontxt=desc_a%matrix_data(psb_ctxt_)

  ! check on blacs grid 
  call blacs_gridinfo(icontxt, nprow, npcol, me, mypcol)
  if (nprow.eq.-1) then
    info = 2010
    call psb_errpush(info,name)
    goto 9999
  else if (npcol.ne.1) then
    info = 2030
    int_err(1) = npcol
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  !... check parameters....
  if (m.lt.0) then
    info = 10
    int_err(1) = 1
    int_err(2) = m
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (.not.psb_is_ok_dec(desc_a%matrix_data(psb_dec_type_))) then
    info = 3110
    int_err(1) = desc_a%matrix_data(psb_dec_type_)
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (size(x, dim=1).lt.desc_a%matrix_data(psb_n_row_)) then
    info = 310
    int_err(1) = 5
    int_err(2) = 4
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  loc_rows=desc_a%matrix_data(psb_n_row_)
  loc_cols=desc_a%matrix_data(psb_n_col_)
  mglob    = desc_a%matrix_data(psb_m_)

  if (present(dupl)) then 
    dupl_ = dupl
  else
    dupl_ = psb_dupl_ovwrt_
  endif

  select case(dupl_) 
  case(psb_dupl_ovwrt_) 
    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      glob_row=irw(i) 
      if ((glob_row>0).and.(glob_row <= mglob)) then 

        loc_row=desc_a%glob_to_loc(glob_row)
        if (loc_row.ge.1) then
          ! this row belongs to me
          ! copy i-th row of block val in x
          x(loc_row) = val(i)
        end if
      end if
    enddo

  case(psb_dupl_add_) 

    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      glob_row=irw(i) 
      if ((glob_row>0).and.(glob_row <= mglob)) then 

        loc_row=desc_a%glob_to_loc(glob_row)
        if (loc_row.ge.1) then
          ! this row belongs to me
          ! copy i-th row of block val in x
          x(loc_row) = x(loc_row) +  val(i)
        end if
      end if
    enddo

  case default
    info = 321
    call psb_errpush(info,name)
    goto 9999
  end select

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act.eq.act_ret) then
    return
  else
    call psb_error(icontxt)
  end if
  return

end subroutine psb_zinsvi


!!$ 
!!$              Parallel Sparse BLAS  v2.0
!!$    (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
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
! Subroutine: psb_zinsi
! 
! Parameters: 
!    m       - integer.        Number of rows of submatrix belonging to 
!                              val to be inserted.
!    irw    - integer(:)       Row indices of rows of val (global numbering)
!    val    - complex, dimension(:,:).   The source dense submatrix.  
!    x       - complex, pointer, dimension(:,:).   The destination dense matrix.  
!    desc_a  - type(<psb_desc_type>).         The communication descriptor.
!    info    - integer.                       Eventually returns an error code
subroutine psb_zinsi(m,irw, val, x, desc_a, info, dupl)
  !....insert dense submatrix to dense matrix .....
  use psb_descriptor_type
  use psb_const_mod
  use psb_error_mod
  implicit none

  ! m rows number of submatrix belonging to val to be inserted

  ! ix  x global-row corresponding to position at which val submatrix
  !     must be inserted

  !....parameters...
  integer, intent(in)             ::  m
  integer, intent(in)             ::  irw(:)
  complex(kind(1.d0)), intent(in) ::  val(:,:)
  complex(kind(1.d0)),pointer     ::  x(:,:)
  type(psb_desc_type), intent(in) ::  desc_a
  integer, intent(out)            ::  info
  integer, optional, intent(in)   ::  dupl

  !locals.....
  integer                :: icontxt,i,loc_row,glob_row,row,k,j,n,&
       & loc_rows,loc_cols,iblock, liflag,mglob,err_act, int_err(5), err
  integer                :: nprow,npcol, me ,mypcol,dupl_
  character(len=20)   :: name, char_err

  if(psb_get_errstatus().ne.0) return 
  info=0
  call psb_erractionsave(err_act)
  name = 'psb_dinsvv'

  if (.not.associated(desc_a%glob_to_loc)) then
    info=3110
    call psb_errpush(info,name)
    return
  end if
  if ((.not.associated(desc_a%matrix_data))) then
    int_err(1)=3110
    call psb_errpush(info,name)
    return
  end if

  icontxt=desc_a%matrix_data(psb_ctxt_)

  ! check on blacs grid 
  call blacs_gridinfo(icontxt, nprow, npcol, me, mypcol)
  if (nprow.eq.-1) then
    info = 2010
    call psb_errpush(info,name)
    goto 9999
  else if (npcol.ne.1) then
    info = 2030
    int_err(1) = npcol
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  !... check parameters....
  if (m.lt.0) then
    info = 10
    int_err(1) = 1
    int_err(2) = m
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (.not.psb_is_ok_dec(desc_a%matrix_data(psb_dec_type_))) then
    info = 3110
    int_err(1) = desc_a%matrix_data(psb_dec_type_)
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (size(x, dim=1).lt.desc_a%matrix_data(psb_n_row_)) then
    info = 310
    int_err(1) = 5
    int_err(2) = 4
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  loc_rows=desc_a%matrix_data(psb_n_row_)
  loc_cols=desc_a%matrix_data(psb_n_col_)
  mglob    = desc_a%matrix_data(psb_m_)

  n = min(size(val,2),size(x,2))
  if (present(dupl)) then 
    dupl_ = dupl
  else
    dupl_ = psb_dupl_ovwrt_
  endif

  select case(dupl_) 
  case(psb_dupl_ovwrt_) 
    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      glob_row=irw(i) 
      if ((glob_row>0).and.(glob_row <= mglob)) then 

        loc_row=desc_a%glob_to_loc(glob_row)
        if (loc_row.ge.1) then
          ! this row belongs to me
          ! copy i-th row of block val in x
          do j=1,n
            x(loc_row,j) = val(i,j)
          end do
        end if
      end if
    enddo

  case(psb_dupl_add_) 

    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      glob_row=irw(i) 
      if ((glob_row>0).and.(glob_row <= mglob)) then 

        loc_row=desc_a%glob_to_loc(glob_row)
        if (loc_row.ge.1) then
          ! this row belongs to me
          ! copy i-th row of block val in x
          do j=1,n
            x(loc_row,j) = x(loc_row,j) +  val(i,j)
          end do
        end if
      end if
    enddo

  case default
    info = 321
    call psb_errpush(info,name)
    goto 9999
  end select

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act.eq.act_ret) then
    return
  else
    call psb_error(icontxt)
  end if
  return

end subroutine psb_zinsi


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
!
!
! package: psb_list_map_mod
!    Defines the LIST_MAP type.
!
! This is essentially the original PSBLAS index map. We assume that
! 1. We have room for GLOB_TO_LOC and LOC_TO_GLOB
! 2. There could be an overlap, so we don't store explicitly who owns an index.
!
!
module psb_list_map_mod
  use psb_const_mod
  use psb_desc_const_mod
  use psb_indx_map_mod
  
  type, extends(psb_indx_map) :: psb_list_map
    integer :: pnt_h          = -1 
    integer, allocatable :: loc_to_glob(:), glob_to_loc(:)
  contains
    procedure, pass(idxmap)  :: init_vl    => list_initvl

    procedure, pass(idxmap)  :: sizeof    => list_sizeof
    procedure, pass(idxmap)  :: asb       => list_asb
    procedure, pass(idxmap)  :: free      => list_free
    procedure, pass(idxmap)  :: clone     => list_clone
    procedure, nopass        :: get_fmt   => list_get_fmt
    procedure, pass(idxmap)  :: row_extendable => list_row_extendable

    procedure, pass(idxmap)  :: l2gs1 => list_l2gs1
    procedure, pass(idxmap)  :: l2gs2 => list_l2gs2
    procedure, pass(idxmap)  :: l2gv1 => list_l2gv1
    procedure, pass(idxmap)  :: l2gv2 => list_l2gv2

    procedure, pass(idxmap)  :: g2ls1 => list_g2ls1
    procedure, pass(idxmap)  :: g2ls2 => list_g2ls2
    procedure, pass(idxmap)  :: g2lv1 => list_g2lv1
    procedure, pass(idxmap)  :: g2lv2 => list_g2lv2

    procedure, pass(idxmap)  :: g2ls1_ins => list_g2ls1_ins
    procedure, pass(idxmap)  :: g2ls2_ins => list_g2ls2_ins
    procedure, pass(idxmap)  :: g2lv1_ins => list_g2lv1_ins
    procedure, pass(idxmap)  :: g2lv2_ins => list_g2lv2_ins

  end type psb_list_map

  private :: list_initvl, list_sizeof, list_asb, list_free,&
       & list_get_fmt, list_l2gs1, list_l2gs2, list_l2gv1,&
       & list_l2gv2, list_g2ls1, list_g2ls2, list_g2lv1,&
       & list_g2lv2, list_g2ls1_ins, list_g2ls2_ins,&
       & list_g2lv1_ins, list_g2lv2_ins, list_row_extendable

contains
    
  function list_row_extendable(idxmap) result(val)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    logical :: val
    val = .true.
  end function list_row_extendable

  function list_sizeof(idxmap) result(val)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer(psb_long_int_k_) :: val
    
    val = idxmap%psb_indx_map%sizeof()

    if (allocated(idxmap%loc_to_glob)) &
         & val = val + size(idxmap%loc_to_glob)*psb_sizeof_int
    if (allocated(idxmap%glob_to_loc)) &
         & val = val + size(idxmap%glob_to_loc)*psb_sizeof_int

  end function list_sizeof


  subroutine list_free(idxmap)
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    
    if (allocated(idxmap%loc_to_glob)) &
         & deallocate(idxmap%loc_to_glob)
    if (allocated(idxmap%glob_to_loc)) &
         & deallocate(idxmap%glob_to_loc)

    call idxmap%psb_indx_map%free()

  end subroutine list_free


  subroutine list_l2gs1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer  :: idxv(1)
    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if

    idxv(1) = idx
    call idxmap%l2g(idxv,info,owned=owned)
    idx = idxv(1)

  end subroutine list_l2gs1

  subroutine list_l2gs2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%l2g(idxout,info,mask,owned)
    
  end subroutine list_l2gs2


  subroutine list_l2gv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i
    logical :: owned_
    info = 0

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    if (present(mask)) then 

      do i=1, size(idx)
        if (mask(i)) then 
          if ((1<=idx(i)).and.(idx(i) <= idxmap%get_lr())) then
            idx(i) = idxmap%loc_to_glob(idx(i))
          else if ((idxmap%get_lr() < idx(i)).and.(idx(i) <= idxmap%local_cols)&
               & .and.(.not.owned_)) then
            idx(i) = idxmap%loc_to_glob(idx(i))
          else 
            idx(i) = -1
          end if
        end if
      end do

    else  if (.not.present(mask)) then 

      do i=1, size(idx)
        if ((1<=idx(i)).and.(idx(i) <= idxmap%get_lr())) then
          idx(i) = idxmap%loc_to_glob(idx(i))
        else if ((idxmap%get_lr() < idx(i)).and.(idx(i) <= idxmap%local_cols)&
             & .and.(.not.owned_)) then
          idx(i) = idxmap%loc_to_glob(idx(i))
        else 
          idx(i) = -1
        end if
      end do

    end if

  end subroutine list_l2gv1

  subroutine list_l2gv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%l2g(idxout(1:im),info,mask,owned)
    if (is > im) info = -3 

  end subroutine list_l2gv2


  subroutine list_g2ls1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer :: idxv(1)
    info = 0

    if (present(mask)) then 
      if (.not.mask) return
    end if
    
    idxv(1) = idx 
    call idxmap%g2l(idxv,info,owned=owned)
    idx = idxv(1) 
      
  end subroutine list_g2ls1

  subroutine list_g2ls2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%g2l(idxout,info,mask,owned)
    
  end subroutine list_g2ls2


  subroutine list_g2lv1(idx,idxmap,info,mask,owned)
    use psb_sort_mod
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i, nv, is, ix
    logical :: owned_

    info = 0

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    is = size(idx)

    if (present(mask)) then 
      if (idxmap%is_valid()) then 
        do i=1,is
          if (mask(i)) then 
            if ((1 <= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              ix = idxmap%glob_to_loc(idx(i))
              if ((ix > idxmap%get_lr()).and.(owned_)) ix = -1
              idx(i) = ix
            else 
              idx(i) = -1
            end if
          end if
        end do
      else 
        idx(1:is) = -1
        info = -1
      end if

    else  if (.not.present(mask)) then 

      if (idxmap%is_valid()) then 
        do i=1, is
          if ((1 <= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            ix = idxmap%glob_to_loc(idx(i))
                if ((ix > idxmap%get_lr()).and.(owned_)) ix = -1
            idx(i) = ix
          else 
            idx(i) = -1
          end if
        end do
      else 
        idx(1:is) = -1
        info = -1
      end if

    end if

  end subroutine list_g2lv1

  subroutine list_g2lv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_list_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned

    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l(idxout(1:im),info,mask,owned)
    if (is > im) info = -3 

  end subroutine list_g2lv2



  subroutine list_g2ls1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    integer :: idxv(1)

    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if
    idxv(1) = idx
    call idxmap%g2l_ins(idxv,info)
    idx = idxv(1) 

  end subroutine list_g2ls1_ins

  subroutine list_g2ls2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    idxout = idxin
    call idxmap%g2l_ins(idxout,info)
    
  end subroutine list_g2ls2_ins


  subroutine list_g2lv1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: i, nv, is, ix

    info = 0
    is = size(idx)

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if


    if (idxmap%is_asb()) then 
      ! State is wrong for this one ! 
      idx = -1
      info = -1

    else if (idxmap%is_valid()) then 

      if (present(mask)) then 
        do i=1, is
          if (mask(i)) then 
            if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              ix = idxmap%glob_to_loc(idx(i))
              if (ix < 0) then 
                ix = idxmap%local_cols + 1
                call psb_ensure_size(ix,idxmap%loc_to_glob,info,addsz=500)
                if (info /= 0) then 
                  info = -4
                  return
                end if
                idxmap%local_cols      = ix
                idxmap%loc_to_glob(ix) = idx(i)
                idxmap%glob_to_loc(idx(i)) = ix
              end if
              idx(i) = ix
            else 
              idx(i) = -1
            end if
          end if
        end do

      else if (.not.present(mask)) then 

        do i=1, is
          if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            ix = idxmap%glob_to_loc(idx(i))
            if (ix < 0) then 
              ix = idxmap%local_cols + 1
              call psb_ensure_size(ix,idxmap%loc_to_glob,info,addsz=500)
              if (info /= 0) then 
                info = -4
                return
              end if
              idxmap%local_cols      = ix
              idxmap%loc_to_glob(ix) = idx(i)
              idxmap%glob_to_loc(idx(i)) = ix
            end if
            idx(i) = ix
          else 
            idx(i) = -1
          end if
        end do
      end if

    else 
      idx = -1
      info = -1
    end if

  end subroutine list_g2lv1_ins

  subroutine list_g2lv2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l_ins(idxout(1:im),info,mask)
    if (is > im) info = -3 

  end subroutine list_g2lv2_ins



!!$
!!$  subroutine list_initvg(idxmap,vg,ictxt,info)
!!$    use psb_penv_mod
!!$    use psb_error_mod
!!$    implicit none 
!!$    class(psb_list_map), intent(inout) :: idxmap
!!$    integer, intent(in)  :: ictxt, vg(:)
!!$    integer, intent(out) :: info
!!$    !  To be implemented
!!$    integer :: iam, np, i, j, n, nl
!!$    
!!$
!!$    info = 0
!!$    call psb_info(ictxt,iam,np) 
!!$    if (np < 0) then 
!!$      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
!!$      info = -1
!!$      return
!!$    end if
!!$    n = size(vg) 
!!$    
!!$    idxmap%global_rows  = n
!!$    idxmap%global_cols  = n
!!$
!!$    allocate(idxmap%loc_to_glob(n),idxmap%glob_to_loc(n),&
!!$         & stat=info) 
!!$    if (info /= 0)  then
!!$      info = -2
!!$      return
!!$    end if
!!$
!!$    idxmap%ictxt        = ictxt
!!$    idxmap%state        = psb_desc_bld_
!!$    call psb_get_mpicomm(ictxt,idxmap%mpic)
!!$
!!$    nl = 0 
!!$    do i=1, n 
!!$      if ((vg(i)  > np-1).or.(vg(i) < 0)) then
!!$        info=psb_err_partfunc_wrong_pid_
!!$        exit
!!$      end if
!!$      if (vg(i) == iam) then
!!$        ! this point belongs to me
!!$        nl = nl + 1
!!$        idxmap%glob_to_loc(i)  = nl
!!$        idxmap%loc_to_glob(nl) = i
!!$      else
!!$        idxmap%glob_to_loc(i) = -(np+vg(i)+1)
!!$      end if
!!$    end do
!!$    
!!$    call idxmap%set_lr(nl)
!!$    call idxmap%set_lc(nl)
!!$   
!!$  end subroutine list_initvg
!!$

  subroutine list_initvl(idxmap,ictxt,vL,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, vl(:)
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, ix, nl, n, nrt

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if

    nl = size(vl) 
    

    n   = maxval(vl(1:nl))
    nrt = nl
    call psb_sum(ictxt,nrt)
    call psb_max(ictxt,n)


    if (n /= nrt) then 
      write(psb_err_unit,*) 'Size mismatch', n, nrt
      info = -1
      return
    end if
    
    idxmap%global_rows  = n
    idxmap%global_cols  = n

    allocate(idxmap%loc_to_glob(n),idxmap%glob_to_loc(n),stat=info) 
    if (info /= 0)  then
      info = -2
      return
    end if

    idxmap%ictxt        = ictxt
    idxmap%state        = psb_desc_bld_
    call psb_get_mpicomm(ictxt,idxmap%mpic)
    do i=1, n
      idxmap%glob_to_loc(i) = -1
    end do
    
    do i=1, nl 
      ix = vl(i) 
      idxmap%loc_to_glob(i)  = ix
      idxmap%glob_to_loc(ix) = i
    end do
    
    idxmap%local_rows   = nl
    idxmap%local_cols   = nl
    call idxmap%set_state(psb_desc_bld_)
   
  end subroutine list_initvl


  subroutine list_asb(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_list_map), intent(inout) :: idxmap
    integer, intent(out) :: info
    
    integer :: nhal, ictxt, iam, np 
    
    info = 0 
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)

    nhal = idxmap%local_cols
    call psb_realloc(nhal,idxmap%loc_to_glob,info)

    call idxmap%set_state(psb_desc_asb_)
    
  end subroutine list_asb

  function list_get_fmt() result(res)
    implicit none 
    character(len=5) :: res
    res = 'LIST'
  end function list_get_fmt


  subroutine list_clone(idxmap,outmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    implicit none 
    class(psb_list_map), intent(in)    :: idxmap
    class(psb_indx_map), allocatable, intent(out) :: outmap
    integer, intent(out) :: info
    Integer :: err_act
    character(len=20)  :: name='list_clone'
    logical, parameter :: debug=.false.

    info = psb_success_
    call psb_get_erraction(err_act)
    if (allocated(outmap)) then 
      write(0,*) 'Error: should not be allocated on input'
      info = -87
      goto 9999
    end if
    
    allocate(psb_list_map :: outmap, stat=info) 
    if (info /= psb_success_) then 
      info = psb_err_alloc_dealloc_
      call psb_errpush(info,name)
      goto 9999
    end if

    select type (outmap)
    type is (psb_list_map) 
      if (info == psb_success_) then 
        outmap%psb_indx_map = idxmap%psb_indx_map
        outmap%pnt_h        = idxmap%pnt_h
      end if
      if (info == psb_success_)&
           &  call psb_safe_ab_cpy(idxmap%loc_to_glob,outmap%loc_to_glob,info)
      if (info == psb_success_)&
           &  call psb_safe_ab_cpy(idxmap%glob_to_loc,outmap%glob_to_loc,info)
    class default
      ! This should be impossible 
      info = -1
    end select
      
    if (info /= psb_success_) then 
      info = psb_err_from_subroutine_
      call psb_errpush(info,name)
      goto 9999
    end if
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act /= psb_act_ret_) then
      call psb_error()
    end if
    return
  end subroutine list_clone

end module psb_list_map_mod
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
subroutine psb_zilu_fct(a,l,u,d,info,blck)
  
  !
  ! This routine copies and factors "on the fly" from A and BLCK
  ! into L/D/U. 
  !
  !
  use psb_base_mod
  implicit none
  !     .. Scalar Arguments ..
  integer(psb_ipk_), intent(out)                ::     info
  !     .. Array Arguments ..
  type(psb_zspmat_type),intent(in)    :: a
  type(psb_z_csr_sparse_mat),intent(inout) :: l,u
  type(psb_zspmat_type),intent(in), optional, target :: blck
  complex(psb_dpk_), intent(inout)     ::  d(:)
  !     .. Local Scalars ..
  integer(psb_ipk_) ::  l1, l2,m,err_act  
  type(psb_zspmat_type), pointer  :: blck_
  character(len=20)   :: name, ch_err
  name='psb_ilu_fct'
  info = psb_success_
  call psb_erractionsave(err_act)
  !     .. Executable Statements ..
  !

  if (present(blck)) then 
    blck_ => blck
  else
    allocate(blck_,stat=info) 
    if (info /= psb_success_) then 
      call psb_errpush(psb_err_from_subroutine_,name,a_err='Allocate')
      goto 9999      
    end if

    call blck_%csall(izero,izero,info,ione)

  endif

  call psb_zilu_fctint(m,a%get_nrows(),a,blck_%get_nrows(),blck_,&
       & d,l%val,l%ja,l%irp,u%val,u%ja,u%irp,l1,l2,info)
  if(info /= psb_success_) then
     info=psb_err_from_subroutine_
     ch_err='psb_zilu_fctint'
     call psb_errpush(info,name,a_err=ch_err)
     goto 9999
  end if

  call l%set_triangle()
  call l%set_lower()
  call l%set_unit()
  call u%set_triangle()
  call u%set_upper()
  call u%set_unit()
  call l%set_nrows(m)
  call l%set_ncols(m)
  call u%set_nrows(m)
  call u%set_ncols(m)

  if (present(blck)) then 
    blck_ => null() 
  else
    call blck_%free()
    if(info /= psb_success_) then
       info=psb_err_from_subroutine_
       ch_err='psb_sp_free'
       call psb_errpush(info,name,a_err=ch_err)
       goto 9999
    end if
    deallocate(blck_) 
  endif

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
     call psb_error()
     return
  end if
  return

contains
  subroutine psb_zilu_fctint(m,ma,a,mb,b,&
       & d,laspk,lia1,lia2,uaspk,uia1,uia2,l1,l2,info)
    implicit none 

    type(psb_zspmat_type)          :: a,b
    integer(psb_ipk_) :: m,ma,mb,l1,l2,info
    integer(psb_ipk_), dimension(:)          :: lia1,lia2,uia1,uia2
    complex(psb_dpk_), dimension(:) :: laspk,uaspk,d

    integer(psb_ipk_) :: i,j,k,l,low1,low2,kk,jj,ll, irb, ktrw,err_act, nz
    complex(psb_dpk_) :: dia,temp
    integer(psb_ipk_), parameter :: nrb=60
    type(psb_z_coo_sparse_mat) :: trw
    integer(psb_ipk_) :: int_err(5) 
    character(len=20)   :: name, ch_err

    name='psb_zilu_fctint'
    if(psb_get_errstatus() /= 0) return 
    info=psb_success_
    call psb_erractionsave(err_act)
    call trw%allocate(izero,izero,ione)
    if(info /= psb_success_) then
      info=psb_err_from_subroutine_
      ch_err='psb_sp_all'
      call psb_errpush(info,name,a_err=ch_err)
      goto 9999
    end if

    lia2(1) = 1
    uia2(1) = 1
    l1=0
    l2=0
    m = ma+mb

    do i = 1, ma
      d(i) = zzero

      !
      !
      select type(aa => a%a) 
      type is (psb_z_csr_sparse_mat)
        do j = aa%irp(i), aa%irp(i+1) - 1
          k = aa%ja(j)
          !           write(psb_err_unit,*)'KKKKK',k
          if ((k < i).and.(k >= 1)) then
            l1 = l1 + 1
            laspk(l1) = aa%val(j)
            lia1(l1) = k
          else if (k == i) then
            d(i) = aa%val(j)
          else if ((k > i).and.(k <= m)) then
            l2 = l2 + 1
            uaspk(l2) = aa%val(j)
            uia1(l2) = k
          end if
        enddo

      class default

        if ((mod(i,nrb) == 1).or.(nrb == 1)) then 
          irb = min(ma-i+1,nrb)
          call aa%csget(i,i+irb-1,trw,info)
          if(info /= psb_success_) then
            info=psb_err_from_subroutine_
            ch_err='a%csget'
            call psb_errpush(info,name,a_err=ch_err)
            goto 9999
          end if
          nz = trw%get_nzeros()
          ktrw=1
        end if

        do 
          if (ktrw > nz ) exit
          if (trw%ia(ktrw) > i) exit
          k = trw%ja(ktrw)
          if ((k < i).and.(k >= 1)) then
            l1 = l1 + 1
            laspk(l1) = trw%val(ktrw)
            lia1(l1) = k
          else if (k == i) then
            d(i) = trw%val(ktrw)
          else if ((k > i).and.(k <= m)) then
            l2 = l2 + 1
            uaspk(l2) = trw%val(ktrw)
            uia1(l2) = k
          end if
          ktrw = ktrw + 1
        enddo
      end select
!!$

      lia2(i+1) = l1 + 1
      uia2(i+1) = l2 + 1

      dia = d(i)
      do kk = lia2(i), lia2(i+1) - 1
        !     
        !     compute element alo(i,k) of incomplete factorization
        !     
        temp = laspk(kk)
        k = lia1(kk)
        laspk(kk) = temp*d(k)
        !     update the rest of row i using alo(i,k)
        low1 = kk + 1
        low2 = uia2(i)
        updateloop: do  jj = uia2(k), uia2(k+1) - 1
          j = uia1(jj)
          !
          if (j < i) then
            !     search alo(i,*) for matching index J
            do  ll = low1, lia2(i+1) - 1
              l = lia1(ll)
              if (l > j) then
                low1 = ll
                exit
              else if (l == j) then
                laspk(ll) = laspk(ll) - temp*uaspk(jj)
                low1 = ll + 1
                cycle updateloop
              end if
            enddo
            !     
          else if (j == i) then
            !    j=i  update diagonal
            !    write(psb_err_unit,*)'aggiorno dia',dia,'temp',temp,'jj',jj,'u%aspk',uaspk(jj)
            dia = dia - temp*uaspk(jj)
            !    write(psb_err_unit,*)'dia',dia,'temp',temp,'jj',jj,'aspk',uaspk(jj)
            cycle updateloop
            !     
          else if (j > i) then
            !     search aup(i,*) for matching index j
            do ll = low2, uia2(i+1) - 1
              l = uia1(ll)
              if (l > j) then
                low2 = ll
                exit
              else if (l == j) then
                uaspk(ll) = uaspk(ll) - temp*uaspk(jj)
                low2 = ll + 1
                cycle updateloop
              end if
            enddo
          end if
          !     
          !     for milu al=1.;  for ilu al=0.
          !     al = 1.d0
          !     dia = dia - al*temp*aup(jj)
        enddo updateloop
      enddo
      !    
      !     
      !     Non singularity
      !     
      if (abs(dia) < d_epstol) then
        !
        !     Pivot too small: unstable factorization
        !     
        info = psb_err_pivot_too_small_
        int_err(1) = i
        write(ch_err,'(g20.10)') abs(dia)
        call psb_errpush(info,name,i_err=int_err,a_err=ch_err)
        goto 9999
      else
        dia = zone/dia
      end if
      d(i) = dia
      ! write(psb_err_unit,*)'diag(',i,')=',d(i)
      !     Scale row i of upper triangle
      do  kk = uia2(i), uia2(i+1) - 1
        uaspk(kk) = uaspk(kk)*dia
      enddo
    enddo

    do i = ma+1, m
      d(i) = zzero

      select type(aa => b%a) 
      type is (psb_z_csr_sparse_mat)
        do j = aa%irp(i-ma), aa%irp(i-ma+1) - 1
          k = aa%ja(j)
          !           write(psb_err_unit,*)'KKKKK',k
          if ((k < i).and.(k >= 1)) then
            l1 = l1 + 1
            laspk(l1) = aa%val(j)
            lia1(l1) = k
          else if (k == i) then
            d(i) = aa%val(j)
          else if ((k > i).and.(k <= m)) then
            l2 = l2 + 1
            uaspk(l2) = aa%val(j)
            uia1(l2) = k
          end if
        enddo

      class default

        if ((mod(i,nrb) == 1).or.(nrb == 1)) then 
          irb = min(ma-i+1,nrb)
          call aa%csget(i-ma,i-ma+irb-1,trw,info)
          nz = trw%get_nzeros()
          if(info /= psb_success_) then
            info=psb_err_from_subroutine_
            ch_err='a%csget'
            call psb_errpush(info,name,a_err=ch_err)
            goto 9999
          end if
          ktrw=1
        end if

        do 
          if (ktrw > nz ) exit
          if (trw%ia(ktrw) > i) exit
          k = trw%ja(ktrw)
          if ((k < i).and.(k >= 1)) then
            l1 = l1 + 1
            laspk(l1) = trw%val(ktrw)
            lia1(l1) = k
          else if (k == i) then
            d(i) = trw%val(ktrw)
          else if ((k > i).and.(k <= m)) then
            l2 = l2 + 1
            uaspk(l2) = trw%val(ktrw)
            uia1(l2) = k
          end if
          ktrw = ktrw + 1
        enddo
      end select


      lia2(i+1) = l1 + 1
      uia2(i+1) = l2 + 1

      dia = d(i)
      do kk = lia2(i), lia2(i+1) - 1
        !     
        !     compute element alo(i,k) of incomplete factorization
        !     
        temp = laspk(kk)
        k = lia1(kk)
        laspk(kk) = temp*d(k)
        !     update the rest of row i using alo(i,k)
        low1 = kk + 1
        low2 = uia2(i)
        updateloopb: do  jj = uia2(k), uia2(k+1) - 1
          j = uia1(jj)
          !
          if (j < i) then
            !     search alo(i,*) for matching index J
            do  ll = low1, lia2(i+1) - 1
              l = lia1(ll)
              if (l > j) then
                low1 = ll
                exit
              else if (l == j) then
                laspk(ll) = laspk(ll) - temp*uaspk(jj)
                low1 = ll + 1
                cycle updateloopb
              end if
            enddo
            !     
          else if (j == i) then
            !   j=i  update diagonal
            dia = dia - temp*uaspk(jj)
            cycle updateloopb
            !     
          else if (j > i) then
            !    search aup(i,*) for matching index j
            do ll = low2, uia2(i+1) - 1
              l = uia1(ll)
              if (l > j) then
                low2 = ll
                exit
              else if (l == j) then
                uaspk(ll) = uaspk(ll) - temp*uaspk(jj)
                low2 = ll + 1
                cycle updateloopb
              end if
            enddo
          end if
          !     
          !     for milu al=1.;  for ilu al=0.
          !     al = 1.d0
          !     dia = dia - al*temp*aup(jj)
        enddo updateloopb
      enddo
      !     
      !     
      !     Non singularity
      !     
      if (abs(dia) < d_epstol) then
        !
        !     Pivot too small: unstable factorization
        !     
        int_err(1) = i
        write(ch_err,'(g20.10)') abs(dia)
        info = psb_err_pivot_too_small_
        call psb_errpush(info,name,i_err=int_err,a_err=ch_err)
        goto 9999
      else
        dia = zone/dia
      end if
      d(i) = dia
      !     Scale row i of upper triangle
      do  kk = uia2(i), uia2(i+1) - 1
        uaspk(kk) = uaspk(kk)*dia
      enddo
    enddo

    call trw%free()

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_zilu_fctint
end subroutine psb_zilu_fct

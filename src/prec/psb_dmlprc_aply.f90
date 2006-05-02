!!$ 
!!$ 
!!$                    MD2P4
!!$    Multilevel Domain Decomposition Parallel Preconditioner Package for PSBLAS
!!$                      for 
!!$              Parallel Sparse BLAS  v2.0
!!$    (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
!!$                       Daniela Di Serafino    II University of Naples
!!$                       Pasqua D'Ambra         ICAR-CNR                      
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the MD2P4 group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE MD2P4 GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$  
subroutine psb_dmlprc_aply(baseprecv,x,beta,y,desc_data,trans,work,info)
  !
  !  Compute   Y <-  beta*Y + K^-1 X 
  !  where K is a multilevel (actually 2-level) preconditioner stored in prec
  ! 

  use psb_serial_mod
  use psb_descriptor_type
  use psb_prec_type
  use psb_psblas_mod
  use psb_blacs_mod
  use psb_const_mod
  use psb_error_mod
  implicit none

  type(psb_desc_type),intent(in)      :: desc_data
  type(psb_dbaseprc_type), intent(in) :: baseprecv(:)
  real(kind(0.d0)),intent(in)         :: beta
  real(kind(0.d0)),intent(inout)      :: x(:), y(:)
  character                           :: trans
  real(kind(0.d0)),target             :: work(:)
  integer, intent(out)                :: info


  ! Local variables
  integer :: n_row,n_col
  real(kind(1.d0)), allocatable :: tx(:),ty(:),t2l(:),w2l(:),&
       &   x2l(:),b2l(:),tz(:),tty(:)
  character     ::diagl, diagu
  integer :: icontxt,nprow,npcol,me,mycol,i, isz, nrg,nr2l,err_act, iptype, int_err(5)
  real(kind(1.d0)) :: omega
  real(kind(1.d0)) :: t1, t2, t3, t4, t5, t6, t7, mpi_wtime
  logical, parameter          :: debug=.false., debugprt=.false.
  integer      :: ismth
  external mpi_wtime
  character(len=20)   :: name, ch_err

  interface psb_baseprc_aply
     subroutine psb_dbaseprc_aply(prec,x,beta,y,desc_data,trans,work,info)
       use psb_descriptor_type
       use psb_prec_type
       type(psb_desc_type),intent(in)      :: desc_data
       type(psb_dbaseprc_type), intent(in) :: prec
       real(kind(0.d0)),intent(inout)      :: x(:), y(:)
       real(kind(0.d0)),intent(in)         :: beta
       character(len=1)                    :: trans
       real(kind(0.d0)),target             :: work(:)
       integer, intent(out)                :: info
     end subroutine psb_dbaseprc_aply
  end interface

  name='psb_dmlprc_aply'
  info = 0
  call psb_erractionsave(err_act)


  icontxt=desc_data%matrix_data(psb_ctxt_)
  call blacs_gridinfo(icontxt,nprow,npcol,me,mycol)

  omega=baseprecv(2)%dprcparm(smooth_omega_)
  ismth=baseprecv(2)%iprcparm(smth_kind_)

  select case(baseprecv(2)%iprcparm(ml_type_)) 
  case(no_ml_) 
    ! Should not really get here.
    write(0,*) 'Smooth preconditioner with no multilevel in MLPRC_APLY????' 

  case(add_ml_prec_)

    ! 
    !  Additive multilevel
    !
    t1 = mpi_wtime()
    n_row = desc_data%matrix_data(psb_n_row_)
    n_col = baseprecv(1)%desc_data%matrix_data(psb_n_col_)
    call psb_baseprc_aply(baseprecv(1),x,beta,y,desc_data,trans,work,info)
    if(info /=0) goto 9999

    nr2l  = baseprecv(2)%desc_data%matrix_data(psb_n_col_)
    nrg   = baseprecv(2)%desc_data%matrix_data(psb_n_row_)
    allocate(t2l(nr2l),w2l(nr2l),stat=info)
    if (info /= 0) then 
      call psb_errpush(4010,name,a_err='Allocate')
      goto 9999      
    end if

    t2l(:) = dzero
    w2l(:) = dzero

    if (ismth  /= no_smth_) then 
      !
      ! Smoothed aggregation
      !
      allocate(tx(max(n_row,n_col)),ty(max(n_row,n_col)),&
           & tz(max(n_row,n_col)),stat=info)
      if (info /= 0) then 
        call psb_errpush(4010,name,a_err='Allocate')
        goto 9999      
      end if

      tx(1:desc_data%matrix_data(psb_n_row_)) = x(1:desc_data%matrix_data(psb_n_row_)) 
      tx(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
      ty(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
      tz(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero


      if (baseprecv(2)%iprcparm(glb_smth_) >0) then 
        call psb_halo(tx,desc_data,info,work=work) 
        if(info /=0) goto 9999
      else
        tx(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
      end if

      call psb_csmm(done,baseprecv(2)%av(sm_pr_t_),tx,dzero,t2l,info)
      if(info /=0) goto 9999

    else
      !
      ! Raw  aggregation, may take shortcut
      !
      do i=1,desc_data%matrix_data(psb_n_row_)
        t2l(baseprecv(2)%mlia(i)) = t2l(baseprecv(2)%mlia(i)) + x(i)
      end do

    end if

    if (baseprecv(2)%iprcparm(coarse_mat_)==mat_repl_) Then 
      call gsum2d(icontxt,'All',t2l(1:nrg))
    else if (baseprecv(2)%iprcparm(coarse_mat_) /= mat_distr_) Then 
        write(0,*) 'Unknown value for baseprecv(2)%iprcparm(coarse_mat_) ',&
             & baseprecv(2)%iprcparm(coarse_mat_)
    endif

    w2l=t2l
    call psb_baseprc_aply(baseprecv(2),w2l,dzero,t2l,baseprecv(2)%desc_data,&
         & 'N',work,info)


    if (ismth  /= no_smth_) then 

      call psb_csmm(done,baseprecv(2)%av(sm_pr_),t2l,dzero,ty,info)
      if(info /=0) goto 9999
      ! 
      ! Finally add back into Y. 
      ! 
      call psb_geaxpby(done,ty,done,y,desc_data,info)
      if(info /=0) goto 9999
      deallocate(tx,ty,tz)

    else

      do i=1, desc_data%matrix_data(psb_n_row_)
        y(i) = y(i) + t2l(baseprecv(2)%mlia(i))
      enddo

    end if

    if (debugprt) write(0,*)' Y2: ',Y(:)

    deallocate(t2l,w2l)

  case(mult_ml_prec_)

    ! 
    !  Multiplicative multilevel
    !  Pre/post smoothing versions. 

    select case(baseprecv(2)%iprcparm(smth_pos_))

    case(post_smooth_)


      t1    = mpi_wtime()
      n_row = desc_data%matrix_data(psb_n_row_)
      n_col = baseprecv(1)%desc_data%matrix_data(psb_n_col_)
      nr2l  = baseprecv(2)%desc_data%matrix_data(psb_n_col_)
      nrg   = baseprecv(2)%desc_data%matrix_data(psb_n_row_)
      allocate(t2l(nr2l),w2l(nr2l),tx(n_col),ty(n_col),stat=info)
      if (info /= 0) then 
        call psb_errpush(4010,name,a_err='Allocate')
        goto 9999      
      end if

      t2l(:) = dzero
      w2l(:) = dzero

      !
      ! Need temp copies to handle Y<- betaY + K^-1 X
      ! One of the temp copies is not strictly needed when beta==dzero
      !

      if (debug) write(0,*)' mult_ml_apply  omega ',omega
      if (debugprt) write(0,*)' mult_ml_apply  X: ',X(:)
      call psb_geaxpby(done,x,dzero,tx,desc_data,info)
      if(info /=0) then 
        if (debug) write(0,*)' From axpby1 ',size(x),size(tx),n_row,n_col,nr2l,nrg
        call psb_errpush(4010,name,a_err='axpby post_smooth 1')
        goto 9999
      endif
      if (ismth  /= no_smth_) then 
        !
        ! Smoothed aggregation
        !
        allocate(tz(max(n_row,n_col)),stat=info)
        if (info /= 0) then 
          call psb_errpush(4010,name,a_err='Allocate')
          goto 9999      
        end if


        if (baseprecv(2)%iprcparm(glb_smth_) >0) then 
          call psb_halo(tx,desc_data,info,work=work) 
          if(info /=0) goto 9999
        else
          tx(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
        end if

        call psb_csmm(done,baseprecv(2)%av(sm_pr_t_),tx,dzero,t2l,info)
        if(info /=0) goto 9999

      else
        !
        ! Raw  aggregation, may take shortcut
        !
        do i=1,desc_data%matrix_data(psb_n_row_)
          t2l(baseprecv(2)%mlia(i)) = t2l(baseprecv(2)%mlia(i)) + tx(i)
        end do
      end if

      if (baseprecv(2)%iprcparm(coarse_mat_)==mat_repl_) Then 
        call gsum2d(icontxt,'All',t2l(1:nrg))
      else if (baseprecv(2)%iprcparm(coarse_mat_) /= mat_distr_) Then 
        write(0,*) 'Unknown value for baseprecv(2)%iprcparm(coarse_mat_) ',&
             & baseprecv(2)%iprcparm(coarse_mat_)
      endif

      t6 = mpi_wtime()
      w2l=t2l
      call psb_baseprc_aply(baseprecv(2),w2l,dzero,t2l,baseprecv(2)%desc_data,&
           &'N',work,info)
      if(info /=0) goto 9999

      if (ismth  /= no_smth_) then 
        if (ismth == smth_omg_) &
             & call psb_halo(t2l,baseprecv(2)%desc_data,info,work=work) 
        call psb_csmm(done,baseprecv(2)%av(sm_pr_),t2l,dzero,ty,info)
        if(info /=0) goto 9999
        ! 
        ! Finally add back into Y. 
        ! 
        deallocate(tz)
      else
        ty(:) = dzero
        do i=1, desc_data%matrix_data(psb_n_row_)
          ty(i) = ty(i) + t2l(baseprecv(2)%mlia(i))
        enddo

      end if
      deallocate(t2l,w2l)

      call psb_spmm(-done,baseprecv(2)%aorig,ty,done,tx,desc_data,info,work=work)
      if(info /=0) goto 9999

      call psb_baseprc_aply(baseprecv(1),tx,done,ty,desc_data,trans,&
           & work,info)
      if(info /=0) goto 9999

      call psb_geaxpby(done,ty,beta,y,desc_data,info)
      if(info /=0) goto 9999

      deallocate(tx,ty)



    case(pre_smooth_)

      t1 = mpi_wtime()
      n_row = desc_data%matrix_data(psb_n_row_)
      n_col = baseprecv(1)%desc_data%matrix_data(psb_n_col_)
      nr2l  = baseprecv(2)%desc_data%matrix_data(psb_n_col_)
      nrg   = baseprecv(2)%desc_data%matrix_data(psb_n_row_)
      allocate(t2l(nr2l),w2l(nr2l),tx(n_col),ty(n_col),tty(n_col),stat=info)
      if (info /= 0) then 
        call psb_errpush(4010,name,a_err='Allocate')
        goto 9999      
      end if

      t2l(:) = dzero
      w2l(:) = dzero

      !
      ! Need temp copies to handle Y<- betaY + K^-1 X
      ! One of the temp copies is not strictly needed when beta==zero
      !
      call psb_geaxpby(done,x,dzero,tx,desc_data,info)
      call psb_geaxpby(done,y,dzero,ty,desc_data,info)
      if(info /=0) goto 9999

      call psb_baseprc_aply(baseprecv(1),x,dzero,tty,desc_data,&
           &  trans,work,info)
      if(info /=0) goto 9999

      call psb_spmm(-done,baseprecv(2)%aorig,tty,done,tx,desc_data,info,work=work)
      if(info /=0) goto 9999

      if (ismth  /= no_smth_) then 
        allocate(tz(max(n_row,n_col)),stat=info)
        if (info /= 0) then 
          call psb_errpush(4010,name,a_err='Allocate')
          goto 9999      
        end if


        if (baseprecv(2)%iprcparm(glb_smth_) >0) then 
          call psb_halo(tx,desc_data,info,work=work) 
          if(info /=0) goto 9999
        else
          tx(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
        end if

        call psb_csmm(done,baseprecv(2)%av(sm_pr_t_),tx,dzero,t2l,info)
        if(info /=0) goto 9999

      else
        !
        ! Raw  aggregation, may take shortcuts
        !
        do i=1,desc_data%matrix_data(psb_n_row_)
          t2l(baseprecv(2)%mlia(i)) = t2l(baseprecv(2)%mlia(i)) + tx(i)
        end do
      end if

      if (baseprecv(2)%iprcparm(coarse_mat_)==mat_repl_) Then 
        call gsum2d(icontxt,'All',t2l(1:nrg))
      else if (baseprecv(2)%iprcparm(coarse_mat_) /= mat_distr_) Then 
        write(0,*) 'Unknown value for baseprecv(2)%iprcparm(coarse_mat_) ',&
             & baseprecv(2)%iprcparm(coarse_mat_)
      endif

      t6 = mpi_wtime()
      w2l=t2l
      call psb_baseprc_aply(baseprecv(2),w2l,dzero,t2l,baseprecv(2)%desc_data,&
           &  'N',work,info)
      if(info /=0) goto 9999

      if (ismth  /= no_smth_) then 

        if (ismth == smth_omg_) &
             & call psb_halo(t2l,baseprecv(2)%desc_data,info,work=work) 
        call psb_csmm(done,baseprecv(2)%av(sm_pr_),t2l,dzero,ty,info)
        if(info /=0) goto 9999

        call psb_geaxpby(done,ty,done,tty,desc_data,info)
        if(info /=0) goto 9999

        deallocate(tz)
      else

        do i=1, desc_data%matrix_data(psb_n_row_)
          tty(i) = tty(i) + t2l(baseprecv(2)%mlia(i))
        enddo

      end if

      call psb_geaxpby(done,tty,beta,y,desc_data,info)
      if(info /=0) goto 9999

      deallocate(t2l,w2l,tx,ty,tty)


    case(smooth_both_)

      t1 = mpi_wtime()
      n_row = desc_data%matrix_data(psb_n_row_)
      n_col = baseprecv(1)%desc_data%matrix_data(psb_n_col_)
      nr2l  = baseprecv(2)%desc_data%matrix_data(psb_n_col_)
      nrg   = baseprecv(2)%desc_data%matrix_data(psb_n_row_)
      allocate(t2l(nr2l),w2l(nr2l),tx(n_col),ty(n_col),tty(n_col),stat=info)
      if (info /= 0) then 
        call psb_errpush(4010,name,a_err='Allocate')
        goto 9999      
      end if

      t2l(:) = dzero
      w2l(:) = dzero
      tx(:)  = dzero
      ty(:)  = dzero
      tty(:) = dzero

      !
      ! Need temp copies to handle Y<- betaY + K^-1 X
      ! One of the temp copies is not strictly needed when beta==zero
      !
      call psb_geaxpby(done,x,dzero,tx,desc_data,info)
      call psb_geaxpby(done,y,dzero,ty,desc_data,info)
      if(info /=0) goto 9999

      call psb_baseprc_aply(baseprecv(1),tx,dzero,tty,desc_data,trans,work,info)
      if(info /=0) goto 9999

      call psb_spmm(-done,baseprecv(2)%aorig,tty,done,tx,desc_data,info,work=work)
      if(info /=0) goto 9999

      if (ismth  /= no_smth_) then 
        if (baseprecv(2)%iprcparm(glb_smth_) >0) then 
          call psb_halo(tx,baseprecv(1)%desc_data,info,work=work) 
          if(info /=0) goto 9999
        else
          tx(desc_data%matrix_data(psb_n_row_)+1:max(n_row,n_col)) = dzero
        end if

        call psb_csmm(done,baseprecv(2)%av(sm_pr_t_),tx,dzero,t2l,info)
        if(info /=0) goto 9999
      else
        !
        ! Raw  aggregation, may take shortcuts
        !
        do i=1,desc_data%matrix_data(psb_n_row_)
          t2l(baseprecv(2)%mlia(i)) = t2l(baseprecv(2)%mlia(i)) + tx(i)
        end do
      end if


      if (baseprecv(2)%iprcparm(coarse_mat_)==mat_repl_) Then 
        call gsum2d(icontxt,'All',t2l(1:nrg))
      else if (baseprecv(2)%iprcparm(coarse_mat_) /= mat_distr_) Then 
        write(0,*) 'Unknown value for baseprecv(2)%iprcparm(coarse_mat_) ',&
             & baseprecv(2)%iprcparm(coarse_mat_)
      endif


      t6 = mpi_wtime()
      w2l=t2l
      call psb_baseprc_aply(baseprecv(2),w2l,dzero,t2l,baseprecv(2)%desc_data,&
           &  'N',work,info)
      if(info /=0) goto 9999

      if (ismth  /= no_smth_) then 

        if (ismth == smth_omg_) &
             & call psb_halo(t2l,baseprecv(2)%desc_data,info,work=work) 
        call psb_csmm(done,baseprecv(2)%av(sm_pr_),t2l,dzero,ty,info)
        if(info /=0) goto 9999

        call psb_geaxpby(done,ty,done,tty,desc_data,info)
        if(info /=0) goto 9999

      else

        do i=1, desc_data%matrix_data(psb_n_row_)
          tty(i) = tty(i) + t2l(baseprecv(2)%mlia(i))
        enddo

      end if
      
      call psb_geaxpby(done,x,dzero,tx,desc_data,info)
      if(info /=0) goto 9999

      call psb_spmm(-done,baseprecv(2)%aorig,tty,done,tx,desc_data,info,work=work)
      if(info /=0) goto 9999
      call psb_baseprc_aply(baseprecv(1),tx,done,tty,desc_data,'N',work,info)


      call psb_geaxpby(done,tty,beta,y,desc_data,info)
      
      deallocate(t2l,w2l,tx,ty,tty)


    case default

      write(0,*) 'Unknown value for ml_smooth_pos',baseprecv(2)%iprcparm(smth_pos_)

    end select

  case default
    write(0,*) me, 'Wrong mltype into PRC_APLY ',&
         & baseprecv(2)%iprcparm(ml_type_)
  end select

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_errpush(info,name)
  call psb_erractionrestore(err_act)
  if (err_act.eq.act_abort) then
    call psb_error()
    return
  end if
  return

end subroutine psb_dmlprc_aply
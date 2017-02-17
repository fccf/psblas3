module psb_cpenv_mod
  use iso_c_binding
  use psb_objhandle_mod
  
contains
  
  function psb_c_get_errstatus() bind(c) result(res)
    use psb_base_mod, only : psb_get_errstatus
    implicit none 
    
    integer(c_int)  :: res
    
    res = psb_get_errstatus()
  end function psb_c_get_errstatus

  function psb_c_init() bind(c)
    use psb_base_mod, only : psb_init
    implicit none 
    
    integer(c_int)  :: psb_c_init
    
    integer :: ictxt

    call psb_init(ictxt)
    psb_c_init = ictxt
  end function psb_c_init
  
  subroutine psb_c_exit_ctxt(ictxt) bind(c)
    use psb_base_mod, only : psb_exit
    integer(c_int), value :: ictxt
    
    call psb_exit(ictxt,close=.false.)
    return
  end subroutine psb_c_exit_ctxt
  
  subroutine psb_c_exit(ictxt) bind(c)
    use psb_base_mod, only : psb_exit
    integer(c_int), value :: ictxt
    
    call psb_exit(ictxt)
    return
  end subroutine psb_c_exit
  
  subroutine psb_c_abort(ictxt) bind(c)
    use psb_base_mod, only : psb_abort
    integer(c_int), value :: ictxt
    
    call psb_abort(ictxt)
    return
  end subroutine psb_c_abort
  

  subroutine psb_c_info(ictxt,iam,np) bind(c)
    use psb_base_mod, only : psb_info
    integer(c_int), value :: ictxt
    integer(c_int)        :: iam,np
    
    call psb_info(ictxt,iam,np)
    return
  end subroutine psb_c_info
  
  subroutine psb_c_barrier(ictxt) bind(c)
    use psb_base_mod, only : psb_barrier
    integer(c_int), value :: ictxt

    call psb_barrier(ictxt)
  end subroutine psb_c_barrier
  
  real(c_double) function psb_c_wtime() bind(c)
    use psb_base_mod, only : psb_wtime
    
    psb_c_wtime = psb_wtime()
  end function psb_c_wtime

  subroutine psb_c_ibcast(ictxt,n,v,root) bind(c)
    use psb_base_mod, only : psb_bcast
    implicit none 
    integer(c_int), value :: ictxt,n, root
    integer(c_int)        :: v(*) 
    
    if (n < 0) then 
      write(0,*) 'Wrong size in BCAST'
      return
    end if
    if (n==0) return 
    
    call psb_bcast(ictxt,v(1:n),root=root)
  end subroutine psb_c_ibcast

  subroutine psb_c_dbcast(ictxt,n,v,root) bind(c)
    use psb_base_mod, only : psb_bcast
    implicit none 
    integer(c_int), value :: ictxt,n, root
    real(c_double)        :: v(*) 
    
    if (n < 0) then 
      write(0,*) 'Wrong size in BCAST'
      return
    end if
    if (n==0) return 
    
    call psb_bcast(ictxt,v(1:n),root=root)
  end subroutine psb_c_dbcast

  subroutine psb_c_hbcast(ictxt,v,root) bind(c)
    use psb_base_mod, only : psb_bcast, psb_info
    implicit none 
    integer(c_int), value :: ictxt, root
    character(c_char)     :: v(*) 
    integer :: n, iam, np
    
    call psb_info(ictxt,iam,np)
    
    if (iam==root) then 
      n = 1 
      do 
        if (v(n) == c_null_char) exit
        n = n + 1
      end do
    end if
    call psb_bcast(ictxt,n,root=root)
    call psb_bcast(ictxt,v(1:n),root=root)
  end subroutine psb_c_hbcast

  function psb_c_f2c_errmsg(cmesg,len) bind(c) result(res)
    use psb_base_mod, only : psb_errpop,psb_max_errmsg_len_
    use psb_base_string_cbind_mod
    implicit none 
    character(c_char), intent(inout)  :: cmesg(*)
    integer(c_int), intent(in), value :: len
    integer(c_int) :: res
    character(len=psb_max_errmsg_len_), allocatable :: fmesg(:)
    character(len=psb_max_errmsg_len_) :: tmp
    integer :: i, j, ll, il

    res = 0
    call psb_errpop(fmesg)
    ll = 1
    if (allocated(fmesg)) then 
      res = size(fmesg) 
      do i=1, size(fmesg)
        tmp = fmesg(i)
        il = len_trim(tmp)
        il = min(il,len-ll)      
        !write(0,*) 'loop f2c_errmsg: ', ll,il          
        call stringf2c(tmp(1:il),cmesg(ll:ll+il))
        cmesg(ll+il)=c_new_line
        ll = ll+il+1
      end do
      !write(0,*) 'From f2c_errmsg: ', ll,len
    end if
    cmesg(ll) = c_null_char
  end function psb_c_f2c_errmsg

  subroutine psb_c_seterraction_ret() bind(c)
    use psb_base_mod, only : psb_set_erraction, psb_act_ret_
    call psb_set_erraction(psb_act_ret_)
  end subroutine psb_c_seterraction_ret

  subroutine psb_c_seterraction_print() bind(c)
    use psb_base_mod, only : psb_set_erraction, psb_act_print_
    call psb_set_erraction(psb_act_print_)
  end subroutine psb_c_seterraction_print

  subroutine psb_c_seterraction_abort() bind(c)
    use psb_base_mod, only : psb_set_erraction, psb_act_abort_
    call psb_set_erraction(psb_act_abort_)
  end subroutine psb_c_seterraction_abort
    

end module psb_cpenv_mod
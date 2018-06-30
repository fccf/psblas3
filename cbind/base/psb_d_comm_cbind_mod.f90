module psb_d_comm_cbind_mod
  use iso_c_binding
  use psb_base_mod
  use psb_objhandle_mod
  use psb_base_string_cbind_mod
  
contains

  function psb_c_d_ovrl(xh,cdh) bind(c) result(res)
    implicit none 
    integer(psb_c_ipk) :: res

    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: xp
    integer(psb_c_ipk)               :: info
    

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,xp)
    else
      return 
    end if

    call psb_ovrl(xp,descp,info)

    res = info

  end function psb_c_d_ovrl
 
  function psb_c_d_ovrl_opt(xh,cdh,update,mode) bind(c) result(res)
    implicit none 
    integer(psb_c_ipk) :: res
    integer(psb_c_ipk), value :: update, mode

    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: xp
    integer(psb_c_ipk)               :: info
    

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,xp)
    else
      return 
    end if

    call psb_ovrl(xp,descp,info,update=update,mode=mode)

    res = info

  end function psb_c_d_ovrl_opt

 
  function psb_c_d_halo(xh,cdh) bind(c) result(res)
    implicit none 
    integer(psb_c_ipk) :: res

    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: xp
    integer(psb_c_ipk)               :: info
    

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,xp)
    else
      return 
    end if

    call psb_halo(xp,descp,info)

    res = info

  end function psb_c_d_halo
 
  function psb_c_d_halo_opt(xh,cdh,tran,data,mode) bind(c) result(res)
    implicit none 
    integer(psb_c_ipk) :: res
    integer(psb_c_ipk), value :: data, mode
    character(c_char)      :: tran
        

    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: xp
    character :: ftran
    integer(psb_c_ipk)               :: info
    

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,xp)
    else
      return 
    end if

    ftran  = tran
    call psb_halo(xp,descp,info,data=data,mode=mode,tran=ftran)

    res = info
    
  end function psb_c_d_halo_opt

  
  function psb_c_d_vscatter(ng,gx,xh,cdh) bind(c) result(res)
    implicit none 

    integer(psb_c_ipk)    :: res
    integer(psb_c_lpk), value :: ng
    real(c_double), target :: gx(*)
    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: vp
    real(psb_dpk_), pointer :: pgx(:)
    integer(psb_c_ipk)       :: info, sz

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,vp)
    else
      return 
    end if
    
    pgx => gx(1:ng)
    
    call psb_scatter(pgx,vp,descp,info)
    res = info 

  end function psb_c_d_vscatter
  
  function psb_c_dvgather(v,xh,cdh) bind(c) result(res)
    implicit none 

    integer(psb_c_ipk)    :: res   
    real(c_double), target :: v(*)
    type(psb_c_dvector) :: xh
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_d_vect_type), pointer :: vp
    real(psb_dpk_), allocatable :: fv(:)
    integer(psb_c_ipk)           :: info, sz

    res = -1

    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(xh%item)) then 
      call c_f_pointer(xh%item,vp)
    else
      return
    end if

    call psb_gather(fv,vp,descp,info)
    res = info 
    if (res /=0) return          
    sz = size(fv)
    v(1:sz) = fv(1:sz)
  end function psb_c_dvgather
    
  function psb_c_dspgather(gah,ah,cdh) bind(c) result(res)
    implicit none 

    integer(psb_c_ipk)    :: res   
    type(psb_c_dspmat)   :: ah, gah
    type(psb_c_descriptor) :: cdh
    
    type(psb_desc_type), pointer :: descp
    type(psb_dspmat_type), pointer :: ap, gap
    integer(psb_c_ipk)               :: info, sz

    res = -1
    if (c_associated(cdh%item)) then 
      call c_f_pointer(cdh%item,descp)
    else
      return 
    end if
    if (c_associated(ah%item)) then 
      call c_f_pointer(ah%item,ap)
    else
      return 
    end if
    if (c_associated(gah%item)) then 
      call c_f_pointer(gah%item,gap)
    else
      return 
    end if
    call psb_gather(gap,ap,descp,info)
    res = info 
  end function psb_c_dspgather
     
end module psb_d_comm_cbind_mod

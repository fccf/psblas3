module psb_vect_mod
  use psb_i_vect_mod
  use psb_l_vect_mod  
  use psb_s_vect_mod
  use psb_d_vect_mod
  use psb_c_vect_mod
  use psb_z_vect_mod
  use psb_i_multivect_mod
  use psb_l_multivect_mod
  use psb_s_multivect_mod
  use psb_d_multivect_mod
  use psb_c_multivect_mod
  use psb_z_multivect_mod

contains

  subroutine psb_init_vect_defaults()
    implicit none
    !
    ! Defaults for vectors 
    !

    type(psb_i_base_vect_type)  :: ivetdef
    type(psb_s_base_vect_type)  :: svetdef
    type(psb_d_base_vect_type)  :: dvetdef
    type(psb_c_base_vect_type)  :: cvetdef
    type(psb_z_base_vect_type)  :: zvetdef

    call psb_set_vect_default(ivetdef)
    call psb_set_vect_default(svetdef)
    call psb_set_vect_default(dvetdef)
    call psb_set_vect_default(cvetdef)
    call psb_set_vect_default(zvetdef)

  end subroutine psb_init_vect_defaults

end module psb_vect_mod

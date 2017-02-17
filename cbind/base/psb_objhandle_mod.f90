module psb_objhandle_mod
  use iso_c_binding
  
  type, bind(c) :: psb_c_object_type
    type(c_ptr) :: item = c_null_ptr
  end type psb_c_object_type
    
  type, bind(c) :: psb_c_descriptor
    type(c_ptr) :: item = c_null_ptr
  end type psb_c_descriptor
  
  type, bind(c) :: psb_c_dvector
    type(c_ptr) :: item = c_null_ptr
  end type psb_c_dvector

  type, bind(c) :: psb_c_dspmat
    type(c_ptr) :: item = c_null_ptr
  end type psb_c_dspmat
  
end module psb_objhandle_mod
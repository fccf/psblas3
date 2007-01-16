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
Module getp
  use psb_base_mod
  public get_parms
  public pr_usage

contains
  !
  ! Get iteration parameters from the command line
  !
  subroutine  get_parms(ictxt,mtrx_file,rhs_file,cmethd,ipart,&
       & afmt,istopc,itmax,itrace,novr,iprec,eps)
    integer      :: ictxt
    character*40 :: cmethd, mtrx_file, rhs_file
    integer      :: iret, istopc,itmax,itrace,ipart,iprec,novr
    character*40 :: charbuf
    real(kind(1.d0)) :: eps
    character    :: afmt*5
    integer      :: np, iam
    integer      :: inparms(40), ip 

    call psb_info(ictxt,iam,np)
    if (iam==0) then
      ! Read Input Parameters
      read(*,*) ip
      if (ip >= 3) then
        read(*,*) mtrx_file
        read(*,*) rhs_file
        read(*,*) cmethd
        read(*,*) afmt


        call psb_bcast(ictxt,mtrx_file)
        call psb_bcast(ictxt,rhs_file)
        call psb_bcast(ictxt,cmethd)
        call psb_bcast(ictxt,afmt)

        read(*,*) ipart
        if (ip >= 5) then
          read(*,*) istopc
        else
          istopc=1        
        endif
        if (ip >= 6) then
          read(*,*) itmax
        else
          itmax=500
        endif
        if (ip >= 7) then
          read(*,*) itrace
        else
          itrace=-1
        endif
        if (ip >= 8) then
          read(*,*) iprec
        else
          iprec=0
        endif
        if (ip >= 9) then
          read(*,*) novr
        else
          novr  = 1
        endif
        if (ip >= 10) then
          read(*,*) eps
        else
          eps=1.d-6
        endif
        inparms(1) = ipart
        inparms(2) = istopc
        inparms(3) = itmax
        inparms(4) = itrace
        inparms(5) = iprec
        inparms(6) = novr
        call psb_bcast(ictxt,inparms(1:6))
        call psb_bcast(ictxt,eps)

        write(*,'("Solving matrix       : ",a40)') mtrx_file      
        write(*,'("Number of processors : ",i3)')  np
        write(*,'("Data distribution    : ",i2)')  ipart
        write(*,'("Preconditioner       : ",i2)')  iprec
        if(iprec.gt.2) write(*,'("Overlapping levels   : ",i2)')novr
        write(*,'("Iterative method     : ",a40)') cmethd
        write(*,'("Storage format       : ",a3)')  afmt(1:3)
        write(*,'(" ")')
      else
        call pr_usage(0)
        call psb_exit(ictxt)
        stop 1
      end if
    else
      ! Receive Parameters
      call psb_bcast(ictxt,mtrx_file)
      call psb_bcast(ictxt,rhs_file)
      call psb_bcast(ictxt,cmethd)
      call psb_bcast(ictxt,afmt)

      call psb_bcast(ictxt,inparms(1:6))
      ipart  =  inparms(1) 
      istopc =  inparms(2) 
      itmax  =  inparms(3) 
      itrace =  inparms(4) 
      iprec  =  inparms(5) 
      novr     =  inparms(6) 
      call psb_bcast(ictxt,eps)

    end if

  end subroutine get_parms

  subroutine pr_usage(iout)
    integer iout
    write(iout, *) ' Number of parameters is incorrect!'
    write(iout, *) ' Use: hb_sample mtrx_file methd prec [ptype &
         &itmax istopc itrace]' 
    write(iout, *) ' Where:'
    write(iout, *) '     mtrx_file      is stored in HB format'
    write(iout, *) '     methd          may be: CGSTAB '
    write(iout, *) '     ptype          Partition strategy default 0'
    write(iout, *) '                    0: BLOCK partition '
    write(iout, *) '     itmax          Max iterations [500]        '
    write(iout, *) '     istopc         Stopping criterion [1]      '
    write(iout, *) '     itrace         0  (no tracing, default) or '
    write(iout, *) '                    >= 0 do tracing every ITRACE'
    write(iout, *) '                    iterations ' 
  end subroutine pr_usage
end module getp
c == =====================================================================
c Sparse Matrix Multiplication Package
c
c Randolph E. Bank and Craig C. Douglas
c
c na.bank@na-net.ornl.gov and na.cdouglas@na-net.ornl.gov
c
c Compile this with the following command (or a similar one):
c
c     f77 -c -O smmp.f
c
c == =====================================================================
      subroutine symbmm 
     *  (n, m, l, 
     *  ia, ja, diaga, 
     *  ib, jb, diagb,
     *  ic, jc, diagc,
     *  index)
      use psb_const_mod
      use psb_realloc_mod
      use psb_sort_mod, only: psb_msort
c
      integer(psb_ipk_) ::       ia(*), ja(*), diaga,
     *  ib(*), jb(*), diagb,  diagc,  index(*)
      integer(psb_ipk_), allocatable :: ic(:),jc(:)
      integer(psb_ipk_) :: nze, info
      
c
c       symbolic matrix multiply c=a*b
c
      if (size(ic) < n+1) then 
        write(psb_err_unit,*)
     +    'Called realloc in SYMBMM '
        call psb_realloc(n+1,ic,info)
        if (info /= psb_success_) then 
          write(psb_err_unit,*)
     +      'realloc failed in SYMBMM ',info
        end if
      endif
      maxlmn = max(l,m,n)
      do 10 i=1,maxlmn
        index(i)=0
 10   continue 
      if (diagc.eq.0) then
        ic(1)=1
      else
        ic(1)=n+2
      endif
      minlm = min(l,m)
      minmn = min(m,n)
c
c    main loop
c
      do 50 i=1,n
        istart=-1
        length=0
c
c    merge row lists
c
        do 30 jj=ia(i),ia(i+1)
c    a = d + ...
          if (jj.eq.ia(i+1)) then
            if (diaga.eq.0 .or. i.gt.minmn) goto 30
            j = i
          else
            j=ja(jj)
          endif
c    b = d + ...
          if (index(j).eq.0 .and. diagb.eq.1 .and. j.le.minlm)then
            index(j)=istart
            istart=j
            length=length+1
          endif
          if ((j<1).or.(j>m)) then 
            write(psb_err_unit,*)
     +        ' SymbMM: Problem with A ',i,jj,j,m
          endif
          do 20 k=ib(j),ib(j+1)-1 
            if ((jb(k)<1).or.(jb(k)>maxlmn)) then 
              write(psb_err_unit,*)
     +          'Problem in SYMBMM 1:',j,k,jb(k),maxlmn
            else
              if(index(jb(k)).eq.0) then
                index(jb(k))=istart
                istart=jb(k)
                length=length+1
              endif
            endif
 20       continue
 30     continue
c
c   row i of jc
c
        if (diagc.eq.1 .and. index(i).ne.0) length = length - 1
        ic(i+1)=ic(i)+length
        
        if (ic(i+1) > size(jc)) then 
          if (n > (2*i)) then 
            nze = max(ic(i+1), ic(i)*((n+i-1)/i))
          else
            nze = max(ic(i+1), nint((dble(ic(i))*(dble(n)/i)))   )
          endif 
          call psb_realloc(nze,jc,info)
          if (info /= 0) then
            write(0,*) 'Failed realloc ',nze,info
            return
          end if
        end if 

        do 40 j= ic(i),ic(i+1)-1
          if (diagc.eq.1 .and. istart.eq.i) then
            istart = index(istart)
            index(i) = 0
          endif
          jc(j)=istart
          istart=index(istart)
          index(jc(j))=0
 40     continue
        call psb_msort(jc(ic(i):ic(i)+length -1))
        index(i) = 0
 50   continue
      return
      end

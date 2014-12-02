#if dimensions == 1

#define PoisFFT_SolverXD PoisFFT_Solver1D
#define PoisFFT_PlanXD   PoisFFT_Plan1D
#define realplantypes    plantypes(1)
#define nxyzs            D%gnx
#define colons           :

#elif dimensions == 2

#define PoisFFT_SolverXD PoisFFT_Solver2D
#define PoisFFT_PlanXD   PoisFFT_Plan2D
#define realplantypes    plantypes(1),plantypes(2)
#define nxyzs            D%gny,D%gnx
#define colons           :,:

#else

#define PoisFFT_SolverXD PoisFFT_Solver3D
#define PoisFFT_PlanXD   PoisFFT_Plan3D
#define realplantypes    plantypes(1),plantypes(2),plantypes(3)
#define nxyzs            D%gnz,D%gny,D%gnx
#define colons           :,:,:

#endif

#if (PREC == 2)
#define pfft_cmplx pfft_plan_dft
#define pfft_real pfft_plan_r2r
#else
#define pfft_cmplx pfftf_plan_dft
#define pfft_real pfftf_plan_r2r
#endif

      type(PoisFFT_PlanXD) :: plan
      
      type(PoisFFT_SolverXD), intent(inout) :: D
      integer, intent(in), dimension(:)     :: plantypes

      if (plantypes(1)==FFT_Complex) then

        if (size(plantypes)<2) then
          write (*,*) "Error: not enough flags when creating PoisFFT_PlanXD"
          STOP
        endif
       
        plan%dir = plantypes(2)

#if defined(MPI) && dimensions > 1
        plan%planptr = pfft_cmplx(dimensions,int([nxyzs],c_intptr_t), &
          D%cwork, D%cwork, D%mpi%comm, &
          plan%dir, PFFT_TRANSPOSED_NONE + PFFT_MEASURE + PFFT_PRESERVE_INPUT)
#else
        plan%planptr = fftw_plan_gen(nxyzs , D%cwork, D%cwork,&
                        plan%dir, FFTW_MEASURE)
#endif

      else

        if (size(plantypes)< dimensions ) then
          write (*,*) "Error: not enough flags when creating PoisFFT_PlanXD, there must be one per dimension."
          STOP
        endif


#if defined(MPI) && dimensions > 1
        plan%planptr = pfft_real(dimensions,int([nxyzs],c_intptr_t), &
          D%rwork, D%rwork, D%mpi%comm, &
          plantypes, PFFT_TRANSPOSED_NONE + PFFT_MEASURE + PFFT_PRESERVE_INPUT)
#else
        plan%planptr = fftw_plan_gen(nxyzs , D%rwork, D%rwork,&
                        realplantypes , FFTW_MEASURE)
#endif

      endif
      
      plan%planowner=.true.
      
      if (.not.c_associated(plan%planptr)) stop "Error, FFT plan not created!"

#undef colons
#undef realplantypes
#undef nxyzs
#undef PoisFFT_SolverXD
#undef PoisFFT_PlanXD
#undef SliceXD
#undef pfft_cmplx
#undef pfft_real
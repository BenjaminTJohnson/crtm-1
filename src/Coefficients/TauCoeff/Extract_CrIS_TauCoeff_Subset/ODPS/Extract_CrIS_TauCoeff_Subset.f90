!
! Extract_CrIS_TauCoeff_Subset
!
! Program to extract the CRIS channel subset from the individual
! CRIS band netCDF format ODPS data files.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, 26-Oct-2009
!                       Yong.Chen@noaa.gov
!
!       based on Paul van Delst's Extract_IASI_TauCoeff_Subset.f90 
!
!       Modified by:    David Groff, 14-Jun-2011
!                       david.groff@noaa.gov

PROGRAM Extract_CrIS_TauCoeff_Subset

  ! ------------------
  ! Environment set up
  ! ------------------
  ! Module usage
  USE Message_Handler,       ONLY: SUCCESS, FAILURE, WARNING, INFORMATION, &
                                   Display_Message, Program_Message
  USE Compare_Float_Numbers, ONLY: Compare_Float
  USE List_File_Utility,     ONLY: Integer_List_File_type, &
                                   Read_List_File, &
                                   Get_List_Size, Get_List_Entry
  USE ODPS_Define,           ONLY: ODPS_type, &
                                   Allocate_ODPS, Destroy_ODPS, Allocate_ODPS_OPTRAN
  USE ODPS_netCDF_IO,        ONLY: Inquire_ODPS_netCDF, &
                                   Read_ODPS_netCDF, &
                                   Write_ODPS_netCDF
  USE Subset_Define,         ONLY: Subset_type, &
                                   Subset_Destroy, &
                                   Subset_GetValue
  USE CRIS_Define,           ONLY: N_CRIS_BANDS, &
                                   N_CRIS_CHANNELS, &
                                   CrIS_BandName
  USE CRIS_Subset,           ONLY: N_CRIS_SUBSET_374, CRIS_SUBSET_374, CRIS_SUBSET_374_COMMENT, &
                                   N_CRIS_SUBSET_399, CRIS_SUBSET_399, CRIS_SUBSET_399_COMMENT, &
                                   N_CRIS_VALID_SUBSETS, CRIS_VALID_SUBSET_NAME, &
                                   CrIS_Subset_Index
  ! Disable implicit typing
  IMPLICIT NONE


  ! ----------
  ! Parameters
  ! ----------
  CHARACTER(*), PARAMETER :: PROGRAM_NAME = 'Extract_CrIS_TauCoeff_Subset'
  CHARACTER(*), PARAMETER :: PROGRAM_VERSION_ID = &
 
  INTEGER, PARAMETER :: SL = 256

  INTEGER, PARAMETER :: GROUP_1_MAX_COMPONENTS  = 8     
  INTEGER, PARAMETER :: GROUP_2_MAX_COMPONENTS  = 5    
  INTEGER, PARAMETER :: GROUP_1_MAX_PREDS       = 91
  INTEGER, PARAMETER :: GROUP_2_MAX_PREDS       = 52
  INTEGER, PARAMETER :: N_PREDICTOR_USED_OPTRAN = 6
  INTEGER, PARAMETER :: MAX_ORDER_OPTRAN        = 10


  ! ---------
  ! Variables
  ! ---------
  INTEGER :: err_stat   ;  CHARACTER(SL) :: err_msg
  INTEGER :: io_stat    ;  CHARACTER(SL) :: io_msg
  INTEGER :: alloc_stat ;  CHARACTER(SL) :: alloc_msg
  CHARACTER(256)  :: Message
  CHARACTER(256)  :: List_Filename
  CHARACTER(256)  :: In_Filename
  CHARACTER(256)  :: Out_Filename
  CHARACTER(256)  :: Profile_Set_Id 
  CHARACTER(5000) :: Title
  CHARACTER(5000) :: History
  CHARACTER(5000) :: Comment
  CHARACTER(256)  :: Subset_Comment
  CHARACTER(20)   :: Sensor_ID
  INTEGER :: i, Set
  LOGICAL :: First_Band
  LOGICAL :: OPTRAN
  INTEGER :: n_Layers           
  INTEGER :: n_Components       
  INTEGER :: n_Absorbers        
  INTEGER :: n_Channels         
  INTEGER :: n_Coeffs           
  INTEGER :: n_OPIndex          
  INTEGER :: n_OCoeffs          
  INTEGER :: Version
  INTEGER :: j, l, l1, l2
  INTEGER :: n_Subset_Channels
  INTEGER :: lch, ls, js, n_Out_Coeffs, j0, np, jp, k
  INTEGER :: n_Subset_Coeffs, n_total_Pred
  INTEGER :: n_orders, n_Subset_OCoeffs, n_Out_OCoeffs, los
  INTEGER :: n_values
  INTEGER, ALLOCATABLE :: idx(:), nmbr(:)
  INTEGER, ALLOCATABLE :: Subset_List(:)
  TYPE(Integer_List_File_type) :: User_Subset_List
  TYPE(ODPS_type) :: In_ODPS, Out_ODPS, Out_ODPS_f
  TYPE(Subset_type) :: Subset

  ! Output program header
  CALL Program_Message(PROGRAM_NAME, &
                       'Program to extract the CRIS channel SUBSET transmittance '//&
                       'coefficient data from the individual band netCDF '//&
                       'ODPS files and write them to a separate netCDF '//&
                       'datafile.', &
                       '$Revision$' )

  ! Select a subset set
  Select_Loop: DO
    ! ...Prompt user to select a subset set 
    WRITE( *,'(/5x,"Select an CrIS channel subset")' )
    DO i = 1, N_CRIS_VALID_SUBSETS
      WRITE( *,'(10x,i1,") ",a)' ) i, CRIS_VALID_SUBSET_NAME(i)
    END DO
    WRITE( *,FMT='(5x,"Enter choice: ")',ADVANCE='NO' )
    READ( *,FMT='(i5)',IOSTAT=io_stat, IOMSG=io_msg ) set
    ! ...Check for I/O errors
    IF ( io_stat /= 0 ) THEN
      err_msg = 'Invalid input - '//TRIM(io_msg)
      CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
    END IF
    ! ...Check the input
    IF ( set < 1 .OR. set > N_CRIS_VALID_SUBSETS ) THEN
      err_msg = 'Invalid selection'
      CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
    ELSE
      EXIT Select_Loop
    END IF
  END DO Select_Loop


  ! Get the required channels list
  SELECT CASE ( Set )

    ! The 374 channel subset
    CASE (1)
      ! ...Allocate list array
      n_Subset_Channels = N_CRIS_SUBSET_374
      Subset_Comment    = CRIS_SUBSET_374_COMMENT
      ALLOCATE( subset_list(n_subset_channels), STAT=alloc_stat )!, ERRMSG=alloc_msg )
      IF ( alloc_stat /= 0 ) THEN
        err_msg = 'Error allocating Subset_List array - '!//TRIM(alloc_msg)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Fill values
      Subset_List = CRIS_SUBSET_374
      Sensor_ID   = 'cris374_npp'


    ! The 399 channel subset
    CASE (2)
      ! ...Allocate list array
      n_Subset_Channels = N_CRIS_SUBSET_399
      Subset_Comment    = CRIS_SUBSET_399_COMMENT
      ALLOCATE( subset_list(n_subset_channels), STAT=alloc_stat )!, ERRMSG=alloc_msg )
      IF ( alloc_stat /= 0 ) THEN
        err_msg = 'Error allocating Subset_List array - '!//TRIM(alloc_msg)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Fill values
      Subset_List = CRIS_SUBSET_399
      Sensor_ID   = 'cris399_npp'


    ! All the channels
    CASE(3)
      ! ...Allocate list array
      n_Subset_Channels = N_CRIS_CHANNELS
      Subset_Comment    = 'CRIS full channel set'
      ALLOCATE( subset_list(n_subset_channels), STAT=alloc_stat )!, ERRMSG=alloc_msg )
      IF ( alloc_stat /= 0 ) THEN
        err_msg = 'Error allocating Subset_List array - '!//TRIM(alloc_msg)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Fill values
      Subset_List = (/(l,l=1,N_CRIS_CHANNELS)/)
      Sensor_ID   = 'cris_npp'


    ! A user specified channel subset
    CASE (4)
      ! ...Get the list of channels required
      WRITE( *, FMT='(/5x,"Enter an CrIS channel subset list filename : ")', ADVANCE='NO' )
      READ( *,FMT='(a)' ) list_filename
      list_filename = ADJUSTL(list_filename)
      ! ...Read the channel subset list file
      err_stat = Read_List_File( list_filename, user_subset_list )
      IF ( err_stat /= SUCCESS ) THEN
        err_msg = 'Error reading channel subset list file '//TRIM(list_filename)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Retrieve the number of subset channels
      n_subset_channels = Get_List_Size( user_subset_list )
      IF ( n_subset_channels < 1 ) THEN
        err_msg = 'No channels listed in '//TRIM(list_filename)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Check the number of channels
      IF ( n_subset_channels < 1 .OR. n_subset_channels > N_CRIS_CHANNELS ) THEN
        err_msg = 'Number of channels listed in '//TRIM(list_filename)//' outside of valid range.'
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Allocate list array
      ALLOCATE( subset_list(n_subset_channels), STAT=alloc_stat )!, ERRMSG=alloc_msg )
      IF ( alloc_stat /= 0 ) THEN
        err_msg = 'Error allocating Subset_List array - '!//TRIM(alloc_msg)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF
      ! ...Fill values
      DO i = 1, n_subset_channels
        err_stat = Get_List_Entry( user_subset_list, i, subset_list(i) )
        IF ( err_stat /= SUCCESS ) THEN
          WRITE( err_msg,'("Error retrieving user subset channel list entry ",i0)' ) i
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF
      END DO
      WRITE( sensor_id,'("cris",i0,"_npp")' ) n_subset_channels

  END SELECT


  ! Initialise the start index for output
  ! and the "initial band" flag
  ! -------------------------------------
  l1 = 1
  ls = 0
  n_Out_Coeffs = 0
  los = 0
  n_Out_OCoeffs = 0
  First_Band = .TRUE.
  OPTRAN = .FALSE.


  ! Loop over bands to extract subset channels
  ! ------------------------------------------
  Band_Loop: DO l = 1, N_CRIS_BANDS


    ! Current band channel subset
    ! ---------------------------
    ! Determine the subset channel indices
    ! for the current band
    err_stat = CrIS_Subset_Index( l, Subset_List, Subset )
    IF ( err_stat /= SUCCESS ) THEN
      err_msg = 'Error extracting subset channel indices for band '//TRIM(CrIS_BandName(l))
      CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
    END IF
    CALL Subset_GetValue( Subset, n_Values = n_values, Index = idx, Number = nmbr )


    ! Output the number of channels to extract
    WRITE( *,'(/10x,"There are ",i0," channels to be extracted from band ",a,":")' ) &
             n_values, TRIM(CrIS_BandName(l))


    ! Read the input ODPS file if required
    ! ----------------------------------------
    Non_Zero_n_Channels: IF ( n_values > 0 ) THEN

      ! Output the list of channel numbers to extract
      WRITE( *,'(10x,10i5)' ) nmbr

      ! Define the filename
      In_Filename = 'cris'//TRIM(CrIS_BandName(l))//'_npp.TauCoeff.nc'


      ! Get the file release/version info and
      ! global attributes for the initial band
      ! --------------------------------------
      IF ( First_Band ) THEN

        ! **NOTE: No Update of First_Band here. It's used later**

        ! Inquire the file
        err_stat = Inquire_ODPS_netCDF( TRIM(In_Filename), &
                                        n_Layers         = n_Layers        , &
                                        n_Components     = n_Components    , &
                                        n_Absorbers      = n_Absorbers     , &
                                        n_Channels       = n_Channels      , &
                                        n_Coeffs         = n_Coeffs        , &
                                        n_OPIndex        = n_OPIndex       , &
                                        n_OCoeffs        = n_OCoeffs       , &
                                        Release          = Out_ODPS%Release         , &
                                        Version          = Out_ODPS%Version         , &
                                        WMO_Satellite_Id = Out_ODPS%WMO_Satellite_Id, &
                                        WMO_Sensor_Id    = Out_ODPS%WMO_Sensor_Id   , &
                                        Title            = Title           , &
                                        History          = History         , &
                                        Comment          = Comment         , &
                                        Profile_Set_Id   = Profile_Set_Id)
        IF ( err_stat /= SUCCESS ) THEN
          err_msg = 'Error inquiring the input netCDF ODPS file '//TRIM(In_Filename)
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF
        
        ! Obtain the total predictors for different Group
        IF( n_Components == GROUP_1_MAX_COMPONENTS) THEN
          n_total_Pred = GROUP_1_MAX_PREDS
        ELSE IF ( n_Components == GROUP_2_MAX_COMPONENTS ) THEN
          n_total_Pred = GROUP_2_MAX_PREDS
        END IF
        ! Estimate the output ODPS Coeffs dimension
        n_Subset_Coeffs = n_total_Pred * n_Layers * n_Subset_Channels
        
        
        ! Append onto the comment attribute.
        Comment = TRIM(Subset_Comment)//'; '//TRIM(Comment)

        ! Allocate the output structure
        err_stat = Allocate_ODPS( n_Layers    , &
                                  n_Components, &
                                  n_Absorbers , &
                                  n_Subset_Channels, &
                                  n_Subset_Coeffs  , &
                                  Out_ODPS )
        IF ( err_stat /= SUCCESS ) THEN
          err_msg = 'Error allocating output ODPS data structure.'
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF

        IF ( n_OPIndex > 0 .AND. n_OCoeffs > 0 ) THEN
          OPTRAN = .TRUE.
          n_Subset_OCoeffs =  (MAX_ORDER_OPTRAN+1)*(N_PREDICTOR_USED_OPTRAN+1) * n_Subset_Channels
          err_stat = Allocate_ODPS_OPTRAN(n_Subset_OCoeffs, Out_ODPS)
          IF ( err_stat /= SUCCESS ) THEN
            err_msg = 'Error allocating output ODPS OPTRAN data structure.'
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF
        
        END IF
      END IF


      ! Get the Version info and compare
      ! --------------------------------
      err_stat = Inquire_ODPS_netCDF( In_Filename, Version = Version )
      IF ( err_stat /= SUCCESS ) THEN
        err_msg = 'Error inquiring the input netCDF ODPS file '//&
                  TRIM(In_Filename)//' for Release/Version info.'
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF

      ! Check the Version value. If different - issue warning and continue, 
      ! but modify the Comment global attribute field for output
      IF ( Out_ODPS%Version /= Version ) THEN
        WRITE( err_msg,'("Input file ",a," Version, ",i0, &
                        &", is different from previous file value, ",i0,".")' ) &
                        TRIM(In_Filename), Version, Out_ODPS%Version
        CALL Display_Message( PROGRAM_NAME, err_msg, WARNING )
        Comment = TRIM(Message)//'; '//TRIM(Comment)
      END IF


      ! Read the data
      ! -------------
      err_stat = Read_ODPS_netCDF( In_Filename, In_ODPS )
      IF ( err_stat /= SUCCESS ) THEN
        err_msg = 'Error reading netCDF CRIS ODPS file '//TRIM(In_Filename)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF


      ! Copy or check the absorber id and alpha data
      ! --------------------------------------------
      IF ( First_Band ) THEN

        ! Now update the First_Band flag
        First_Band = .FALSE.

        ! Simply copy these for the first band
        Out_ODPS%Group_Index      = In_ODPS%Group_Index
        Out_ODPS%WMO_Satellite_ID = In_ODPS%WMO_Satellite_ID  
        Out_ODPS%WMO_Sensor_ID    = In_ODPS%WMO_Sensor_ID     
        Out_ODPS%Sensor_Type      = In_ODPS%Sensor_Type 
              
        Out_ODPS%Component_ID      = In_ODPS%Component_ID      
        Out_ODPS%Absorber_ID       = In_ODPS%Absorber_ID       
        Out_ODPS%Ref_Level_Pressure= In_ODPS%Ref_Level_Pressure
        Out_ODPS%Ref_Pressure      = In_ODPS%Ref_Pressure      
        Out_ODPS%Ref_Temperature   = In_ODPS%Ref_Temperature   
        Out_ODPS%Ref_Absorber      = In_ODPS%Ref_Absorber      
        Out_ODPS%Min_Absorber      = In_ODPS%Min_Absorber      
        Out_ODPS%Max_Absorber      = In_ODPS%Max_Absorber      

        IF ( OPTRAN ) THEN
          Out_ODPS%Alpha            = In_ODPS%Alpha   
          Out_ODPS%Alpha_C1         = In_ODPS%Alpha_C1
          Out_ODPS%Alpha_C2         = In_ODPS%Alpha_C2
          Out_ODPS%OComponent_Index = In_ODPS%OComponent_Index 
        ENDIF
        
      ELSE ! Subsequent bands

        ! Check Group_Index
        IF ( IN_ODPS%Group_Index /= Out_ODPS%Group_Index ) THEN
          WRITE( err_msg,'("Group_Index values are different for band ",a)' ) TRIM(CrIS_BandName(l)) 
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF

        ! Check Sensor_Type
        IF ( IN_ODPS%Sensor_Type /= Out_ODPS%Sensor_Type ) THEN
          WRITE( err_msg,'("Sensor types are different for band ",a)' ) TRIM(CrIS_BandName(l)) 
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF  
        
        ! Check WMO Satellite ID
        IF ( IN_ODPS%WMO_Satellite_ID /= Out_ODPS%WMO_Satellite_ID ) THEN
          WRITE( err_msg,'("WMO_Satellite_ID values are different for band ",a)' ) TRIM(CrIS_BandName(l)) 
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF  
        
        ! Check WMO Sensor ID
        IF ( IN_ODPS%WMO_Sensor_ID /= Out_ODPS%WMO_Sensor_ID ) THEN
          WRITE( err_msg,'("WMO_Sensor_ID values are different for band ",a)' ) TRIM(CrIS_BandName(l)) 
          CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
        END IF  
 
        ! Check Component_ID
        DO j = 1, Out_ODPS%n_Components
          IF ( IN_ODPS%Component_ID(j) /= Out_ODPS%Component_ID(j) ) THEN
            WRITE( err_msg,'("Component #",i2," ID values are different for band ",a)' ) &
                           j, TRIM(CrIS_BandName(l)) 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF  
        END DO

        ! Check Absorber IDs
        DO j = 1, In_ODPS%n_Absorbers 
          IF ( In_ODPS%Absorber_ID(j) /= Out_ODPS%Absorber_ID(j) ) THEN
            WRITE( err_msg, '( "Absorber #",i2," ID values are different for band ",a)' ) &
                            j, TRIM(CrIS_BandName(l))
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF
        END DO
        
        ! Check reference level pressure value                                                                     
        DO k = 0, In_ODPS%n_Layers
          IF ( .NOT. Compare_Float( In_ODPS%Ref_Level_Pressure(k) , Out_ODPS%Ref_Level_Pressure(k)  ) ) THEN                  
            WRITE( err_msg, '( "Ref_Level_Pressure #",i2," level values are different for band ",a)' ) &    
                            k+1, TRIM(CrIS_BandName(l))                                                 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF                                                                                  
        END DO

        ! Check reference layer pressure value                                                                     
        DO k = 1, In_ODPS%n_Layers
          IF ( .NOT. Compare_Float( In_ODPS%Ref_Pressure(k) , Out_ODPS%Ref_Pressure(k)  ) ) THEN                  
            WRITE( err_msg, '( "Ref_Pressure #",i2," layer values are different for band ",a)' ) &    
                            k, TRIM(CrIS_BandName(l))                                                 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF                                                                                  
        END DO

        ! Check reference Temperature value                                                                     
        DO k = 1, In_ODPS%n_Layers
          IF ( .NOT. Compare_Float( In_ODPS%Ref_Temperature(k) , Out_ODPS%Ref_Temperature(k)  ) ) THEN                  
            WRITE( err_msg, '( "Ref_Temperature #",i2," layer values are different for band ",a)' ) &    
                            k, TRIM(CrIS_BandName(l))                                                 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF                                                                                  
        END DO

        ! Check Ref_Absorber value                                                                     
        DO j = 1, In_ODPS%n_Absorbers 
          DO k = 1, In_ODPS%n_Layers
            IF ( .NOT. Compare_Float( In_ODPS%Ref_Absorber(k,j) , Out_ODPS%Ref_Absorber(k,j)  ) ) THEN                 
              WRITE( err_msg, '( "Ref_Absorber values are different for band ",a, " for index (", i3, 1x, i0, ")" )' ) &   
                              TRIM(CrIS_BandName(l)), k, j                                                 
              CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
            END IF 
          END DO                                                                                 
        END DO
       
        ! Check Min_Absorber value                                                                     
        DO j = 1, In_ODPS%n_Absorbers 
          DO k = 1, In_ODPS%n_Layers
            IF ( .NOT. Compare_Float( In_ODPS%Min_Absorber(k,j) , Out_ODPS%Min_Absorber(k,j)  ) ) THEN                 
              WRITE( err_msg, '( "Min_Absorber values are different for band ",a, " for index (", i3, 1x, i0, ")" )' ) &   
                              TRIM( CrIS_BandName(l)), k, j                                                 
              CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
            END IF 
          END DO                                                                                 
        END DO

        ! Check Max_Absorber value                                                                     
        DO j = 1, In_ODPS%n_Absorbers 
          DO k = 1, In_ODPS%n_Layers
            IF ( .NOT. Compare_Float( In_ODPS%Max_Absorber(k,j) , Out_ODPS%Max_Absorber(k,j)  ) ) THEN                 
              WRITE( err_msg, '( "Max_Absorber values are different for band ",a, " for index (", i3, 1x, i0, ")" )' ) &   
                              TRIM( CrIS_BandName(l)), k, j                                                 
              CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
            END IF 
          END DO                                                                                 
        END DO


        ! Check Optran quantities
        IF ( OPTRAN ) THEN
          ! ...Check Alpha
          IF ( IN_ODPS%Alpha /= Out_ODPS%Alpha ) THEN
            WRITE( err_msg, '( "Alpha values are different for band ",a)' ) &
                              TRIM(CrIS_BandName(l)) 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF
          ! ...Check Alpha_C1
          IF ( IN_ODPS%Alpha_C1 /= Out_ODPS%Alpha_C1 ) THEN
            WRITE( err_msg,'("Alpha_C1 values are different for band ",a)' ) &
                              TRIM(CrIS_BandName(l)) 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF  
          ! ...Check Alpha_C2
          IF ( IN_ODPS%Alpha_C2 /= Out_ODPS%Alpha_C2 ) THEN
            WRITE( err_msg,'("Alpha_C2 values are different for band ",a)' ) &
                              TRIM(CrIS_BandName(l)) 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF  
          ! ...Check OComponent_Index
          IF ( IN_ODPS%OComponent_Index /= Out_ODPS%OComponent_Index ) THEN
            WRITE( err_msg,'("OComponent_Index values are different for band ",a)' ) &
                              TRIM(CrIS_BandName(l)) 
            CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
          END IF  
         END IF 
       END IF


      ! Copy the required channel's data for particular components
      l2 = l1 + n_values - 1
      Out_ODPS%Sensor_Channel(l1:l2) = In_ODPS%Sensor_Channel(idx)

      DO lch = 1, n_values 
        ls = ls + 1
        DO j = 1, Out_ODPS%n_Components
          np = In_ODPS%n_Predictors(j,idx(lch))
          Out_ODPS%n_Predictors(j, ls) = np 

          j0 = In_ODPS%Pos_Index(j,idx(lch))

          js = n_Out_Coeffs
          IF ( np > 0 ) THEN
            DO i = 1, np
              jp = j0+(i-1)*In_ODPS%n_Layers-1
              DO k = 1, In_ODPS%n_Layers          
                n_Out_Coeffs = n_Out_Coeffs + 1             
                Out_ODPS%C(n_Out_Coeffs) = In_ODPS%C(jp+k)
              END DO
            END DO
            Out_ODPS%Pos_Index(j, ls) = js+1
          ELSE
            Out_ODPS%Pos_Index(j, ls) = 0
          END IF
        END DO
      END DO  
      
      IF ( OPTRAN ) THEN
        Out_ODPS%OSignificance(l1:l2) = In_ODPS%OSignificance(idx)
        Out_ODPS%Order(l1:l2)         = In_ODPS%Order(idx)
        Out_ODPS%OP_Index(:,l1:l2)    = In_ODPS%OP_Index(:, idx)
        
        DO lch = 1, n_values
          los = los + 1 
          np       = In_ODPS%OP_Index(0, idx(lch))    
          n_orders = In_ODPS%Order(idx(lch))          
          j0 = In_ODPS%OPos_Index(idx(lch))
          
          Out_ODPS%OPos_Index(los) = n_Out_OCoeffs + 1 

          js = 0
          DO i = 0, np
            jp = j0 + i * (n_orders + 1)
            DO j = 0, n_orders
              js = js + 1
              Out_ODPS%OC(n_Out_OCoeffs + js) = In_ODPS%OC(jp + j)
            END DO
          END DO
          n_Out_OCoeffs = n_Out_OCoeffs + js 
        END DO 
      END IF
          
      l1 = l2 + 1
      
 
      ! Destroy the input ODPS structure
      ! for the next band read
      err_stat = Destroy_ODPS( In_ODPS )
      IF ( err_stat /= SUCCESS ) THEN
        err_msg = 'Error destroying ODPS structure for input from '//TRIM(In_Filename)
        CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
      END IF

    END IF Non_Zero_n_Channels


    ! Destroy the CRIS channel subset structure
    CALL Subset_Destroy( Subset )

  END DO Band_Loop


  ! Write the output SpcCoeff file
  ! ...The output filename
  Out_Filename = TRIM(Sensor_ID)//'.TauCoeff.nc'
  ! ...Set the sensors ID
  Out_ODPS%Sensor_ID  = TRIM(Sensor_ID)
  ! ...Allocate the final output structure                                                
  err_stat = Allocate_ODPS(n_Layers    , &                                   
                           n_Components, &                                   
                           n_Absorbers , &                                   
                           n_Subset_Channels, &                              
                           n_Out_Coeffs  , &                              
                           Out_ODPS_f ) 
  IF ( err_stat /= SUCCESS ) THEN                                            
    err_msg = 'Error allocating final output ODPS data structure.'               
    CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
  END IF 

  Out_ODPS_f%Version               = Out_ODPS%Version                
  Out_ODPS_f%Release               = Out_ODPS%Release                
  Out_ODPS_f%Group_Index           = Out_ODPS%Group_Index              
  Out_ODPS_f%Sensor_ID             = Out_ODPS%Sensor_ID                
  Out_ODPS_f%Sensor_type           = Out_ODPS%Sensor_type              
  Out_ODPS_f%WMO_Satellite_ID      = Out_ODPS%WMO_Satellite_ID         
  Out_ODPS_f%WMO_Sensor_ID         = Out_ODPS%WMO_Sensor_ID            
  Out_ODPS_f%Component_ID          = Out_ODPS%Component_ID             
  Out_ODPS_f%Absorber_ID           = Out_ODPS%Absorber_ID              
  Out_ODPS_f%Ref_Level_Pressure    = Out_ODPS%Ref_Level_Pressure       
  Out_ODPS_f%Ref_Pressure          = Out_ODPS%Ref_Pressure             
  Out_ODPS_f%Ref_Temperature       = Out_ODPS%Ref_Temperature          
  Out_ODPS_f%Ref_Absorber          = Out_ODPS%Ref_Absorber             
  Out_ODPS_f%Min_Absorber          = Out_ODPS%Min_Absorber             
  Out_ODPS_f%Max_Absorber          = Out_ODPS%Max_Absorber             
  Out_ODPS_f%Sensor_Channel        = Out_ODPS%Sensor_Channel         
  Out_ODPS_f%n_Predictors          = Out_ODPS%n_Predictors           
  Out_ODPS_f%Pos_Index             = Out_ODPS%Pos_Index              
  
  IF( n_Out_Coeffs > 0 )THEN                       
    Out_ODPS_f%C(1: n_Out_Coeffs) = Out_ODPS%C(1: n_Out_Coeffs)
  END IF                                           

  ! COPTRAN part
  IF ( n_Out_OCoeffs > 0 )THEN 
    err_stat = Allocate_ODPS_OPTRAN(n_Out_OCoeffs, Out_ODPS_f)                                         
    IF ( err_stat /= SUCCESS ) THEN
      err_msg = 'Error allocating output ODPS OPTRAN data structure.'
      CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
    END IF

    Out_ODPS_f%Alpha               = Out_ODPS%Alpha   
    Out_ODPS_f%Alpha_C1            = Out_ODPS%Alpha_C1
    Out_ODPS_f%Alpha_C2            = Out_ODPS%Alpha_C2
    Out_ODPS_f%OComponent_Index    = Out_ODPS%OComponent_Index  
    Out_ODPS_f%OSignificance       = Out_ODPS%OSignificance 
    Out_ODPS_f%Order               = Out_ODPS%Order        
    Out_ODPS_f%OP_Index            = Out_ODPS%OP_Index     
    Out_ODPS_f%OPos_Index          = Out_ODPS%OPos_Index     
    Out_ODPS_f%OC(1:n_Out_OCoeffs) = Out_ODPS%OC(1:n_Out_OCoeffs)     
                                                                                   
  ENDIF
                                                                          
  ! Write the data
  WRITE( *,'(/10x,"Creating the output file...")' )
  err_stat = Write_ODPS_netCDF( TRIM(Out_Filename), &
                                Out_ODPS_f    , &
                                Title         = 'Optical depth coefficients for '//&
                                                TRIM(Sensor_ID), &
                                History       = PROGRAM_VERSION_ID//'; '//&
                                                TRIM(History), &
                                Comment       = 'Data extracted from the individual '//&
                                                'CRIS band ODPS datafiles.; '//&
                                                TRIM(Comment), &
                                Profile_Set_Id= TRIM(Profile_Set_Id) )
  IF ( err_stat /= SUCCESS ) THEN
    err_msg = 'Error writing the CRIS ODPS file '//TRIM(Out_Filename)
    CALL Display_Message( PROGRAM_NAME, err_msg, FAILURE ); STOP
  END IF


  ! Destroy the output ODPS structure
  err_stat = Destroy_ODPS( Out_ODPS )
  IF ( err_stat /= SUCCESS ) THEN
    err_msg = 'Error destroying ODPS structure for output to '//TRIM(Out_Filename)
    CALL Display_Message( PROGRAM_NAME, err_msg, WARNING )
  END IF
  err_stat = Destroy_ODPS( Out_ODPS_f )
  IF ( err_stat /= SUCCESS ) THEN
    err_msg = 'Error destroying final ODPS structure for output to '//TRIM(Out_Filename)
    CALL Display_Message( PROGRAM_NAME, err_msg, WARNING )
  END IF

END PROGRAM Extract_CrIS_TauCoeff_Subset

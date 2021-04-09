######################################################
# Determine and set the Fortran compiler flags we want 
######################################################

####################################################################
# Make sure that the default build type is RELEASE if not specified.
####################################################################
INCLUDE(${CMAKE_MODULE_PATH}/SetCompileFlag.cmake)

# Make sure the build type is uppercase
STRING(TOUPPER "${CMAKE_BUILD_TYPE}" BT)

IF(BT STREQUAL "RELEASE")
    SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE, or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "DEBUG")
    SET (CMAKE_BUILD_TYPE DEBUG CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE, or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "TESTING")
    SET (CMAKE_BUILD_TYPE TESTING CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE, or TESTING."
      FORCE)
ELSEIF(NOT BT)
    SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE, or TESTING."
      FORCE)
    MESSAGE(STATUS "CMAKE_BUILD_TYPE not given, defaulting to RELEASE")
ELSE()
    MESSAGE(FATAL_ERROR "CMAKE_BUILD_TYPE not valid, choices are DEBUG, RELEASE, or TESTING")
ENDIF(BT STREQUAL "RELEASE")

#########################################################
# If the compiler flags have already been set, return now
#########################################################

IF(CMAKE_Fortran_FLAGS_RELEASE AND CMAKE_Fortran_FLAGS_TESTING AND CMAKE_Fortran_FLAGS_DEBUG)
    RETURN ()
ENDIF(CMAKE_Fortran_FLAGS_RELEASE AND CMAKE_Fortran_FLAGS_TESTING AND CMAKE_Fortran_FLAGS_DEBUG)

########################################################################
# Determine the appropriate flags for this compiler for each build type.
# For each option type, a list of possible flags is given that work
# for various compilers.  The first flag that works is chosen.
# If none of the flags work, nothing is added (unless the REQUIRED 
# flag is given in the call).  This way unknown compiles are supported.
#######################################################################

#####################
### GENERAL FLAGS ###
#####################

# There is some bug where -march=native doesn't work on Mac
IF(APPLE)
    SET(GNUNATIVE "-mtune=native")
ELSE()
    SET(GNUNATIVE "-march=native")
ENDIF()

# Optimize for the host's architecture
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "host optimization"
                 Fortran "-xHost"        # Intel
                         "/QxHost"       # Intel Windows
                         ${GNUNATIVE}    # GNU
                         "-ta=host"      # Portland Group
                )

# Enable preprocessor
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "preprosessor"
                 Fortran "-fpp"         # Intel
                         "/fpp"         # Intel Windows
                         "-cpp"         # GNU
                         "-Mpreprocess" # Portland Group
                )


# Lowercase names
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "lowercase names"
                 Fortran "-names lowercase"         # Intel
                         "/names:lowercase"         # Intel Windows
                                                    # GNU (default beghaviour)
                         "-Mnoupcase"               # Portland Group
                )
				
# Underscore
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "underscore"
                 Fortran "-assume underscore"   # Intel
                         "/assume:underscore"   # Intel Windows
                                                # GNU (default beghaviour)
                                                # Portland Group (-Msecond_underscore)
                )

# Calling convention
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "calling convention"
                 Fortran                # Intel (default behaviour)
                         "/iface:cref"  # Intel Windows
                                        # GNU (default behaviour)
                         "-Miface=cref" # Portland Group (?)
                )
# Set default real to real*8
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "default real size"
                 Fortran "-r8"                                 # Intel and Portland Group
                         "/real-size:64"                       # Intel Windows
                         "-fdefault-real-8 -fdefault-double-8" # GNU
                )

# Make position independent code
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				"position independent code"
                 Fortran "-fPIC"  # Intel, GNU and Portland Group
                                  # Intel Windows None
                )

# No right margin wraps at column 80
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				 "text format"
                 Fortran "-no-wrap-margin" # Intel
                         "/wrap-margin-"   # Intel Windows
                )

# Enable precise floating point model variation
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
				"floating point model"
                 Fortran "-fp-model precise" # Intel
                         "/fp:precise"       # Intel Windows
                )

# Floating-point operations in conformance with the IEEE 754
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
 				"floating point consistency"
                 Fortran "-fltconsistency" # Intel and GNU
                         "/fltconsistency" # Intel Windows
                         "-Kieee" # Portland Group
                )

###################
### DEBUG FLAGS ###
###################

# NOTE: debugging symbols (-g or /debug:full) are already on by default

# Disable optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
				  "disabled optimization"
                 Fortran REQUIRED "-O0" # All compilers not on Windows
                                  "/Od" # Intel Windows
                )

# Turn on (almost) all warnings
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
 				 "warnings"
                 Fortran "-warn all"                        # Intel
                         "/warn:all"                        # Intel Windows
                         "-Wno-unused-dummy-argument -Wall" # GNU
                         "-Minform=inform"                  # Portland Group
                )

# Traceback
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
				 "traceback"
                 Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )

# Check array bounds
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
#                  Fortran "-check bounds"  # Intel
#                          "/check:bounds"  # Intel Windows
#                          "-fcheck=bounds" # GNU (New style)
#                          "-Mbounds"       # Portland Group
# 		 )

# Enable checks
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
				 "run-time checks"
                 Fortran "-check all,noarg_temp_created,nopointers"  # Intel
                         "/check:all,noarg_temp_created,nopointers"  # Intel Windows
                         "-fcheck=all,no-pointer"                    # GNU
                         "-Mbounds -Mchkfpstk"                       # Portland Group
		)

# Trap floating point exception
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
				 "floating point exception"
                 Fortran "-fpe0"                            # Intel
                         "/fpe:0"                           # Intel Windows
                         "-ffpe-trap=invalid,zero,overflow" # GNU
                         "-Ktrap=inv,divz,ovf"              # Portland Group
                )

#####################
### TESTING FLAGS ###
#####################

# Optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
				 "optimization"
                 Fortran REQUIRED "-O2" # All compilers not on Windows
                                  "/O2" # Intel Windows
                )

#####################
### RELEASE FLAGS ###
#####################

# NOTE: agressive optimizations (-O3) are already turned on by default

# Unroll loops
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
				 "loop unroll"
                 Fortran "-funroll-loops" # GNU
                         "-unroll"        # Intel
                         "/Qunroll"        # Intel Windows
                         "-Munroll"       # Portland Group
                )

# Inline functions
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
				 "function inlining"
                 Fortran "-inline"            # Intel
                         "/inline"            # Intel Windows
                         "-finline-functions" # GNU
                         "-Minline"           # Portland Group
                )

# Interprocedural (link-time) optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
 				"interprocedural (link-time) optimizations"
                 Fortran "-ipo"     # Intel
                         "/Qipo"    # Intel Windows
                         "-flto"    # GNU
                         "-Mipa"    # Portland Group
                )

# Single-file optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
				 "single-file optimizations"
                 Fortran "-ip"  # Intel
                         "/Qip" # Intel Windows
                )

# Vectorize code
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
				 "vectorized code"
                 Fortran "-vec-report0"  # Intel
                         "/Qvec-report0" # Intel Windows
                         "-Mvect"        # Portland Group
                )

# Disable warnings
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
				 "warnings"
                 Fortran "-w"      # Intel and GNU
                         "/w"      # Intel Windows
                         "-silent" # Portland Group
                )

# Optimization options
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
 				"custom optimization"
                 Fortran "-ax"                  # Intel and GNU
                         "-march=x86-64 -msse2" # GNU
                )


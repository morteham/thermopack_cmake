# CMake project file for thermopack

##################################################
# Define the project and the depencies that it has
##################################################

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(thermopack Fortran)

# Set the thermopack version
SET(VERSION 1.0)

# Add our local modlues to the module path
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Require that Fortran 90 is supported
IF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)
    MESSAGE(FATAL_ERROR "Fortran compiler does not support F90")
ENDIF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)

# Set options to use OPENMP
OPTION(USE_OPENMP "Use OpenMP for parallelization" OFF)

# Sets compile flags for DEBUG, RELEASE, and TESTING.
# are to your liking.
INCLUDE(${CMAKE_MODULE_PATH}/SetFortranFlags.cmake)
# Locate and set parallelization libraries.
INCLUDE(${CMAKE_MODULE_PATH}/SetParallelizationLibrary.cmake)
# Setup the LAPACK libraries.
INCLUDE(${CMAKE_MODULE_PATH}/SetUpLAPACK.cmake)
# Find python
FIND_PACKAGE(Python3 COMPONENTS Interpreter)
GET_FILENAME_COMPONENT(PYTHON_EXE ${Python3_EXECUTABLE} NAME)

# There is an error in CMAKE with this flag for pgf90.  Unset it
GET_FILENAME_COMPONENT(FCNAME ${CMAKE_Fortran_COMPILER} NAME)
IF(FCNAME STREQUAL "pgf90")
    UNSET(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS)
ENDIF(FCNAME STREQUAL "pgf90")

############################################################
# Define the actual files and folders that make up the build
############################################################

# Define the executable name
SET(THERMOPACKEXE run_thermopack)

# Define the library name
SET(LIBTHERMOPACK thermopack)
SET(LIBTHERMOPACK_STATIC thermopack_static)

# Define name for pycThermopack target
SET(PYCTHERMOPACK pycThermopack)

# Define some directories
SET(SRC ${CMAKE_SOURCE_DIR}/src)
SET(LIB ${CMAKE_SOURCE_DIR}/lib)
SET(BIN ${CMAKE_SOURCE_DIR}/bin)
SET(MOD ${CMAKE_SOURCE_DIR}/mod)

# Have the .mod files placed in the mod folder
SET(CMAKE_Fortran_MODULE_DIRECTORY ${MOD})
# Set output folders for lib
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIB})
# Set output folders for executable
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BIN})

# Define targets and source files
INCLUDE(${CMAKE_MODULE_PATH}/DefineBuild.cmake)

# Add a distclean target to the Makefile
ADD_CUSTOM_TARGET(distclean
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/distclean.cmake
)

########################################
# Set up how to compile the source files
########################################

# Collect the source files from SRC
file(GLOB LIB_SOURCES "${SRC}/*.f90")

# Remove the file thermopack.f90 from the list of files to be compiled for the dynamic library
foreach (source ${LIB_SOURCES})
  string(FIND "${source}" "thermopack.f90" found_INDEX)
  if (${found_INDEX} GREATER 0)
    list(REMOVE_ITEM LIB_SOURCES ${source})
  endif()
endforeach()

# Define the executable in terms of the source files
ADD_LIBRARY(${LIBTHERMOPACK_STATIC} STATIC ${LIB_SOURCES})
ADD_LIBRARY(${LIBTHERMOPACK} SHARED $<TARGET_OBJECTS:${LIBTHERMOPACK_STATIC}> )
ADD_EXECUTABLE(${THERMOPACKEXE} ${SRC}/thermopack.f90)
TARGET_INCLUDE_DIRECTORIES(${LIBTHERMOPACK} PRIVATE ${CMAKE_SOURCE_DIR}/addon/trend_interface/include)
TARGET_INCLUDE_DIRECTORIES(${LIBTHERMOPACK_STATIC} PRIVATE ${CMAKE_SOURCE_DIR}/addon/trend_interface/include)

# TODO: Add linker script
# LINKER_SCRIPT
# SET_TARGET_PROPERTIES(${LIBTHERMOPACK} PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})

# Copy shared library to python package pycThermopack
ADD_CUSTOM_TARGET(${PYCTHERMOPACK} ALL
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${LIBTHERMOPACK}>          ${CMAKE_SOURCE_DIR}/addon/pycThermopack/pyctp
  # Output Message
  COMMENT "Copying libthermopack shared lirary from '${CMAKE_SOURCE_DIR}/lib/' to '${CMAKE_SOURCE_DIR}/addon/pycThermopack/pyctp'" VERBATIM
)
ADD_DEPENDENCIES(${PYCTHERMOPACK} ${LIBTHERMOPACK})

#####################################################
# Add the needed libraries and special compiler flags
#####################################################

# This links thermopack to libthermopack
TARGET_LINK_LIBRARIES(${THERMOPACKEXE} ${LIBTHERMOPACK_STATIC})

# Link to BLAS and LAPACK
TARGET_LINK_LIBRARIES(${THERMOPACKEXE} ${BLAS_LIBRARIES}
  ${LAPACK_LIBRARIES}
  ${CMAKE_THREAD_LIBS_INIT})
TARGET_LINK_LIBRARIES(${LIBTHERMOPACK} ${BLAS_LIBRARIES}
  ${LAPACK_LIBRARIES}
  ${CMAKE_THREAD_LIBS_INIT})

# Uncomment if you have parallization
IF(USE_OPENMP)
   SET_TARGET_PROPERTIES(${THERMOPACKEXE} PROPERTIES
                         COMPILE_FLAGS "${OpenMP_Fortran_FLAGS}"
                         LINK_FLAGS "${OpenMP_Fortran_FLAGS}")
   SET_TARGET_PROPERTIES(${LIBTHERMOPACK} PROPERTIES
                         COMPILE_FLAGS "${OpenMP_Fortran_FLAGS}"
                         LINK_FLAGS "${OpenMP_Fortran_FLAGS}")
ENDIF(USE_OPENMP)

#####################################
# Tell how to install this executable
#####################################

IF(WIN32)
    SET(CMAKE_INSTALL_PREFIX "C:\\Program Files")
ELSE()
    SET(CMAKE_INSTALL_PREFIX /usr/local)
ENDIF(WIN32)
INSTALL(TARGETS ${THERMOPACKEXE} RUNTIME DESTINATION bin)

# Find LAPACK (finds BLAS also) if not already found
IF(NOT LAPACK_FOUND)
  #ENABLE_LANGUAGE(C) # Some libraries (MKL) need a C compiler to find
  #SET(CMAKE_C_FLAGS -fopenmp)
  #FIND_PACKAGE(BLAS REQUIRED)
  FIND_PACKAGE(LAPACK REQUIRED)
ENDIF(NOT LAPACK_FOUND)

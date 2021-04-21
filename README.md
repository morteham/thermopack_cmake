# CMake Script for Thermopack #

This reposotory contains cmake files for building [thermopack](https://github.com/SINTEF/thermopack). The scripts are based on the fortran template by Seth Morton [cmake_fortran_template](https://github.com/SethMMorton/cmake_fortran_template).

It is currently tested only with Intel FORTRAN 2020 and GNU FORTRAN on Ubuntu 20.04 and Windows 10 with Visual Studio 2019 and Intel FORTRAN 2020. When the scripts are properly tested they will be integrated with the thermopack reposotory.

## Prerequisites ## 

A FORTRAN compiler is required to run the CMake script and to compile the binaries. The script also require tha lapack/blas libraries are available and a working python 3 installation.

## Targets ## 

* `thermopack_static`: Static thermopack libray
* `thermopack`: Dynamic thermopack library used by python 
* `run_thermopack`: Executable, running the program defined in thermopack/src/thermopack.f90
* `pycThermopack`: Set up the python package thermopack/addon/pycThermopack/pyctp
* `distclean`: Delete CMake files.

`make all` will run `thermopack_static` `thermopack` `run_thermopack` and `pycThermopack`

## Configuring the build ##

It is  preferred that you do an out-of-source build.  To do this, create a `build/` directory at the top level of your project and build there.

```bash
git clone https://github.com/morteham/thermopack_cmake.git
cd thermopack_cmake
cp -r cmake CMakeLists.txt distclean.cmake "path to thermopack"
cd "path to thermopack"
mkdir build
cd build
cmake ..
make all
```

To specific the compiler you can do as follows:
```bash
cmake .. -DCMAKE_Fortran_COMPILER=ifort
```

### Windows specifics ##

[Lapack](http://www.netlib.org/lapack/) is not as easily managed on Windows as on Linux, and must in many cases be downloaded and compiled. Assuming you are using Intel FORTRAN, you can compile Lapack as follows:
```bash
cmake .. -DCMAKE_Fortran_FLAGS="/real-size:64 /names:lowercase /iface:cref /assume:underscore"
```

Having compiled lapack, you can specify were thermopack will find the lapack and blas libraries:
```bash
cmake .. -DLAPACK_DIR="path to folder containing lapack.a and blas.a" -DBLA_STATIC=ON
```

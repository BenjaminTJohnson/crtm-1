CRTM REL-2.4.0-alpha
====================

Preamble
--------

CRTM v2.4.0 alpha release (`REL-2.4.0-alpha`)  

Created on October 7, 2020  

This is a fully functional release of CRTM v2.4.0.  

"Alpha" status indicates that this release has not been fully tested, and some minor work remains.  

Basic requirements:  
(1) A Fortran 2003 compatible compiler.  
(2) A netCDF4 / HDF5 library.   


Contents
========

1. Configuration  
2. Building the library  
3. Testing the library  
4. Installing the library  
  a. GNU Install  
      - Linking to the library  
  b. Uninstalling the library  
5. Cleaning up  
6. Feedback and contact info  



Configuration, building, and testing the library
================================================	
JCSDA CRTM v2.4.x Build Instructions

- Development Repository Build
- Note: the development repository build differs from a release build. 
	
The CRTM **development** repository directory structure looks like:

<pre>
 .
  ├── LICENSE
  ├── NOTES
  ├── README.md
  ├── Set_CRTM_Environment.sh
  ├── <b>configuration/</b>
  ├── <b>documentation/</b>
  ├── <b>fix/</b>
  │   ├── AerosolCoeff/
  │   ├── CloudCoeff/
  │   ├── EmisCoeff/
  │   ├── SpcCoeff/
  │   └── TauCoeff/
  ├── scripts/
  │   ├── idl/
  │   ├── ruby/
  │   └── shell/
  ├── <b>src/</b>
  │   ├── Ancillary/
  │   ├── AntennaCorrection/
  │   ├── AtmAbsorption/
  │   ├── AtmOptics/
  │   ├── AtmScatter/
  │   ├── Atmosphere/
  │   ├── <b>Build/</b>
	│   │   └── <b>libsrc/</b>
	│   │       └── <b>test/</b>
  │   ├── CRTM_Utility/
  │   ├── ChannelInfo/
  │   ├── Coefficients/
  │   ├── GeometryInfo/
  │   ├── InstrumentInfo/
  │   ├── Interpolation/
  │   ├── NLTE/
  │   ├── Options/
  │   ├── RTSolution/
  │   ├── SensorInfo/
  │   ├── SfcOptics/
  │   ├── Source_Functions/
  │   ├── Statistics/
  │   ├── Surface/
  │   ├── TauProd/
  │   ├── TauRegress/
  │   ├── Test_Utility/
  │   ├── User_Code/
  │   ├── Utility/
  │   ├── Validation/
  │   ├── Zeeman/
  └── <b>test/</b>
      └── Main/
</pre>

In the above list, the directories highlighted in bold (bold in markdown), are the key directories of interest to the casual developer.
A user is only likely to be interested in creating a "build" or use a previously created build (see releases/* on the github.com repository).

A typical "build release" of CRTM (what you would normally find in a tarball and see in libraries) is what's contained under the `src/Build` directory.
But after a clean clone of the development repository, none of the links to source code have been created yet under `src/Build`.   To get there, follow the next steps.

Configuration
-------------

At the top level (`CRTM_dev/`), the `configuration` directory contains the various compiler-specific configuration files.
```
  $ ls  configuration/
  ftn.setup                 ftn.setup.csh
  g95-debug.setup           gfortran.setup.csh     pgf95.setup
  g95-debug.setup.csh       ifort-debug.setup      pgf95.setup.csh
  g95.setup                 ifort-debug.setup.csh  xlf2003-debug.setup
  g95.setup.csh             ifort.setup            xlf2003-debug.setup.csh
  gfortran-debug.setup      ifort.setup.csh        xlf2003.setup
  gfortran-debug.setup.csh  pgf95-debug.setup      xlf2003.setup.csh
  gfortran.setup            pgf95-debug.setup.csh

```
[Note: as of the time of writing, October 2020, only `ifort.setup`, `ifort-debug.setup`, `gfortran.setup`, `gfortran-debug.setup` have been actively developed and tested.  It is strongly recommended that the user use one of these compilers until the remaining setup files are updated.  Contact the support email address for specific compiler support requests.  The c-shell (.csh) extension files have not been updated.]

All of the above files define values for the environment variables `FC`, `FCFLAGS`, `LDFLAGS`, and `LIBS`.
 
To use these files to define the CRTM build environment, you should source them. For example, if you use the sh/bash/ksh shells and you want to setup
for a build using the gfortran compiler using debug options you would type:

**Configuration Step 1**

    . configuration/gfortran-debug.setup

(note the `. ` -- for a detailed discussion of `.` vs. `source` see: https://unix.stackexchange.com/questions/58514/what-is-the-difference-between-and-source-in-shells)

**Configuration Step 2**

    . ./Set_CRTM_Environment.sh

Again noting the leading `. `.  This sets the required environment variables to identify various paths needed to build.  `CRTM_ROOT`, `CRTM_SOURCE_ROOT`, etc.

**Configuration Step 3**
<pre>
cd src/
cd Build/
make clean  
cd ..  
make realclean  
make  
</pre>
The commands `make clean` and `make realclean` ensures that the underlying links, compiled files, generated Makefiles. are removed to avoid conflicts with a clean build.
The command `make` at the `src/` level performs the linking process between the upper level `src/**` directories and the `src/Build/libsrc` directory.  

Note: After runnin `make`, you may see certain "nc4" files listed as missing, these are files that will be converted to netCDF4 format, but have not yet been added.  

Assuming no fatal error messages, continue to the Build steps below.

**Build Step 1**
<pre>
cd Build/
./configure --prefix=${PWD}
make clean
make -j4
</pre>

(See additional options for `configure` below.  `-j4` sets the number of parallel make processes to 4.)

Now we have finally compiled the linked source codes that reside in the `libsrc/` directory.    Please note that once the source codes are linked in the libsrc directory, all development and testing can occur at the `Build/` level.  In the `libsrc/` directory, the source codes link back to the version-controlled counterparts, so you'll want to answer "yes" to any queries about opening the version controlled codes when trying to edit them (this occurs in `emacs`, for example).

**Build Step 2**
<pre>
cd libsrc/
ls -l *.mod
ls -l *.a
make check
make install
</pre>

The `ls` commands are to verify that indeed the .mod files have been created and the library file (which external codes link against) has also been created.
The `make check` command 

Summary of Build Script
-----------------------
<pre>
. configuration/gfortran-debug.setup  
. ./Set_CRTM_Environment.sh  
cd src/  
make realclean  
make  
cd Build/  
./configure --prefix=${PWD}  
make clean  
make -j4  
cd libsrc/  
ls -l *.mod  
ls -l *.a  
rm -rf make_check.out  
make check > make_check.out  
head -n10 make_check.out  
tail -n10 make_check.out  
make install  
</pre>

(optional) "Build Release" Setup and Configuration:
--------------------------------------------------

Within the 'src/Build' directory, The legacy build system for the CRTM uses an autoconf-generated `configure` script, which depends on the existence of a few key files.  
(1) the `configure.ac` file, which contains instructions for how the `configure` file will be built when the `autoconf` command is executed.   
(2) The `Makefile.in` file, which contains instructions on how executing the `configure` script will generate `Makefile` in libsrc and test subdirectories.  

The Build `Makefile`s assume that environment variables (envars) will be defined that describe the compilation environment. The envars
that *must* be defined are:  
  FC:      the Fortran95/2003 compiler executable,  
  FCFLAGS: the flags/switches provided to the Fortran compiler.
These can be set (in the Build directory) by `. ./config-setup/<compiler>.setup` as described previously).

In src/Build:
<pre>
. ./config-setup/gfortran-debug.setup
./configure --prefix=${PWD}
make clean
make -j4
make check
make install
</pre>


**Additional options for `configure`**

`configure` sets an install path environment variable, among other things.  This, by default, will set the `lib/` and `include/` directory paths in the `/usr/local/crtm_v2.4.0-alpha/` (or whatever string in in `src/CRTM_Version.inc`).  

The `--prefix` switch sets the installation directory, make sure you have write access to that directory.  

You can override this by setting a different install directory as follows:  
  `./configure --prefix=<install directory>`  
For example, `./configure --prefix=${PWD}` will create the library in the directory in which you're currently in (e.g., CRTM_dev/src/Build/crtm_v2.4.0-alpha/).

By default, the CRTM is built for big-endian I/O. The --disable-big-endian switch builds the library and test programs for little-endian I/O:

  `$ ./configure --disable-big-endian --prefix=<install directory>`

If you need more flexibility in the library build you can specify the necessary information directly to the configure script that generates the Makefiles. For
example, for the Intel ifort compiler:
```
  $ ./configure --prefix=${PWD} \
                --disable-big-endian \
                FC="ifort" \
                FCFLAGS="-O3 -openmp -g -traceback" 
```
This overrides the FC and FCFLAGS variables that were set by "sourcing" the `configuration/` file earlier, it is strongly recommended that you use the provided configuration files since they contain flags that have been added after substantial debugging and testing.



**Feedback and Contact Information**

CRTM SUPPORT EMAIL: crtm-support@googlegroups.com OR visit https://forums.jcsda.org/

If you have problems building the library please include the generated "config.log" file in your email correspondence.



Known Issues
============

(1) Transmitance Coefficient generation codes included in src/ are not functional.  Contact CRTM support above for details.  
(2) No testing was done on PGI compilers.  
(3) Compiler setup files do not contain "generic" ways to point to netCDF libraries - you need to edit those files and ensure that the paths point to the correct place.



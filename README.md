Repository to build wheels
==========================

We are using this repo to build wheels for symengine.py. Instead of using
the multibuild infrastructure, we are using conda-forge infrastructure
because of few reasons

  1. Dependencies like LLVM which take a lot of time are pre-built
  2. cross-compiling is supported.

In order to use conda-forge built dependencies, there are a few catches
due to the use of recent libgcc and libsdtcxx. In order to do that, we
need to do the following for Linux,

  1. If C shared libraries are used, they need to be built with 
     `-static-libgcc` or cross our fingers that they don't need
     a newer version of libgcc. (We checked and they didn't)
     Else use static libraries.
  2. Use only static libraries for C++ dependencies.
  3. Build the wrapper with `-static-libgcc -static-libstdcxx`

For macOS we need to do the following,

  1. Use only static libraries for C++ dependencies.
  2. Link in libc++ statically or hope that the dependencies don't
     use newer features of libc++. (We checked and they didn't)

For Windows,

  1. Hope that the user has install Visual C++ 2017 Redistributable;

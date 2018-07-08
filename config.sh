function install_cmake {
    if [ -e cmake-stamp ]; then
       return;
    fi
    if [ -n "$IS_OSX" ]; then
        brew install cmake || true
        cmake --version
    else
        yum install -y cmake28 > /dev/null
        if [ -f "$BUILD_PREFIX/bin/cmake" ]; then
            rm $BUILD_PREFIX/bin/cmake
        fi
        ln -s `which cmake28` $BUILD_PREFIX/bin/cmake
    fi
    touch cmake-stamp
}

function build_gmp {
    local version=$1
    local url=$2
    if [ -e gmp-stamp ]; then
       return;
    fi
    fetch_unpack $url/gmp-${version}.tar.bz2
    (cd gmp-${version} \
        && ./configure --prefix=$BUILD_PREFIX --enable-fat --enable-shared \
        && make \
        && make install)
    touch gmp-stamp
}

function build_symengine {
    export PATH=$PATH:$BUILD_PREFIX/bin

    local version=$1
    local url=$2
    if [ -e symengine-stamp ]; then
       return;
    fi
    fetch_unpack $url/${version}.tar.gz

    local ver=${version}
    if [[ $ver == "v"* ]]
    then
       ver=${ver:1};
    fi

    mv archives/${version}.tar.gz archives/libsymengine-${version}.tar.gz || true

    (cd symengine-${ver}                            \
        && cmake -DWITH_MPC=yes                     \
              -DBUILD_FOR_DISTRIBUTION=yes          \
              -DCMAKE_BUILD_TYPE=Release            \
              -DCMAKE_PREFIX_PATH=$BUILD_PREFIX     \
              -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX  \
              -DWITH_COTIRE=no                      \
              -DBUILD_TESTS=no                      \
              -DBUILD_BENCHMARKS=no                 \
              -DBUILD_SHARED_LIBS=no .              \
        && make -j4                                 \
        && make install)

    touch symengine-stamp
}

function pre_build {
    set -x
    #echo "nameserver 192.248.8.97" > /etc/resolv.conf
    export PATH=$PATH:$BUILD_PREFIX/bin
    if [ -n "$IS_OSX" ]; then
        export CC="clang"
        export CXX="clang++"
        export CFLAGS="-arch x86_64"
        export CXXFLAGS="-arch x86_64"
        export LDFLAGS="-arch x86_64"
        export MACOSX_DEPLOYMENT_TARGET="10.9"
    fi
    local symengine_version=`cat symengine/symengine_version.txt`

    build_gmp 6.1.2 https://gmplib.org/download/gmp
    build_simple mpfr 3.1.5 http://ftp.gnu.org/gnu/mpfr
    build_simple mpc 1.0.3 https://ftp.gnu.org/gnu/mpc/
    install_cmake
    build_symengine $symengine_version https://github.com/symengine/symengine/archive
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import symengine; symengine.test()"
}

if [ -n "$IS_OSX" ]; then
    function repair_wheelhouse {
        echo "custom repair_wheelhouse for osx"
        local wheelhouse=$1
        check_pip
        $PIP_CMD install delocate
        delocate-listdeps $wheelhouse/*.whl # lists library dependencies
        # repair_wheelhouse can take more than 10 minutes without generating output
        # but jobs that do not generate output within 10 minutes are aborted by travis-ci.
        # Echoing something here solves the problem.
        echo in repair_wheelhouse, executing delocate-wheel
        delocate-wheel $wheelhouse/*.whl # copies library dependencies into wheel

        local wheels=$(python $MULTIBUILD_DIR/supported_wheels.py $wheelhouse/*.whl)
        for wheel in $wheels
        do
            se_file_name=$(basename $wheel)
            se_file_name="${se_file_name/macosx_10_6_intel./macosx_10_9_x86_64.macosx_10_10_x86_64.}"
            mv $wheel $wheelhouse/$se_file_name
        done
    }
fi

function install_cmake {
    if [ -n "$IS_OSX" ]; then
        brew install cmake || true
        cmake --version
    else
        yum install -y cmake28 > /dev/null
        rm $BUILD_PREFIX/bin/cmake
        ln -s `which cmake28` $BUILD_PREFIX/bin/cmake
    fi
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
    export PATH=$BUILD_PREFIX/bin:$PATH

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

    (cd symengine-${ver}                            \
        && cmake -DWITH_MPC=yes                     \
              -DBUILD_FOR_DISTRIBUTION=yes          \
              -DCMAKE_BUILD_TYPE=Release            \
              -DCMAKE_PREFIX_PATH=$BUILD_PREFIX     \
              -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX  \
              -DWITH_COTIRE=no                      \
              -DBUILD_TESTS=no                      \
              -DBUILD_BENCHMARKS=no                 \
              -DBUILD_SHARED_LIBS=yes .             \
        && make -j4                                 \
        && make install)

    touch symengine-stamp
}

function pre_build {
    set -x
    #echo "nameserver 192.248.8.97" > /etc/resolv.conf
    export PATH=$BUILD_PREFIX/bin:$PATH
    if [ -n "$IS_OSX" ]; then
        export CC="clang"
        export CC="clang++"
        export CFLAGS="-arch x86_64"
        export CXXFLAGS="-arch x86_64"
        export LDFLAGS="-arch x86_64"
        export MACOSX_DEPLOYMENT_TARGET="10.9"
        function build_wheel {
            # Set default building method to pip
            build_pip_wheel $@
            local wheelhouse=$(abspath ${WHEEL_SDIR:-wheelhouse})
            local wheels=$(python $MULTIBUILD_DIR/supported_wheels.py $wheelhouse/*.whl)
            for wheel in $wheels
            do
                se_file_name=$(basename $wheel)
                se_file_name="${se_file_name/macosx_10_6_intel./macosx_10_9_x86_64.macosx_10_10_x86_64.}"
                mv $wheel $wheelhouse/$se_file_name
            done
        }
    fi
    local symengine_version=`cat symengine/symengine_version.txt`

    build_gmp 6.1.2 https://gmplib.org/download/gmp
    build_simple mpfr 3.1.5 http://ftp.gnu.org/gnu/mpfr
    build_simple mpc 1.0.3 http://www.multiprecision.org/mpc/download
    install_cmake
    build_symengine $symengine_version https://github.com/symengine/symengine/archive
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import symengine; symengine.test()"
}

function get_cmake3 {
    if [ -n "$IS_OSX" ]; then
        brew install cmake > /dev/null
    else
         if [ -e "cmake-stamp" ]; then
            return
         fi
         # curl -L -o cmake_script.sh https://cmake.org/files/v3.8/cmake-3.8.2-Linux-x86_64.sh
         # bash cmake_script.sh --prefix=$BUILD_PREFIX <<< $'Y\nn\n'
         yum install -y cmake28 > /dev/null
         rm $BUILD_PREFIX/bin/cmake
         ln -s `which cmake28` $BUILD_PREFIX/bin/cmake
         touch cmake-stamp
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

function pre_build {
    set -x
    echo "nameserver 192.248.8.97" > /etc/resolv.conf
    build_gmp 6.1.2 https://gmplib.org/download/gmp
    build_simple mpfr 3.1.5 http://ftp.gnu.org/gnu/mpfr
    build_simple mpc 1.0.3 http://www.multiprecision.org/mpc/download
    get_cmake3
    export PATH=$BUILD_PREFIX/bin:$PATH
    symengine_version=`cat symengine/symengine_version.txt`
    cd libsymengine
    git checkout ${symengine_version}
    ls ${BUILD_PREFIX}/lib
    ls ${BUILD_PREFIX}/include
    #export CPPFLAGS="-I${BUILD_PREFIX}/include ${CPPFLAGS}"
    cmake -DWITH_MPC=yes \
           -DBUILD_FOR_DISTRIBUTION=yes \
           -DCMAKE_BUILD_TYPE=Release \
           -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
           -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
           -DWITH_COTIRE=no \
           -DBUILD_SHARED_LIBS=yes .
    make symengine -j4
    make install
    cd ..
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    echo "nameserver 192.248.8.97" > /etc/resolv.conf
    python -c "import symengine; symengine.test()"
}

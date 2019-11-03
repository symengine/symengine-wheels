function install_cmake {
    if [ -e cmake-stamp ]; then
       return;
    fi
    if [ -n "$IS_OSX" ]; then
        brew install cmake || true
        cmake --version
    else
        mkdir cmake && cd cmake
        fetch_unpack https://github.com/isuruf/isuruf.github.io/releases/download/v1.0/cmake-3.10.2-manylinux1_x86_64.tar.gz
        cd ..
        rsync -av cmake/* $BUILD_PREFIX
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

function install_llvm {
    if [ -e llvm-stamp ]; then
       return;
    fi
    if [ -n "$IS_OSX" ]; then
        local MINICONDA_URL="https://repo.continuum.io/miniconda"
        local MINICONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh"
        curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
        bash $MINICONDA_FILE -b
        source /Users/travis/miniconda3/bin/activate root
        conda config --add channels conda-forge
        conda config --set show_channel_urls true
        conda create -y -q -p `pwd`/llvm llvmdev=8.0.1
        conda remove -y -q -p `pwd`/llvm libcxx --force
        for c in bin lib share include; do
            mkdir -p $BUILD_PREFIX/$c
            sudo rsync -av `pwd`/llvm/$c/ $BUILD_PREFIX/$c/
        done
        source /Users/travis/miniconda3/bin/deactivate
    else
        yum install xz -y
        mkdir llvm-8.0.1 && cd llvm-8.0.1
        fetch_unpack https://github.com/isuruf/isuruf.github.io/releases/download/v1.0/llvm-8.0.1-manylinux1_x86_64.tar.gz
        cd ..
        local archive_fname=llvm-8.0.1.src.tar.xz
        local arch_sdir="${ARCHIVE_SDIR:-archives}"
        # Make the archive directory in case it doesn't exist
        mkdir -p $arch_sdir
        local out_archive="${arch_sdir}/${archive_fname}"
        # Fetch the archive if it does not exist
        if [ ! -f "$out_archive" ]; then
            curl -L http://releases.llvm.org/8.0.1/llvm-8.0.1.src.tar.xz > $out_archive
        fi
        rsync -av llvm-8.0.1/* $BUILD_PREFIX
    fi
    touch llvm-stamp
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
              -DWITH_LLVM=yes                       \
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
    build_simple mpfr 4.0.2 https://ftp.gnu.org/gnu/mpfr
    build_simple mpc 1.1.0 https://ftp.gnu.org/gnu/mpc/
    install_llvm
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

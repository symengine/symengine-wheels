rm -r venv
set -x
export REPO_DIR=symengine
        # Commit from your-project that you want to build
export BUILD_COMMIT=00e126f36af227f36288ae1ff7b5e5877868e640
        # pip dependencies to _build_ your project
export BUILD_DEPENDS="Cython numpy"
export NP_BUILD_DEP="numpy==1.8.1"
export NP_TEST_DEP="numpy==1.8.1"
        # pip dependencies to _test_ your project.  Include any dependencies
        # that you need, that are also specified in BUILD_DEPENDS, this will be
        # a separate install.
export TEST_DEPENDS="numpy pytest"
export PLAT=x86_64
export UNICODE_WIDTH=32
export MB_PYTHON_VERSION=3.5
source multibuild/common_utils.sh
source multibuild/travis_steps.sh
before_install
clean_code $REPO_DIR $BUILD_COMMIT
build_wheel $REPO_DIR $PLAT
install_run $PLAT

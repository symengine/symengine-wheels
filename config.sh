function pre_build {
    yum install libmpc-devel
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
}

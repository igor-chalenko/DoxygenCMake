# suppress the warning coming from empty arch check `if("TRUE)`
cmake_policy(SET CMP0012 NEW)
set(_project_source_dir "${CMAKE_CURRENT_BINARY_DIR}/../..")

macro(_doxygen_find_package _name)
    find_package(${_name} ${ARGN})
endmacro()

include(${_project_source_dir}/cmake/add-docs.cmake)
include(${_project_source_dir}/test/cmake/CommonTest.cmake)

function(add_docs_test)
    log_level(doxygen-cmake-report DEBUG)
    create_mock_target(main EXECUTABLE)
    # it's not set in the script mode
    set(PROJECT_NAME main)
    add_doxygen_targets(
            PROJECT_FILE ${_project_source_dir}/test/cmake/Doxyfile3
            INPUT_TARGET main)

    #target_created(main.doxygen.open_html _doxygen_docs_open_html)
    #assert(_doxygen_docs_open_html)
endfunction()

function(override_parameters_test)
    create_mock_target(main EXECUTABLE)
    set(PROJECT_NAME main)
    add_doxygen_targets(
            PROJECT_FILE ${_project_source_dir}/test/cmake/Doxyfile3
            INPUT_TARGET main
            WARN_AS_ERROR YES
    )
    assert_empty("${WARN_AS_ERROR}")
    _doxygen_load_project(${CMAKE_CURRENT_BINARY_DIR}/Doxyfile3 _properties)
    assert_same(${WARN_AS_ERROR} YES)
endfunction()

set(CMAKE_CURRENT_SOURCE_DIR "${SOURCE_ROOT_DIR}")
add_docs_test()
override_parameters_test()
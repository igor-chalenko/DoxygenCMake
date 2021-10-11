set(_project_source_dir "${CMAKE_CURRENT_BINARY_DIR}/../..")

include(${_project_source_dir}/cmake/AddDocs.cmake)
include(${_project_source_dir}/test/cmake/CommonTest.cmake)

function(load_project_test)
    _doxygen_load_project(${_project_source_dir}/test/cmake/Doxyfile2 _properties)
    assert_same(${OUTPUT_DIRECTORY} docs1)
    assert_same(${INPUT} "include2 include3")
    assert_same("${EXAMPLE_PATH}" "examples1 examples2")
    assert_same(${DOT_MULTI_TARGETS} YES)
endfunction()

function(update_project_test)
    log_level(doxygen-cmake DEBUG)
    _doxygen_load_project(${_project_source_dir}/test/cmake/Doxyfile2 _properties)
    assert_same("${OUTPUT_DIRECTORY}" "docs1")

    _doxygen_update_properties(_properties INPUT "test/include") # EXAMPLE_PATH examples)
    assert_same(${INPUT} "${CMAKE_CURRENT_SOURCE_DIR}/test/include")
    assert_same("${EXAMPLE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/examples1;${CMAKE_CURRENT_SOURCE_DIR}/examples2")
    assert_same("${OUTPUT_DIRECTORY}" "${CMAKE_CURRENT_BINARY_DIR}/docs1")

    _doxygen_save_project(Doxyfile3 ${_properties})
endfunction()

load_project_test()
update_project_test()

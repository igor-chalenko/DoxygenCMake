cmake_minimum_required(VERSION 3.19)

set(_project_source_dir "${doxygen.cmake.path}/..")
include(${doxygen.cmake.path}/../test/cmake/CommonTest.cmake)

#log_level(doxygen-cmake DEBUG)
# there's no project name in the script mode
set(PROJECT_NAME test)

function(test_project_file)
    _doxygen_parse_inputs(PROJECT_FILE Doxyfile)
    assert_same(${PROJECT_FILE} Doxyfile)
    assert_empty("${INPUT_TARGET}")
    assert_same(${INSTALL_COMPONENT} docs)
    assert_same(${DOCS_TARGET} test.doxygen)
    assert_same(${GENERATE_HTML} YES)
    assert_same(${GENERATE_PDF} FALSE)
endfunction()

function(test_input_target)
    _doxygen_parse_inputs(INPUT_TARGET main)
    assert_same(${PROJECT_FILE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.in)
    assert_same(${INPUT_TARGET} main)
endfunction()

function(test_docs_target)
    _doxygen_parse_inputs(DOCS_TARGET docs
            INSTALL_COMPONENT component
            GENERATE_PDF
            GENERATE_HTML NO)
    assert_same(${DOCS_TARGET} docs)
    assert_same(${INSTALL_COMPONENT} component)
    assert_same(${GENERATE_HTML} NO)
    assert_same(${GENERATE_PDF} TRUE)
endfunction()

test_project_file()
test_input_target()
test_docs_target()

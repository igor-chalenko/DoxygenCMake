function(test_input_flags_1)
    _doxygen_params_init()
    _doxygen_inputs_parse(GENERATE_XML GENERATE_LATEX GENERATE_HTML NO)

    _doxygen_get(GENERATE_XML _xml)
    _doxygen_get(GENERATE_LATEX _latex)
    _doxygen_get(GENERATE_HTML _html)
    assert_same(${_xml} YES)
    assert_same(${_latex} YES)
    assert_same(${_html} NO)

    global_map_clear_scope()
endfunction()

function(test_input_flags_2)
    _doxygen_params_init()
    _doxygen_inputs_parse(GENERATE_LATEX)
    _doxygen_project_update(_out cmake/Doxyfile GENERATE_LATEX)

    _doxygen_get(GENERATE_XML _xml)
    _doxygen_get(GENERATE_LATEX _latex)
    _doxygen_get(GENERATE_HTML _html)
    assert_same(${_xml} NO)
    # assert_same(${_latex} true)
    assert_same(${_html} YES)

    global_map_clear_scope()
endfunction()

# give input directories as input and read them back
function(test_input_directories_1)
    global_map_index(_index)
    _doxygen_params_init()

    set(_args INPUT dir1/dir3 dir2)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile ${_args})

    _doxygen_get("INPUT" _inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/dir1/dir3;${CMAKE_CURRENT_SOURCE_DIR}/dir2")
    global_map_clear_scope()
endfunction()

# there's no target with the name ${PROJECT_NAME}, so the input sources are
# empty.
function(test_input_directories_2)
    _doxygen_params_init()
    set(_args PROJECT_FILE Doxyfile2 INPUT x)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile2 ${_args})

    _doxygen_get("INPUT" _inputs)
    assert_same("${_inputs}" "${CMAKE_CURRENT_SOURCE_DIR}/x")
    global_map_clear_scope()
endfunction()

# includes are taken from the input target
function(test_input_directories_3)
    _doxygen_params_init()
    set(_args INPUT_TARGET main)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile ${_args})

    _doxygen_get(INPUT _inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/include;${CMAKE_CURRENT_SOURCE_DIR}/include5")
    global_map_clear_scope()
endfunction()

function(test_output_directory)
    _doxygen_params_init()
    set(_args PROJECT_FILE Doxyfile2 OUTPUT_DIRECTORY "docs2")
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile2 ${_args})

    _doxygen_get("OUTPUT_DIRECTORY" _output)
    assert_same("${_output}" "${CMAKE_CURRENT_BINARY_DIR}/docs2")
    global_map_clear_scope()
endfunction()

function(test_custom_project_file_1)
    _doxygen_params_init()
    set(_args PROJECT_FILE cmake/Doxyfile2)
    _doxygen_inputs_parse(${_args})

    _doxygen_project_update(_out cmake/Doxyfile2 ${_args})

    _doxygen_get("PROJECT_FILE" _project_file)
    _doxygen_get("OUTPUT_DIRECTORY" _output)
    _doxygen_get("EXAMPLE_PATH" _examples)

    assert_same("${_project_file}"
            "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Doxyfile2")
    # assert_same("${_output}" "${CMAKE_CURRENT_BINARY_DIR}/docs1")
    assert_same("${_examples}"
            "${CMAKE_CURRENT_SOURCE_DIR}/examples1;${CMAKE_CURRENT_SOURCE_DIR}/examples2")
    global_map_clear_scope()
endfunction()

function(test_custom_project_file_2)
    _doxygen_params_init()
    set(_args PROJECT_FILE cmake/Doxyfile2 EXAMPLE_PATH x1 x2)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile2 ${_args})

    _doxygen_get("EXAMPLE_PATH" _examples)
    assert_same("${_examples}"
            "${CMAKE_CURRENT_SOURCE_DIR}/x1;${CMAKE_CURRENT_SOURCE_DIR}/x2")
    global_map_clear_scope()
endfunction()

function(test_input_directories_full_1)
    doxygen_add_override("WARNINGS" NO)
    doxygen_add_override("QUIET" NO)
    doxygen_add_override("TOC_INCLUDE_HEADINGS" 2)
    global_map_get(WARNINGS_OVERWRITE _overwrite)

    _doxygen_params_init()
    set(_args INPUT dir1 dir2)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile ${_args})

    _doxygen_project_load(${_out})
    _doxygen_get("INPUT" _inputs)

    separate_arguments(_inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/dir1;${CMAKE_CURRENT_SOURCE_DIR}/dir2")

    _doxygen_get("WARNINGS" _warnings)
    assert_same(${_warnings} NO)
    _doxygen_get("QUIET" _quiet)
    assert_same(${_quiet} NO)
    _doxygen_get("TOC_INCLUDE_HEADINGS" _headers)
    assert_same(${_headers} "2")
    global_map_clear_scope()
endfunction()

function(test_input_directories_full_2)
    doxygen_add_override("WARNINGS" NO)

    _doxygen_params_init()
    set(_args INPUT_TARGET main)
    _doxygen_inputs_parse(${_args})
    _doxygen_project_update(_out cmake/Doxyfile ${_args})

    _doxygen_project_load(${_out})

    _doxygen_get(INPUT _inputs)

    separate_arguments(_inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/include;${CMAKE_CURRENT_SOURCE_DIR}/include5")
    _doxygen_get("WARNINGS" _warnings)
    assert_same(${_warnings} NO)
    global_map_clear_scope()
endfunction()

# Make sure LATEX module is imported when GENERATE_LATEX is true.
# Will only perform the tests if latex is installed.
function(test_latex_find_package)
    _doxygen_params_init()
    set(_args GENERATE_LATEX)
    _doxygen_parse_inputs(${_args})
    _doxygen_project_update(_out cmake/Doxyfile ${_args})

    global_map_get(LATEX_FOUND _latex_found)
    if (_latex_found STREQUAL "")
        _doxygen_assert_fail("LATEX_FOUND not set")
    endif()
    global_map_clear_scope()
endfunction()

set(doxygen.project.dir "${CMAKE_CURRENT_SOURCE_DIR}")

test_input_flags_1()
test_input_flags_2()
test_input_directories_1()
test_input_directories_2()
test_input_directories_3()
test_output_directory()
test_custom_project_file_1()
test_custom_project_file_2()
test_input_directories_full_1()
test_input_directories_full_2()
test_latex_find_package()

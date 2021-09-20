function(test_input_directories_full_3)
    # todo there was a test of override precedence here
    #doxygen_add_override("GENERATE_LATEX" NO)
    #set(LATEX_FOUND NO)
    doxygen_prepare_doxyfile(INPUT_TARGET main
            INPUT dir1 dir2)
    doxygen_add_docs(
            INPUT_TARGET main
            INPUT dir1 dir2)

    _doxygen_project_load(${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
    _doxygen_get(INPUT _inputs)
    separate_arguments(_inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/dir1;${CMAKE_CURRENT_SOURCE_DIR}/dir2")
    TPA_clear_scope()
endfunction()

set(doxygen.project.dir "${CMAKE_CURRENT_SOURCE_DIR}")
test_input_directories_full_3()

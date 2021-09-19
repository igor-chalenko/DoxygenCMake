function(test_input_directories_full_3)
    doxypress_add_override("output-latex.generate-latex" false)
    set(LATEX_FOUND true)
    doxypress_add_docs(
            INPUT_TARGET main
            INPUTS dir1 dir2 GENERATE_LATEX)

    _doxypress_project_load(${CMAKE_CURRENT_BINARY_DIR}/DoxypressCMake.json)
    _JSON_get("doxypress.${_DOXYPRESS_INPUT_SOURCE}" _inputs)
    assert_same("${_inputs}"
            "${CMAKE_CURRENT_SOURCE_DIR}/dir1;${CMAKE_CURRENT_SOURCE_DIR}/dir2")
    _doxypress_get("output-latex.generate-latex" _latex)
    assert_same(${_latex} true)
    unset(LATEX_FOUND)
endfunction()

function(test_logging)
    include(${PROJECT_SOURCE_DIR}/cmake/FindDoxypressCMake.cmake)
    add_executable(main2 src/main.cc)
    set_target_properties(main2 PROPERTIES EXCLUDE_FROM_ALL 1)
    target_include_directories(main2 PUBLIC
            "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/test/include>")

    #_doxypress_params_init()
    #_doxypress_inputs_parse(INPUT_TARGET main GENERATE_XML GENERATE_PDF)
    #_doxypress_project_update(../cmake/DoxypressCMake.json _out)
    doxypress_add_override("output-latex.latex-cmd-name" "/usr/local/texlive/2020/bin/x86_64-linux/pdflatex")
    doxypress_add_docs(INPUT_TARGET main2 GENERATE_XML)

    TPA_get("histories" _histories)
    foreach(_property ${_histories})
        TPA_get(history.${_property} _messages)
        _doxypress_log(INFO "actions for ${_property}: ====")
        foreach(_message ${_messages})
            _doxypress_log(INFO ${_message})
        endforeach()
        _doxypress_log(INFO "====")
    endforeach()
    TPA_clear_scope()
endfunction()

#test_input_directories_full_3()
test_logging()
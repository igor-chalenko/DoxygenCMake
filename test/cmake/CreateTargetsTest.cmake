# suppress the warning coming from empty arch check `if("TRUE)`
cmake_policy(SET CMP0012 NEW)
set(_project_source_dir "${CMAKE_CURRENT_BINARY_DIR}/../..")

include(${_project_source_dir}/test/cmake/FindPackageWrapper.cmake)
include(${_project_source_dir}/cmake/add-docs.cmake)
include(${_project_source_dir}/test/cmake/CommonTest.cmake)

function(test_create_targets)
    set(OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    set(GENERATE_HTML YES)
    set(GENERATE_LATEX YES)
    #_JSON_set(doxygen.output-latex.generate-latex true)
    set(GENERATE_PDF true)

    create_mock_target(main EXECUTABLE)
    set(INPUT_TARGET main)
    set(DOCS_TARGET "doxygen_docs")
    set(PROJECT_FILE ${_project_source_dir}/test/cmake/Doxyfile2)
    configure_file(${_project_source_dir}/test/cmake/Doxyfile2
            ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile2 @ONLY)
    _doxygen_create_generate_docs_target(
            "${WORKING_DIRECTORY}"
            "${PROJECT_FILE}"
            "${OUTPUT_DIRECTORY}"
            ${DOCS_TARGET}
            ${GENERATE_PDF})
    _doxygen_create_open_targets(
            "${PROJECT_FILE}"
            "${OUTPUT_DIRECTORY}"
            ${DOCS_TARGET}
            ${GENERATE_HTML}
            ${GENERATE_LATEX}
            ${GENERATE_PDF})

    target_created(doxygen_docs _doxygen_docs)
    target_created(doxygen_docs.open_html doxygen_docs_open_html)
    target_created(doxygen_docs doxygen_docs_open_latex)
    target_created(doxygen_docs doxygen_docs_open_pdf)

    if (NOT _doxygen_docs)
        assert(false "doxygen target `doxygen_docs` was not created")
    endif()
    if (NOT doxygen_docs_open_html)
        assert(false "The target `doxygen_docs.open_html` was not created")
    endif()
    if (NOT doxygen_docs_open_latex)
        assert(false "The target `doxygen_docs.open_latex` was not created")
    endif()
    if (NOT doxygen_docs_open_pdf)
        assert(false "The target `doxygen_docs.open_pdf` was not created")
    endif()
endfunction()

test_create_targets()
cmake_policy(SET CMP0054 NEW)
get_filename_component(_doxygen_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

include(${_doxygen_dir}/AddDocs.cmake)

#set(_inputs "${args}")
set(doxygen.project.dir "${project_dir}")
set(_project_file ${PROJECT_FILE})
if (DEFINED GENERATE_HTML)
    set(_html GENERATE_HTML ${GENERATE_HTML})
else()
    set(_html "")
endif()
if (DEFINED GENERATE_XML)
    set(_xml GENERATE_XML ${GENERATE_XML})
else()
    set(_xml "")
endif()
if (DEFINED GENERATE_LATEX)
    set(_latex GENERATE_LATEX ${GENERATE_LATEX})
else()
    set(_latex "")
endif()
if (DEFINED GENERATE_PDF)
    set(_pdf GENERATE_PDF ${GENERATE_PDF})
else()
    set(_pdf "")
endif()
if (DEFINED QUIET)
    set(_quiet QUIET ${QUIET})
else()
    set(_quiet "")
endif()
if (DEFINED WARNINGS)
    set(_warnings WARNINGS ${WARNINGS})
else()
    set(_warnings "")
endif()

#set(DOXYGEN_LOG_LEVEL DEBUG)
set(_cmd PROJECT_FILE "${PROJECT_FILE}"
        INPUT "${INPUT}"
        INPUT_TARGET "${INPUT_TARGET}"
        TARGET_NAME "${TARGET_NAME}"
        INSTALL_COMPONENT "${INSTALL_COMPONENT}"
        ${_html}
        ${_xml}
        ${_latex}
        ${_pdf}
        OUTPUT_DIRECTORY "${OUTPUT_DIRECTORY}"
        ${_quiet}
        ${_warnings})
message(STATUS "_cmd = ${_cmd}")
doxygen_prepare_doxyfile(${_cmd})

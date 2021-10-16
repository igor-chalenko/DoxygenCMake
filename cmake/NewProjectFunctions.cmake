cmake_policy(SET CMP0057 NEW)

function(_doxygen_load_project _project_file_name _out)
    unset(_properties)
    log_info(doxygen-cmake "Loading project template ${_project_file_name}...")

    file(STRINGS "${_project_file_name}" _file_lines)
    foreach(_line IN LISTS _file_lines)
        if(_line MATCHES "^([A-Z][A-Z0-9_]+)( *=)(.*)")
            set(_key "${CMAKE_MATCH_1}")
            set(_eql "${CMAKE_MATCH_2}")
            set(_value "${CMAKE_MATCH_3}")
            #string(REPLACE "\"" "\\\\\"" _value "${_value}")
            string(REPLACE "\\" "\\\\" _value "${_value}")
            string(REPLACE ";" "\\\n" _value "${_value}")
            string(STRIP ${_key} _key)
            string(STRIP "${_value}" _value)
            set(_key "${_key}")

            set(${_key} "${_value}" PARENT_SCOPE)
            list(APPEND _properties ${_key})
        endif()
    endforeach()
    set(${_out} ${_properties} PARENT_SCOPE)
endfunction()

function(_doxygen_save_project _project_file_name)
    assert_not_empty("${_project_file_name}")

    unset(_contents)
    foreach(_key IN LISTS ARGN)
        string(APPEND _contents "${_key} = @${_key}@\n")

        set(_value "${${_key}}")
        string(SUBSTRING "${_value}" 0 1 _first_char)
        string(FIND "${_value}" " " _ind)
        string(FIND "${_value}" "\n" _multiline)

        if (_ind GREATER -1 AND NOT _first_char STREQUAL "\"" AND _multiline EQUAL -1)
            set(${_key} "\"${_value}\"")
            set(${_key} "\"${_value}\"" PARENT_SCOPE)
        endif()
        #message(STATUS "!!! _value=${_value}, _len = ${_len}")
    endforeach()

    log_info(doxygen "Saving project file ${_project_file_name}.in ...")
    file(WRITE "${_project_file_name}.in" "${_contents}")

    configure_file("${_project_file_name}.in" "${_project_file_name}" @ONLY)
endfunction()

macro(_doxygen_parse_inputs)
    _doxygen_parse_input(
            PROJECT_FILE
            STRING
            SETTER "set_project_file"
            UPDATER "update_project_file" ${ARGN})
    _doxygen_parse_input(INPUT_TARGET STRING SETTER "set_input_target" ${ARGN})
    _doxygen_parse_input(DOCS_TARGET STRING UPDATER "update_docs_target" DEFAULT "${_input_target}.doxygen" ${ARGN})
    _doxygen_parse_input(INSTALL_COMPONENT STRING DEFAULT docs ${ARGN})
    _doxygen_parse_input(GENERATE_HTML STRING DEFAULT YES ${ARGN})
    _doxygen_parse_input(GENERATE_PDF OPTION DEFAULT NO ${ARGN})
endmacro()

macro(_doxygen_property _index _name)
    set(doxygen.${_name} ${ARGN})
    list(APPEND ${_index} ${_name})
endmacro()

# _properties = project file
macro(_doxygen_update_properties _properties)
    unset(_specials)

    _doxygen_property(_specials INPUT UPDATER "update_input_source")
    _doxygen_property(_specials GENERATE_XML DEFAULT NO)
    _doxygen_property(_specials GENERATE_LATEX
            UPDATER "update_generate_latex"
            DEFAULT NO)
    _doxygen_property(_specials OUTPUT_DIRECTORY
            UPDATER "update_output_dir"
            DEFAULT "${CMAKE_CURRENT_BINARY_DIR}/doxygen-generated")

    _doxygen_property(_specials HAVE_DOT SETTER "set_have_dot" OVERWRITE)
    _doxygen_property(_specials DOT_PATH SETTER "set_dot_path" OVERWRITE)
    _doxygen_property(_specials DIA_PATH SETTER "set_dia_path" OVERWRITE)
    _doxygen_property(_specials EXAMPLE_PATH
            SETTER "set_example_source"
            UPDATER "update_example_source")
    _doxygen_property(_specials WARN_FORMAT
            SETTER "set_warn_format" OVERWRITE)
    _doxygen_property(_specials MAKEINDEX_CMD_NAME
            SETTER "set_makeindex_cmd_name" OVERWRITE)
    _doxygen_property(_specials LATEX_CMD_NAME
            SETTER "set_latex_cmd_name" OVERWRITE)
    _doxygen_property(_specials LAYOUT_FILE
            UPDATER "update_layout_file")
    _doxygen_property(_specials HTML_HEADER
            UPDATER "update_html_header")
    _doxygen_property(_specials HTML_FOOTER
            UPDATER "update_html_footer")
    _doxygen_property(_specials HTML_EXTRA_STYLESHEET
            UPDATER "update_html_extra_stylesheet")
    _doxygen_property(_specials HTML_EXTRA_FILES
            UPDATER "update_html_extra_files")

    _doxygen_property(_specials PROJECT_BRIEF DEFAULT "${PROJECT_DESCRIPTION}" OVERWRITE)
    _doxygen_property(_specials PROJECT_NAME DEFAULT "${PROJECT_NAME}" OVERWRITE)
    _doxygen_property(_specials PROJECT_VERSION DEFAULT "${PROJECT_VERSION}" OVERWRITE)
    _doxygen_property(_specials LATEX_BATCHMODE DEFAULT YES OVERWRITE)
    _doxygen_property(_specials PDF_HYPERLINKS DEFAULT YES OVERWRITE)
    _doxygen_property(_specials LATEX_OUTPUT DEFAULT "latex" OVERWRITE)
    _doxygen_property(_specials USE_PDFLATEX DEFAULT YES OVERWRITE)

    _doxygen_property(_specials HTML_OUTPUT DEFAULT "html" OVERWRITE)
    _doxygen_property(_specials HTML_FILE_EXTENSION DEFAULT ".html" OVERWRITE)
    _doxygen_property(_specials XML_OUTPUT DEFAULT "xml" OVERWRITE)
    _doxygen_property(_specials RECURSIVE DEFAULT YES OVERWRITE)
    _doxygen_property(_specials EXAMPLE_RECURSIVE DEFAULT YES OVERWRITE)

    foreach(_property ${${_properties}})
        if ("${${_property}}" STREQUAL "")
            _doxygen_parse_input(${_property} STRING ${doxygen.${_property}} ${ARGN})
        else()
            _doxygen_parse_input(${_property} STRING ${doxygen.${_property}} PROJECT_VALUE "${${_property}}" ${ARGN})
        endif()
    endforeach()
endmacro()

function(_doxygen_parse_input _property _type)
    set(_options OVERWRITE)
    set(_one_value_args DEFAULT SETTER UPDATER PROJECT_VALUE)
    set(_multi_value_args "")

    cmake_parse_arguments(PARAM "${_options}" "${_one_value_args}" $"{_multi_value_args}" "${ARGN}")

    unset(_one_value_args)
    unset(_options)
    unset(_multi_value_args)
    if (_type STREQUAL STRING)
        list(APPEND _one_value_args ${_property})
    endif ()
    if (_type STREQUAL OPTION)
        list(APPEND _options ${_property})
    endif ()
    if (_type STREQUAL LIST)
        list(APPEND _multi_value_args ${_property})
    endif ()

    cmake_parse_arguments(IN
            "${_options}"
            "${_one_value_args}"
            "${_multi_value_args}"
            "${ARGN}")

    unset(_value)
    if ("${IN_${_property}}" STREQUAL "")
        list(APPEND _report "${_property} is not in the input arguments")
        if (DEFINED PARAM_PROJECT_VALUE AND NOT PARAM_OVERWRITE)
            list(APPEND _report "${_property} is set to the project value `${PARAM_PROJECT_VALUE}`")
            set(_value "${PARAM_PROJECT_VALUE}")
        else()
            if (DEFINED PARAM_DEFAULT)
                list(APPEND _report "${_property} is set to default `${PARAM_DEFAULT}`")
                set(_value "${PARAM_DEFAULT}")
            else()
                if (DEFINED PARAM_SETTER)
                    list(APPEND _report "${_property} will be set by `${PARAM_SETTER}`")
                    _doxygen_call_setter(${PARAM_SETTER} _value)
                endif()
            endif ()
        endif()
        if (DEFINED PARAM_UPDATER)
            list(APPEND _report "${_property}=${_value} will be updated by `${PARAM_UPDATER}`")
            _doxygen_call_updater(${PARAM_UPDATER} "${_value}" _value)
        endif()
    else()
        list(APPEND _report "${_property} was in the input arguments: `${IN_${_property}}`")
        if (DEFINED PARAM_UPDATER)
            list(APPEND _report "${_property}=`${IN_${_property}}` will be updated by `${PARAM_UPDATER}`")
            _doxygen_call_updater(${PARAM_UPDATER} "${IN_${_property}}" _value)
        else()
            list(APPEND _report "${_property} has no updater, the input value wins")
            set(_value "${IN_${_property}}")
        endif()
    endif()
    list(APPEND _report "${_property} becomes `${_value}`")
    foreach (_line IN LISTS _report)
        log_debug(_doxygen_parse_input "${_line}")
    endforeach()
    set(${_property} "${_value}" PARENT_SCOPE)
endfunction()

function(_doxygen_call_setter _setter _out_var)
    _doxygen_call_1(${_setter} _new_value)
    set(${_out_var} "${_new_value}" PARENT_SCOPE)
endfunction()

function(_doxygen_call_updater _updater _current_value _out_var)
    _doxygen_call_2(${_updater} "${_current_value}" _new_value)
    set(${_out_var} "${_new_value}" PARENT_SCOPE)
endfunction()

macro(_doxygen_call_1 _id _arg1)
    if (NOT COMMAND _doxygen_${_id})
        message(FATAL_ERROR "Unsupported function/macro \"${_id}\"")
    else ()
        dynamic_call(_doxygen_${_id} "${_arg1}")
    endif ()
endmacro()

macro(_doxygen_call_2 _id _arg1 _arg2)
    if (NOT COMMAND _doxygen_${_id})
        message(FATAL_ERROR "Unsupported function/macro \"${_id}\"")
    else ()
        dynamic_call(_doxygen_${_id} "${_arg1}" "${_arg2}")
    endif ()
endmacro()

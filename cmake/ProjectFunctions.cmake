##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

##############################################################################
#.rst:
# Project functions
# -----------------
#
# This module contains non-public functions that are a part of the
# :ref:`doxygen_add_docs` implementation.
##############################################################################

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_params_init_inputs
#
# .. code-block:: cmake
#
#    _doxygen_params_init_overrides()
#
# Initializes properties that are processed by the chain of handlers:
#   ``input`` -> ``json`` -> ``setter`` -> ``updater`` -> ``default``
##############################################################################
function(_doxygen_params_init_properties)
    get_property(_doxygen_dir GLOBAL PROPERTY _doxygen_dir)
    if (NOT _doxygen_dir)
        get_filename_component(_doxygen_dir ${CMAKE_CURRENT_LIST_FILE} PATH)
    endif()

    _doxygen_property_add(PROJECT_FILE STRING
            SETTER "set_project_file"
            UPDATER "update_project_file")
    _doxygen_property_add(INPUT_TARGET STRING SETTER "set_input_target")
    _doxygen_property_add(TARGET_NAME STRING SETTER "set_target_name")
    _doxygen_property_add(INSTALL_COMPONENT STRING DEFAULT docs)
    _doxygen_property_add(GENERATE_PDF OPTION DEFAULT NO)

    #_doxygen_property_add("QUIET" OPTION DEFAULT YES)
    #_doxygen_property_add("WARNINGS" OPTION DEFAULT YES)
    _doxygen_property_add("HAVE_DOT" OPTION SETTER "set_have_dot" OVERWRITE)
    _doxygen_property_add("DOT_PATH" STRING SETTER "set_dot_path" OVERWRITE)
    _doxygen_property_add("DIA_PATH" STRING SETTER "set_dia_path" OVERWRITE)
    _doxygen_property_add(GENERATE_XML OPTION DEFAULT NO)
    _doxygen_property_add(GENERATE_LATEX OPTION UPDATER "update_generate_latex"
            DEFAULT NO)
    _doxygen_property_add(GENERATE_HTML STRING DEFAULT YES)
    _doxygen_property_add(OUTPUT_DIRECTORY STRING
            UPDATER "update_output_dir"
            DEFAULT "${CMAKE_CURRENT_BINARY_DIR}/doxygen-generated")
    _doxygen_property_add(INPUT LIST
            UPDATER "update_input_source")
    _doxygen_property_add(EXAMPLE_PATH LIST
            SETTER "set_example_source"
            UPDATER "update_example_source")
    _doxygen_property_add(WARN_FORMAT STRING
            SETTER "set_warn_format" OVERWRITE)
    _doxygen_property_add("MAKEINDEX_CMD_NAME" STRING
            SETTER "set_makeindex_cmd_name" OVERWRITE)
    _doxygen_property_add("LATEX_CMD_NAME" STRING
            SETTER "set_latex_cmd_name" OVERWRITE)

    _doxygen_property_add("PROJECT_BRIEF" STRING DEFAULT "${PROJECT_DESCRIPTION}" OVERWRITE)
    _doxygen_property_add("PROJECT_NAME" STRING DEFAULT "${PROJECT_NAME}" OVERWRITE)
    _doxygen_property_add("PROJECT_VERSION" STRING DEFAULT "${PROJECT_VERSION}" OVERWRITE)
    _doxygen_property_add("LATEX_BATCHMODE" OPTION DEFAULT YES OVERWRITE)
    _doxygen_property_add("PDF_HYPERLINKS" OPTION DEFAULT YES OVERWRITE)
    _doxygen_property_add("LATEX_OUTPUT" STRING DEFAULT "latex" OVERWRITE)
    _doxygen_property_add("USE_PDFLATEX" OPTION DEFAULT YES OVERWRITE)
    _doxygen_property_add("HTML_OUTPUT" OPTION DEFAULT "html" OVERWRITE)
    _doxygen_property_add("HTML_FILE_EXTENSION" STRING DEFAULT ".html" OVERWRITE)
    _doxygen_property_add("XML_OUTPUT" OPTION DEFAULT "xml" OVERWRITE)
    _doxygen_property_add("INPUT_RECURSIVE" OPTION DEFAULT YES OVERWRITE)
    _doxygen_property_add("EXAMPLE_RECURSIVE" OPTION DEFAULT YES OVERWRITE)
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_project_update
#
# .. code-block:: cmake
#
#   _doxygen_project_update(_input_project_file_name _out_var)
#
# Loads a given project file ``_input_project_file_name``, applies update logic
# that was previously defined by :cmake:command:`_doxygen_params_init`
# and saves the updated file. The name of the updated file is written into
# the output variable ``_out_var``.
##############################################################################
macro(_doxygen_project_update _out_var _input_project_file_name)
    _doxygen_project_load(${_input_project_file_name})

    TPA_get(doxygen.updatable.properties _updatable_paths)

    foreach (_path ${_updatable_paths})
        _doxygen_update_path(${_path} ${ARGN})
    endforeach()

    # create name for the processed project file
    _doxygen_output_project_file_name(
            ${_input_project_file_name}
            _output_project_file_name)

    # save processed project file
    _doxygen_project_save("${_output_project_file_name}")
    set(${_out_var} "${_output_project_file_name}")
endmacro()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_project_load
#
# .. code-block:: cmake
#
#    _doxygen_project_load(_project_file_name)
#
# Loads a given project file ``_project_file_name`` into the current
# :ref:`TPA scope`. The name of every resulting property is prefixed with
# ``doxygen.``.
##############################################################################
function(_doxygen_project_load _project_file_name)
    TPA_unset(doxygen.project)
    _doxygen_log(INFO "Loading project template ${_project_file_name}...")

    file(STRINGS "${_project_file_name}" _file_lines)
    foreach(_line IN LISTS _file_lines)
        if(_line MATCHES "^([A-Z][A-Z0-9_]+)( *=)(.*)")
            set(_key "${CMAKE_MATCH_1}")
            set(_eql "${CMAKE_MATCH_2}")
            set(_value "${CMAKE_MATCH_3}")
            string(REPLACE "\\" "\\\\" _value "${_value}")
            string(REPLACE ";" "\\\n" _value "${_value}")
            string(STRIP ${_key} _key)
            string(STRIP "${_value}" _value)
            set(_key "project.file.${_key}")
            TPA_set(${_key} "${_value}")
            TPA_append(doxygen.project ${_key})
        endif()
    endforeach()
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_project_save
#
# .. code-block:: cmake
#
#    _doxygen_project_save(_project_file_name)
#
# Saves a parsed JSON document into a given file ``_project_file_name``.
# The JSON tree is taken from the current TPA scope. Any existing file with
# the same name is overwritten.
##############################################################################
function(_doxygen_project_save _project_file_name)
    _doxygen_assert_not_empty("${_project_file_name}")
    TPA_get(doxygen.project _variables)

    unset(_contents)
    foreach(_key IN LISTS _variables)
        TPA_get(${_key} _value)
        string(SUBSTRING ${_key} 13 -1 _key)
        string(APPEND _contents "${_key} =")
        #_doxygen_log(DEBUG "${_key} = ${_value}")
        foreach(_val ${_value})
            string(SUBSTRING "${_val}" 0 1 _first_char)
            string(FIND _val " " _ind)
            if (_ind GREATER -1 AND NOT _first_char STREQUAL "\"")
                #message(STATUS "writing \"${_val}\"")
                string(APPEND _contents " \"${_val}\"")
            else()
                #message(STATUS "writing ${_val}")
                string(APPEND _contents " ${_val}")
            endif()
        endforeach()
        string(APPEND _contents "\n")
    endforeach()

    _doxygen_log(INFO "Saving project file ${_project_file_name}...")
    file(WRITE "${_project_file_name}" "${_contents}")
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_get
#
# .. code-block:: cmake
#
#    # same as _JSON_get("doxygen.${_path}" _out_var)
#    _doxygen_get(_path _out_var)
#
##############################################################################
function(_doxygen_get _path _out_var)
    TPA_get(project.file.${_path} _value)
    set(${_out_var} "${_value}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_set
#
# .. code-block:: cmake
#
#    # same as _JSON_set("doxygen.${_path}" _value)
#    _doxygen_set(_path _value)
##############################################################################
function(_doxygen_set _property _value)
    TPA_set(project.file.${_property} "${_value}")
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_call
#
# .. code-block:: cmake
#
#    _doxygen_call(_id _arg1)
#
# Calls a function or a macro given its name ``_id``. Writes actual call code
# into a temporary file, which is then included. ``ARGN`` is also passed.
##############################################################################
macro(_doxygen_call _id _arg1)
    if (NOT COMMAND ${_id})
        message(FATAL_ERROR "Unsupported function/macro \"${_id}\"")
    else ()
        set(_helper "${CMAKE_CURRENT_BINARY_DIR}/helpers/macro_helper_${_id}.cmake")
        if ("${_arg1}" MATCHES "^\"(.+)")
            file(WRITE "${_helper}" "${_id}(${_arg1} ${ARGN})\n")
        else()
            file(WRITE "${_helper}" "${_id}(\"${_arg1}\" ${ARGN})\n")
        endif()
        include("${_helper}")
    endif ()
endmacro()

macro(_doxygen_call_2 _id _arg1)
    if (NOT COMMAND ${_id})
        message(FATAL_ERROR "Unsupported function/macro \"${_id}\"")
    else ()
        set(_helper "${CMAKE_CURRENT_BINARY_DIR}/helpers/macro_helper_${_id}.cmake")
        file(WRITE "${_helper}" "${_id}(${_arg1})\n")
        include("${_helper}")
    endif ()
endmacro()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_find_directory
#
# .. code-block:: cmake
#
#   _doxygen_find_directory(_base_dir _names _out_var)
#
# Searches for a directory with a name from ``_names``, starting from
# ``_base_dir``. Sets the output variable ``_out_var`` to contain absolute
# path of every found directory.
##############################################################################
function(_doxygen_find_directory _base_dir _names _out_var)
    set(_result "")
    foreach (_name ${_names})
        if (IS_DIRECTORY ${_base_dir}/${_name})
            _doxygen_log(DEBUG "Found directory ${_base_dir}/${_name}")
            list(APPEND _result ${_base_dir}/${_name})
        endif ()
    endforeach ()
    set(${_out_var} "${_result}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_output_project_file_name
#
# ..  code-block:: cmake
#
#   _doxygen_output_project_file_name(_project_file_name _out_var)
#
# Generates an output project file's name, given the input name.
# Replaces th path to input project file ``_project_file_name`` by
# *CMAKE_CURRENT_BINARY_DIR* while leaving the file name unchanged.
##############################################################################
function(_doxygen_output_project_file_name _project_file_name _out_var)
    _doxygen_assert_not_empty("${_project_file_name}")
    get_filename_component(_name "${_project_file_name}" NAME)
    set(${_out_var} ${CMAKE_CURRENT_BINARY_DIR}/${_name} PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_params_init
#
# .. code-block:: cmake
#
#    _doxygen_params_init()
#
# Initializes parsing context. Changes made by this function in the current
# scope can be reverted by :cmake:command:`TPA_clear_scope`.
##############################################################################
function(_doxygen_params_init)
    # define acceptable input parameters
    # _doxygen_params_init_inputs()
    # define properties that are processed by the chain of handlers
    # `input` -> `json` -> `setter` -> `updater` -> `default`
    _doxygen_params_init_properties()
endfunction()

##############################################################################
#.rst:
#
# ======================
# doxygen_add_override
# ======================
#
# .. code-block:: cmake
#
#   doxygen_add_override(_path _value)
#
# Creates an :ref:`override<overrides-reference-label>` with the given value.
##############################################################################
function(doxygen_add_override _path _value)
    _doxygen_property_add(${_path} DEFAULT "${_value}" OVERWRITE)
endfunction()

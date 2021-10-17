##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

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
    assert_not_empty("${_project_file_name}")
    get_filename_component(_name "${_project_file_name}" NAME)
    if (_name STREQUAL "doxyfile.template.in")
        set(_name "doxyfile.template.txt")
    endif()
    set(${_out_var} "${CMAKE_CURRENT_BINARY_DIR}/${_name}" PARENT_SCOPE)
endfunction()

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
        string(SUBSTRING "${_base_dir}" 0 1 _first_char)
        if (_first_char STREQUAL "\"")
            # insert _name inside the quotes
            string(LENGTH ${_base_dir} _len)
            math(EXPR _len "${_len} - 2")
            string(SUBSTRING ${_base_dir} 1 ${_len} _new_base_dir)
            set(_search_path "${_new_base_dir}/${_name}")
        else()
            set(_search_path ${_base_dir}/${_name})
        endif()
        if (IS_DIRECTORY "${_search_path}")
            list(APPEND _result ${_search_path})
        endif ()
    endforeach ()
    set(${_out_var} "${_result}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
# Setters and updaters
# --------------------
#
# These functions implement property update logic:
#
# * relative directory names are converted into absolute ones;
# * properties derived by `CMake` are updated from the corresponding variables
#   and targets.
#
# These functions are never called directly; they are configured to participate
# in the property :ref:`transformation<Project file generator>` process.
##############################################################################

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_dia_path
#
# ..  code-block:: cmake
#
#    _doxygen_set_dia_path(_out_var)
#
# Sets the ``dot.dia-path`` configuration property. Puts the result into
# ``_out_var``.
##############################################################################
function(_doxygen_set_dia_path _out_var)
    if (TARGET Doxygen::dia)
        get_target_property(DIA_PATH Doxygen::dia IMPORTED_LOCATION)
        set(${_out_var} "${DIA_PATH}" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_latex_cmd_name
#
# ..  code-block:: cmake
#
#    _doxygen_set_latex_cmd_name(_out_var)
#
# Sets the property ``output-latex.latex-cmd-name`` to the value of
# ``PDFLATEX_COMPILER``, previously configured by ``find_package(LATEX)``.
# Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_update_latex_cmd_name _latex_cmd_name _out_var)
    if (NOT "${PDFLATEX_COMPILER}" STREQUAL PDFLATEX_COMPILER-NOTFOUND)
        set(${_out_var} "${PDFLATEX_COMPILER}" PARENT_SCOPE)
    else ()
        if (LATEX_FOUND)
            set(${_out_var} "${LATEX_COMPILER}" PARENT_SCOPE)
        else ()
            set(${_out_var} "${_latex_cmd_name}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_makeindex_cmd_name
#
# ..  code-block:: cmake
#
#    _doxygen_set_makeindex_cmd_name(_out_var)
#
# Sets ``output-latex.makeindex-cmd-name`` to the value of
# `MAKEINDEX_COMPILER` set by `find_package(LATEX)`. Puts the result into
# ``_out_var``.
##############################################################################
function(_doxygen_update_makeindex_cmd_name _cmd_name _out_var)
    if (NOT "${MAKEINDEX_COMPILER}" STREQUAL "MAKEINDEX_COMPILER-NOTFOUND")
        set(${_out_var} "${MAKEINDEX_COMPILER}" PARENT_SCOPE)
    else()
        set(${_out_var} "${_cmd_name}" PARENT_SCOPE)
    endif ()
endfunction()

function(_doxygen_set_project_file _out_var)
    set(_template "${CMAKE_CURRENT_BINARY_DIR}/doxyfile.template.in")
    if (NOT EXISTS "${_template}")
        log_debug(doxygen "Create default project `doxyfile.template.in` in `${CMAKE_CURRENT_BINARY_DIR}`")
        execute_process(
           COMMAND ${DOXYGEN_EXECUTABLE} -s -g "${_template}"
           OUTPUT_QUIET
           RESULT_VARIABLE _doxygen_tpl_result)
    endif()
    set(${_out_var} "${_template}" PARENT_SCOPE)
endfunction()
##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_project_file
#
# .. code-block:: cmake
#
#   _doxygen_update_project_file(_file_name _out_var)
#
# Transforms a relative file name ``_file_name`` into an absolute one, if
# needed, and puts the result into ``_out_var``. Does nothing otherwise.
##############################################################################
function(_doxygen_update_project_file _file_name _out_var)
    assert_not_empty("${_file_name}")
    set(_result "")
    if (NOT IS_ABSOLUTE "${_file_name}")
        get_filename_component(_result
                "${_file_name}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        log_debug(doxygen-updater "setting ${_out_var} to ${_result}")
        set(${_out_var} "${_result}" PARENT_SCOPE)
    else()
        set(${_out_var} "${_file_name}" PARENT_SCOPE)
    endif ()
endfunction()

function(_doxygen_update_layout_file _file_name _out_var)
    unset(_result)
    if ("${_file_name}" STREQUAL "")
        set(${_out_var} "" PARENT_SCOPE)
    else()
        if (NOT IS_ABSOLUTE "${_file_name}")
            get_filename_component(_result
                    "${_file_name}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
            log_debug(doxygen-updater "setting ${_out_var} to ${_result}")
            set(${_out_var} "${_result}" PARENT_SCOPE)
        else()
            set(${_out_var} "${_file_name}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

function(_doxygen_update_html_header _file_name _out_var)
    unset(_result)
    if ("${_file_name}" STREQUAL "")
        set(${_out_var} "" PARENT_SCOPE)
    else()
        if (NOT IS_ABSOLUTE "${_file_name}")
            get_filename_component(_result
                    "${_file_name}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
            log_debug(doxygen-updater "setting ${_out_var} to ${_result}")
            set(${_out_var} "${_result}" PARENT_SCOPE)
        else()
            set(${_out_var} "${_file_name}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

function(_doxygen_update_html_footer _file_name _out_var)
    unset(_result)
    if ("${_file_name}" STREQUAL "")
        set(${_out_var} "" PARENT_SCOPE)
    else()
        if (NOT IS_ABSOLUTE "${_file_name}")
            get_filename_component(_result
                    "${_file_name}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
            log_debug(doxygen-updater "setting ${_out_var} to ${_result}")
            set(${_out_var} "${_result}" PARENT_SCOPE)
        else()
            set(${_out_var} "${_file_name}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

function(_doxygen_update_html_extra_stylesheet _file_name _out_var)
    unset(_result)
    if ("${_file_name}" STREQUAL "")
        set(${_out_var} "" PARENT_SCOPE)
    else()
        if (NOT IS_ABSOLUTE "${_file_name}")
            get_filename_component(_result
                    "${_file_name}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
            log_debug(doxygen-updater "setting ${_out_var} to ${_result}")
            set(${_out_var} "${_result}" PARENT_SCOPE)
        else()
            set(${_out_var} "${_file_name}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()


function(_doxygen_update_html_extra_files _file_names _out_var)
    unset(_result)
    if ("${_file_names}" STREQUAL "")
        set(${_out_var} "" PARENT_SCOPE)
    else()
        separate_arguments(_file_names)
        foreach(_file ${_file_names})
            if (NOT IS_ABSOLUTE "${_file}")
                list(APPEND _result "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            else()
                list(APPEND _result "${_file}")
            endif()
        endforeach()
        set(${_out_var} "${_result}" PARENT_SCOPE)
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_input_target
#
# .. code-block:: cmake
#
#   _doxygen_set_input_target(_out_var)
#
# Sets the output variable ``_out_var`` to ``${PROJECT_NAME}`` if a target with
# that name exists. Clears the output variable otherwise.
##############################################################################
function(_doxygen_set_input_target _out_var)
    if (TARGET ${PROJECT_NAME})
        set(${_out_var} ${PROJECT_NAME} PARENT_SCOPE)
    else ()
        set(${_out_var} "" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_warn_format
#
# .. code-block:: cmake
#
#   _doxygen_set_warn_format(_out_var)
#
# Sets the value of the configuration property ``messages.warn-format``
# depending on the current build tool. Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_set_warn_format _out_var)
    if ("${CMAKE_BUILD_TOOL}" MATCHES "(msdev|devenv)")
        set(${_out_var} [[$file($line) : $text]] PARENT_SCOPE)
    else ()
        set(${_out_var} [[$file:$line: $text]] PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_dot_path
#
# .. code-block:: cmake
#
#   _doxygen_set_dot_path(_out_var)
#
# Sets the ``dot.dot-path`` configuration property. Uses result of the call
# ``find_package(Doxygen)``. Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_set_dot_path _out_var)
    if (TARGET Doxygen::dot)
        get_target_property(DOT_PATH Doxygen::dot IMPORTED_LOCATION)
        set(${_out_var} "${DOT_PATH}" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_input_source
#
# .. code-block:: cmake
#
#   _doxygen_update_input_source(<directories> <output variable>)
#
# Walks through directory paths ``_paths`` and updates relative
# ones by prepending ``CMAKE_CURRENT_SOURCE_DIR``. Does nothing
# to absolute directory paths. Writes updated list to ``_out_var``.
##############################################################################
function(_doxygen_update_input_source _paths _out_var)
    set(_inputs "")
    if (_paths)
        separate_arguments(_paths)
        foreach (_path ${_paths})
            if (NOT IS_ABSOLUTE "${_path}")
                get_filename_component(_path
                        "${_path}" ABSOLUTE
                        BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
            endif ()
            list(APPEND _inputs "${_path}")
        endforeach ()
    else ()
        if (TARGET ${INPUT_TARGET})
            _doxygen_get_target_property(_type ${INPUT_TARGET} TYPE)
            if (_type STREQUAL "INTERFACE_LIBRARY")
                _doxygen_get_target_property(_inputs
                        "${INPUT_TARGET}"
                        INTERFACE_INCLUDE_DIRECTORIES)
            else()
                _doxygen_get_target_property(_inputs
                        "${INPUT_TARGET}"
                        INCLUDE_DIRECTORIES)
            endif()
        endif ()
    endif ()

    set(_result "")
    foreach(_input ${_inputs})
        string(REGEX MATCH "\\$<BUILD_INTERFACE:(.*)?>" _input_copy1 "${_input}")
        set(_input_copy1 "${CMAKE_MATCH_1}")
        string(REGEX MATCH "\\$<INSTALL_INTERFACE:(.*)?>" _input_copy2 "${_input}")
        set(_input_copy2 "${CMAKE_MATCH_1}")
        if (_input_copy1)
            file(GLOB_RECURSE _inputs ${_input_copy1}/*)
            list(APPEND _result "${_inputs}")
        elseif(NOT _input_copy2)
            list(APPEND _result "${_input}")
        endif()
    endforeach()
    #message(STATUS "input sources after update: ${_result}")
    set(${_out_var} "${_result}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_example_source
#
# .. code-block:: cmake
#
#   _doxygen_update_example_source(_directories _out_var)
#
# Walks through directory paths ``_directories`` and updates relative
# ones by prepending ``CMAKE_CURRENT_SOURCE_DIR``. Does nothing
# to absolute directory paths. Writes updated list to ``_out_var``.
##############################################################################
function(_doxygen_update_example_source _directories _out_var)
    if (_directories)
        separate_arguments(_directories)
        set(_result "")
        foreach (_dir ${_directories})
            if (NOT IS_ABSOLUTE "${_dir}")
                get_filename_component(_dir
                        "${_dir}" ABSOLUTE
                        BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
            endif ()
            list(APPEND _result "${_dir}")
        endforeach ()
        set(${_out_var} "${_result}" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_output_dir
#
# .. code-block:: cmake
#
#   _doxygen_update_output_dir(_directory _out_var)
#
# Updates a given output directory ``_directory``:
#
# * a relative directory path is converted into an absolute one by prepending
#   *CMAKE_CURRENT_BINARY_DIR*;
# * an absolute path stays unchanged. Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_update_output_dir _directory _out_var)
    if (_directory)
        if (NOT IS_ABSOLUTE "${_directory}")
            get_filename_component(_dir "${_directory}"
                    ABSOLUTE
                    BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
            set(${_out_var} "${_dir}" PARENT_SCOPE)
        else()
            set(${_out_var} "${_directory}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_have_dot
#
# .. code-block:: cmake
#
#   _doxygen_set_have_dot(_out_var)
#
# Sets ``dot.have-dot`` configuration flag depending on `Graphviz` ``dot``
# presence. Uses the results of the ``find_package(DoxygenCMake)`` call.
# Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_set_have_dot _out_var)
    if (TARGET Doxygen::dot)
        set(${_out_var} YES PARENT_SCOPE)
    else ()
        set(${_out_var} NO PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_set_example_source
#
# .. code-block:: cmake
#
#   _doxygen_set_example_source(_out_var)
#
# Setter for the property ``input.example-source``. Searches for
# the sub-directories  [``example``, ``examples``] in the current source
# directory, and collects found ones. Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_set_example_source _out_var)
    _doxygen_find_directory(
            "${CMAKE_CURRENT_SOURCE_DIR}"
            "example;examples"
            _example_path
    )
    set(${_out_var} "${_example_path}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_docs_target
#
# .. code-block:: cmake
#
#   _doxygen_update_docs_target(_out_var)
#
# Sets the ``DOCS_TARGET`` parameter when it was not given explicitly:
#
# * if ``INPUT_TARGET`` is not empty, sets it to ``${INPUT_TARGET}.doxygen``;
# * otherwise, sets it to ``${PROJECT_NAME}``
#
# Puts the result into ``_out_var``.
##############################################################################
function(_doxygen_update_docs_target _target _out_var)
    if (${_target} STREQUAL ".doxygen")
        set(${_out_var} "${PROJECT_NAME}.doxygen" PARENT_SCOPE)
    else()
        set(${_out_var} ${_target} PARENT_SCOPE)
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_update_generate_latex
#
# .. code-block:: cmake
#
#   _doxygen_update_generate_latex(_generate_latex _out_var)
#
# If ``.tex`` generation was requested (``_generate_latex`` is ``true``), but
# no LATEX was found in the local environment, ``_out_var`` is set to ``false``.
# Otherwise, it's set to ``true``.
##############################################################################
macro(_doxygen_update_generate_latex _generate_latex _out_var)
    if (_generate_latex STREQUAL YES)
        if (NOT DEFINED LATEX_FOUND)
            log_info(doxygen-updater "LaTex docs requested, importing LATEX...")
            find_package(LATEX QUIET OPTIONAL_COMPONENTS MAKEINDEX PDFLATEX)
            #doxygen_global_set(LATEX_FOUND ${LATEX_FOUND})
        endif()
        if (NOT LATEX_FOUND)
            log_info(doxygen-updater "LATEX was not found; skip LaTex generation.")
            set(_generate_latex NO)
        endif()
    endif()
    set(${_out_var} ${_generate_latex})
endmacro()

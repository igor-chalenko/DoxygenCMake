##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

cmake_policy(SET CMP0011 NEW)

##############################################################################
#.rst:
#
# .. _cmake-target-generator-reference-label:
#
# CMake target generator
# ----------------------
#
# This module implements creation of the following targets:
#
# * ``${DOCS_TARGET}`` to run `doxygen`;
# * ``${DOCS_TARGET}.open_html``:
#
#   .. code-block:: bash
#
#      ${DOXYGEN_LAUNCHER_COMMAND} ${OUTPUT_DIRECTORY}/html/index.html
#
#   This target is created unless HTML generation was disabled.
#
#   * ``${DOCS_TARGET}.latex``:
#
#   .. code-block:: bash
#
#      ${DOXYGEN_LAUNCHER_COMMAND} ${OUTPUT_DIRECTORY}/latex/refman.tex
#
#   This target is created if LaTex generation was enabled.
#
#   * ``${DOCS_TARGET}.pdf``:
#
#   .. code-block:: bash
#
#      ${DOXYGEN_LAUNCHER_COMMAND} ${OUTPUT_DIRECTORY}/pdf/refman.pdf
#
#   This target is created if PDF generation was enabled.
#
# In addition to the above, ``doxygen-cmake`` uses
# :cmake:command:`_doxygen_install_docs` to add documentation files to the
# ``install`` target.
#
# See also:
#
# * :cmake:variable:`DOXYGEN_LAUNCHER_COMMAND`
##############################################################################

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_add_targets
#
# ..  code-block:: cmake
#
#    _doxygen_add_targets(<project file> <processed project file>)
#
# Creates a `doxygen` target and an `open generated docs` target for every
# output format that was requested.
#
# Parameters:
#
# * ``_project_file``  unprocessed project file name
# * ``_updated_project_file`` processed project file name
##############################################################################


function(_doxygen_create_generate_docs_target _project_file _output_directory _docs_target _generate_pdf)
    log_info(doxygen "Create the target `${_docs_target}` to run `Doxygen::doxygen`")
    _doxygen_output_project_file_name(${_project_file} _updated_project_file)
    # collect inputs for `DEPENDS` parameter
    _doxygen_list_inputs(_inputs)
    assert_not_empty("${_inputs}")
    # collect outputs for the `OUTPUTS` parameter
    _doxygen_list_outputs("${_output_directory}" _files FILES)

    set(__stamp_file "${CMAKE_CURRENT_BINARY_DIR}/${_docs_target}.stamp")

    set(_extra_dependencies
            "Doxygen will run every time some of the following files are modified (relative to ${CMAKE_CURRENT_SOURCE_DIR}):")
    _doxygen_log_path("${_project_file}" _extra_dependencies)
    foreach(_input IN LISTS _inputs)
        _doxygen_log_path("${_input}" _extra_dependencies)
    endforeach()
    foreach(_input ${ARGN})
        _doxygen_log_path("${_input}" _extra_dependencies)
    endforeach()

    unset(_pdf_command)
    if (_generate_pdf)
        if (WIN32)
            set(_pdf_command COMMAND ${_output_directory}/latex/make.bat)
        else()
            set(_pdf_command COMMAND ${CMAKE_MAKE_PROGRAM} -f ${_output_directory}/latex/Makefile)
        endif()
    endif()

    _doxygen_add_custom_command(OUTPUT "${__stamp_file}"
            COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_CURRENT_BINARY_DIR}"
            COMMAND "${CMAKE_COMMAND}" -E remove_directory "${_output_directory}"
            MAIN_DEPENDENCY "${_project_file}"
            DEPENDS "${_inputs}" "${ARGN}"
            COMMAND Doxygen::doxygen "${_updated_project_file}"
            ${_pdf_command}
            COMMAND ${CMAKE_COMMAND} -E touch "${__stamp_file}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            COMMENT "Generating documentation using ${_updated_project_file} ..."
            BYPRODUCTS "${_files}"
            VERBATIM)

    _doxygen_add_custom_command(OUTPUT "${__stamp_file}"
            COMMAND ${CMAKE_COMMAND} -E touch "${__stamp_file}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            COMMENT "Generating stamp file ..."
            VERBATIM)

    _doxygen_add_custom_target(${_docs_target}
            DEPENDS "${__stamp_file}" "${_output_directory}"
            SOURCES ${_inputs}
            )

    unset(__stamp_file)

endfunction()

function(dir_relative_to _dir _file _root)
    message(STATUS "_file = ${_file}")
    message(STATUS "_root = ${_root}")
    file(RELATIVE_PATH _result "${_file}" "${_root}")
    set(${_dir} "${_result}" PARENT_SCOPE)
endfunction()

macro(_doxygen_log_path _path _out_var)
    if(IS_ABSOLUTE "${_path}")
        file(RELATIVE_PATH _result  "${CMAKE_CURRENT_SOURCE_DIR}" "${_path}")
        string(APPEND ${_out_var} " `${_result}`")
    else()
        string(APPEND ${_out_var} " `${_path}`")
    endif()
endmacro()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_add_pdf_commands
#
# ..  code-block:: cmake
#
#    _doxygen_add_pdf_commands(<target name>)
#
# Adds PDF generation commands to a previously created `doxygen` target
# ``_target_name``.
#
# Parameters:
#
# * ``_target_name`` the name of the target to add commands to
##############################################################################
function(_doxygen_add_pdf_commands _output_dir _target_name)
    #file(MAKE_DIRECTORY ${_output_dir}/pdf)
    if (WIN32)
        _doxygen_add_custom_command(DEPENDS "${_output_dir}"
                OUTPUT "${_output_dir}/latex/refman.pdf"
                COMMAND make.bat
                COMMAND "${CMAKE_COMMAND}" -E copy
                "${_output_dir}/latex/refman.pdf"
                "${_output_dir}/pdf/refman.pdf"
                COMMAND "${CMAKE_COMMAND}" -E rm "${_output_dir}/latex/refman.pdf"
                WORKING_DIRECTORY
                "${_output_dir}/latex"
                COMMENT "Generating PDF..."
                VERBATIM)
    else()
        _doxygen_add_custom_command(
                DEPENDS "${_output_dir}"
                OUTPUT "${_output_dir}/latex/refman.pdf"
                COMMAND ${CMAKE_MAKE_PROGRAM} #> ${_output_directory}/latex.log 2>&1
                COMMAND ${CMAKE_COMMAND} -E copy
                "${_output_dir}/latex/refman.pdf"
                "${_output_dir}/pdf/refman.pdf"
                COMMAND ${CMAKE_COMMAND} -E rm "${_output_dir}/latex/refman.pdf"
                WORKING_DIRECTORY "${_output_dir}/latex"
                COMMENT "Generating PDF..."
                VERBATIM)
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_add_open_targets
#
# ..  code-block:: cmake
#
#    _doxygen_add_open_targets(<name prefix> <output directory>)
#
# Parameters:
#
# * ``_name_prefix`` a string prepended to the names of the targets being
#   created
# * ``_output_dir`` a directory where documentation files will be generated
#   by the ``doxygen`` target
##############################################################################
function(_doxygen_create_open_targets _project_file _output_directory _docs_target _generate_html _generate_latex _generate_pdf)
    if (WIN32)
        set(DOXYGEN_LAUNCHER_COMMAND start "\"\"")
    elseif (NOT APPLE)
        set(DOXYGEN_LAUNCHER_COMMAND xdg-open)
    else ()
        # I didn't test this
        set(DOXYGEN_LAUNCHER_COMMAND open)
    endif ()

    if (DOXYGEN_LAUNCHER_COMMAND)
        if (_generate_html STREQUAL "YES" AND NOT TARGET ${_docs_target}.open_html)
            log_info(doxygen "Create the target `${_docs_target}.open_html` to open the generated HTML files")
            _doxygen_create_open_target(
                    ${_docs_target}.open_html
                    ${_docs_target}
                    "${_output_directory}/html/index.html")
        endif ()
        if (_generate_latex STREQUAL "YES" OR _generate_pdf AND NOT TARGET ${_docs_target}.open_latex)
            log_info(doxygen "Create the target `${_docs_target}.open_latex` to open the generated LaTex files")
            _doxygen_create_open_target(
                    ${_docs_target}.open_latex
                    ${_docs_target}
                    "${_output_directory}/latex/refman.tex")
        endif ()
        if (_generate_pdf AND NOT TARGET ${_docs_target}.open_pdf)
            log_info(doxygen "Create the target `${_docs_target}.open_pdf` to open the generated PDF file")
            _doxygen_create_open_target(
                    ${_docs_target}.open_pdf
                    ${_docs_target}
                    "${_output_directory}/latex/refman.pdf")
        endif ()
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_create_open_target
#
# ..  code-block:: cmake
#
#   _doxygen_create_open_target(<target name> <parent target name> <file name>)
#
# Creates a target that opens a given file for viewing. Synonymous
# to `start file` on Windows or `xdg-open file` on Gnome desktops.
#
# Parameters:
#
# * ``_target_name`` a name of the newly created target that should open 
#   the given file
# * ``_parent_target_name`` a name of the target that generates documentation;
#   serves as a dependency for the target ``_target_name``
# * ``_file`` a file to open, such as `index.html`
##############################################################################
function(_doxygen_create_open_target _target_name _parent_target_name _file)
    _doxygen_add_custom_target(${_target_name}
            COMMAND ${DOXYGEN_LAUNCHER_COMMAND} ${_file}
            COMMENT "Opening ${_file}..."
            )
    _doxygen_set_target_properties(${_target_name}
            PROPERTIES
            EXCLUDE_FROM_DEFAULT_BUILD TRUE
            EXCLUDE_FROM_ALL TRUE)
    _doxygen_add_dependencies(${_target_name} ${_parent_target_name})
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_install_docs
#
# Sets up install commands for the generated documentation.
#
# * HTML files are installed under ``_destination``/``html``
# * LaTex files are installed under ``_destination``/``latex``
# * PDF file is installed under ``_destination``/``pdf``
#
# These
##############################################################################
function(_doxygen_create_install_targets)
    _doxygen_get(OUTPUT_DIRECTORY _output_dir)
    _doxygen_get(INSTALL_COMPONENT _component)

    if (NOT DEFINED CMAKE_INSTALL_DOCDIR)
        set(CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_PREFIX}")
        include(GNUInstallDirs)
    endif ()
    set(_destination ${CMAKE_INSTALL_DOCDIR})

    _doxygen_list_outputs("${_output_dir}" _files DIRECTORIES)

    foreach (_artifact ${_files})
        string(REPLACE " " "\\ " _new_artifact "${_artifact}")
        _doxygen_log(INFO "install ${_new_artifact} to ${_destination}...")
        install(DIRECTORY "${_new_artifact}"
                DESTINATION "${_destination}"
                COMPONENT ${_component}
        )
    endforeach ()
endfunction()


##############################################################################
#.rst:
# .. cmake:command:: _doxygen_list_outputs
#
# ..  code-block:: cmake
#
#   _doxygen_list_outputs(<mode> <output variable>)
#
# Collects configured `doxygen` outputs. Two modes of operation are
# supported, controlled by the ``mode`` parameter. The following ``mode`` values
# are accepted:
#
# * ``FILES``
#   In this mode, ``index.html``, ``index.xml``, ``refman.tex``, and
#   ``refman.pdf`` are added to the result, depending on whether
#   the corresponding format generation was requested.
# * ``DIRECTORIES``
#   In this mode, ``html``, ``xml``, ``latex``, and ``pdf`` directories are
#   added to the result (their absolute paths, to be precise).
##############################################################################
function(_doxygen_list_outputs _option _out_var)
    set(_out "")
    if (_option STREQUAL FILES)
        if (GENERATE_HTML STREQUAL "YES")
            set(_html_index_file "${_output_dir}/html/index.html")
            list(APPEND _out "${_html_index_file}")
        endif ()
        if (GENERATE_XML STREQUAL "YES")
            set(_xml_index_file "${_output_dir}/xml/index.xml")
            list(APPEND _out "${_xml_index_file}")
        endif ()
        if (GENERATE_LATEX STREQUAL "YES")
            set(_latex_index_file "${_output_dir}/latex/refman.tex")
            list(APPEND _out "${_latex_index_file}")
        endif ()
        if (GENERATE_PDF)
            set(_pdf_file "${_output_dir}/pdf/refman.pdf")
            list(APPEND _out "${_pdf_file}")
        endif ()
    else ()
        if (GENERATE_LATEX STREQUAL "YES")
            list(APPEND _out "${_output_dir}/latex")
        endif()
        if (GENERATE_XML STREQUAL "YES")
            list(APPEND _out "${_output_dir}/xml")
        endif()
        if (GENERATE_HTML STREQUAL "YES")
            list(APPEND _out "${_output_dir}/html")
        endif()
        if (GENERATE_PDF)
            list(APPEND _out "${_output_dir}/pdf")
        endif()
    endif ()

    set(${_out_var} "${_out}" PARENT_SCOPE)
endfunction()

macro(_doxygen_set_target_properties _target)
    set_target_properties(${_target} ${ARGN})
endmacro()

function(_doxygen_get_target_property _out_var _target _property)
    get_target_property(_type ${_target} ${_property})
    set(${_out_var} ${_type} PARENT_SCOPE)
endfunction()

macro(_doxygen_add_custom_command)
    add_custom_command(${ARGN})
endmacro()

macro(_doxygen_add_custom_target _target)
    add_custom_target(${_target} ${ARGN})
endmacro()

macro(_doxygen_add_dependencies)
    add_dependencies(${ARGN})
endmacro()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_list_inputs(_out_var)
#
# Collects input file names based on the value of input parameters that control
# input sources:
# * If ``INPUTS`` is not empty, collects all files in the paths given by
# ``INPUTS``. Files are added to the resulting list directly, and directories
# are globbed. Puts the resulting list into ``_out_var``.
# * If ``INPUT_TARGET`` is not empty, takes include directories from
# the corresponding target. Every directory is then globbed to get the files.
# * If none of the above holds, an error is raised.
#
# Parameters:
#
# * ``_out_var`` the list of files in input sources
##############################################################################
function(_doxygen_list_inputs _out_var)
    set(_all_inputs "")
    if (INPUT)
        foreach (_dir ${INPUT})
            if (IS_DIRECTORY "${_dir}")
                file(GLOB_RECURSE _inputs "${_dir}/*")
                list(APPEND _all_inputs "${_inputs}")
                log_debug(doxygen.list_inputs "appending directory contents: ${_inputs}")
            else ()
                list(APPEND _all_inputs "${_dir}")
                log_debug(doxygen.list_inputs "appending a file ${_dir}")
            endif ()
        endforeach ()
    elseif (INPUT_TARGET)
        _doxygen_get_target_property(_type ${INPUT_TARGET} TYPE)
        if (_type STREQUAL INTERFACE_LIBRARY)
            _doxygen_get_target_property(_include_directories
                    ${INPUT_TARGET}
                    INTERFACE_INCLUDE_DIRECTORIES)
        else()
            _doxygen_get_target_property(_include_directories
                    ${INPUT_TARGET}
                    INCLUDE_DIRECTORIES)
            log_debug(doxygen.list_inputs "include_directories of `${INPUT_TARGET}`: ${_include_directories}")
        endif()
        foreach (_dir ${_include_directories})
            file(GLOB_RECURSE _inputs "${_dir}/*")
            list(APPEND _all_inputs "${_inputs}")
            log_debug(doxygen.list_inputs "appending ${_inputs} from ${_dir}")
        endforeach ()
    else ()
        message(FATAL_ERROR [=[
Either INPUT or INPUT_TARGET must be specified as input argument
for `doxygen_add_docs`:
1) INPUT_TARGET couldn't be defaulted to ${PROJECT_NAME};
2) Input project file didn't specify any inputs either.]=])
    endif ()

    log_debug(doxygen.list_inputs "collected inputs: ${_all_inputs}")
    set(${_out_var} "${_all_inputs}" PARENT_SCOPE)
endfunction()

function(_doxygen_collect_dependencies _out_var)
    unset(_result)
    if(LAYOUT_FILE)
        log_debug(doxygen "LAYOUT_FILE ${LAYOUT_FILE} was supplied")
        list(APPEND _result "${LAYOUT_FILE}")
    endif()
    if(HTML_EXTRA_STYLESHEET)
        log_debug(doxygen "HTML_EXTRA_STYLESHEET ${HTML_EXTRA_STYLESHEET} was supplied")
        list(APPEND _result "${HTML_EXTRA_STYLESHEET}")
    endif()
    if(HTML_FOOTER)
        log_debug(doxygen "HTML_FOOTER ${HTML_FOOTER} was supplied")
        list(APPEND _result "${HTML_FOOTER}")
    endif()
    if (HTML_HEADER)
        log_debug(doxygen "HTML_HEADER ${HTML_HEADER} was supplied")
        list(APPEND _result "${HTML_HEADER}")
    endif()
    if (HTML_EXTRA_FILES)
        log_debug(doxygen "HTML_EXTRA_FILES ${HTML_EXTRA_FILES} was supplied")
        separate_arguments(HTML_EXTRA_FILES)
        foreach(_file ${HTML_EXTRA_FILES})
            if (NOT IS_ABSOLUTE "${_file}")
                list(APPEND _result "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            else()
                list(APPEND _result "${_file}")
            endif()
        endforeach()
    endif()
    set(${_out_var} ${_result} PARENT_SCOPE)
endfunction()
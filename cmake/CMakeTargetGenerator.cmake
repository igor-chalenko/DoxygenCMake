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
# * ``${TARGET_NAME}`` to run `doxygen`;
# * ``${TARGET_NAME}.open_html``:
#
#   .. code-block:: bash
#
#      ${DOXYGEN_LAUNCHER_COMMAND} ${OUTPUT_DIRECTORY}/html/index.html
#
#   This target is created unless HTML generation was disabled.
#
#   * ``${TARGET_NAME}.latex``:
#
#   .. code-block:: bash
#
#      ${DOXYGEN_LAUNCHER_COMMAND} ${OUTPUT_DIRECTORY}/latex/refman.tex
#
#   This target is created if LaTex generation was enabled.
#
#   * ``${TARGET_NAME}.pdf``:
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
function(_doxygen_add_targets _project_file _updated_project_file)
    _doxygen_assert_not_empty("${_project_file}")
    _doxygen_assert_not_empty("${_updated_project_file}")

    _doxygen_get(TARGET_NAME _target_name)
    if (NOT TARGET "${_target_name}")
        _doxygen_add_target("${_project_file}"
                "${_updated_project_file}"
                "${_target_name}")
        _doxygen_add_pdf_commands("${_target_name}")
        if (DOXYGEN_ADD_OPEN_TARGETS)
            _doxygen_create_open_targets("${_target_name}" )
        endif ()
    else()
        _doxygen_log(WARN "The target ${_target_name} already exists.")
    endif ()
endfunction()

function(_doxygen_create_generate_project_target)
    TPA_get("option_args" _option_args)
    TPA_get("one_value_args" _one_value_args)
    TPA_get("multi_value_args" _multi_value_args)

    _doxygen_get(PROJECT_FILE _project_file)
    _doxygen_get(TARGET_NAME _target_name)
    _doxygen_output_project_file_name(${_project_file} _updated_project_file)

    set (_new_args "")
    TPA_get(doxygen.updatable.properties _input_properties)
    foreach(_property ${_input_properties})
        _doxygen_get(${_property} _value)
        TPA_get(${_property}_TYPE _type)
        if (_type STREQUAL OPTION)
            if (_value STREQUAL "YES")
                list(APPEND _new_args "${_property}")
            endif()
        else()
            list(APPEND _new_args "${_property} ${_value}")
        endif()
    endforeach()

    get_property(_doxygen_dir GLOBAL PROPERTY _doxygen_dir)
    message(STATUS "!!! _project_file = ${_project_file}")
    message(STATUS "!!! _updated_project_file = ${_updated_project_file}")
    add_custom_command(
            OUTPUT "${_updated_project_file}"
            DEPENDS "${_project_file}"
            COMMAND ${CMAKE_COMMAND} -Dproject_dir="${CMAKE_CURRENT_SOURCE_DIR}" -Dargs=\"${_new_args}\" -P ${_doxygen_dir}/proto.cmake)

    message(STATUS "CMake will use: -Dproject_dir=\"${CMAKE_CURRENT_SOURCE_DIR}\" -Dargs=\"${_new_args}\"")

    add_custom_target(${_target_name}.prepare_doxyfile
            DEPENDS "${_updated_project_file}")
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_add_target
#
# ..  code-block:: cmake
#
#    _doxygen_add_target(<project file name>
#                          <processed project file name>
#                          <target name>)
#
# Creates a `doxygen` target ``_target_name`` and an `open generated docs`
# target for every output format that was requested.
#
# Parameters:
#
# * ``_project_file``  unprocessed project file name
# * ``_updated_project_file`` processed project file name
# * ``_target_name`` the name of the target to create
##############################################################################
function(_doxygen_create_generate_docs_target)
    _doxygen_get(OUTPUT_DIRECTORY _output_dir)
    _doxygen_get(PROJECT_FILE _project_file)
    _doxygen_get(TARGET_NAME _target_name)
    _doxygen_output_project_file_name(${_project_file} _updated_project_file)
    # collect inputs for `DEPENDS` parameter
    _doxygen_list_inputs(_inputs)
    _doxygen_assert_not_empty("${_inputs}")
    # collect outputs for the `OUTPUTS` parameter
    _doxygen_list_outputs("${_output_dir}" _files FILES)

    set(__stamp_file "${CMAKE_CURRENT_BINARY_DIR}/${_target_name}.stamp")

    add_custom_command(OUTPUT ${__stamp_file}
            COMMAND ${CMAKE_COMMAND} -E remove_directory "${_output_dir}"
            MAIN_DEPENDENCY "${_updated_project_file}"
            DEPENDS ${_inputs}
            COMMAND Doxygen::doxygen "${_updated_project_file}"
            COMMAND ${CMAKE_COMMAND} -E touch ${__stamp_file}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating documentation using ${_updated_project_file} ..."
            BYPRODUCTS "${_files}"
            VERBATIM)

    add_custom_target(${_target_name}
            DEPENDS ${__stamp_file}
            SOURCES ${_sources}
            )
    unset(__stamp_file)

endfunction()

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
function(_doxygen_add_pdf_commands _target_name)
    _doxygen_get(GENERATE_PDF _pdf)
    _doxygen_get(OUTPUT_DIRECTORY _output_dir)

    if (_pdf)
        file(MAKE_DIRECTORY ${_output_dir}/pdf)
        add_custom_command(TARGET
                ${_target_name}
                POST_BUILD
                COMMAND
                ${CMAKE_MAKE_PROGRAM} #> ${_output_directory}/latex.log 2>&1
                WORKING_DIRECTORY
                "${_output_dir}/latex"
                COMMENT "Generating PDF..."
                VERBATIM)
        add_custom_command(TARGET ${_target_name} POST_BUILD
                COMMENT "Copying refman.pdf to its own directory..."
                COMMAND ${CMAKE_COMMAND} -E copy
                "${_output_dir}/latex/refman.pdf"
                "${_output_dir}/pdf/refman.pdf")
        add_custom_command(TARGET ${_target_name} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E rm "${_output_dir}/latex/refman.pdf")
    endif ()
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
function(_doxygen_create_open_targets)
    _doxygen_get(TARGET_NAME _name_prefix)
    _doxygen_get(GENERATE_HTML _generate_html)
    _doxygen_get(GENERATE_LATEX _generate_latex)
    _doxygen_get(GENERATE_PDF _generate_pdf)
    _doxygen_get(OUTPUT_DIRECTORY _output_dir)

    if (WIN32)
        set(DOXYGEN_LAUNCHER_COMMAND start)
    elseif (NOT APPLE)
        set(DOXYGEN_LAUNCHER_COMMAND xdg-open)
    else ()
        # I didn't test this
        set(DOXYGEN_LAUNCHER_COMMAND open)
    endif ()

    if (DOXYGEN_LAUNCHER_COMMAND)
        if (_generate_html AND NOT TARGET ${_name_prefix}.open_html)
            # Create a target to open the generated HTML file.
            _doxygen_create_open_target(
                    ${_name_prefix}.open_html
                    ${_name_prefix}
                    "${_output_dir}/html/index.html")
        endif ()
        if (_generate_latex OR _generate_pdf AND NOT TARGET ${_name_prefix}.open_latex)
            _doxygen_create_open_target(
                    ${_name_prefix}.open_latex
                    ${_name_prefix}
                    "${_output_dir}/latex/refman.tex")
        endif ()
        if (_generate_pdf AND NOT TARGET ${_name_prefix}.open_pdf)
            _doxygen_create_open_target(
                    ${_name_prefix}.open_pdf
                    ${_name_prefix}
                    "${_output_dir}/pdf/refman.pdf")
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
    _doxygen_log(INFO "Adding launch target ${_target_name} for ${_file}...")
    add_custom_target(${_target_name}
            COMMAND ${DOXYGEN_LAUNCHER_COMMAND} "${_file}"
            COMMENT "Opening ${_file}..."
            VERBATIM)
    set_target_properties(${_target_name}
            PROPERTIES
            EXCLUDE_FROM_DEFAULT_BUILD TRUE
            EXCLUDE_FROM_ALL TRUE)
    add_dependencies(${_target_name} ${_parent_target_name})
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
function(_doxygen_install_docs)
    _doxygen_get(general.output-dir _output_dir)
    _doxygen_get(INSTALL_COMPONENT _component)

    if (NOT DEFINED CMAKE_INSTALL_DOCDIR)
        set(CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_PREFIX}")
        include(GNUInstallDirs)
    endif ()
    set(_destination ${CMAKE_INSTALL_DOCDIR})

    _doxygen_list_outputs("${_output_dir}" _files DIRECTORIES)

    foreach (_artifact ${_files})
        _doxygen_log(INFO "install ${_artifact} to ${_destination}...")
        install(DIRECTORY ${_artifact}
                DESTINATION ${_destination}
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
    # can't override these because they are in input parameters
    _doxygen_get(GENERATE_HTML _html)
    _doxygen_get(GENERATE_XML _xml)
    _doxygen_get(GENERATE_LATEX _latex)
    _doxygen_get(OUTPUT_DIRECTORY _output_dir)
    _doxygen_get(GENERATE_PDF _pdf)

    set(_out "")
    if (_option STREQUAL FILES)
        if (_html)
            set(_html_index_file "${_output_dir}/html/index.html")
            list(APPEND _out "${_html_index_file}")
        endif ()
        if (_xml)
            set(_xml_index_file "${_output_dir}/xml/index.xml")
            list(APPEND _out "${_xml_index_file}")
        endif ()
        if (_latex)
            set(_latex_index_file "${_output_dir}/latex/refman.tex")
            list(APPEND _out "${_latex_index_file}")
        endif ()
        if (_pdf AND)
            set(_pdf_file "${_output_dir}/pdf/refman.pdf")
            list(APPEND _out "${_pdf_file}")
        endif ()
    else ()
        list(APPEND _out "${_output_dir}/latex")
        list(APPEND _out "${_output_dir}/xml")
        list(APPEND _out "${_output_dir}/html")
        list(APPEND _out "${_output_dir}/pdf")
    endif ()

    set(${_out_var} "${_out}" PARENT_SCOPE)
endfunction()

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
    _doxygen_get(INPUT _inputs)
    _doxygen_get(INPUT_TARGET _input_target)

    set(_all_inputs "")
    if (_inputs)
        foreach (_dir ${_inputs})
            if (IS_DIRECTORY ${_dir})
                file(GLOB_RECURSE _inputs ${_dir}/*)
                list(APPEND _all_inputs "${_inputs}")
                message(STATUS "1. appending inputs ${_inputs}")
            else ()
                list(APPEND _all_inputs "${_dir}")
                message(STATUS "2. appending inputs ${_dir}")
            endif ()
        endforeach ()
    elseif (_input_target)
        get_target_property(_include_directories
                ${_input_target}
                INTERFACE_INCLUDE_DIRECTORIES)
        foreach (_dir ${_include_directories})
            file(GLOB_RECURSE _inputs "${_dir}/*")
            list(APPEND _all_inputs "${_inputs}")
            message(STATUS "3. appending inputs ${_inputs} from ${_dir}")
        endforeach ()
    else ()
        message(FATAL_ERROR [=[
Either INPUTS or INPUT_TARGET must be specified as input argument
for `doxygen_add_docs`:
1) INPUT_TARGET couldn't be defaulted to ${PROJECT_NAME};
2) Input project file didn't specify any inputs either.]=])
    endif ()

    message(STATUS "!!! _all_inputs = ${_all_inputs}")
    set(${_out_var} "${_all_inputs}" PARENT_SCOPE)
endfunction()

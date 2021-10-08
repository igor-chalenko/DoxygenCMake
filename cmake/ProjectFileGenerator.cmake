##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

##############################################################################
#.rst:
# Project file generator
# ----------------------
# This module implements functions that merge property values from different
# sources into a project file that will be used by `doxygen` as input.
# These sources include:
#
# * Inputs of :ref:`doxygen_add_docs`
#
#   These fall into two categories. The first one is the input parameters that
#   are not bound to any JSON paths. They are defined dynamically using
#   the functions :cmake:command:`_doxygen_input_string`,
#   :cmake:command:`_doxygen_input_option`, and
#   :cmake:command:`_doxygen_input_list`. The second category is the input
#   parameters that are bound to some JSON paths and thus may appear in
#   the final project file. Parameters from this category are handled
#   by :cmake:command:`_doxygen_property_add`.
#
# * Project file template
#
#   A property in a project file is identified by its JSON paths. It's then
#   possible to bind some processing
#   :cmake:command:`_doxygen_property_add` to that JSON path.
#
# * Overrides
#
#   These are defined via :cmake:command:`doxygen_add_override`. If an
#   override is defined for a certain property, that property in the final
#   project file will have the value of that override, with one exception.
#   It's not possible to have an override for a property that also has
#   input parameter bound to it.
#
##############################################################################
cmake_policy(SET CMP0057 NEW)

unset(IN_INPUT_STRING)
unset(IN_INPUT_OPTION)
unset(IN_INPUT_LIST)
unset(IN_DEFAULT)
unset(IN_SETTER)
unset(IN_UPDATER)
unset(IN_OVERWRITE)

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_inputs_parse
#
#  ..  code-block:: cmake
#
#    _doxygen_inputs_parse()
#
# Parses the input arguments previously defined by
# :cmake:command:`_doxygen_input_string`,
# :cmake:command:`_doxygen_input_option`, and
# :cmake:command:`_doxygen_input_list`. Applies any bound handlers, such as
# ``setter``, ``updater``, and ``default``, to every input argument.
##############################################################################
function(_doxygen_parse_input _out_var _property)
    doxygen_global_get("option_args" _option_args)
    doxygen_global_get("one_value_args" _one_value_args)
    doxygen_global_get("multi_value_args" _multi_value_args)

    cmake_parse_arguments(DOXYGEN
            "${_option_args}"
            "${_one_value_args}"
            "${_multi_value_args}"
            "${ARGN}")

    if ("${DOXYGEN_${_property}}" STREQUAL "TRUE")
        set(_value "YES")
    elseif("${DOXYGEN_${_property}}" STREQUAL "FALSE")
        set(_value "NO")
    else()
        set(_value "${DOXYGEN_${_property}}")
    endif()
    if (${_property} IN_LIST _option_args)
        if (_value STREQUAL NO AND NOT _property IN_LIST ARGN)
            # message(STATUS "erase the non-option ${_property}")
            set(_value "")
        endif()
    endif()
    set(${_out_var} "${_value}" PARENT_SCOPE)

    #foreach (_option ${_option_args})
    #    _doxygen_update_input_parameter(${_option} "${DOXYGEN_${_option}}")
    #endforeach ()
    #foreach (_arg ${_one_value_args})
    #    _doxygen_update_input_parameter(${_arg} "${DOXYGEN_${_arg}}")
    #endforeach ()
    #foreach (_list ${_multi_value_args})
    #    _doxygen_update_input_parameter(${_list} "${DOXYGEN_${_list}}")
    #endforeach ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: _doxygen_property_add
#
#  ..  code-block:: cmake
#
#    _doxygen_property_add(<property>
#                 [INPUT_OPTION <name>]
#                 [INPUT_STRING <name>]
#                 [INPUT_LIST <name>]
#                 [SETTER <function name>]
#                 [UPDATER <function name>]
#                 [DEFAULT <value>]
#                 [USE_PRODUCT_NAME]
#                 [OVERWRITE])
#
# Attaches read/write logic to a given property identified by its JSON path
# ``_path``. Declarations made using this function are interpreted later by
# :cmake:command:`_doxygen_update_path`. The following arguments are
# recognized:
#
# * ``INPUT_OPTION``, ``INPUT_STRING``, ``INPUT_LIST``
#
#   This JSON path can be updated if an input argument specified by one of
#   these options is provided. For example, `INPUT_OPTION GENERATE_XML`
#   specifies that `GENERATE_XML` is a valid argument of `doxygen_add_docs`.
#   If given, it will overwrite an existing value at the corresponding JSON
#   path; otherwise other handlers are invoked.
#
# * ``DEFAULT``
#
#   If the value in input JSON is empty, and no other handlers set it either,
#   this value is put into JSON path.
#
# * ``SETTER``
#
#   A function with this name is called if the current property value is empty.
#   The output variable becomes the new value in JSON.
#
# * ``UPDATER``
#
#   A function with this name is called if the current value of the property
#   is not empty. the current value is given as an argument. The output variable
#   becomes the new value in JSON.
#
# * ``OVERWRITE``
#
#   If given, the value in JSON is ignored and a given setter is called if
#   it was specified by `SETTER` argument. In other words, makes a call to
#   setter unconditional.
#
# The input arguments are parsed and stored in the current :ref:`TPA scope`.
#
# .. note::
#    ``_doxygen_property_add(_property)`` can be called more than once for
#    the same property. In this case, property's handlers will be merged by
#    adding the new ones and keeping the existing ones.
##############################################################################
function(_doxygen_property_add _path _type)
    doxygen_global_get(doxygen.updatable.properties _properties)

    set(_options OVERWRITE)
    set(_one_value_args DEFAULT SETTER UPDATER)
    #set(_multi_value_args INPUT_LIST)

    cmake_parse_arguments(IN "${_options}" "${_one_value_args}" "" "${ARGN}")

    doxygen_global_index(_index)
    #message(STATUS "1. _index = ${_index}")
    list(FIND _properties ${_path} _ind)
    if (NOT _ind EQUAL -1)
        return()
    endif()

    doxygen_global_set(${_path}_TYPE ${_type})
    if (_type STREQUAL STRING)
        doxygen_global_append(one_value_args ${_path})
        #doxygen_global_set(${_path}_INPUT ${IN_INPUT_STRING})
    endif ()
    if (_type STREQUAL OPTION)
        doxygen_global_append(option_args ${_path})
        #doxygen_global_set(${_path}_INPUT ${IN_INPUT_OPTION})
    endif ()
    if (_type STREQUAL LIST)
        doxygen_global_append(multi_value_args ${_path})
        #doxygen_global_set(${_path}_INPUT "${IN_INPUT_LIST}")
    endif ()
    if (DEFINED IN_DEFAULT AND NOT ${_path}_DEFAULT IN_LIST _index)
        doxygen_global_set(${_path}_DEFAULT ${IN_DEFAULT})
    endif ()
    if (DEFINED IN_SETTER)
        doxygen_global_set(${_path}_SETTER ${IN_SETTER})
    endif ()
    if (DEFINED IN_UPDATER)
        doxygen_global_set(${_path}_UPDATER ${IN_UPDATER})
    endif ()
    doxygen_global_get(${_path}_OVERWRITE _prev_overwrite)
    if (_prev_overwrite STREQUAL "")
        doxygen_global_set(${_path}_OVERWRITE ${IN_OVERWRITE})
    endif ()

    doxygen_global_append(doxygen.updatable.properties "${_path}")
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_update_path
#
# .. code-block:: cmake
#
#   _doxygen_update_path(_path)
#
# Applies update logic to a given property identified by its JSON path
# ``_path``. The property is updated in the loaded JSON document; if an input
# parameter is bound to this path, the corresponding input argument is updated
# as well. See :ref:`algorithm<algorithm-reference-label>` for a detailed
# description of actions taken by the function.
##############################################################################
function(_doxygen_update_path _path)
    #doxygen_global_get(${_path}_INPUT _input_param)
    doxygen_global_get(${_path}_SETTER _setter)
    doxygen_global_get(${_path}_UPDATER _updater)
    doxygen_global_get(${_path}_DEFAULT _default)
    doxygen_global_get(${_path}_TYPE _type)

    _doxygen_property_read_input(_input_value ${_path} ${ARGN})
    _doxygen_get(${_path} _project_value)
    if (_type STREQUAL LIST)
        separate_arguments(_project_value)
    endif()
    log_debug(_doxygen_update_path "[${_path}] _input_value = ${_input_value}")
    log_debug(_doxygen_update_path "[${_path}] _project_value = ${_project_value}")

    set(_value "")
    if (_input_value STREQUAL "")
        #_doxygen_log(DEBUG "before applying default: ${_path} = ${_value}")
        _doxygen_property_apply_default(${_path}
                "${_default}"
                "${_value}"
                "${_input_value}"
                _value)

        _doxygen_property_apply_setter(${_path} "${_setter}" _value)
        if ("${_value}" STREQUAL "")
            set(_value "${_project_value}")
        endif()

        #_doxygen_log(DEBUG "before applying updater: ${_path} = ${_value}")
        _doxygen_property_apply_updater(${_path}
                "${_updater}"
                "${_value}"
                _value)
        #_doxygen_log(DEBUG "after applying default: ${_path} = ${_value}")

        #_doxygen_set(${_path} "${_value}")
        #if (_input_param)
        #    doxygen_global_set(${_input_param} "${_value}")
        # endif ()
    else()
        #_doxygen_log(DEBUG "before applying updater: _input_value of ${_path} = ${_input_value}")
        set(_value "${_input_value}")
        _doxygen_property_apply_updater(${_path}
                "${_updater}"
                "${_value}"
                _value)
    endif()
    log_debug(_doxygen_update_path "set ${_path} to ${_value}")
    _doxygen_set(${_path} "${_value}")
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_property_apply_setter
#
# .. code-block:: cmake
#
#   _doxygen_property_apply_setter(_path _name _out_var)
#
# Helper function that applies setter to a property identified by ``_path``.
#
# Parameters:
#
# * ``_path`` a property to update, identified by its JSON path
# * ``_name`` the name of a setter function to call
# * ``_out_var`` the output variable
##############################################################################
function(_doxygen_property_apply_setter _path _name _out_var)
    if (_name)
        doxygen_global_get(${_path}_OVERWRITE _overwrite)
        if ("${_project_value}" STREQUAL "" AND "${_input_value}" STREQUAL "" OR _overwrite)
            # call setter
            log_debug(_doxygen_property_apply_setter "call setter ${_name}")
            _doxygen_call_2(_doxygen_${_name} _new_value)
            set(${_out_var} ${_new_value} PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_property_apply_updater
#
# .. code-block:: cmake
#
#   _doxygen_property_apply_updater(_path _name _out_var)
#
# Helper function that applies updater to a property identified by ``_path``.
#
# Parameters:
#
# * ``_path`` a property to update, identified by its JSON path
# * ``_name`` the name of an updater function to call
# * ``_out_var`` the output variable
##############################################################################
function(_doxygen_property_apply_updater _property _name _value _out_var)
    if (_name)
        # call updater
        log_debug(_doxygen_property_apply_updater "call updater ${_name}(${_value})")
        _doxygen_call(_doxygen_${_name} "${_value}" _new_value)
        set(${_out_var} "${_new_value}" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_property_apply_default
#
# .. code-block:: cmake
#
#   _doxygen_property_apply_default(_property
#                                     _default
#                                     _value
#                                     _input_value
#                                     _out_var)
#
# Sets output variable to the value of ``_default``, if ``_value`` is empty.
# Does nothing otherwise.
#
# Parameters:
#
# * ``_property`` an input property
# * ``_default`` a value to set
# * ``_value`` the current value of the property ``_property``
# * ``_input_value`` an input value of the corresponding input parameter
# * ``_out_var`` the output variable
##############################################################################
function(_doxygen_property_apply_default _property
        _default _value _input_value _out_var)
    if (NOT _default STREQUAL "")
        doxygen_global_get(${_property}_OVERWRITE _overwrite)
        #doxygen_global_get(${_property}_TYPE _type)
        if (NOT _input_value STREQUAL "")
            set(_overwrite false)
        endif ()
        #if (_value STREQUAL "NO" AND _type STREQUAL OPTION)
            #message(STATUS "unset the option ${_path}")
        #    set(_value "")
        #endif()

        if (_value STREQUAL "" OR _overwrite)
            set(${_out_var} "${_default}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_property_read_input
#
# .. code-block:: cmake
#
#   _doxygen_property_read_input(_path _input_arg_name _out_var)
#
# Finds the input argument ``_input_arg_name`` in the current TPA scope,
# converts `CMake`'s boolean values to ``true``/``false`` format, and writes
# the result into the output variable ``_out_var``.
##############################################################################
function(_doxygen_property_read_input _out_var _path)
    _doxygen_parse_input(_input_value ${_path} ${ARGN})

    set(${_out_var} "${_input_value}" PARENT_SCOPE)
endfunction()

# todo rename
function(_doxygen_inputs_parse)
    doxygen_global_get(doxygen.updatable.properties _updatable_paths)

    foreach (_path ${_updatable_paths})
        _doxygen_update_path(${_path} ${ARGN})
    endforeach()
endfunction()

function(_doxygen_parse_inputs)
    #_doxygen_init_input_params()
    # todo rename
    doxygen_global_get(doxygen.updatable.properties _updatable_paths)
    foreach (_path ${_updatable_paths})
        _doxygen_update_path(${_path} ${ARGN})
    endforeach()
endfunction()
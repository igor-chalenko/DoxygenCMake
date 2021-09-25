##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

get_property(_include_guard GLOBAL PROPERTY TPA_CMAKE_INCLUDE_GUARD)
if (NOT _include_guard)
    set_property(GLOBAL PROPERTY TPA_CMAKE_INCLUDE_GUARD ON)
else()
    return()
endif()
##############################################################################
#.rst:
# Target Property Accessors (TPA)
# -------------------------------
#
# Functions with prefix ``TPA`` manage state of a surrogate `INTERFACE` target:
# properties of this target are used as a global cache for stateful data.
# This surrogate target is called :ref:`TPA scope` throughout this
# documentation. It's possible to set, unset, or append to a target property
# using syntax similar to that of usual variables:
#
# .. code-block:: cmake
#
#   # set(variable value)
#   global_map_set(variable value)
#   # unset(variable)
#   global_map_unset(variable)
#   # list(APPEND variable value)
#   global_map_append(variable value)
#
# ---------
# TPA scope
# ---------
#
# A TPA scope is a dictionary of some target's properties. Therefore, it is
# a named global scope with a lifetime of the underlying target. Variables never
# go out of scope in `TPA` and must be deleted explicitly (if needed). `CMake`
# doesn't allow arbitrary property names; therefore, input property names are
# prefixed with ``INTERFACE_`` to obtain the actual property name in that
# `INTERFACE` target. Each TPA scope maintains the index of properties
# it contains; this makes it easy to clear up a scope entirely and re-use it
# afterward. There can be only one TPA scope in a project, as its name uses
# the value of  ``CMAKE_PROJECT_NAME`` as prefix.
##############################################################################
#.rst:
# -------------
# TPA functions
# -------------
##############################################################################

#set(_DOXYPRESS_global_map_index_KEY property.index CACHE STRING "index of properties")
#mark_as_advanced(_DOXYPRESS_global_map_index_KEY)

##############################################################################
#.rst:
# .. cmake:command:: global_map_set
#
# .. code-block:: cmake
#
#    global_map_set(_name _value)
#
# Sets the property with the ``_name`` to a new value of ``_value``.
##############################################################################
function(global_map_set _name _value)
    set(_prefix "__doxygen.")
    #_TPA_current_scope(_scope)
    #set_property(TARGET ${_scope} PROPERTY INTERFACE_${_name} "${_value}")

    global_map_index(_index)
    list(FIND _index "${_prefix}${_name}" _ind)
    set_property(GLOBAL PROPERTY "${_prefix}${_name}" ${_value})
    if (_ind EQUAL -1)
        list(APPEND _index "${_prefix}${_name}")
        global_map_set_index("${_index}")
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_unset
#
# .. code-block:: cmake
#
#    global_map_unset(_name)
#
# Unsets the property with the name ``_name``.
##############################################################################
function(global_map_unset _name)
    set(_prefix "__doxygen.")
    #_TPA_current_scope(_scope)
    #set_property(TARGET ${_scope} PROPERTY INTERFACE_${_name})

    global_map_index(_index)
    list(FIND _index "${_prefix}${_name}" _ind)
    if (NOT _ind EQUAL -1)
        set_property(GLOBAL PROPERTY "${_prefix}${_name}")
        list(REMOVE_ITEM _index "${_prefix}${_name}")
        global_map_set_index("${_index}")
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_get
#
# .. code-block:: cmake
#
#    global_map_get(_name _out_var)
#
# Stores the value of a property ``_name`` into the parent scope's variable
# designated by ``_out_var``.
##############################################################################
function(global_map_get _name _out_var)
    set(_prefix "__doxygen.")
    get_property(_value GLOBAL PROPERTY ${_prefix}${_name})
    list(LENGTH _value _length)
    # message(STATUS "Length of ${_name} is ${_length}")
    if ("${_value}" STREQUAL "_value-NOTFOUND")
        #message(STATUS "property ${_name} not found - return empty string")
        set(${_out_var} "" PARENT_SCOPE)
    else ()
        set(${_out_var} "${_value}" PARENT_SCOPE)
    endif ()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_append
#
# .. code-block:: cmake
#
#    global_map_append(_name _value)
#
# If the property `_name` exists, it is treated as a list, and the value of
# ``_value`` is appended to it. Otherwise, the property ``_name`` is created and
# set to the given value.
##############################################################################
function(global_map_append _name _value)
    global_map_index(_index)
    #list(FIND _index ${_name} _ind)

    # list(APPEND ${_name} ${_values})
    global_map_get(${_name} _current_value)
    if ("${_current_value}" STREQUAL "")
        global_map_set(${_name} "${_value}")
        #list(APPEND _index ${_name})
        #global_map_set_index("${_index}")
    else()
        list(APPEND _current_value "${_value}")
        global_map_set(${_name} "${_current_value}")
    endif()
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_clear_scope
#
# .. code-block:: cmake
#
#    global_map_clear_scope()
#
# Clears all properties previously set by calls to ``global_map_set`` and
# ``global_map_append``.
##############################################################################
function(global_map_clear_scope)
    set(_prefix "__doxygen.")

    global_map_index(_index)
    foreach(_name ${_index})
        set_property(GLOBAL PROPERTY "${_name}")
    endforeach()
    set_property(GLOBAL PROPERTY ${_prefix}property.index)
    global_map_get(doxygen.updatable.properties _input_properties)
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_index
#
# .. code-block:: cmake
#
#    global_map_index(_out_var)
#
# Writes the current scope's index into the variable designated by ``_out_var``
# in the parent scope.
##############################################################################
function(global_map_index _out_var)
    global_map_get(property.index _index)
    #message(STATUS "_index_xx = ${_index_xx}")
    set(${_out_var} "${_index}" PARENT_SCOPE)
endfunction()

##############################################################################
#.rst:
# .. cmake:command:: global_map_set_index
#
# Replace the current TPA scope's index by the list given by ``_index``.
##############################################################################
function(global_map_set_index _index)
    set(_prefix "__doxygen.")
    set_property(GLOBAL PROPERTY ${_prefix}property.index "${_index}")
endfunction()

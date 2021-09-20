##############################################################################
# Copyright (c) 2020 Igor Chalenko
# Distributed under the MIT license.
# See accompanying file LICENSE.md or copy at
# https://opensource.org/licenses/MIT
##############################################################################

##############################################################################
#.rst:
# =======
# Logging
# =======
#
# This module implements basic logging with level limited by
# :cmake:variable:`DOXYGEN_LOG_LEVEL`. There's also a function
# :cmake:command:`_doxygen_action`, which tracks property updates on
# a per-property basis, so that all updates to a single property can
# be examined.
##############################################################################

cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0011 NEW)

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_log
#
# .. code-block:: cmake
#
#    _doxygen_log(_level _message)
#
# Prints a given message if the corresponding log level is on (set by
# :cmake:variable:`DOXYGEN_LOG_LEVEL`). Does nothing otherwise.
##############################################################################
function(_doxygen_log _level _message)
    if (NOT DOXYGEN_LOG_LEVEL)
        set(DOXYGEN_LOG_LEVEL WARN)
    endif()
    set(_log_levels "DEBUG;INFO;WARN")

    list(FIND _log_levels ${_level} _ind)
    if (_ind EQUAL -1)
        set(_ind 2)
    endif()
    list(FIND _log_levels ${DOXYGEN_LOG_LEVEL} _ind2)
    if (_ind2 EQUAL -1)
        set(_ind2 1)
    endif()
    if (${_ind} GREATER_EQUAL ${_ind2})
        if (${_level} STREQUAL WARN AND DOXYGEN_PROMOTE_WARNINGS)
            message(WARNING "${_message}")
        else()
            message(STATUS "[${_level}] ${_message}")
        endif()
    endif ()
endfunction()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_assert_not_empty
#
# .. code-block:: cmake
#
#    _doxygen_assert_not_empty(_value)
#
# If the value given by ``_value`` is empty, fails with a fatal error.
# Does nothing otherwise.
macro(_doxygen_assert_not_empty _value)
    if ("${_value}" STREQUAL "")
        _doxygen_assert_fail("Expected non-empty variable.")
    endif()
endmacro()

##############################################################################
#.rst:
#
# .. cmake:command:: _doxygen_assert_fail
#
# .. code-block:: cmake
#
#    # equivalent to message(FATAL_ERROR "${_message}")
#    _doxygen_assert_fail(_message)
#
function(_doxygen_assert_fail _message)
    message(FATAL_ERROR "${_message}")
endfunction()
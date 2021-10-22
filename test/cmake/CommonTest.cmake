get_filename_component(_current_dir ${CMAKE_CURRENT_LIST_FILE} PATH)
set_property(GLOBAL PROPERTY current.dir "${_current_dir}")

include(${_current_dir}/Obtain.cmake)

message(STATUS "CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}")
find_package(doxygen-cmake REQUIRED)
message(STATUS "doxygen-cmake_DIR = ${doxygen-cmake_DIR}")
add_to_registry(self "${doxygen-cmake_DIR}")

# overrides
function(_doxygen_get_target_property _out_var _target _property)
    global_get(add.target.${_target} ${_property} _value)
    set(${_out_var} "${_value}" PARENT_SCOPE)
endfunction()

function(create_mock_target _target _type)
    global_set(add.target.${_target} TYPE ${_type})
    global_set(add.target.${_target} SOURCES src/main.cc)
    global_set(add.target.${_target} EXCLUDE_FROM_ALL 1)
    global_set(add.target.${_target} INCLUDE_DIRECTORIES ${_project_source_dir}/test/include;${_project_source_dir}/test/include5)
endfunction()

function(_doxygen_set_target_properties _target)
endfunction()

function(_doxygen_add_dependencies)
endfunction()

macro(_doxygen_add_custom_command)
endmacro()

macro(_doxygen_add_custom_target _target)
    create_mock_target(${_target} CUSTOM)
endmacro()

function(target_created _target _out_var)
    global_get_or_fail(add.target.${_target} TYPE _value)
    if (${_value} STREQUAL CUSTOM)
        set(${_out_var} true PARENT_SCOPE)
    else()
        set(${_out_var} false PARENT_SCOPE)
    endif()
endfunction()

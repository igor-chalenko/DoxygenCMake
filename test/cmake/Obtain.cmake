get_filename_component(_current_dir ${CMAKE_CURRENT_LIST_FILE} PATH)
set_property(GLOBAL PROPERTY current.dir "${_current_dir}")

macro(obtain _name)
    find_package(${_name} QUIET ${ARGN})
endmacro()

macro(add_to_registry _module _path)
    get_property(_current_dir GLOBAL PROPERTY current.dir)
    set_property(GLOBAL PROPERTY module.path.${_module} "${_path}")
endmacro()

macro(import _module)
    get_property(_current_dir GLOBAL PROPERTY current.dir)

    if (${_module} MATCHES "(.+)::(.+)")
        get_property(_path GLOBAL PROPERTY module.path.${CMAKE_MATCH_1})
        if (NOT _path)
            obtain(${CMAKE_MATCH_1} ${ARGN})
            if (${CMAKE_MATCH_1}_FOUND)
                get_property(_path GLOBAL PROPERTY module.path.${CMAKE_MATCH_1})
            else()
                message(FATAL_ERROR "obtain(${CMAKE_MATCH_1}) failed.")
            endif()
        endif()
        include(${_path}/${CMAKE_MATCH_2}.cmake)
    else()
        message(FATAL_ERROR "Use package::module form for importing")
    endif()
endmacro()

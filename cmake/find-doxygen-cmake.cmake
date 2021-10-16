include(FindPackageHandleStandardArgs)

find_package(Doxygen QUIET)
if (TARGET Doxygen::doxygen)
    # We must run the following at "include" time, not at function call time,
    # to find the path to this module rather than the path to a calling list file
    get_filename_component(_current_dir ${CMAKE_CURRENT_LIST_FILE} PATH)
    set_property(GLOBAL PROPERTY _current_dir "${_current_dir}")

    find_package_handle_standard_args(
            doxygen-cmake
            REQUIRED_VARS DOXYGEN_EXECUTABLE
            VERSION_VAR DOXYGEN_VERSION
            HANDLE_COMPONENTS
    )

    # "New" IN_LIST syntax
    cmake_policy(SET CMP0057 NEW)

    include(${_current_dir}/AddDocs.cmake)
else()
    message(STATUS "Doxygen is not installed, DoxygenCMake is disabled.")
endif()
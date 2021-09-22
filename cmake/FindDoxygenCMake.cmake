include(FindPackageHandleStandardArgs)

find_package(Doxygen REQUIRED)

find_package_handle_standard_args(
        DoxygenCMake
        REQUIRED_VARS DOXYGEN_EXECUTABLE
        VERSION_VAR DOXYGEN_VERSION
        HANDLE_COMPONENTS
)

# We must run the following at "include" time, not at function call time,
# to find the path to this module rather than the path to a calling list file
get_filename_component(_doxygen_dir ${CMAKE_CURRENT_LIST_FILE} PATH)
set_property(GLOBAL PROPERTY _doxygen_dir "${_doxygen_dir}")

# "New" IN_LIST syntax
cmake_policy(SET CMP0057 NEW)

include(${_doxygen_dir}/AddDocs.cmake)

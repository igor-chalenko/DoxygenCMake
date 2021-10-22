include(FindPackageHandleStandardArgs)

find_package(Doxygen QUIET)
find_package(LATEX QUIET OPTIONAL_COMPONENTS MAKEINDEX PDFLATEX)
if (TARGET Doxygen::doxygen)
    set(DOXYGEN_CMAKE_VERSION 0.1)

    find_package_handle_standard_args(
            doxygen-cmake
            REQUIRED_VARS PACKAGE_PREFIX_DIR
            VERSION_VAR DOXYGEN_CMAKE_VERSION
    )
    include(${DOXYGEN_CMAKE_MODULE_DIR}/add-docs.cmake)
else()
    message(STATUS "Doxygen is not installed, doxygen-cmake is disabled.")
endif()
cmake_minimum_required(VERSION 3.19)
project(doxygen-cmake VERSION 0.1 DESCRIPTION "Doxygen module for CMake")

function(doxygen_install _NAME _DESTINATION)
    if (NOT DEFINED CMAKE_INSTALL_DATADIR)
        include(GNUInstallDirs)
    endif()
    install_basic_package_files(${_NAME}
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY AnyNewerVersion
            ARCH_INDEPENDENT
            LOWERCASE_FILENAMES
            NO_EXPORT
            EXTRA_PATH_VARS_SUFFIX MODULE_DIR
            NO_CHECK_REQUIRED_COMPONENTS_MACRO)

    # slash at the end removes `cmake` from the directory structure
    install(DIRECTORY "${CMAKE_SOURCE_DIR}/cmake/"
            DESTINATION ${_DESTINATION}
            PATTERN "${CMAKE_SOURCE_DIR}/cmake/3rd-party/InstallBasicPackageFiles.cmake" EXCLUDE)
endfunction()

if (PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    include(cmake/3rd-party/InstallBasicPackageFiles.cmake)

    enable_testing()
    add_subdirectory(test)
    add_subdirectory(docs)

    set(_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME})
    doxygen_install("${PROJECT_NAME}" "${_DESTINATION}")
endif()
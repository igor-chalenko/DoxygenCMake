cmake_minimum_required(VERSION 3.3)
project(DoxygenCMake VERSION 0.1 DESCRIPTION "Doxygen module for CMake")

if (PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    include(cmake/3rd-party/InstallBasicPackageFiles.cmake)

    enable_testing()
    add_subdirectory(test)
    add_subdirectory(docs)

    if (NOT DEFINED CMAKE_INSTALL_DATADIR)
        include(GNUInstallDirs)
    endif()
    set(_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION})
    install_basic_package_files(${PROJECT_NAME}
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY AnyNewerVersion
            ARCH_INDEPENDENT
            NO_EXPORT
            EXTRA_PATH_VARS_SUFFIX MODULE_DIR
            NO_CHECK_REQUIRED_COMPONENTS_MACRO)

    # slash at the end removes `cmake` from the directory structure
    install(DIRECTORY "cmake/"
            DESTINATION ${_DESTINATION}
            PATTERN cmake/3rd-party EXCLUDE)
endif()
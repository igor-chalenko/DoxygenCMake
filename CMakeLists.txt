cmake_minimum_required(VERSION 3.3)
project(doxygen-cmake VERSION 0.1 DESCRIPTION "Doxygen module for CMake")

if (PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    include(cmake/InstallBasicPackageFiles.cmake)

    enable_testing()
    add_subdirectory(test)
    #add_subdirectory(doc)

    if (${CMAKE_VERSION} VERSION_LESS 3.14)
        if (NOT DEFINED CMAKE_INSTALL_LIBDIR)
            include(GNUInstallDirs)
        endif()
        set(_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
        install_basic_package_files(${PROJECT_NAME}
                VERSION ${PROJECT_VERSION}
                COMPATIBILITY AnyNewerVersion
                #ARCH_INDEPENDENT
                NO_EXPORT
                EXTRA_PATH_VARS_SUFFIX MODULE_DIR
                NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    else()
        if (NOT DEFINED CMAKE_INSTALL_DATADIR)
            unset(CMAKE_INSTALL_DATADIR)
            include(GNUInstallDirs)
        endif()
        set(_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME})
        install_basic_package_files(${PROJECT_NAME}
                VERSION ${PROJECT_VERSION}
                COMPATIBILITY AnyNewerVersion
                ARCH_INDEPENDENT
                LOWERCASE_FILENAMES
                NO_EXPORT
                EXTRA_PATH_VARS_SUFFIX MODULE_DIR
                NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    endif()

    # slash at the end removes `cmake` from the directory structure
    install(DIRECTORY "cmake/"
            DESTINATION ${_DESTINATION}
            PATTERN cmake/InstallBasicPackageFiles.cmake EXCLUDE)
endif()
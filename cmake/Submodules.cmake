find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    # Update submodules as needed
    option(GIT_SUBMODULES "Check submodules during build" ON)
    if(GIT_SUBMODULES)
        message(STATUS "Update submodules...")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                RESULT_VARIABLE _GIT_RESULT)
        if(NOT _GIT_RESULT EQUAL 0)
            message(FATAL_ERROR "git submodule update --init --recursive failed with ${GIT_RESULT}, please checkout submodules")
        endif()
    endif()
endif()

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/externals/cmake-utilities/CMakeLists.txt")
    message(FATAL_ERROR "The submodules were not downloaded! GIT_SUBMODULES was turned off or failed. Please update submodules and try again.")
endif()

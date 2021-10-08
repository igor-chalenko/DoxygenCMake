project(doxygen-cmake-test VERSION 0.1)

set(_doxygen_dir ${PROJECT_SOURCE_DIR}/../cmake)
#include(../cmake/AddDocs.cmake)

add_executable(main src/main.cc)
set_target_properties(main PROPERTIES EXCLUDE_FROM_ALL 1)
target_include_directories(main PUBLIC include include5)

add_test(
        NAME dynamic_functions_test
        COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/cmake/GlobalMapTest.cmake
)

add_test(
        NAME parameter_test
        COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/cmake/ParameterTest.cmake
)

if (TRUE)
    message(STATUS "Running tests...")
    set(DOXYGEN_LOG_LEVEL INFO)
    #set(doxygen.project.dir "${CMAKE_CURRENT_SOURCE_DIR}")
    #doxygen_add_docs_new(PROJECT_FILE cmake/Doxyfile INPUT_TARGET main GENERATE_PDF)
    #include(cmake/GlobalMapTest.cmake)
    #include(cmake/ParameterTest.cmake)
    #include(cmake/TestCreateTargets.cmake)
    #include(cmake/TestAddDocs.cmake)
    #include(TestFindAddDocs.cmake)
endif()
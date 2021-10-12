project(doxygen-cmake-test VERSION 0.1)

set(_doxygen_dir ${PROJECT_SOURCE_DIR}/../cmake)
#include(../cmake/AddDocs.cmake)

add_executable(main src/main.cc)
set_target_properties(main PROPERTIES EXCLUDE_FROM_ALL 1)
target_include_directories(main PUBLIC include include5)

find_package(cmake-utilities REQUIRED)

add_test(
        NAME global_map_test
        COMMAND ${CMAKE_COMMAND}
        -Dcmake-utilities_DIR=${CMAKE_MODULE_PATH}
        -P ${PROJECT_SOURCE_DIR}/cmake/GlobalMapTest.cmake
)

add_test(
        NAME parse_inputs_test
        COMMAND ${CMAKE_COMMAND}
        -Dcmake-utilities_DIR=${CMAKE_MODULE_PATH}
        -P ${PROJECT_SOURCE_DIR}/cmake/ParseInputsTest.cmake
)

add_test(
        NAME load_project_test
        COMMAND ${CMAKE_COMMAND}
        -DDOXYGEN_OPEN_TARGETS=ON
        -Dcmake-utilities_DIR=${CMAKE_MODULE_PATH}
        -DCMAKE_CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
        -DCMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
        -P ${PROJECT_SOURCE_DIR}/cmake/LoadProjectTest.cmake
)

add_test(
        NAME create_targets_test
        COMMAND ${CMAKE_COMMAND}
        -Dcmake-utilities_DIR=${CMAKE_MODULE_PATH}
        -P ${PROJECT_SOURCE_DIR}/cmake/CreateTargetsTest.cmake
)

add_test(
        NAME add_docs_test
        COMMAND ${CMAKE_COMMAND}
        -Dcmake-utilities_DIR=${CMAKE_MODULE_PATH}
        -DCMAKE_CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
        -DCMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
        -DDOXYGEN_OPEN_TARGETS=ON
        -P ${PROJECT_SOURCE_DIR}/cmake/AddDocsTest.cmake
)

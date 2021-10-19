add_custom_target(docs
        COMMAND sphinx-build -b html ./ -c ${CMAKE_CURRENT_SOURCE_DIR}/source ${CMAKE_CURRENT_BINARY_DIR}/sphinx-generated
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/source)

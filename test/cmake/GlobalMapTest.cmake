set(_project_source_dir "${CMAKE_CURRENT_BINARY_DIR}/../../")

include(${_project_source_dir}/externals/cmake-utilities/cmake/Testing.cmake)
include(${_project_source_dir}/externals/cmake-utilities/cmake/GlobalMap.cmake)
include(${_project_source_dir}/externals/cmake-utilities/cmake/DynamicFunctions.cmake)
include(${_project_source_dir}/externals/cmake-utilities/cmake/Logging.cmake)

function(test_get_set_append)
    doxygen_global_set(property "value")
    doxygen_global_append(property "value2")
    doxygen_global_get(property _new_value)
    assert_same("${_new_value}" "value;value2")
endfunction()

function(test_clear)
    doxygen_global_set(output-xml.generate-xml_INPUT GENERATE_XML)
    doxygen_global_set(output-xml.generate-xml_SETTER "set_generate_xml")

    doxygen_global_get(output-xml.generate-xml_INPUT _xml)
    assert_same("${_xml}" "GENERATE_XML")
    doxygen_global_get(output-xml.generate-xml_SETTER _setter)
    assert_same("${_setter}" "set_generate_xml")
    doxygen_global_clear()
    doxygen_global_get(output-xml.generate-xml_INPUT _xml)
    assert_same("${_xml}" "")
    doxygen_global_get(output-xml.generate-xml_SETTER _setter)
    assert_same("${_setter}" "")
endfunction()

parameter_to_function_prefix(doxygen
        global_get
        global_set
        global_append
        global_clear
        global_index)

test_get_set_append()
test_clear()


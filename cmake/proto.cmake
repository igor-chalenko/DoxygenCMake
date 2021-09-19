cmake_policy(SET CMP0054 NEW)
get_filename_component(_doxygen_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

include(${_doxygen_dir}/AddDocs.cmake)

#SEPARATE_ARGUMENTS(_new_args)
set(_inputs "${_new_args}")
SEPARATE_ARGUMENTS(_inputs)
list(LENGTH _inputs _len)
doxygen_prepare_doxyfile(${_inputs})

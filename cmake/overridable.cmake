macro(_doxygen_set_target_properties _target)
    set_target_properties(${_target} ${ARGN})
endmacro()

function(_doxygen_get_target_property _out_var _target _property)
    get_target_property(_type ${_target} ${_property})
    set(${_out_var} ${_type} PARENT_SCOPE)
endfunction()

macro(_doxygen_add_custom_command)
    add_custom_command(${ARGN})
endmacro()

macro(_doxygen_add_custom_target _target)
    add_custom_target(${_target} ${ARGN})
endmacro()

macro(_doxygen_add_dependencies)
    add_dependencies(${ARGN})
endmacro()

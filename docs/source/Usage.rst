Usage
-----

Once installed, use ``find_package`` and ``add_doxygen_targets``:

.. code-block:: cmake

   find_package(doxygen-cmake REQUIRED)

   # enable XML and disable HTML generation
   add_doxygen_targets(
                     PROJECT_FILE docs/Doxyfile
                     INPUT_TARGET my_library
                     GENERATE_HTML NO
                     GENERATE_XML)

   # default project file, the target `PROJECT_NAME` must exist
   add_doxygen_targets()

   # enable .pdf generation, a few properties have a custom value;
   # paths are relative to `CMAKE_CURRENT_SOURCE_DIR`
   add_doxygen_targets(
                     PROJECT_FILE docs/Doxyfile
                     INPUT_TARGET my_library
                     GENERATE_PDF
                     DISABLE_INDEX YES
                     HTML_EXTRA_STYLESHEET css/custom.css
                     GENERATE_TREEVIEW YES)



Why
---

There are a few things this package can do that can not be done easily with
the `Doxygen` module bundled with `CMake`:

- One can provide a prepared project file instead of using
  the ``default`` + ``CMake overrides`` formula. The input arguments
  will be merged into the final project file.
- The input project is parsed to set up the target dependencies on extra files,
  such as a custom stylesheet, HTML header/footer, etc. The documentation build
  will correctly re-trigger when those files are modified.
- Environment-specific properties, such as ``HAVE_DOT``, ``WARN_FORMAT``, etc.,
  will be set automatically.
- PDF generation is supported (from the generated LaTex sources).


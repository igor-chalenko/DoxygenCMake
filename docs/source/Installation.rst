Installation
------------

This package is not intended to be used standalone. Instead, it is integrated
into calm-cmake_ as one of the plugins. However, it's still an ordinary CMake
package with one dependency:

.. code-block:: bash

  git clone https://github.com/igor-chalenko/CMakeUtilities.git
  cd CMakeUtilities
  mkdir build && cd build
  cmake ..
  make test
  sudo make install
  cd ../..
  git clone https://github.com/igor-chalenko/DoxygenCMake.git
  mkdir build && cd build
  cmake ..
  make test
  sudo make install

.. _calm-cmake: https://github.com/igor-chalenko/calm-cmake

The package initialization depends on ``find_package(Doxygen)``. If `Doxygen`
is not found, the module will not expose any public API at all.
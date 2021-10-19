# doxygen-cmake
[![Build Status](https://app.travis-ci.com/igor-chalenko/doxygen-cmake.svg?branch=master)](https://app.travis-ci.com/igor-chalenko/doxygen-cmake)

What is it
----------

This is a CMake package that makes it easy to set up API documentation
generation via
[Doxygen](https://github.com/doxygen/doxygen).
[Read](https://doxygen-cmake.readthedocs.io/en/latest/index.html)
the documentation at [Read the Docs](https://readthedocs.io/).

Files
-----
* `add-docs.cmake`, `cmake-target-generators.cmake`, 
  `find-doxygen-cmake.cmake`,  `project-functions.cmake`, 
  `property-handlers.cmake`

  The package files.

* `InstallBasicPackageFiles.cmake`

  A helper module that generates CMake's config and config version files.
  It's taken from the project [YCM](https://github.com/robotology/ycm),
  which is
  [copyrighted](https://github.com/robotology/ycm/blob/master/Copyright.txt)
  by Istituto Italiano di Tecnologia (IIT):

    ```
    Copyright 2014 Istituto Italiano di Tecnologia (IIT)
      Authors: Daniele E. Domenichelli <daniele.domenichelli@iit.it>

    Distributed under the OSI-approved BSD License (the "License");
    see accompanying file Copyright.txt for details.

    This software is distributed WITHOUT ANY WARRANTY; without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the License for more information.
    ```

  Follow the
  [link](https://github.com/robotology/ycm/blob/master/modules/InstallBasicPackageFiles.cmake)
  to view the original source. It's not a part of the installation package.
     
Installation
------------

```bash
  git clone https://github.com/igor-chalenko/cmake-utilities.git
  cd cmake-utilities
  mkdir build && cd build
  cmake ..
  make test
  sudo make install
  cd ../..
  git clone https://github.com/igor-chalenko/doxygen-cmake.git
  mkdir build && cd build
  cmake ..
  make test
  sudo make install
```

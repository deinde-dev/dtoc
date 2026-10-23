.. SPDX-License-Identifier: GPL-2.0+

Devicetree-to-C generator
=========================

This is a Python program and associated utilities, which supports converting
devicetree files into C code. It generates header files containing struct
definitions, as well as C files containing the data. It does not require any
modification of the devicetree files.

Some high-level libraries are provided for working with devicetree. These may
be useful in other projects.

This package also includes some U-Boot-specific features, such as creating
`struct udevice` and `struct uclass` entries for devicetree nodes.

Installation
------------

Install the latest release from PyPI::

    pip install dtoc

This brings in the pylibfdt and u-boot-pylib packages, which dtoc uses.
Compiling devicetree source files, as the tests do, also needs the devicetree
compiler (``dtc``) and a C preprocessor.

How it works
------------

U-Boot's ``OF_PLATDATA`` options let SPL and TPL use devicetree data without
including libfdt or parsing a devicetree at run time. Instead, U-Boot's build
runs dtoc on the devicetree for the phase, and dtoc writes C code holding the
same data, which is compiled into that phase.

To do this, dtoc:

- reads the devicetree binary (.dtb), which U-Boot's build has already cut
  down to the nodes the phase needs, skipping any which are disabled;
- scans the U-Boot source tree for drivers (``U_BOOT_DRIVER()``), their
  compatible strings, driver aliases and uclasses, along with the header
  files which define the structs they use;
- matches each node to its driver using its compatible string;
- writes out a C struct for each driver's devicetree data, then the data
  itself for each node.

With ``OF_PLATDATA_INST``, dtoc goes further and writes out the devices and
uclasses themselves, so that U-Boot does not need to bind them at run time.

How U-Boot uses the generated code is described in its documentation, under
:doc:`uboot:develop/driver-model/of-plat`.

Running dtoc
------------

The usual way to run dtoc is::

    dtoc -d <dtb> -p <phase> --source-dir <u-boot> -c <c-dir> -C <h-dir> all

For example, this generates the files for the SPL devicetree of a board
built in ``/tmp/b/firefly-rk3399``::

    dtoc -d /tmp/b/firefly-rk3399/spl/u-boot-spl.dtb -p spl \
        --source-dir ~/u-boot -c out -C out/include all

The final argument is the command, which selects the files to write. It is a
comma-separated list of the following:

``struct``
    ``dt-structs-gen.h``: the structs which hold the devicetree data for each
    driver

``decl``
    ``dt-decl.h``: declarations for all the device and uclass instances

``platdata``
    ``dt-plat.c``: the platform data for each node, along with a
    ``U_BOOT_DRVINFO()`` record to bind it to its driver. This is only
    available without ``-i``

``device``
    ``dt-device.c``: a ``DM_DEVICE_INST()`` record for each device. This is
    only available with ``-i``

``uclass``
    ``dt-uclass.c``: the uclass instances. This is only available with ``-i``

``all``
    all the files available for the mode in use

Options
-------

``-d``, ``--dtb-file``
    The devicetree binary to read.

``-s``, ``--source-dir``
    The U-Boot source tree to scan for drivers. This defaults to the top of the
    U-Boot tree when dtoc is run as ``tools/dtoc/dtoc`` from one, and otherwise
    to the current directory.

``-p``, ``--phase``
    The U-Boot phase which the code is for, such as ``spl`` or ``tpl``. Where
    two drivers have the same name, dtoc uses the one marked for this phase
    with ``DM_PHASE()``.

``-i``, ``--instantiate``
    Instantiate the devices and uclasses, for ``OF_PLATDATA_INST``, rather
    than writing the platform data for U-Boot to bind at run time.

``-c``, ``--c-output-dir``
    The directory for the C files.

``-C``, ``--h-output-dir``
    The directory for the header files. This defaults to the directory for the
    C files.

``-o``, ``--output``
    Write all the output to a single file, rather than one file for each
    command. Without this or the output directories, dtoc writes to standard
    output.

``--include-disabled``
    Include nodes whose status is 'disabled'.

``-t``, ``--test``
    Run the tests. Most of these need a U-Boot source tree, given in the
    ``UBOOT_SRC`` environment variable.

``-T``, ``--test-coverage``
    Run the tests and check that they cover all of the code.

``-P``, ``--processes``
    The number of processes to use when running the tests.

Libraries
---------

The ``dtoc.fdt`` module reads a devicetree into a tree of ``Node`` and
``Prop`` objects, which can be changed and then written back out. The
``dtoc.fdt_util`` module has helpers for reading property values and for
compiling devicetree source, with the C preprocessor and dtc. Binman uses
both of these.

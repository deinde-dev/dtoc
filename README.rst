Devicetree-to-C generator
=========================

.. image:: https://github.com/deinde-dev/dtoc/actions/workflows/test.yml/badge.svg
   :target: https://github.com/deinde-dev/dtoc/actions/workflows/test.yml
   :alt: Test status

.. image:: https://img.shields.io/pypi/v/dtoc.svg
   :target: https://pypi.org/project/dtoc/
   :alt: PyPI version

.. image:: https://readthedocs.org/projects/dtoc/badge/?version=latest
   :target: https://dtoc.readthedocs.io/en/latest/
   :alt: Documentation status

.. image:: https://img.shields.io/pypi/pyversions/dtoc.svg
   :target: https://pypi.org/project/dtoc/
   :alt: Supported Python versions

Dtoc converts a devicetree binary (.dtb) into C code, so that a program can
use the devicetree's data without parsing it at run time. U-Boot uses it to
give SPL and TPL their devicetree data when they are too small to include
libfdt, with the ``OF_PLATDATA`` options. It:

- generates a C struct for each devicetree compatible string, holding the
  node's properties with suitable C types;
- generates the platform data for each node, along with a ``U_BOOT_DRVINFO()``
  record which binds it to its driver;
- scans the U-Boot source tree for drivers, so that each node is matched to
  its driver, including driver aliases and parent drivers;
- can instead instantiate the devices and uclasses at build time, so that
  U-Boot does not need to bind them at run time (``OF_PLATDATA_INST``).

It also provides Python libraries for reading and changing devicetrees
(``dtoc.fdt`` and ``dtoc.fdt_util``), which binman uses too.

Installation
------------

Install the latest release from PyPI::

    pip install dtoc

The ``dtoc`` command is then on your path. It needs the devicetree compiler
(``dtc``) to compile devicetree source files.

Quick start
-----------

Generate the C files for an SPL devicetree, scanning a U-Boot tree for
drivers::

    dtoc -d u-boot-spl.dtb -p spl --source-dir ~/u-boot \
        -c out -C out/include all

U-Boot's build runs dtoc like this for each phase which uses
``OF_PLATDATA``. See the documentation linked below for the files it writes
and the other options.

Documentation
-------------

Full documentation is hosted on Read the Docs:

    https://dtoc.readthedocs.io/

How U-Boot uses the generated code is described in its documentation, under
`Compiled-in Device Tree / Platform Data
<https://docs.u-boot-project.org/en/latest/develop/driver-model/of-plat.html>`_.

Development
-----------

Run the test suite from a checkout::

    pip install -r requirements.txt
    pip install -e .[test]
    dtoc -t

Most tests generate code for U-Boot's sandbox drivers. Set ``UBOOT_SRC`` to a
U-Boot source tree to include them; otherwise they are skipped. ``dtoc -T``
checks that the tests cover all of the code.

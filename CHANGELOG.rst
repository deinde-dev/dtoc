Changelog
=========

All notable changes to this project are documented here. The format is
based on `Keep a Changelog <https://keepachangelog.com/en/1.1.0/>`_ and
the project follows `Semantic Versioning <https://semver.org/>`_.

Unreleased
----------

Added
~~~~~
- Support for U-Boot's ``dev_prop_regmap()`` helper, which reads ``reg``
  like ``dev_prop_addr()`` does.
- Support for U-Boot's ``dev_prop_driver_data()`` helper. The generated
  struct has a ``driver_data`` member holding the ``.data`` from the
  driver's ``of_match`` table for the compatible string the node matched.
  Where this data is in ``dt-plat.c`` or ``dt-device.c``, those include
  the headers named by the driver's ``DM_HEADER()``.

0.4.0 - 2026-11-11
------------------

Added
~~~~~
- A ``prop`` command, part of ``all``, which writes ``dt-prop.h``. This
  has a ``DTPLAT_GET_<driver>()`` macro for each driver which uses U-Boot's
  ``dev_prop_...()`` helpers, which U-Boot's ``DTPLAT()`` uses to find the
  data.

Changed
~~~~~~~
- For a driver which uses the ``dev_prop_...()`` helpers and has just one
  node, the node's data goes in ``dt-prop.h`` instead of ``dt-plat.c`` or
  ``dt-device.c``, so that the compiler can see the values in the driver and
  drop code it does not need. The macro then uses U-Boot's
  ``DTPLAT_SINGLE()`` with the node's index, so that U-Boot can check the
  device. This needs a U-Boot which has these macros and includes
  ``dt-prop.h``.

0.3.0 - 2026-11-10
------------------

Added
~~~~~
- With no ``--source-dir``, an installed dtoc scans the ``srctree`` directory
  which the U-Boot build exports, before falling back to the current directory.
  So a U-Boot whose Makefile does not give the directory, such as mainline, can
  run it in place of its own dtoc.
- A check that dtoc generates the same code as mainline U-Boot's own dtoc,
  run by CI against a pinned mainline release and weekly against mainline's
  ``next`` branch.

Changed
~~~~~~~
- The ``U_BOOT_DRVINFO()`` for a device whose driver uses the
  ``dev_prop_...()`` helpers no longer sets ``plat_size`` to
  ``DRIVER_INFO_DTPLAT``. U-Boot now records the generated data for every
  device bound from a ``driver_info``, so no marker is needed. This needs
  a U-Boot which has dropped the marker.

0.2.0 - 2026-11-10
------------------

Added
~~~~~
- Support for U-Boot's ``dev_prop_...()`` helpers, which let a driver read
  its devicetree properties with the same code whether or not of-platdata
  is in use. dtoc finds the driver named in ``DTPLAT()`` and the
  properties its helpers read, and generates ``struct dtd_drv_<driver>``
  holding just those properties, with a 'has' flag for each optional one.
  The data is const and read in place, rather than copied into the plat
  data. Such a driver is found from any of its compatible strings, so it
  needs no ``DM_DRIVER_ALIAS()`` lines. Output for drivers which do not
  use the helpers is unchanged.

0.1.1 - 2026-11-03
------------------

Fixed
~~~~~
- ``Node.copy_subnodes_from_phandles()`` copies the phandles of the
  subnodes it copies, so that binman templates can contain nodes which are
  referenced by phandle. Previously binman failed with ``Cannot find node
  for phandle``.

0.1.0 - 2026-10-23
------------------

Added
~~~~~
- A ``-s/--source-dir`` option gives the U-Boot source tree to scan for
  drivers. Without it, dtoc uses the top of the tree when run as
  ``tools/dtoc/dtoc`` from a U-Boot tree, as before, and otherwise the
  current directory.

Changed
~~~~~~~
- Dtoc is now developed in its own repository at
  https://github.com/deinde-dev/dtoc, with its history carried over from the
  U-Boot tree.
- The ``dtoc`` package depends on the ``pylibfdt`` and ``u-boot-pylib``
  packages, rather than on U-Boot's build output and tools directory.
- ``dtoc -t`` runs all the tests, including those for the ``fdt`` and
  ``fdt_util`` libraries, which U-Boot runs separately with ``test_fdt``.
  The tests which need a U-Boot source tree take it from ``UBOOT_SRC`` and
  are skipped without it.
- Documentation is now published at https://dtoc.readthedocs.io/.

Earlier releases
----------------

Releases 0.0.7 and earlier were published from the U-Boot tree and predate
this changelog.

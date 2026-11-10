Changelog
=========

All notable changes to this project are documented here. The format is
based on `Keep a Changelog <https://keepachangelog.com/en/1.1.0/>`_ and
the project follows `Semantic Versioning <https://semver.org/>`_.

Unreleased
----------

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

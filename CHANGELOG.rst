Changelog
=========

All notable changes to this project are documented here. The format is
based on `Keep a Changelog <https://keepachangelog.com/en/1.1.0/>`_ and
the project follows `Semantic Versioning <https://semver.org/>`_.

Unreleased
----------

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

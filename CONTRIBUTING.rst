Contributing to Dtoc
====================

Development setup
-----------------

Work in a virtual environment::

    python -m venv .venv
    . .venv/bin/activate
    pip install -r requirements.txt
    pip install -e .[test]

The tests compile devicetree sources, so they also need the devicetree
compiler (``dtc``) and a C preprocessor, e.g. from the ``device-tree-compiler``
and ``build-essential`` packages on Debian and Ubuntu.

Running the tests
-----------------

::

    dtoc -t                     # the whole suite
    dtoc -t <name>              # a single test, e.g. test_simple
    dtoc -T                     # check that the tests cover all the code

Most tests generate code for devicetree nodes which use U-Boot's sandbox
drivers, so they first scan a U-Boot source tree for drivers. To include them,
point ``UBOOT_SRC`` at a U-Boot source tree::

    UBOOT_SRC=/path/to/u-boot dtoc -t

Otherwise they are skipped. The tests check the code generated for particular
drivers, so a tree much newer or older than the one the CI uses may need the
expected output updating. The CI uses the U-Boot commit given by
``UBOOT_REF`` in ``.github/workflows/test.yml``.

The coverage check needs ``UBOOT_SRC`` too, since the skipped tests are the
ones which cover most of the code.

Checking compatibility with mainline U-Boot
-------------------------------------------

Mainline U-Boot has its own copy of dtoc, but this one should stay usable in
its place: for a tree whose drivers do not use features which mainline lacks,
such as the ``dev_prop_...()`` helpers, the generated code must be the same.
To check this, build some boards with each dtoc and compare the output::

    scripts/check-mainline.sh /path/to/mainline/u-boot /tmp/work \
        sandbox_spl sandbox_noinst chromebook_jerry

This uses the dtoc on the ``PATH``, or the one given by ``DTOC``. It needs the
packages to build U-Boot for each board, including ``gcc-arm-linux-gnueabihf``
for chromebook_jerry. It replaces ``tools/dtoc/dtoc`` in the mainline tree
while it runs and puts it back afterwards.

Building the documentation
--------------------------

::

    pip install -r doc/requirements.txt
    make -C doc html        # output in doc/_build/html

The manual itself lives in ``dtoc/dtoc.rst``; ``doc/`` only wraps it for
Sphinx, so edit the manual there.

Building the package
--------------------

::

    python -m build
    twine check --strict dist/*

Dependencies
------------

Dtoc uses the ``u_boot_pylib`` library from the ``u-boot-pylib`` package
(https://github.com/deinde-dev/u-boot-pylib) and the libfdt bindings from the
``pylibfdt`` package. Nothing is vendored from the U-Boot tree.

Continuous integration
----------------------

The *Tests* workflow runs the suite on Python 3.10-3.12, checks test coverage
and builds and checks the package on every push and pull request.

The *Mainline* workflow runs ``scripts/check-mainline.sh`` on every push and
pull request, using the mainline release given by ``MAINLINE_REF`` in
``.github/workflows/mainline.yml``. It also runs weekly against mainline's
``next`` branch, so that a change in mainline which needs a matching change
here shows up early. Update ``MAINLINE_REF`` after each mainline release.

Making a release
----------------

Releases are published to PyPI automatically by the *Release* workflow
when a version tag is pushed. The flow is:

1. Update ``CHANGELOG.rst``: move the ``Unreleased`` entries under a new
   ``X.Y.Z - <date>`` heading.
2. Bump ``version`` in ``pyproject.toml``.
3. Commit the changes.
4. Tag it. The tag must be ``v`` followed by the exact version, for
   example::

       git tag v0.1.0
       git push origin v0.1.0

   A tag containing ``rc`` (for example ``v0.1.0rc1``) publishes to
   TestPyPI; a final tag publishes to the real PyPI. The workflow
   refuses to publish if the tag does not match the project version.

   You can also trigger the *Release* workflow manually (the
   ``workflow_dispatch`` option) to publish the current branch to
   TestPyPI for a dry run, without a tag.

Publishing uses PyPI Trusted Publishing (OIDC), so no API tokens are
stored. The PyPI and TestPyPI projects must each be configured to trust
this repository's ``release.yml`` workflow (environments ``pypi`` and
``testpypi``) before the first release.

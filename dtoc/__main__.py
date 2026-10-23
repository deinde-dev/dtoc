# SPDX-License-Identifier: GPL-2.0+

"""Allow dtoc to be run with 'python3 -m dtoc'"""

import sys

from dtoc.main import run_dtoc

sys.exit(run_dtoc())

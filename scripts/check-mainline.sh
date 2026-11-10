#!/bin/bash
# SPDX-License-Identifier: GPL-2.0+
#
# Check that this dtoc generates the same code as mainline U-Boot's own dtoc
#
# Copyright 2026 Simon Glass <sjg@chromium.org>
#
# Mainline U-Boot runs the dtoc in its tools/dtoc directory. This builds each
# board twice, once with that dtoc and once with the dtoc on the PATH (or the
# one given by $DTOC), then checks that the generated files are the same.
#
# Usage: check-mainline.sh <u-boot-dir> <work-dir> <board>...
#
# The second build replaces tools/dtoc/dtoc in the U-Boot tree with a wrapper,
# which is put back afterwards. The wrapper gives no --source-dir, so dtoc must
# find the source tree from the 'srctree' directory which the build exports.
#
# Avoid boards which use of-platdata in more than one phase, such as mk808.
# Mainline writes each phase's dt-structs-gen.h to the same file, in parallel,
# so the result depends on which phase finishes last.

set -e

if [ $# -lt 3 ]; then
	echo "Usage: $0 <u-boot-dir> <work-dir> <board>..." >&2
	exit 1
fi

src=$(realpath "$1")
work=$(realpath -m "$2")
shift 2

dtoc=$(command -v "${DTOC:-dtoc}") || {
	echo "Cannot find dtoc; install it or set DTOC" >&2
	exit 1
}

link="${src}/tools/dtoc/dtoc"
saved="${work}/dtoc.orig"
mkdir -p "${work}"
cp -P "${link}" "${saved}"
trap 'rm -f "${link}"; cp -P "${saved}" "${link}"' EXIT

# Print the cross-compiler prefix for a configured build directory
cross_compile() {
	local config="$1/.config"

	if grep -q '^CONFIG_SANDBOX=y' "${config}"; then
		echo
	elif grep -q '^CONFIG_ARM64=y' "${config}"; then
		echo aarch64-linux-gnu-
	elif grep -q '^CONFIG_ARM=y' "${config}"; then
		echo arm-linux-gnueabihf-
	else
		echo "Unsupported architecture in ${config}" >&2
		return 1
	fi
}

# Build a board, giving 0 if the build succeeds
build() {
	local board="$1" out="$2" cross

	rm -rf "${out}"
	make -C "${src}" O="${out}" "${board}_defconfig" > "${out}.log" 2>&1
	cross=$(cross_compile "${out}")
	make -C "${src}" O="${out}" CROSS_COMPILE="${cross}" NO_SDL=1 \
		BINMAN_ALLOW_MISSING=1 -j"$(nproc)" >> "${out}.log" 2>&1
}

failed=0
declare -A built
for kind in mainline this; do
	rm -f "${link}"
	if [ "${kind}" = mainline ]; then
		cp -P "${saved}" "${link}"
	else
		printf '#!/bin/sh\nexec "%s" "$@"\n' "${dtoc}" > "${link}"
		chmod +x "${link}"
	fi
	for board in "$@"; do
		if build "${board}" "${work}/${kind}-${board}"; then
			built[${kind}-${board}]=1
			echo "Built ${board} with ${kind} dtoc"
		else
			echo "Failed to build ${board} with ${kind} dtoc," \
				"see ${work}/${kind}-${board}.log"
		fi
	done
done

for board in "$@"; do
	ref="${work}/mainline-${board}"
	new="${work}/this-${board}"
	if [ -n "${built[mainline-${board}]}" ] &&
	   [ -z "${built[this-${board}]}" ]; then
		echo "${board}: builds with mainline's dtoc but not with this one"
		failed=1
	fi
	files=$(cd "${ref}" && ls include/generated/dt-*.h \
		{spl,tpl,vpl}/dts/dt-*.c 2>/dev/null) || true
	if [ -z "${files}" ]; then
		echo "${board}: mainline's dtoc generated nothing"
		failed=1
		continue
	fi
	for fname in ${files}; do
		if cmp -s "${ref}/${fname}" "${new}/${fname}"; then
			echo "${board}: ${fname} is the same"
		else
			echo "${board}: ${fname} differs:"
			diff -u "${ref}/${fname}" "${new}/${fname}" | head -40 || true
			failed=1
		fi
	done
done

exit ${failed}

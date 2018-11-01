# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit flag-o-matic python-single-r1

DESCRIPTION="An efficient SMT solver"
HOMEPAGE="http://fmv.jku.at/boolector/"
SRC_URI="http://fmv.jku.at/boolector/${P}-with-lingeling-bbc.tar.bz2"
RESTRICT="mirror"

LICENSE="FMV-EULA"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc debug log python shared static static-libs"

DEPEND="
	python? ( ${PYTHON_DEPS} )
	|| (
		sci-mathematics/lingeling[shared]
		sci-mathematics/lingeling[static-libs]
	)
	"
RDEPEND="${DEPEND}"

REQUIRED_USE="python? ( shared ${PYTHON_REQUIRED_USE} )"

PATCHES="${FILESDIR}/${PN}-2.4-configure.sh.patch"

HEADERS="
	boolector.h
	btortypes.h
	btoropt.h
	utils/btormem.h
	utils/btorhashptr.h
	utils/btorhash.h
	"

src_unpack() {
	# unpack distributed archive (contains boolector + lingeling)
	unpack ${A}
	cd "${P}-with-lingeling-bbc"

	# unpack boolector source archive
	tar xf archives/${P}*.tar.gz
	cd ${PN}*

	# boolector build directory
	S=$(pwd)
}

src_configure() {
	# configure script arguments
	local CONF_OPTS=""

	# enable debugging support
	use debug && CONF_OPTS="${CONF_OPTS} -g"

	# enable logging
	use log && CONF_OPTS="${CONF_OPTS} -l"

	# build shared library
	use shared && CONF_OPTS="${CONF_OPTS} -shared"

	# build static executables
	use static && CONF_OPTS="${CONF_OPTS} -static"

	# build python API
	use python && CONF_OPTS="${CONF_OPTS} -python"

	# configure boolector
	export -f _is_flagq
	export -f all-flag-vars
	export -f append-cflags
	export -f is-flagq
	export -f replace-flags
	./configure.sh ${CONF_OPTS} || die
}

src_install() {
	# install boolector binaries
	dobin bin/*

	# install header files
	if use shared || use static-libs
	then
		INCLUDE="${S}/${PN}"
		mkdir -p "${INCLUDE}"
		for h in ${HEADERS}
		do
			[ ! -d "${INCLUDE}/$(dirname $h)" ] && mkdir -p "${INCLUDE}/$(dirname $h)"
			sed \
				-e "s,#include \"\(.\+\)\",#include <${PN}/\1>,g" \
				"${S}/src/${h}" > "${INCLUDE}/${h}"
		done
		doheader -r "${INCLUDE}"
	fi

	# install shared library
	use shared && dolib.so build/libboolector.so

	# install static library
	use static-libs && dolib.a build/libboolector.a

	# install python library
	use python && python_domodule build/boolector.cpython*.so

	# install documentation
	if use doc
	then
		HTML_DOCS="doc/*"
		einstalldocs
	fi
}

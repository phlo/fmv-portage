# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit git-r3 python-single-r1

DESCRIPTION="An efficient SMT solver"
HOMEPAGE="http://fmv.jku.at/boolector https://github.com/Boolector/boolector"

EGIT_REPO_URI="https://github.com/Boolector/boolector.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc debug log python shared static static-libs"

RDEPEND="
	|| (
		sci-mathematics/lingeling[shared]
		sci-mathematics/lingeling[static-libs]
	)
	|| (
		sci-mathematics/btor2tools[shared]
		sci-mathematics/btor2tools[static-libs]
	)
	python? ( ${PYTHON_DEPS} )
	"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-2.8
	doc? ( >=dev-python/sphinx-1.2 )
	"

REQUIRED_USE="python? ( shared ${PYTHON_REQUIRED_USE} )"

HEADERS="
	boolector.h
	btortypes.h
	"

BUILD_DIR="build"

src_configure() {
	# configure script arguments
	local CONF_OPTS="-DCMAKE_SKIP_RPATH=TRUE"

	# enable debugging support
	use debug && CONF_OPTS="${CONF_OPTS} -DCMAKE_BUILD_TYPE=Debug"

	# enable logging
	use log && CONF_OPTS="${CONF_OPTS} -DLOG=ON"

	# build shared library
	use shared && CONF_OPTS="${CONF_OPTS} -DSHARED=ON"

	# build python API
	use python && CONF_OPTS="${CONF_OPTS} -DPYTHON=ON"

	# create build dir
	mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}

	# configure boolector
	cmake .. ${CONF_OPTS} || die
}

src_compile() {
	# compile
	make -C build || die

	# build api doc with sphinx
	use doc && cd doc && make html
}

src_install() {
	# install boolector binaries
	dobin build/bin/boolector
	dobin build/bin/btormc

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
	use shared && dolib.so build/lib/libboolector.so

	# install static library
	use static-libs && dolib.a build/lib/libboolector.a

	# install python library
	use python && python_domodule build/lib/pyboolector*.so

	# install documentation
	if use doc
	then
		HTML_DOCS="doc/_build/html/*"
		einstalldocs
	fi
}

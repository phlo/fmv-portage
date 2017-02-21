# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python3_4 )

inherit python-single-r1

DESCRIPTION="An efficient SMT solver"
HOMEPAGE="http://fmv.jku.at/boolector/"
SRC_URI="http://fmv.jku.at/boolector/boolector-2.4.0-with-lingeling-bbc.tar.bz2"
RESTRICT="mirror"

LICENSE="boolector-2.4.0.license"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

DEPEND="python? ( ${PYTHON_DEPS} )"
RDEPEND="${DEPEND}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_unpack() {
	# unpack distributed archive (contains boolector + lingeling)
	unpack ${A}
	S=${WORKDIR}/$(ls ${WORKDIR})/archives
	cd ${S}

	# unpack boolector and lingeling source archives
	unpack ./*

	# lingeling build directory
	S_LINGELING=${S}/lingeling
	ln -s $(ls -d lingeling*/) ${S_LINGELING}

	# boolector build directory
	S=${S}/$(ls -d ${P}*/)
}

src_prepare() {
	eapply_user

	# remove -rpath linker argument
	sed -i '/RPATHS/d' configure.sh
	sed -i 's/\(^\s\+extra_compile_args=.\+\),$/\1/g' configure.sh
	sed -i '/extra_link_args/d' configure.sh
}

src_compile() {
	# configure script arguments
	local CONF_OPTS=""

	# build lingeling
	cd ${S_LINGELING}
	use python && CONF_OPTS=-fPIC
	./configure.sh ${CONF_OPTS}
	emake

	# build boolector
	cd ${S}
	# missing -DNDEBUG breaks compilation (BTOR_OPT_LOGLEVEL undeclared)
	local CFLAGS=""
	use python && CONF_OPTS=-python
	./configure.sh ${CONF_OPTS}
	emake
}

src_install() {
	# install boolector binaries
	dobin bin/*

	# install library
	if use python; then
		dolib.so build/libboolector.so
		python_domodule build/boolector.cpython*.so
	fi

	# install documentation
	if use doc; then
		HTML_DOCS="doc/*"
		einstalldocs
	fi
}

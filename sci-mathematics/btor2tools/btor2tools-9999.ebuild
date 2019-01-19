# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic git-r3

DESCRIPTION="A generic parser and tools for the BTOR2 format"
HOMEPAGE="https://github.com/Boolector/btor2tools"
EGIT_REPO_URI="https://github.com/Boolector/btor2tools.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc debug shared static static-libs"

DEPEND=""
RDEPEND="${DEPEND}"

PATCHES="${FILESDIR}/${P}-configure.sh.patch"

src_configure() {
	# configure script arguments
	local CONF_OPTS=""

	# enable debugging support
	use debug && CONF_OPTS="${CONF_OPTS} -g"

	# build shared library
	use shared && CONF_OPTS="${CONF_OPTS} -shared"

	# build static executables
	use static && CONF_OPTS="${CONF_OPTS} -static"

	# configure btor2tools
	export -f _is_flagq
	export -f all-flag-vars
	export -f append-cflags
	export -f is-flagq
	export -f replace-flags
	./configure.sh ${CONF_OPTS} || die
}

src_install() {
	# install btorsim and catbtor binaries
	dobin bin/*

	# install header files
	if use shared || use static-libs
	then
		rm "src/btor2parser/btor2parser.c"
		doheader -r "src/btor2parser"
	fi

	# install shared library
	use shared && dolib.so build/libbtor2parser.so

	# install static library
	use static-libs && dolib.a build/libbtor2parser.a

	# install documentation
	if use doc
	then
		DOCS="README.md"
		einstalldocs
	fi
}

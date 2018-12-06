# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="An efficient SAT solver"
HOMEPAGE="http://fmv.jku.at/lingeling https://github.com/arminbiere/lingeling"

EGIT_REPO_URI="https://github.com/arminbiere/lingeling.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc shared static static-libs"

PATCHES="
	"${FILESDIR}"/lingeling-bbc-configure.sh.patch
	"${FILESDIR}"/lingeling-bbc-makefile.in.patch
	"

src_configure() {
	# configure script arguments
	local CONF_OPTS=""

	# enable debugging support
	use debug && CONF_OPTS="${CONF_OPTS} -g"

	# build shared library
	use shared && CONF_OPTS="${CONF_OPTS} --shared"

	# build static executables
	use static && CONF_OPTS="${CONF_OPTS} --static"

	# configure lingeling
	./configure.sh ${CONF_OPTS} || die
}

src_install() {
	# install executables
	dobin lingeling
	dobin plingeling
	dobin treengeling
	dobin ilingeling
	dobin lglmbt
	dobin lgluntrace
	dobin lglddtrace

	# install header file
	use shared || use static-libs && doheader lglib.h

	# install shared library
	use shared && dolib.so liblgl.so

	# install static library
	use static-libs && dolib.a liblgl.a

	# install documentation
	use doc && dodoc NEWS README
}

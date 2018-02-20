# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic

DESCRIPTION="A format, library and set of utilities for And-Inverter Graphs (AIGs)."
HOMEPAGE="http://fmv.jku.at/aiger/"
SRC_URI="http://fmv.jku.at/${PN}/${PF}.tar.gz"
RESTRICT="mirror"

LICENSE="AIGER-EULA"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="bmc debug doc"

DEPEND="
	bmc? (
		|| (
			sci-mathematics/lingeling[shared]
			sci-mathematics/lingeling[static-libs]
		)
	)
	"
RDEPEND="${DEPEND}"

PATCHES="
	"${FILESDIR}"/aiger-1.9.9-aigbmc.c.patch
	"${FILESDIR}"/aiger-1.9.9-aigdep.c.patch
	"${FILESDIR}"/aiger-1.9.9-aigunconstraint.c.patch
	"${FILESDIR}"/aiger-1.9.9-configure.sh.patch
	"${FILESDIR}"/aiger-1.9.9-makefile.in.patch
	"

src_unpack() {
	# unpack distributed archive
	unpack ${A}

	# update path to temporary build directory
	S="${WORKDIR}/${PF}"
}

src_configure() {
	# configure script arguments
	local CONF_OPTS=""

	# enable lingeling
	use bmc && export LINGELING=yes

	# enable debugging support
	use debug && CONF_OPTS="${CONF_OPTS} -g"

	# configure lingeling
	export -f all-flag-vars
	export -f append-cflags
	export -f replace-flags
	./configure.sh ${CONF_OPTS} || die
}

src_install() {
	# install executables
	dobin aigand
	use bmc && dobin aigbmc
	dobin aigdd
	use bmc && dobin aigdep
	dobin aigflip
	dobin aigfuzz
	dobin aiginfo
	dobin aigjoin
	dobin aigmiter
	dobin aigmove
	dobin aignm
	dobin aigor
	dobin aigreset
	dobin aigsim
	dobin aigsplit
	dobin aigstrip
	dobin aigtoaig
	dobin aigtoblif
	dobin aigtocnf
	dobin aigtodot
	dobin aigtosmv
	dobin aigunconstraint
	dobin aigunroll
	dobin aigvis
	dobin andtoaig
	dobin bliftoaig
	dobin smvtoaig
	dobin soltostim
	dobin wrapstim

	# install header file
	cp aiger.h libaiger.h
	doheader libaiger.h
	cp simpaig.h libsimpaig.h
	doheader libsimpaig.h

	# install shared library
	dolib.so libaiger.so
	dolib.so libsimpaig.so

	# install documentation
	use doc && dodoc -r examples FORMAT mc.sh NEWS README
}

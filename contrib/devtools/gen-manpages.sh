#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

GIRINOCOIND=${GIRINOCOIND:-$SRCDIR/girinocoind}
GIRINOCOINCLI=${GIRINOCOINCLI:-$SRCDIR/girinocoin-cli}
GIRINOCOINTX=${GIRINOCOINTX:-$SRCDIR/girinocoin-tx}
GIRINOCOINQT=${GIRINOCOINQT:-$SRCDIR/qt/girinocoin-qt}

[ ! -x $GIRINOCOIND ] && echo "$GIRINOCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
GIRVER=($($GIRINOCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$GIRINOCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $GIRINOCOIND $GIRINOCOINCLI $GIRINOCOINTX $GIRINOCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${GIRVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${GIRVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m

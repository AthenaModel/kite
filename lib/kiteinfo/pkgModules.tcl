#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    athena-kite: kiteinfo(n) package modules file
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

package provide kiteinfo 1.0

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kiteinfo:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Modules

source [file join $::kiteinfo::library kiteinfo.tcl]


#-----------------------------------------------------------------------
# TITLE:
#    ktools.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Kite: utility code used by kite.kit.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

package provide ktools 1.0

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::ktools:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::ktools::library project.tcl]

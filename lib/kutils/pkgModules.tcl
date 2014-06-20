#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
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

package provide kutils 1.0

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kutils:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::kutils::library misc.tcl    ]
source [file join $::kutils::library project.tcl ]

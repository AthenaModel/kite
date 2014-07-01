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

package provide ktools 1.0

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::ktools:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Dependencies

package require kutils


#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::ktools::library buildtool.tcl  ]
source [file join $::ktools::library depstool.tcl   ]
source [file join $::ktools::library helptool.tcl   ]
source [file join $::ktools::library infotool.tcl   ]
source [file join $::ktools::library installtool.tcl]
source [file join $::ktools::library newtool.tcl    ]
source [file join $::ktools::library runtool.tcl    ]
source [file join $::ktools::library shelltool.tcl  ]
source [file join $::ktools::library teapottool.tcl ]
source [file join $::ktools::library testtool.tcl   ]
source [file join $::ktools::library versiontool.tcl]

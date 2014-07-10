#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): Package loader.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

# -kite-start-provide  DO NOT EDIT THIS BLOCK BY HAND
package provide kiteutils 0.0a1
# -kite-end-provide

#-----------------------------------------------------------------------
# Required Packages

# -kite-start-require DO NOT EDIT THIS BLOCK BY HAND
package require snit 2.3
package require textutil::expander 1.3.1
# -kite-end-require

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kiteutils:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::kiteutils::library control.tcl    ]
source [file join $::kiteutils::library filex.tcl      ]
source [file join $::kiteutils::library listx.tcl      ]
source [file join $::kiteutils::library stringx.tcl    ]
source [file join $::kiteutils::library template.tcl   ]
source [file join $::kiteutils::library tclchecker.tcl ]
source [file join $::kiteutils::library smartinterp.tcl]

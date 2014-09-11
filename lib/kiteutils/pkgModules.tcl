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

# -kite-provide-start  DO NOT EDIT THIS BLOCK BY HAND
package provide kiteutils 0.2.1a0
# -kite-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -kite-require-start ADD EXTERNAL DEPENDENCIES
package require snit 2.3
package require textutil::expander 1.3.1
# -kite-require-end

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
source [file join $::kiteutils::library dictx.tcl      ]
source [file join $::kiteutils::library filex.tcl      ]
source [file join $::kiteutils::library listx.tcl      ]
source [file join $::kiteutils::library os.tcl         ]
source [file join $::kiteutils::library pluck.tcl      ]
source [file join $::kiteutils::library stringx.tcl    ]
source [file join $::kiteutils::library table.tcl      ]
source [file join $::kiteutils::library template.tcl   ]
source [file join $::kiteutils::library tclchecker.tcl ]
source [file join $::kiteutils::library smartinterp.tcl]
source [file join $::kiteutils::library valtools.tcl   ]

source [file join $::kiteutils::library project.tcl    ]





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

# -kite-start-provide  DO NOT EDIT THIS BLOCK BY HAND
package provide kiteapp 0.0a1
# -kite-end-provide

#-----------------------------------------------------------------------
# Required Packages

package require snit 2.3
package require kiteutils
package require kitedocs

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kiteapp:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::kiteapp::library misc.tcl       ]
source [file join $::kiteapp::library project.tcl    ]
source [file join $::kiteapp::library trees.tcl      ]
source [file join $::kiteapp::library includer.tcl   ]
source [file join $::kiteapp::library teacup.tcl     ]
source [file join $::kiteapp::library teapot.tcl     ]
source [file join $::kiteapp::library docs.tcl       ]
source [file join $::kiteapp::library buildtool.tcl  ]
source [file join $::kiteapp::library depstool.tcl   ]
source [file join $::kiteapp::library docstool.tcl   ]
source [file join $::kiteapp::library helptool.tcl   ]
source [file join $::kiteapp::library infotool.tcl   ]
source [file join $::kiteapp::library installtool.tcl]
source [file join $::kiteapp::library newtool.tcl    ]
source [file join $::kiteapp::library runtool.tcl    ]
source [file join $::kiteapp::library shelltool.tcl  ]
source [file join $::kiteapp::library teapottool.tcl ]
source [file join $::kiteapp::library testtool.tcl   ]
source [file join $::kiteapp::library versiontool.tcl]

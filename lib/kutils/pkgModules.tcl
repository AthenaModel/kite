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
package provide kutils 0.0a1
# -kite-end-provide

#-----------------------------------------------------------------------
# Required Packages

# -kite-start-require  DO NOT EDIT THIS BLOCK BY HAND
package require snit 2.3
# -kite-end-require


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
source [file join $::kutils::library trees.tcl   ]
source [file join $::kutils::library includer.tcl]
source [file join $::kutils::library teacup.tcl  ]
source [file join $::kutils::library teapot.tcl  ]
source [file join $::kutils::library docs.tcl    ]

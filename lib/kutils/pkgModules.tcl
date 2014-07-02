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
# Dependencies

# TODO: Figure out whether this belongs here or not.  We'd like to handle
# all dependencies at the toplevel; but not all libraries need the same
# ones.

package require snit


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

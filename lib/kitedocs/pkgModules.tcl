#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kitedocs(n): Package loader.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

# -kite-provide-start  DO NOT EDIT THIS BLOCK BY HAND
package provide kitedocs 0.0a2
# -kite-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -kite-require-start DO NOT EDIT THIS BLOCK BY HAND

# -kite-require-end

package require kiteutils

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kitedocs:: {
    variable library [file dirname [info script]]
    namespace import ::kiteutils::*
}

#-----------------------------------------------------------------------
# Submodules
#
# Note: modules are listed in order of dependencies; be careful if you
# change the order!

source [file join $::kitedocs::library ehtml.tcl  ]
source [file join $::kitedocs::library manpage.tcl]
source [file join $::kitedocs::library kitedoc.tcl]







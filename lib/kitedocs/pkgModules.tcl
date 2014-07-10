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

# -kite-start-provide  DO NOT EDIT THIS BLOCK BY HAND
package provide kitedocs 0.0a1
# -kite-end-provide

#-----------------------------------------------------------------------
# Required Packages

# -kite-start-require DO NOT EDIT THIS BLOCK BY HAND
package require snit 2.3
package require textutil::expander 1.3.1
# -kite-end-require

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



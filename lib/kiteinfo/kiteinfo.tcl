#-----------------------------------------------------------------------
# TITLE:
#   kiteinfo.tcl
#
# PROJECT:
#   athena-kite - Athena/Kite Development Tool
#
# DESCRIPTION:
#   Kite: kiteinfo(n) Package
#
#   This package was auto-generated by Kite to provide the 
#   project athena-kite's code with access to the contents of its 
#   project.kite file at runtime.
#
#   Generated by Kite.
#-----------------------------------------------------------------------

namespace eval ::kiteinfo:: {
    variable kiteInfo

    array set kiteInfo {
        require-textutil::expander {version 1.3.1 local 0}
        require-snit {version 2.3 local 0}
        description {Athena/Kite Development Tool}
        provides {kiteutils kitedocs}
        gui-kite 0
        includes {}
        pkgversion 0.1
        requires {snit textutil::expander}
        shell {
    package require kiteutils
    package require kitedocs
    namespace import kiteutils::*
}
        name athena-kite
        poc William.H.Duquette@jpl.nasa.gov
        srcs {}
        apps kite
        apptype-kite kit
        version 0.1
    }

    namespace export \
        project      \
        version      \
        description  \
        includes     \
        gui          \
        require

    namespace ensemble create
}

#-----------------------------------------------------------------------
# Commands

# project
#
# Returns the project name.
# FIXME: should be kiteinfo(project) when project.tcl is updated.

proc ::kiteinfo::project {} {
    variable kiteInfo

    return $kiteInfo(name)
}

# version
#
# Returns the project version number.

proc ::kiteinfo::version {} {
    variable kiteInfo

    return $kiteInfo(version)
}

# description
#
# Returns the project description.

proc ::kiteinfo::description {} {
    variable kiteInfo

    return $kiteInfo(description)
}

# includes
#
# Returns the names of the "include" libraries.

proc ::kiteinfo::includes {} {
    variable kiteInfo

    return $kiteInfo(includes)
}

# gui app
#
# app  - An application name
#
# Returns 1 if the app is supposed to have a GUI, and 0 otherwise.

proc ::kiteinfo::gui {app} {
    variable kiteInfo

    return $kiteInfo(gui-$app)
}

# require name
#
# name  - Name of a "require"'d teapot package.
#
# Does a Tcl [package require] on the given package, using the
# version specified by the "require" statement in project.kite.
#
# DEPRECATED

proc ::kiteinfo::require {name} {
    variable kiteInfo
    
    if {$name ni $kiteInfo(requires)} {
        error "unknown package name: \"$name\""
    }
    set version [dict get $kiteInfo(require-$name) version]
}

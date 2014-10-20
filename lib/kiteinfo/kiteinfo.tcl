#-----------------------------------------------------------------------
# TITLE:
#   kiteinfo.tcl
#
# PROJECT:
#   kite - Kite Project Automation Tool
#
# DESCRIPTION:
#   Kite: kiteinfo(n) Package
#
#   This package was auto-generated by Kite to provide the 
#   project kite's code with access to the contents of its 
#   project.kite file at runtime.
#
#   Generated by Kite.
#-----------------------------------------------------------------------

namespace eval ::kiteinfo:: {
    variable kiteInfo

    array set kiteInfo {
        binary-kitedocs 0
        local-tls 0
        icon-kite {}
        description {Kite Project Automation Tool}
        provides {kiteutils kitedocs}
        local-crc32 0
        reqver-zipfile::encode 0.3
        reqver-platform 1.0
        gui-kite 0
        reqver-textutil::expander 1.3.1
        reqver-snit 2.3
        binary-kiteutils 0
        requires {platform snit textutil::expander zipfile::encode tls crc32}
        shell {
    package require kiteutils
    package require kitedocs
    namespace import kiteutils::*
}
        name kite
        poc William.H.Duquette@jpl.nasa.gov
        srcs {}
        xfiles {}
        distpat-install-%platform {
    README.md
    INSTALL.md
    LICENSE
    %apps
    %libs
    docs/INSTALL.md
    docs/*.html
    docs/*/*.html
}
        apps kite
        reqver-tls 1.6
        local-zipfile::encode 0
        local-platform 0
        apptype-kite exe
        local-textutil::expander 0
        local-snit 0
        version 0.4.3
        reqver-crc32 1.3
        dists install-%platform
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

#-----------------------------------------------------------------------
# TITLE:
#   installtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "install" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(install) {
    arglist     {}
    package     kiteapp
    ensemble    ::kiteapp::installtool
    description "Build and install applications to ~/bin."
    intree      yes
}

set ::khelp(install) {
    The "install" tool installs build products into the local file
    system for general use.

    Applications:

    Apps and appkits are installed into ~/bin.  For example, 
    appkit myapp.kit is installed as ~/bin/myapp.  Appkits run against 
    the installed development tclsh.  

    Libraries:

    Libs are installed into the local teapot, and are then accessible
    to other applications on the same host.
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type ::kiteapp::installtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Builds the build targets, and installs the apps to ~/bin for use.
    #
    # TODO: When we really have multiple kinds of build target, support
    # installing just one kind or one target.

    typemethod execute {argv} {
        checkargs install 0 0 {} $argv

        # FIRST, install any teapot packages.
        if {[llength [project lib names]] > 0} {
            InstallLibs
        }

        # NEXT, install any applications.
        # TODO: Support multiple apps.
        if {[project app name] ne ""} {
            InstallApp
        }
    }

    #-------------------------------------------------------------------
    # Installing Teapot Libraries
    
    # InstallLibs
    #
    # Installs exported libraries into the local teaput.

    proc InstallLibs {} {
        # FIRST, make sure there's a local teapot to install them 
        # into.
        if {[teapot state] ne "ok"} {
            puts [outdent {
                WARNING: Kite cannot install project libraries,
                because the local teapot has not been set up.
                Please execute 'kite teapot' for more information.
            }]
            puts ""

            return
        }

        # NEXT, for each library, see if it has a package; and if so,
        # install it.
        foreach lib [project lib names] {
            InstallLib $lib
        }
    }

    # InstallLib lib
    #
    # lib  - A lib name
    #
    # Verifies that lib has a teapot package, and installs it if so.

    proc InstallLib {lib} {
        set ver [project version]
        set basename "package-$lib-$ver-tcl.zip"
        set fullname [project root .kite libzips $basename]

        # FIRST, is there a package?
        if {![file isfile $fullname]} {
            puts [outdent "
                WARNING: Kite cannot install lib \"$lib\", because
                it has not been built yet.  Try 'kite build'.
            "]

            return
        }

        # NEXT, add it.
        try {
            puts "Installing lib \"$lib $ver\" into the local teapot."
            if {[teacup has $lib $ver]} {
                teacup remove $lib $ver
            }

            teacup installfile $fullname
        } on error {result} {
            throw FATAL "Error installing lib \"$lib\": $result"
        }
    }


    #-------------------------------------------------------------------
    # Installing Applications
    
    # InstallApp
    #
    # Installs the application to ~/bin.

    proc InstallApp {} {
        try {
            # FIRST, make sure that ~/bin exists.
            file mkdir [file join ~ bin]

            # Copy app
            set app [project app name]
            if {[project app get exe] eq "kit"} {
                set kitname $app.kit
                set source [project root bin $kitname]
                set target [file join ~ bin $app]
            } elseif {[project app get exe] eq "pack"} {
                if {$::tcl_platform(platform) eq "windows"} {
                    set exename "$app.exe"
                } else {
                    set exename $app
                }

                set source [project root bin $exename]
                set target [file join ~ bin $exename]
            }

            if {![file exists $source]} {
                puts [outdent "
                    WARNING: Application \"$app\" has not yet been built.
                "]
                return
            }

            puts "Installing $app to '$target'"
            file copy -force -- $source $target
        } on error {result} {
            throw FATAL $result
        }
    }    
}






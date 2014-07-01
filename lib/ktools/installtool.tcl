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
    package     ktools
    ensemble    ::ktools::installtool
    description "Build and install applications to ~/bin."
    intree      yes
}

set ::khelp(install) {
    The "install" tool installs build products into the local file
    system for general use.

    Apps:

    Apps and appkits are installed into ~/bin.  For example, 
    appkit myapp.kit is installed as ~/bin/myapp.  Appkits run against 
    the installed development tclsh.  
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type ::ktools::installtool {
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

        try {
            # FIRST, make sure that ~/bin exists.
            file mkdir [file join ~ bin]

            # Copy app
            set app [project app name]
            if {$app ne ""} {
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
            }

            if {![file exists $source]} {
                puts "Warning: app $app has not been built;"
                puts "not installed."
                continue
            }

            puts "Installing $app to '$target'"
            file copy -force -- $source $target
        } on error {result} {
            throw FATAL $result
        }

        puts ""
    }    
}




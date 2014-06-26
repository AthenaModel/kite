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

    Appkits

    Appkits are installed into ~/bin.  For example, appkit myapp.kit
    is installed as ~/bin/myapp.  Appkits run against the installed
    development tclsh.  
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
    # TODO: Allow installing just one target.

    typemethod execute {argv} {
        checkargs install 0 0 {} $argv

        try {
            # FIRST, make sure that ~/bin exists.
            file mkdir [file join ~ bin]

            # Copy appkit
            set kitname [project appkit].kit
            set source [project root bin $kitname]

            if {![file exists $source]} {
                puts "Warning: $kitname does not exist; not installed."
                continue
            }

            set target [file join ~ bin [project appkit]]
            puts "Installing $kitname to '$target'"
            file copy -force -- $source $target
        } on error {result} {
            throw FATAL $result
        }

        puts ""
    }    
}




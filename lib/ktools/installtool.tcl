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
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type ::ktools::installtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type variables

    # TBD

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

            # Copy appkits
            foreach name [project appkits] {
                set source [project root bin $name.kit]

                if {![file exists $source]} {
                    puts "Warning: $name.kit does not exist; not installed."
                    continue
                }

                set target [file join ~ bin $name.kit]
                puts "Installing $name.kit to '$target'"
                file copy -force -- $source $target
            }
        } on error {result} {
            throw FATAL $result
        }

        puts ""
    }    
}




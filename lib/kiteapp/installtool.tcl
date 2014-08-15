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
    ensemble    installtool
    description "Build and install applications to ~/bin."
    usage       "?app|lib? ?<name>...?"
    intree      yes
}

set ::khelp(install) {
    The "install" tool installs build products into the local file
    system for general use.

    Applications are installed into ~/bin, e.g., myapp.kit is installed 
    as ~/bin/myapp.  Libraries are installed in the default teapot, and  
    are then accessible to other applications on the same host.

    By default, "install" installs all libraries and applications.  
    To install libraries only:

      $ kite install lib

    To install specific libraries:

      $ kite install lib mylib1 mylib2 ...

    To install applications only:

      $ kite install app

    To install specific applications:

      $ kite install app myapp1 myapp2
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type installtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Installs the desired build targets.

    typemethod execute {argv} {
        checkargs install 0 - $argv

        # FIRST, get the arguments.
        set kind [lshift argv]

        if {$kind ni {"" lib app}} {
            throw FATAL "Invalid install type: \"$kind\"."
        }

        # NEXT, install any teapot packages.
        if {$kind in {lib ""}} {
            if {[llength $argv] > 0} {
                InstallProvidedLibraries $argv
            } else {
                InstallProvidedLibraries [project provide names]                
            }
        }

        # NEXT, install any applications.
        if {$kind in {app ""}} {
            if {[llength $argv] > 0} {
                set names $argv
            } else {
                set names [project app names]
            }

            foreach app $names {
                if {$app ni [project app names]} {
                    puts "WARNING, Unknown application: \"$app\""
                    continue
                }
                InstallApp $app
            }
        }
    }

    #-------------------------------------------------------------------
    # Installing Teapot Libraries
    
    # InstallProvidedLibraries names
    #
    # names  - Names of the libraries to install.
    #
    # Installs exported libraries into the local teaput.

    proc InstallProvidedLibraries {names} {
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
        foreach lib $names {
            if {$lib ni [project provide names]} {
                puts "WARNING, Unknown library: \"$lib\""
                continue
            }
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
    
    # InstallApp app
    #
    # app  - The named application
    #
    # Installs the application to ~/bin.

    proc InstallApp {app} {
        try {
            # FIRST, make sure that ~/bin exists.
            file mkdir [file join ~ bin]

            # Copy app
            # TODO: use [project app exefile $app]

            if {[project app apptype $app] eq "kit"} {
                set kitname $app.kit
                set source [project root bin $kitname]
                set target [file join ~ bin $app]
            } elseif {[project app apptype $app] eq "exe"} {
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







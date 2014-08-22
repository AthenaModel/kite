#-----------------------------------------------------------------------
# TITLE:
#   tool_info.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "info" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::INFO

tool define info {
    usage       {0 1 "?<option>?"}
    description "Display information about Kite and this project."
    needstree      yes
} {
    The 'kite info' tool displays information about the current project
    in human readable format.  Most of the information is from the 
    project.kite file.  In addition, the tool can return individual
    pieces of data given an option; this is useful in Makefiles and
    other scripts.

    The available options are as follows:

    -os        - The OS on which Kite is running: "linux", "osx", or 
                 "windows".
    -root      - The project root directory (i.e., the directory containing
                 the project.kite file).
    -tclhome   - The root of the TCL installation tree.
    -version   - The project version number.
} {
    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.

    typemethod execute {argv} {
        set opt [lindex $argv 0]

        # FIRST, handle the default case.
        # TODO: Move dumpinfo here.
        if {$opt eq ""} {
            DisplayInfo

            puts ""
            return            
        }

        # NEXT, handle the option.
        switch -exact -- $opt {
            -os      { set result [plat id]                        }
            -root    { set result [project root]                   }
            -tclhome { set result [plat pathof tclhome]            }
            -version { set result [project version]                }
            default  { throw FATAL "Unknown info option: \"$opt\"" }
        }

        puts $result
    }

    # DisplayInfo
    #
    # Display the project information.

    proc DisplayInfo {} {
        set title "[project name] [project version] -- [project description]"
        puts ""
        puts $title
        puts [string repeat - [string length $title]]

        if {[got [project app names]]} {
            puts ""
            puts "Applications:"

            set table [list]

            foreach app [project app names] {
                if {[project app gui $app]} {
                    set tag "GUI"
                } else {
                    set tag "Console"
                }
                append tag ",[project app apptype $app]"
                lappend table [list app $app tag ($tag)]
            }

            table puts $table -indent "    "
        }

        if {[got [project provide names]]} {
            puts ""
            puts "Provided Libraries:"

            set table [list]

            foreach name [project provide names] {
                if {[project provide binary $name]} {
                    set tag "(Binary)"
                } else {
                    set tag "(Pure TCL)"
                }

                lappend table [list lib ${name}(n) tag $tag]
            }

            table puts $table -indent "    "
        }


        if {[got [project src names]]} {
            puts ""
            puts "Compiled Directories:"
            foreach name [project src names] {
                puts "    src/$name"
            }
        }

        if {[got [project require names]]} {
            puts ""
            puts "Required Packages:"
            set table [list]

            foreach name [project require names] {
                set ver [project require version $name]

                if {[project require islocal $name]} {
                    set tag "(Locally built)"
                } else {
                    set tag "(External)"
                }

                lappend table [list name "$name $ver" tag $tag]
            }

            table puts $table -indent "    "
        }
    }
}







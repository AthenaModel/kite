#-----------------------------------------------------------------------
# TITLE:
#   tool_xfiles.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "xfiles" tool.  This tool reports on the state of the project
#   dependencies, and can update them.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::XFILES

tool define xfiles {
    usage       {0 2 "?update|clean? ?<name>?"}
    description "Manage external files"
    needstree      yes
} {
    The 'kite xfiles' tool manages the project's external files,
    e.g., large MS Office files that ought not go in the project's VCS.
    External files are declared in the project file using the 
    'xfile' statement.

    kite xfiles
        Get the status of all external files.  Note that Kite cannot
        tell whether the file has been updated on the server.

    kite xfiles update
        Retrieve all external files that are not already in the tree.

    kite xfiles update <path>
        Forces a fresh retrieval of the named file.  The <path>
        must be the same as that in the project file.

    kite xfiles update all
        Forces a fresh retrieval of all external files.

    kite xfiles clean
        Removes all external files from the project tree.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, if there are no arguments then just dump the dependency
        # status.
        set subc [lshift argv]

        if {$subc eq ""} {
            DisplayStatus
        } elseif {$subc eq "clean"} {
            $type clean
        } elseif {$subc eq "update"} {
            UpdateXfiles [lshift argv]
        } else {
            throw FATAL "Unknown subcommand: \"$subc\""
        }

        puts ""
    }

    # clean
    #
    # Removes all external files.

    typemethod clean {} {
        set count 0

        foreach path [project xfile paths] {
            set fname [project root $path]
            if {[file isfile $fname]} {
                puts "Removing $path..."
                file delete $fname
                incr count
            }
        }

        if {$count == 0} {
            puts "There were no external files to remove."
        }
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, is this even relevant?
        if {[llength [project xfile paths]] == 0} {
            puts "This project declares no external files.\n"
            return
        }

        # NEXT, build the table.
        set table [list]

        foreach path [project xfile paths] {
            set row [dict create]
            dict set row "Local Path" $path

            if {[file isfile [project root $path]]} {
                dict set row State "Present"
            } else {
                dict set row State "Missing"
            }

            lappend table $row
        }

        puts "External File Status:\n"

        dictab puts $table -indent "   " -headers

        puts ""
        puts [outdent {
            Note: Kite cannot tell whether or not the external files that 
            are present are up-to-date.
        }]
    }

    # UpdateXfiles which
    #
    # which - "" or path or "all"
    #
    # Updates the indicates files.

    proc UpdateXfiles {which} {
        if {$which eq ""} {
            set files [MissingFiles]

            if {![got $files]} {
                puts "No external files are missing."
                return
            }

            foreach path $files {
                UpdateFile $path
            }
        } elseif {$which eq "all"} {
            set files [project xfile paths]

            if {![got $files]} {
                puts "This project has no external files."
                return
            }

            foreach path [project xfile paths] {
                UpdateFile $path
            }
        } elseif {$which in [project xfile paths]} {
            UpdateFile $which
        } else {
            throw FATAL [outdent "
                Path \"$which\" is not one of this project's external
                files.
            "]
        }
    }

    # MissingFiles 
    #
    # Returns a list of the paths for which there is no file.

    proc MissingFiles {} {
        set result [list]
        foreach path [project xfile paths] {
            if !{[file isfile [project root $path]]} {
                lappend result $path
            }
        }

        return $result
    }

    # UpdateFile path
    #
    # path   - The file's local path
    #
    # Retrieves the file.

    proc UpdateFile {path} {
        puts "xfile $path <= [project xfile url $path]"
        set fullpath [project root $path]
        set url [project xfile url $path]
        try {
            pluck file $fullpath $url
        } trap NOTFOUND {result} {
            puts ""
            throw FATAL [outdent "
                Could not retrieve file \"$path\" from URL:
                $url
                => $result
            "]
        }
    }
}







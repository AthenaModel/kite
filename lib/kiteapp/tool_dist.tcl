#-----------------------------------------------------------------------
# TITLE:
#   tool_dist.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "dist" tool.  This tool knows how build distribution zip files.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::DIST

tool define dist {
    usage       {0 - "?<target>...?"}
    description "Builds one or more distribution .zip files."
    needstree      yes
} {
    The 'kite dist' tool is used to build distribution .zip files,
    based on the 'dist' statements in project.kite.  See the project(5)
    man page for more information about specifying distribution 
    targets.

    kite dist ?<target>...?
        Builds all distribution targets, or optionally just the named
        targets.

    The distribution files are placed in <root>/.kite/dist.  The name
    of the file will be 

        <project>-<version>-<target>.zip

    If the <target> is "install", it is omitted.
} {
    #-------------------------------------------------------------------
    # Transient data

    # trans

    typevariable trans -array {
        counter 0
    }
    
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, get the distribution names.
        if {[llength $argv] > 0} {
            foreach name $argv {
                if {$name ni [project dist names]} {
                    throw FATAL "Unknown distribution target: \"$name\""
                }
            }

            set targets $argv
        } else {
            set targets [project dist names]
        }

        # NEXT, build each target.
        foreach target $targets {
            BuildZip $target
        }
    }

    # BuildZip target
    #
    # target - A distribution target name.
    #
    # Builds a zip file for the distribution target.

    proc BuildZip {target} {
        # FIRST, create the encoder.
        set e [zipfile::encode %AUTO%]

        # NEXT, populate the zip file.
        set zroot [project name]

        dict for {zfile pfile} [project dist files $target] {
            $e file: $zroot/$zfile 0 $pfile
        }

        # NEXT, save the zip file.
        set name "[project name]-[project version]-$target.zip"

        set fullname [project root $name]
        puts "Building distribution '$target' as\n  $fullname"
        $e write $fullname
        rename $e ""
    }
}







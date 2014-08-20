#-----------------------------------------------------------------------
# TITLE:
#   disttool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "dist" tool.  This tool knows how build distribution zip files.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(dist) {
    usage       {0 - "?<target>...?"}
    ensemble    disttool
    description "Builds one or more distribution .zip files."
    intree      yes
}

set ::khelp(dist) {
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
}


#-----------------------------------------------------------------------
# disttool ensemble

snit::type disttool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

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

        # NEXT, get the files that match the pattern.
        set droot [project name]
        set sroot [project root]

        foreach pattern [project dist patterns $target] {
            if {$pattern eq "%apps"} {
                set dict [getapps]
            } elseif {$pattern eq "%libs"} {
                set dict [getlibs]
            } else {
                set dict [getfiles $pattern]
            }

            dict for {dfile sfile} $dict {
                $e file: $dfile 0 $sfile
            }
        }

        # NEXT, save the zip file.
        set name "[project name]-[project version]"
        if {$target ne "install"} {
            append name "-$target"
        }
        append name ".zip"

        file mkdir [project root .kite]
        file mkdir [project root .kite dist]

        set fullname [project root $name]
        puts "Building distribution '$target' as\n  $fullname"
        $e write $fullname
        rename $e ""
    }

    # getfiles pattern
    #
    # Gets arbitrary files given a glob pattern and returns a dictionary
    # of file paths by destination path.

    proc getfiles {pattern} {
        set dict [dict create]

        foreach filename [project globfiles $pattern] {
            dict set dict [dfile $filename] $filename
        }

        return $dict
    } 

    # getapps 
    #
    # Gets a dictionary of the as-built names of the project's 
    # applications, by destination path.

    proc getapps {} {
        set dict [dict create]
        foreach name [project app names] {
            set filename [project root bin [project app exefile $name]]
            if {[file isfile $filename]} {
                dict set dict [dfile $filename] $filename
            }
        }

        return $dict
    }

    # getlibs 
    #
    # Gets a dictionary of the files to zip by destination path.

    proc getlibs {} {
        set dict [dict create]
        set pattern "package-*-[project version]-*.zip"

        foreach name [project globfiles .kite libzips $pattern] {
            set dfile [project name]/[file tail $name]
            dict set dict $dfile $name 
        }

        return $dict
    }

    # dfile filename
    #
    # filename  - Absolute path to a project file
    #
    # Replaces the absolute project root with the project name.

    proc dfile {filename} {
        set slen [string length [project root]]
        set relfile [string replace $filename 0 $slen]

        return [project name]/$relfile
    }
}







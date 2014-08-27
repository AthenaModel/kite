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

        # NEXT, get the files that match the pattern.
        set patterns [project dist patterns $target]
        set trans(counter) 0
        set zroot [project name]

        while {[got $patterns]} {
            set pattern [lshift patterns]

            switch -exact -- $pattern {
                %apps   { set dict [GetApps]                  }
                %libs   { set dict [GetLibs]                  }
                %get    { set dict [GetURL [lshift patterns]] }
                default { set dict [GetFiles $pattern]        }
            }

            dict for {zfile dfile} $dict {
                $e file: $zroot/$zfile 0 $dfile
            }
        }

        # NEXT, save the zip file.
        set name "[project name]-[project version]"
        if {$target ne "install"} {
            append name "-$target"
        }
        append name ".zip"

        set fullname [project root $name]
        puts "Building distribution '$target' as\n  $fullname"
        $e write $fullname
        rename $e ""
    }

    # GetFiles pattern
    #
    # Gets arbitrary files given a glob pattern and returns a dictionary
    # of file paths by destination path.

    proc GetFiles {pattern} {
        set dict [dict create]

        foreach filename [project globfiles {*}[split $pattern /]] {
            dict set dict [zfile $filename] $filename
        }

        return $dict
    } 

    # GetApps 
    #
    # Gets a dictionary of the as-built names of the project's 
    # applications, by destination path.

    proc GetApps {} {
        set dict [dict create]
        foreach name [project app names] {
            set filename [project root bin [project app exefile $name]]
            if {[file isfile $filename]} {
                dict set dict [zfile $filename] $filename
            }
        }

        return $dict
    }

    # GetLibs 
    #
    # Gets a dictionary of the files to zip by destination path.

    proc GetLibs {} {
        set dict [dict create]
        set pattern "package-*-[project version]-*.zip"

        foreach name [project globfiles .kite libzips $pattern] {
            set zfile [project name]/[file tail $name]
            dict set dict $zfile $name 
        }

        return $dict
    }

    # GetURL pair
    #
    # pair  - a zfile/URL pair.
    #
    # Plucks the document at the URL, and returns an fdict.

    proc GetURL {pair} {
        lassign $pair zfile url
        set dfile [project root .kite tempfile[incr trans(counter)]]

        try {
            pluck file $dfile $url
        } trap NOTFOUND {result} {
            throw FATAL [outdent "
                Could not %get file \"$zfile\" from URL:
                $url
                => $result
            "]
        }

        return [dict create $zfile $dfile]
    }

    # zfile filename
    #
    # filename  - Absolute path to a project file
    #
    # Removes the absolute project root.

    proc zfile {filename} {
        set slen [string length [project root]]
        set relfile [string replace $filename 0 $slen]

        return $relfile
    }
}







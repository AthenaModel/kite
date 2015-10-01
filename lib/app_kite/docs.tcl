#-----------------------------------------------------------------------
# TITLE:
#   docs.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: app_kite(n) docs module; knows how to build documentation in 
#   the /docs directory. Used by buildtool and docstool.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# docs ensemble

snit::type docs {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # kitedoc(5) Documents

    # kitedocs ?target?
    #
    # target  -  Optionally, full path to a directory containing 
    #            kitedoc(5) files, or a specific kitedoc(5) file.
    #
    # Builds all kitedocs found in docs/ and its subdirectories, or
    # just the given target file.  NOTE: Any .ehtml file found
    # in docs or its subdirectories, other than the "man*" subdirectories,
    # is assumes to be a kitedoc(5) file.

    typemethod kitedocs {{target ""}} {
        # FIRST, allow the project macros
        kitedocs::kitedoc register ::project_macros

        # NEXT, get the files to process.
        if {$target eq ""} {
            foreach dir [GetDocDirs] {
                FormatKiteDocs $dir
            }
        } else {
            FormatKiteDocs $target
        }
    }

    # FormatKiteDocs target
    #
    # target - A kitedoc(5) file or a directory containing them.
    # 
    # Formats all of the kitedoc(5) files in the directory,
    # or the named file.

    proc FormatKiteDocs {target} {
        if {[file isdirectory $target]} {
            set dir $target
            set infiles [glob -nocomplain [file join $dir *.ehtml]]
        } elseif {[file isfile $target]} {
            set dir [file dirname $target]
            set infiles [list $target]
        } else {
            error "No such file or directory: \"$target\""
        }

        if {[llength $infiles] == 0} {
            return
        }

        # NEXT, format the files one by one
        puts "Formatting documents in $dir..."

        try {
            kitedocs::kitedoc format \
                -project     [project name]          \
                -version     [project version]       \
                -description [project description]   \
                -poc         [project poc]           \
                -docroot     [GetDocRoot $dir]       \
                -anchors                             \
                {*}$infiles
        } trap SYNTAX {result} {
            throw FATAL "Syntax error in kitedoc(5) file: $result"
        }
    }

    # GetDocDirs
    #
    # Gets a list of the paths of the non-manpage directories.

    proc GetDocDirs {} {
        set result [list [project root docs]]

        foreach dir [glob -nocomplain [project root docs *]] {
            if {[file isdirectory $dir] &&
                [string match "man*" $dir]
            } {
                lappend result $dir
            }
        }

        return $result
    }

    # GetDocRoot dir
    #
    # dir   - A directory of kitedoc(5) files
    #
    # Determines the appropriate relative path to the docs/ directory.
    # The dir is either $root/docs or a subdirectory.

    proc GetDocRoot {dir} {
        set dir [file normalize $dir]
        set docroot [project root docs]

        if {![string match $docroot* $dir]} {
            # Not in the docs tree.
            return ""
        }

        set count 0
        set thisdir $dir
        while {$thisdir ne $docroot} {
            incr count
            set thisdir [file dirname $thisdir]
        }

        if {$count == 0} {
            set components "."
        } else {
            set components [lrepeat $count ".."]
        }

        return [join $components /]
    }

    #-------------------------------------------------------------------
    # manpage(5) Documents    

    # manpages ?secname?
    #
    # secname - man1, man5, mann, mani, etc.
    #
    # Builds the man pages in the specified docs subdirectory, or
    # all of them.

    typemethod manpages {{secname ""}} {
        if {$secname ne ""} {
            set mandirs [list [project root docs $secname]]
        } else {
            set mandirs [glob -nocomplain [project root docs man*]]
        }

        kitedocs::manpage register ::project_macros

        foreach mandir $mandirs {
            # Skip non-manpage-directories.
            if {![file isdirectory $mandir]} {
                continue
            }

            FormatManPages $mandir
        }

    }

    # FormatManPages mandir
    #
    # mandir - The specific man page directory to work in.
    # 
    # Formats all of the man pages in the directory.

    proc FormatManPages {mandir} {
        # FIRST, validate the section number
        set num [SectionNum [file tail $mandir]]
        
        if {$num ni [project mansecs]} {
            throw FATAL "Unknown man page section: \"man$num\""
        }

        set errfile [project root .kite manerr.html]

        # NEXT, process the man pages in the directory.
        try {
            puts "Formatting man pages in $mandir..."
            kitedocs::manpage format $mandir $mandir          \
                -project     [project name]                   \
                -version     [project version]                \
                -description [project description]            \
                -section     "($num) [project mansec $num]"   \
                -errfile     $errfile
        } trap SYNTAX {result} {
            throw FATAL \
                "Syntax error in man page: $result\nSee $errfile for intermediate outputs."
        }
    }

    # SectionNum secname
    #
    # secname  - A manpage directory, man<num>
    #
    # Extracts the manpage section number.

    proc SectionNum {secname} {
        return [string range $secname 3 end]
    }

}



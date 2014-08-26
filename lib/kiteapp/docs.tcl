#-----------------------------------------------------------------------
# TITLE:
#   docs.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) docs module; knows how to build documentation in 
#   the /docs directory. Used by buildtool and docstool.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# docs ensemble

snit::type docs {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Lookup Tables

    # manpage section titles
    #
    # TODO: We'll need a way to handle non-standard sections

    typevariable manpageSections -array {
        1 "Executables"
        5 "File Formats"
        i "Tcl Interfaces"
        n "Tcl Commands"
    }


    #-------------------------------------------------------------------
    # kitedoc(5) Documents

    # kitedocs ?dirname?
    #
    # dirname  - Optionally, full path to a directory containing 
    #            kitedoc(5) files.  
    #
    # Builds all kitedocs found in docs/ and its subdirectories, or
    # just in the given subdirectory.  NOTE: Any .ehtml file found
    # in docs or its subdirectories, other than the "man*" subdirectories,
    # is assumes to be a kitedoc(5) file.

    typemethod kitedocs {{dirname ""}} {
        # FIRST, get the directories to process.
        if {$dirname ne ""} {
            set docdirs [list $dirname]
        } else {
            set docdirs [GetDocDirs]
        }

        # NEXT, process them.
        foreach dir $docdirs {
            # Skip non-directories.
            if {![file isdirectory $dir]} {
                continue
            }

            FormatKiteDocs $dir
        }
    }

    # FormatKiteDocs dir
    #
    # dir - The specific directory to work in.
    # 
    # Formats all of the kitedoc(5) files in the directory.

    proc FormatKiteDocs {dir} {
        # FIRST, get the files to process.
        set infiles [glob -nocomplain [file join $dir *.ehtml]]

        if {[llength $infiles] == 0} {
            return
        }

        # NEXT, determine the manroots.
        set manroots [GetManRoots $dir]

        vputs "manroots = $manroots"

        # NEXT, format the files one by one
        puts "Formatting documents in $dir..."

        try {
            kitedocs::kitedoc format \
                -project     [project name]          \
                -version     [project version]       \
                -description [project description]   \
                -poc         [project poc]           \
                -manroots    $manroots               \
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

    # GetManRoots dir
    #
    # dir   - A directory of kitedoc(5) files
    #
    # Determines the appropriate relative path for this project's
    # man pages.  The dir is either $root/docs or a subdirectory.

    proc GetManRoots {dir} {
        set dir [file normalize $dir]
        set docroot [project root docs]

        if {![string match $docroot* $dir]} {
            # Not in the docs tree.
            return
        }

        set count 0
        set thisdir $dir
        while {$thisdir ne $docroot} {
            incr count
            set thisdir [file dirname $thisdir]
        }

        if {$count == 0} {
            set leader "."
        } else {
            set leader [string repeat ".." $count]
        }

        set relpath [file join {*}$leader man%s/%n.html]

        return [dict create : $relpath]
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
        
        if {![info exists manpageSections($num)]} {
            throw FATAL "Unknown man page section: \"man$num\""
        }

        # NEXT, process the man pages in the directory.
        # TODO: base manroots on required version of Tcl/Tk.
        try {
            puts "Formatting man pages in $mandir..."
            kitedocs::manpage format $mandir $mandir         \
                -project     [project name]                  \
                -version     [project version]               \
                -description [project description]           \
                -section     "($num) $manpageSections($num)" \
                -libpath     [project auto_path]             \
                -manroots {
                    tcl: http://www.tcl.tk/man/tcl8.6/TclCmd/%n.htm
                    tk: http://www.tcl.tk/man/tcl8.6/TkCmd/%n.htm
                }
        } trap SYNTAX {result} {
            throw FATAL "Syntax error in man page: $result"
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



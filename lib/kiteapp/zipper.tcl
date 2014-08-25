#-----------------------------------------------------------------------
# TITLE:
#   zipper.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n): .zip file commands
#
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# zip ensemble

snit::type zipper {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Public Typemethods

    # folder folder zipfile ?options...?
    #
    # folder  - The full path to a folder on the disk
    # zipfile - The name of the zipfile to create
    #
    # Options:
    #   -recurse  - Pull in subdirectories as well.
    #   -destroot - Root directory in .zipfile.  Defaults to ""
    #
    # Builds a zipfile from the given folder.

    typemethod folder {folder zipfile args} {
        # FIRST, get the options
        set recurse  0
        set destroot ""

        foroption opt args {
            -recurse  { set recurse  1             }
            -destroot { set destroot [lshift args] }
        }

        # NEXT, create the zipper.
        set zipper [zipfile::encode %AUTO%]

        # NEXT, get the files to zip
        set folder [string trimright $folder "/"]
        set prelen [string length $folder]

        foreach sname [GetFiles $folder $recurse] {
            # FIRST, remove the folder's name.
            set dname [string range $sname $prelen+1 end]

            # NEXT, root it if need be.
            if {$destroot ne ""} {
                set dname [file join $destroot $dname]
            }

            $zipper file: $dname 0 $sname
        }

        # NEXT, output the zip file.
        try {
            $zipper write $zipfile
        } finally {
            rename $zipper ""
        }
    }

    # GetFiles folder recurse
    #
    # folder  - Absolute path to a folder on the disk.
    # recurse - Whether to recurse into subdirectories.
    #
    # Returns a list of the absolute paths of the normal
    # files in the directory, recursing into subdirectories if
    # requested.

    proc GetFiles {folder recurse} {
        set result [list]

        foreach path [glob -nocomplain [file join $folder *]] {
            if {[file isfile $path]} {
                lappend result $path
            } elseif {$recurse && [file isdirectory $path]} {
                lappend result {*}[GetFiles $path $recurse]
            }
        }

        return $result
    } 
}
#-----------------------------------------------------------------------
# TITLE:
#    filex.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): File utilities
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        readfile \
        writefile
}

#-------------------------------------------------------------------
# File Handling Utilities


# readfile filename
#
# filename    The file name
#
# Reads the file and returns the text.  Throws the normal
# open/read errors.

proc ::kiteutils::readfile {filename} {
    set f [open $filename r]

    try {
        return [read $f]
    } finally {
        close $f
    }
}

# writefile filename content ?-ifchanged?
#
# filename - The file name
# content  - The content to write
#
# Writes the content to the file.  Throws the normal
# open/write errors.  If -ifchanged is given, reads the file first,
# and only writes the content if it's different than what was there.

proc ::kiteutils::writefile {filename content {opt ""}} {
    # FIRST, If we care, has the file's content changed?
    if {$opt eq "-ifchanged" && [file exists $filename]} {
        set oldContent [readfile $filename]

        if {$oldContent eq $content} {
            return
        }
    }

    # NEXT, write the file, first making sure the directory exists.
    file mkdir [file dirname $filename]

    set f [open $filename w]

    try {
        return [puts -nonewline $f $content]
    } finally {
        close $f
    }
}
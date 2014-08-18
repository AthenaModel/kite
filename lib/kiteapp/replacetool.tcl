#-----------------------------------------------------------------------
# TITLE:
#   replacetool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "replace" tool.  This tool does global replacements in
#   text files.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(replace) {
    usage       {3 - "<target> <subtest> <file> ?<file>...?"}
    ensemble    replacetool
    description "Global string replacement in text files"
    intree      no
}

set ::khelp(replace) {
    The 'kite replace' tool replaces all occurrences of <target> with
    <subtext> in the text files listed on the command line.

    For example, to replace all occurrences of "cat" with
    "dog" in a set of code files, do this:

       $ kite replace cat dog *.tcl

    The tool lists the names of the modified files, and saves a backup
    file for each.  The backup file has the same name as the original
    file, with a "~" appended on the end.
}

#-----------------------------------------------------------------------
# replacetool ensemble

snit::type replacetool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        set target [lindex $argv 0]
        set subtext [lindex $argv 1]
        set files [lrange $argv 2 end]

        # NEXT, Step over the files
        foreach file $files {
            try {
                ReplaceString $target $subtext $file
            } on error {result} {
                throw FATAL "Error processing '$file': $result"
            }
        }
    }

    # ReplaceString target subtext file
    #
    # target   - The text to replace
    # subtext  - The text to replace it with
    # file     - Name of a file to replace it in.
    #
    # Replaces all occurrences of the target with the subtext in the
    # file.  If any occurrences are found, the original file is copied
    # to "$file~".

    proc ReplaceString {target subtext file} {
        # FIRST, read the text from the file
        set text [readfile $file]

        # NEXT, see whether it contains the string at all.  If not, skip this
        # one.
        if {[string first $target $text] == -1} {
            return
        }

        puts "kite replace: $file"

        # NEXT, backup the file
        set backup "$file~"
        file copy -force $file $backup

        # NEXT, do the subtext.
        writefile $file [string map [list $target $subtext] $text]
    }

}







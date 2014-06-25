#-----------------------------------------------------------------------
# TITLE:
#   includer.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) includer module; knows how to query and manipulate
#   external includes libraries.
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export includer
}

#-----------------------------------------------------------------------
# includer ensemble

snit::type ::kutils::includer {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Constants

    # The name for the kite signature file in an include directory.
    typevariable kiteSigFile ".kite_signature"
    


    #-------------------------------------------------------------------
    # Helpers

    # SigFile name
    #
    # name  - The include name
    #
    # Returns the signature file name for this include.

    proc SigFile {name} {
        project root includes $name $kiteSigFile        
    }

    # IncludeDir name
    #
    # name  - The include name
    #
    # Returns the include directory name for this include.

    proc IncludeDir {name} {
        project root includes $name        
    }

    # Signature name
    #
    # name  - Include name
    # 
    # Returns the signature for the given include.

    proc Signature {name} {
        set idict [project include get $name]
        dict with idict {}

        return "$name|$includer|$url|$tag"
    }

    # SignatureMatches name signature
    #
    # name       - The include name
    # signature  - The include signature
    #
    # Returns 1 if the signature file on the disk matches the given
    # signature, and 0 otherwise.  Otherwise includes absence of the
    # signature file and absence of the directory as a whole.

    proc SignatureMatches {name signature} {
        # FIRST, on POSIX errors (i.e., directory doesn't exist or isn't
        # readable, return false).

        try {
            set oldsig [readfile [SigFile $name]]

            if {[string trim $oldsig] eq $signature} {
                return 1
            }

        } trap POSIX {} {
            return 0
        }

        return 0
    }

    # SaveSignature name
    #
    # name       - The include name
    #
    # Saves the include signature to the include directory.  Throws
    # FATAL if it can't be done.

    proc SaveSignature {name} {
        # FIRST, on POSIX errors (i.e., directory doesn't exist or isn't
        # writable) throw FATAL.

        try {
            set f [open [SigFile $name] w]
            puts $f [Signature $name]
            close $f
        } trap POSIX {result} {
            throw FATAL "Failed to write \"$name\" signature file: $result"
        }

        return
    }
    
    # DeleteInclude name
    #
    # name - Include name
    #
    # Deletes any include with this name.  Throws FATAL if it can't
    # be done.

    proc DeleteInclude {name} {
        # FIRST, on POSIX errors throw FATAL.

        try {
            # Note: no error is thrown if the directory doesn't exist.
            file delete -force -- [IncludeDir $name]
        } trap POSIX {result} {
            throw FATAL "Failed to purge include \"$name\": $result"
        }

        return
    }

    # DeleteUnknownIncludes
    #
    # Deletes all includes for which we have no matching "include"
    # in project.kite.

    proc DeleteUnknownIncludes {} {
        set dir [project root includes]

        foreach fname [glob -nocomplain [file join $dir *]] {
            if {[file tail $fname] ni [project include names]} {
                DeleteInclude [file tail $fname]
            }
        }
    }

    # GetInclude name
    #
    # name  - Include name
    #
    # Retrieves the include into <root>/includes/<name>.

    proc GetInclude {name} {
        puts "Retrieving include \"$name\""

        # FIRST, delete the old include.
        DeleteInclude $name

        # FIRST, do the retrieval
        set includer [project include get $name includer]

        switch -exact -- $includer {
            git     { GetIncludeGit $name }
            svn     { GetIncludeSvn $name }
            default { error "Unknown includer: \"$includer\"" }
        }

        # NEXT, we succeeded; save the signature.
        SaveSignature $name
        puts "Finished retrieving include \"$name\""
    }

    # GetIncludeGit name
    #
    # name  - Include name
    #
    # "git clone"'s the include to <root>/includes/<name>.

    proc GetIncludeGit {name} {
        # FIRST, get the include details.
        set idict [project include get $name]
        dict with idict {}

        # NEXT, put together the command.
        set command [list git clone --branch $tag $url [IncludeDir $name]]

        # NEXT, support a log
        set logfile [project root git_error.log]
        lappend command >& $logfile

        # NEXT, try to clone it.
        try {
            # FIRST, do the clone
            eval exec $command

            # On success, we don't need the log file.
            catch {file delete $logfile}
        } on error {result} {
            throw FATAL "Error cloning \"$name\"; see git_error.log:\n$result"
        }
    }

    # GetIncludeSvn name
    #
    # name  - Include name

    proc GetIncludeSvn {name} {
        # FIRST, get the include details.
        set idict [project include get $name]
        dict with idict {}

        # NEXT, put together the command.
        set command [list svn checkout $url/$tag [IncludeDir $name]]

        # NEXT, support a log
        set logfile [project root svn_error.log]
        lappend command >& $logfile

        # NEXT, try to clone it.
        try {
            # FIRST, do the clone
            eval exec $command

            # On success, we don't need the log file.
            catch {file delete $logfile}
        } on error {result} {
            throw FATAL "Error cloning \"$name\"; see svn_error.log:\n$result"
        }
    }
}




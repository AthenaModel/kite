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
    # Public Commands

    # status
    #
    # Outputs the status of the project's includes.

    typemethod status {} {
        set unknown [UnknownIncludes]
        if {[llength $unknown] > 0} {
            puts "The includes/ directory contains these unknown includes:"

            foreach iname $unknown {
                puts "  $iname"
            }

            puts ""
        }

        if {[llength [project include names]] == 0} {
            puts "The project has no known includes.\n"
            return
        }

        puts "Include Status:\n"

        foreach name [project include names] {
            set tag [project include get $name tag]

            if {[SignatureMatches $name]} {
                puts "  include \"$name $tag\" appears to be up-to-date."
            } else {
                puts "  include \"$name $tag\" needs to be retrieved."
            }
        }

        puts ""
    }
    
    # clean
    #
    # Removes all unknown includes from the "includes" directory.

    typemethod clean {} {
        puts "Removing all unknown included libraries from"
        puts "[project root includes]..."
        
        # FIRST, delete the ones that are no longer in project.kite.
        DeleteUnknownIncludes
    }

    # update
    #
    # Updating any includes that are missing or out-of-date.

    typemethod update {} {
        set count 0

        foreach name [project include names] {
            set tag [project include get $name tag]

            if {![SignatureMatches $name]} {
                incr count
                GetInclude $name
            }
        }

        puts "\nUpdated $count include(s)."
    }

    # retrieve name
    #
    # name  - An include name.
    #
    # Retrieves the specific include from its repository, whether
    # it is up-to-date or not.

    typemethod retrieve {name} {
        GetInclude $name
    }

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

        return "$name|$vcs|$url|$tag"
    }

    # SignatureMatches name
    #
    # name       - The include name
    #
    # Returns 1 if the signature file on the disk matches the given
    # signature, and 0 otherwise.  Otherwise includes absence of the
    # signature file and absence of the directory as a whole.

    proc SignatureMatches {name} {
        # FIRST, on POSIX errors (i.e., directory doesn't exist or isn't
        # readable, return false).

        try {
            set oldsig [readfile [SigFile $name]]

            if {[string trim $oldsig] eq [Signature $name]} {
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
            vputs "Deleting: [IncludeDir $name]"
            # Note: no error is thrown if the directory doesn't exist.
            file delete -force -- [IncludeDir $name]
        } trap POSIX {result eopts} {
            vputs "eopts <$eopts>"
            if {[string match "*file already exists" $result]} {
                throw FATAL \
"Purge of include \"$name\" failed; is some app watching that directory?"
            } else {
                throw FATAL "Failed to purge include \"$name\": $result"
            }
        }

        return
    }

    # UnknownIncludes
    #
    # Returns the directory names of all unrecognized includes.

    proc UnknownIncludes {} {
        set result [list]

        set dir [project root includes]

        foreach fname [glob -nocomplain [file join $dir *]] {
            set iname [file tail $fname]
            if {$iname ni [project include names]} {
                lappend result $iname
            }
        }

        return $result
    }

    # DeleteUnknownIncludes
    #
    # Deletes all includes for which we have no matching "include"
    # in project.kite.

    proc DeleteUnknownIncludes {} {
        foreach iname [UnknownIncludes] {
            DeleteInclude $iname
        }
    }

    # GetInclude name
    #
    # name  - Include name
    #
    # Retrieves the include into <root>/includes/<name>.

    proc GetInclude {name} {
        # FIRST, delete the old include.
        DeleteInclude $name

        # NEXT, do the retrieval
        puts "Retrieving include \"$name\"..."

        set vcs [project include get $name vcs]

        switch -exact -- $vcs {
            git     { GetIncludeGit $name }
            svn     { GetIncludeSvn $name }
            default { error "Unknown VCS: \"$vcs\"" }
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




#-----------------------------------------------------------------------
# TITLE:
#   os.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   kiteutils(n): OS abstraction layer.
#
#   This module is not concerned with the architectural details of the
#   OS (e.g., 32 vs. 64 bit), but with the details of interacting with
#   the OS, e.g., where do certain files go, file naming conventions,
#   ways to make things happen, that change based on the OS.
#
#   The module defines a number of "flavors" that represent distinct
#   OS-interaction patterns.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export \
        os
}


#-----------------------------------------------------------------------
# os ensemble

snit::type ::kiteutils::os {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Constants
    
    # osNames, by flavor

    typevariable osNames -array {
        linux    "Linux"
        osx      "Mac OS X"
        windows  "Windows"
    }

    #-------------------------------------------------------------------
    # Public Methods

    # flavor
    #
    # Returns the platform flavor, one of linux|osx|windows.
    #
    # This is the routine that figures out what kind of machine we're
    # on.  These selectors are enough for most purposes; for actually
    # setting the "arch", see the standard platform(n) package.
    #
    # Note: if we aren't on Windows or OS X, we assume we're on Linux,
    # or something enough like it not to matter.
    #
    # Other parts of the code can query this, if need be; but if they
    # do the function may need to be refactored into this API. 
    
    typemethod flavor {} {
        switch -glob -- $::tcl_platform(os) {
            "Windows*" { return "windows" }
            "Darwin*"  { return "osx"     }
            default    { return "linux"   }
        }
    }

    # flavors
    #
    # Returns the list of flavors.

    typemethod flavors {} {
        return [lsort [array names osNames]]
    }

    # osname
    #
    # Returns the OS name for the platform flavor. 
    
    typemethod name {} {
        return $osNames([$type flavor])
    }

    # exefile name
    #
    # name - A program name or path
    #
    # Given the program name or path, adds on the appropriate file 
    # extensions for executables on this platfor.

    typemethod exefile {name} {
        if {[$type flavor] eq "windows" && 
            [file extension $name] != ".exe"
        } {
            return "$name.exe"
        } else {
            return $name
        }
    }

    # appdir
    #
    # Returns the name of the root directory for application preference files
    # and the like, if there's one specifically defined for the platform,
    # and "" otherwise.  (If "", the application can assume that Un*x 
    # standard apply, and create a "dot-file" or "dot-directory" in the
    # user's home directory.)

    typemethod appdir {} {
        if {[$type flavor] eq "windows"} {
            return $::env(APPDATA)
        } else {
            return ""
        }
    }

    # pathfind exe
    #
    # exe   - The name of an executable file
    #
    # Attempts to find the executable file on the user's PATH.  Returns
    # the full, normalized path; or "" if not found.

    typemethod pathfind {exe} {
        # FIRST, if there's no PATH we're done.  However, env(PATH)
        # is peculiar; so just grab it.
        set path ""
        catch {set path $::env(PATH)}

        if {$path eq ""} {
            return ""
        }

        # NEXT, try it with the default path separator.
        set sep $::tcl_platform(pathSeparator)
        set result [FindOnPath $exe [split $path $sep]]
    }

    # FindOnPath exe dirlist
    #
    # exe      - The executable name
    # dirlist  - The list of directories.
    #
    # Looks for the exe on the path, and returns the result.

    proc FindOnPath {exe dirlist} {
        foreach dir $dirlist {
            set path [file join $dir $exe]
            if {[file isfile $path]} {
                return [file normalize $path]
            }
        }

        return ""
    }
}
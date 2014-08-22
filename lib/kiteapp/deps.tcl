#-----------------------------------------------------------------------
# TITLE:
#   deps.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) "deps": commands for tracking and managing
#   external dependencies, as lists in project.kite using the 
#   "require" statement.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# deps ensemble

snit::type deps {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Teapot Commands

    # uptodate
    #
    # Returns 1 if all required packages are up-to-date.

    typemethod uptodate {} {
        foreach name [project require names] {
            set version [project require version $name]

            if {![deps has $name $version]} {
                return 0
            }
        }

        return 1
    }

    # has package version
    #
    # package - A package name
    # version - A version requirement, as for [package vsatisfies]

    typemethod has {package version} {
        set rows [teacup list --at-default $package]

        foreach row $rows {
            set v [dict get $row version]

            if {[package vsatisfies $v $version]} {
                return 1
            }
        }

        return 0
    }

    # update ?name?
    #
    # name   - The package to update, or "".
    #
    # Called with no arguments, this routine looks through the list of
    # "requires" and attempts to install all packages that are required
    # but not present in the local teapot repository.  It reports 
    # success or failure for each.
    # 
    # Called with a name, this routine attempts to update that particular
    # package.

    typemethod update {{name ""}} {
        if {$name ne ""} {
            if {$name ni [project require names]} {
                throw FATAL [outdent "
                    This project does not require any package called '$name'.
                "]
            }
            RefreshPackage $name
        } else {
            UpdateAllPackages
        }
    }

    # RefreshPackage name
    #
    # name  - The package to refresh.
    #
    # Removes the package from the local teapot, and reinstalls it from
    # the remote repository.

    proc RefreshPackage {name} {
        if {[project require islocal $name]} {
            throw FATAL [outdent "
                Package $name is locally built, and must be installed
                by the developer.
            "]
        }

        set ver [project require version $name]

        if {[deps has $name $ver]} {
            try {
                RemovePackage $name
            } on error {result} {
                throw FATAL \
                    "Could not remove package $name from the local teapot: $result"
            }
        }

        try {
            InstallPackage $name
        } on error {result} {
            throw FATAL \
                "Could not install $name $ver into the local teapot: $result"
        }
    }

    # UpdateAllPackages
    #
    # Updates all out-of-date packages.

    proc UpdateAllPackages {} {
        # FIRST, update all that need it.
        set errCount 0
        set updateCount 0

        foreach rname [project require names] {
            if {[project require islocal $rname]} {
                continue
            }

            set ver [project require version $rname]

            if {[deps has $rname $ver]} {
                continue
            }

            try {
                InstallPackage $rname
                incr updateCount
            } on error {result} {
                incr errCount
                puts "Could not install $rname $ver: $result"
            }
        }

        puts "Updated $updateCount required package(s)."

        if {$errCount} {
            throw FATAL "Some required packages could not be installed."
        }
    }

    # InstallPackage name
    #
    # name  - A required package name
    #
    # Attempts to install the given package into the repository.
    # Throws any error.

    proc InstallPackage {name} {
        set ver [project require version $name]
        puts "Installing required package: $name $ver..."

        teacup install $name $ver
    }

    # RemovePackage name
    #
    # name  - A required package name
    #
    # Attempts to remove the given package from the repository.
    # Throws any error.

    proc RemovePackage {name} {
        set ver [project require version $name]
        puts "Removing required package: $name $ver..."

        teacup remove $name $ver
    }



}


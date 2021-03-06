#-----------------------------------------------------------------------
# TITLE:
#   trees.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: app_kite(n) module for creating project trees.  This module
#   uses template files from app_kite/templates and the [generate]
#   command to generate the trees.
#
#   The commands in this file build a project tree given the root
#   directory name.  They assume that the root directory does not
#   exist, and will happily overwrite anything there.  In other words,
#   it is the job of the "kite new" tool to check for problems.
#
#   TODO: Ultimately, we'd want a plugin mechanism for adding new
#   kinds of project trees.
#
# STANDARD MAPPINGS:
#   The template files should make use of these standard mappings.
#
#   %project   - The project name
#   %app       - When defining an [app] or [appkit], the application name,
#                e.g., "kite".
#   %package   - When defining a package, the package name.
#   %module    - When defining a module within a package, the bare module
#                name, e.g., "mymodule" not "mymodule.tcl".
#   %template  - The template file used.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Help for the project trees.

set ::khelp(app) {
    The "app" project template is for applications that
    will be deployed as executable "starpack" files.  Apps are platform-
    dependent, but can generally be run without any ancillary files.
    Apps are therefore useful for delivered software.

    The template takes one optional argument, the root name of the 
    executable file; this name defaults to the project name.  For example,

        $ kite new app my-project

    produces the app "<root>/bin/my-project.exe" (on Windows).  However,

        $ kite new app my-project mytool

    products the app "<root>/bin/mytool.exe".

    The application will have:

    * A loader script, e.g., bin/<appname>.tcl
    * A Tcl package, lib/app_<appname>, containing the main routine
      in lib/<appname>app/main.tcl
    * Standard documentation and test files.

    An application can be a console app or a GUI app.  This project tree
    assumes the application should be a GUI app; this can be changed
    by editing the "app" statement in the generated project.kite file.
}

set ::khelp(appkit) {
    The "appkit" project template is for pure-tcl applications that
    will be deployed as "starkit" files.  Appkits run against the 
    installed version of Tcl, and so are primarily useful for 
    developer tools.

    The template takes one optional argument, the root name of the 
    executable file; this name defaults to the project name.  For example,

        $ kite new appkit my-project

    produces the appkit "<root>/bin/my-project.exe" (on Windows).  However,

        $ kite new appkit my-project mytool

    products the app "<root>/bin/mytool.exe".

    The application will have:

    * A loader script, e.g., bin/<appname>.tcl
    * A Tcl package, lib/app_<appname>, containing the main routine
      in lib/<appname>app/main.tcl
    * Standard documentation and test files.

    An application can be a console app or a GUI app.  This project tree
    assumes the application should be a console app; this can be changed
    by editing the "app" statement in the generated project.kite file.
}

set ::khelp(lib) {
    The "lib" project template is for projects that provide one or
    more Tcl library packages for use by other projects, but do not
    define any application.  The template creates a project tree for 
    a project with one library package; others can be added subsequently.

    The template takes one optional argument, the name of the 
    library package file; this name defaults to the project name.  
    For example,

        $ kite new lib my-project

    produces the package "<root>/lib/my-project", while

        $ kite new lib my-project mylib

    products the package "<root>/lib/mylib".

    A project can define any number of library packages via the 
    "provide" statement in the project.kite file.  These should be
    initialized using "kite new lib" or "kite add lib"; this ensures
    that the package files contain the correct markers so that Kite
    can update their version numbers as the version number changes
    in project.kite.
}


#-----------------------------------------------------------------------
# trees ensemble

snit::type trees {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type Variables

    typevariable treetypes {
        app    ".exe application template"
        appkit ".kit application template"
        lib    "Tcl library package template"
    }


    #-------------------------------------------------------------------
    # Public Queries

    # types
    #
    # Returns the list of tree types.

    typemethod types {} {
        return [dict keys $treetypes]
    }

    # description tree
    #
    # tree  - A tree type
    #
    # Returns the description of the tree type.

    typemethod description {tree} {
        return [dict get $treetypes $tree]
    }


    #-------------------------------------------------------------------
    # Project trees
    

    # app parent project app
    #
    # parent  - The directory in which to create the new tree.
    # project - The project name, e.g., "athena-mytool"
    # app     - The application name, e.g., "mytool"
    #
    # Builds a default app template rooted at the given directory,
    # assuming that there is nothing there.

    typemethod app {parent project app} {
        # FIRST, determine the app name.
        if {$app eq ""} {
            set app $project
        }
        
        # NEXT, log what we're doing.
        puts "Making an app project tree for project \"$project.\""
        puts "The application will be called \"$app\"."

        # NEXT, create the project root directory
        project new $project

        # NEXT, create the rest of the tree.
        # TODO: Refactor with tool_add.
        project add app $app -apptype exe -gui
        subtree proj
        subtree app $app

        # NEXT, apply the project metadata to the code.
        metadata apply
        project save
    }

    # appkit parent project app
    #
    # parent  - The directory in which to create the new tree.
    # project - The project name, e.g., "athena-mytool"
    # app     - The application name, e.g., "mytool"
    #
    # Builds a default appkit template rooted at the given directory,
    # assuming that there is nothing there.

    typemethod appkit {parent project app} {
        # FIRST, determine the app name.
        if {$app eq ""} {
            set app $project
        }
        
        # NEXT, log what we're doing.
        puts "Making an appkit project tree for project \"$project.\""
        puts "The application will be called \"$app.kit\"."

        # NEXT, create the project root directory
        project new $project

        # NEXT, create the rest of the tree.
        # TODO: Refactor with tool_add.
        project add app $app -apptype kit
        subtree proj
        subtree app $app

        # NEXT, apply the project metadata to the code.
        metadata apply
        project save
    }


    # lib parent project libname
    #
    # parent  - The directory in which to create the new tree.
    # project - The project name, e.g., "athena-mylib"
    # libname  - The barename of the library package, e.g., "mylib"
    #
    # Builds a default library template rooted at the given directory,
    # assuming that there is nothing there.

    typemethod lib {parent project libname} {
        # FIRST, determine the lib name.
        if {$libname eq ""} {
            set libname $project
        }

        # NEXT, log what we're doing.
        puts "Making a library project tree for project \"$project.\""
        puts "The library package will be called ${libname}(n)."

        # FIRST, create the project root directory
        project new $project

        # NEXT, create the rest of the tree
        project add lib $libname
        subtree proj
        subtree pkg $libname $libname

        # NEXT, apply the project metadata to the code.
        metadata apply
        project save
    }    
}






#-----------------------------------------------------------------------
# TITLE:
#   subtree_proj.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n), "proj" subtree writer: project files
#
#-----------------------------------------------------------------------

namespace eval ::kiteapp::subtree:: {
    namespace export \
        proj
}

# proj
#
# Saves the main project files to the project root.

proc ::kiteapp::subtree::proj {} {
    treefile .gitignore       [Proj_gitignore]
    treefile README.md        [Proj_README]
    treefile TODO.md          [Proj_TODO]
    treefile docs/index.ehtml [Proj_index]
}

# Proj_gitignore
#
# Returns the contents of the default .gitignore file.

codeblock ::kiteapp::subtree::Proj_gitignore {} {
    # Kite Artifacts
    /.kite
    /includes
    /docs/man*/*.html
    *.log
    *.kit
    teapot.txt

    # SublimeText artifacts
    *.sublime-*
}

# Proj_README
#
# Returns the contents of the default README.md file.

codeblock ::kiteapp::subtree::Proj_README {} {
    set project [project name]
} {
    # %project - Your new project

    A Tcl project designed to....

    ## Usage

    FIXME

    ## License

    FIXME (probably, you want a LICENSE or DISTRIBUTION file).
}

# Proj_TODO
#
# Returns the contents of the default TODO.md file.

codeblock ::kiteapp::subtree::Proj_TODO {} {
    set project [project name]
} {
    # %project - To Do List

    * Write the code
    * Test the code
    * ...
}


# Proj_index 
#
# Returns the contents of the package's documentation index file.

codeblock ::kiteapp::subtree::Proj_index {} {
    set project [project name]
} {
    <document "Project Documentation">

    <preface doc "Development Documents">

    <ul>
      <li> <link ../README.md "Project README">
      <li> FIXME: Top-level docs
    </ul>

    <preface man "Man Pages">

    <ul>
      <li> <link man1/index.html "Section (1)">: Executables
      <li> <link man5/index.html "Section (5)">: File Formats
      <li> <link mann/index.html "Section (n)">: Tcl Commands
      <li> <link mani/index.html "Section (i)">: Tcl Interfaces
    </ul>

    </document>
}

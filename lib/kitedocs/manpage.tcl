#-----------------------------------------------------------------------
# TITLE:
#    manpage.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kitedocs(n): ehtml(5) man page processor.
#
#    This singleton is a document processor for manpage(5) man page
#    format.  manpage(5) man pages are written in "Extended HTML", 
#    i.e., HTML extended with Tcl macros.  It automatically generates
#    tables of contents, etc., and provides easy linking to other
#    man pages.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kitedocs:: {
    namespace export \
        manpage
}

#-----------------------------------------------------------------------
# manpage ensemble

snit::type ::kitedocs::manpage {
    pragma -hastypedestroy 0 -hasinstances 0

    #-------------------------------------------------------------------
    # Look-up Tables

    # manpage(5)-specific CSS.
    typevariable css {
        BODY {
            color: black;
            background: white;
            margin-left: 6%;
            margin-right: 6%;
        }

        H1 {
            margin-left: -5%;
        }
        H2 {
            margin-left: -5%;
        }
        HR {
            margin-left: -5%;
        }

        TABLE {
            text-align:    left;
        }
        
        /* mktree styles */
        ul.mktree  li  { list-style: none; }
        ul.mktree, ul.mktree ul, ul.mktree li { 
            margin-left:10px; padding:0px; }
        ul.mktree li .bullet { padding-left: 10px }
        ul.mktree  li.liOpen   .bullet {cursor : pointer; }
        ul.mktree  li.liClosed .bullet {cursor : pointer; }
        ul.mktree  li.liBullet .bullet {cursor : default; }
        ul.mktree  li.liOpen   ul {display: block; }
        ul.mktree  li.liClosed ul {display: none; }
    }
    

    #-------------------------------------------------------------------
    # Type Variables

    # Info array: scalars
    #
    #  srcdir       - The source directory name
    #  destdir      - The destination directory name
    #  project      - The project name
    #  version      - The project version
    #  description  - The project description
    #  section      - The man page section name
    #  manroots     - The "manroot" links dictionary

    typevariable info -array {}

    # macrosets -- List of registered macrosets.
    typevariable macrosets {}

    # ehtml -- The ehtml translator
    typevariable ehtml ""

    # An array: key is module name, value is list of submodules.
    # modules with no parent are under submodule().
    typevariable submodule -array {}

    # An array: key is module name, value is description.
    typevariable module -array {}

    # Mktree script flag
    typevariable mktreeFlag 0

    # Man Page variables

    typevariable currentManpage         ;# Name of the current man page

    typevariable items {}               ;# List of item tags, in order of 
                                         # definition 
    typevariable itemtext -array {}     ;# Array, item text by tag
    typevariable sections {}            ;# List of section names, in order of 
                                         # definition.
    typevariable curSection {}          ;# Current section
    typevariable subsections -array {}  ;# Array of subsection names by parent 
                                         # section.
    typevariable optsfor -array {}      ;# Option data
    typevariable opttext -array {}      ;# Option text

    #-------------------------------------------------------------------
    # Public Typemethods

    # register macroset
    #
    # macroset  - A macroset(i) macro set
    #
    # Registers the macro set for use in man pages.

    typemethod register {macroset} {
        ladd macrosets $macroset
        if {$ehtml ne ""} {
            $ehtml register $macroset
            $ehtml reset
        }
    }

    # format srcdir destdir ?option value...?
    #
    # srcdir   - The directory containing man page files in .ehtml
    #            format.
    # destdir  - The directory in which to put the formatted .html
    #            files.
    #
    # Options:
    #   -project name      - Project name
    #   -version num       - Project version number
    #   -description text  - Project description
    #   -section text      - Manpage Section Title
    #   -manroots dict     - ehtml(n) "manroots"
    #
    # Formats the man pages in a man page directory.

    typemethod format {srcdir destdir args} {
        # FIRST, initialize the options
        array set info {
            project     "YourProject"
            version     "0.0.0"
            description "Your project description"
            section     "Project Man Pages"
            manroots    {: ../man%s/%n.html}
        }

        # NEXT, initialize the ehtml processor.
        if {$ehtml eq ""} {
            set ehtml [macro ${type}::ehtmltrans]
            $ehtml register ::kitedocs::ehtml
            foreach macroset $macrosets {
                $ehtml register $macroset
            }
            $ehtml reset            
        }
        
        # NEXT, validate the directories.
        if {![file isdirectory $srcdir]} {
            error "'$val' is not a valid directory."
        }

        set info(srcdir) $srcdir

        if {![file isdirectory $destdir]} {
            error "'$val' is not a valid directory."
        }

        set info(destdir) $destdir

        # NEXT, get the option values
        while {[string match "-*" [lindex $args 0]]} {
            set opt [lshift args]
            set val [lshift args]
            
            switch -exact -- $opt {
                -version {
                    set info(version) $val
                }
                -project {
                    set info(project) $val
                }

                -description {
                    set info(description) $val
                }
                -manroots {
                    set val [dict merge $info(manroots) $val]
                    set info(manroots) $val
                }
                -section {
                    set info(section) $val
                }
                default {
                    error "Unknown option: \"$opt\""
                }
            }
        }

        # NEXT, save the manroots.
        if {[catch {::kitedocs::ehtml manroots $info(manroots)} result]} {
            error "Error: Invalid -manroots: \"$info(manroots)\", $result"
        }

        # NEXT, clear all state.
        $type ClearState

        # NEXT, get the files
        set files [lsort [glob -nocomplain [file join $srcdir *.ehtml]]]

        if {[llength $files] == 0} {
            return
        }

        foreach infile $files {
            set pagename [file tail [file root $infile]]
            set outfile [file join $destdir $pagename.html]
            $type DefineMacros

            try {
                set output [$ehtml expandfile $infile]
            } on error {result} {
                throw SYNTAX "[file tail $infile]:\n$result"
            }

            set f [open $outfile w]
            puts $f $output
            close $f
        }

        # NEXT, output the index
        set outfile [file join $destdir index.html]
        set f [open $outfile w]
        puts $f [indexfile]
        close $f
    }

    # ClearState 
    #
    # Resets all state variables.

    typemethod ClearState {} {
        array unset module
        array unset submodule
        array unset itemtext
        array unset subsections
        array unset optsfor
        array unset opttext

        set mktreeFlag 0
        set currentManpage ""
        set items {}
        set sections {} 
        set curSection {}
    }

    #-------------------------------------------------------------------
    # Translator Configuration

    # DefineMacros
    #
    # Defines all macros in the context of the ehtml(5) translator

    typemethod DefineMacros {} {
        $ehtml reset

        $ehtml smartalias manpage 2 2 {nameList description} \
            [myproc manpage]

        $ehtml smartalias /manpage 0 0 {} \
            [myproc /manpage]

        $ehtml smartalias version 0 0 {} \
            [myproc version]

        $ehtml smartalias section 1 1 {name} \
            [myproc section]

        $ehtml smartalias subsection 1 1 {name} \
            [myproc subsection]

        $ehtml smartalias contents 0 0 {} \
            [myproc contents]

        $ehtml smartalias defitem 2 2 {item text} \
            [myproc defitem]

        $ehtml smartalias itemlist 0 0 {} \
            [myproc itemlist]

        $ehtml smartalias iref 1 - {iref...} \
            [myproc iref]

        $ehtml smartalias defopt 1 1 {text} \
            [myproc defopt]

        $ehtml smartalias indexfile 0 0 {} \
            [myproc indexfile]

        $ehtml smartalias indexlist 1 1 {modules} \
            [myproc indexlist]

        $ehtml proc itag {args} {
            return "[tt][lb][iref {*}$args][rb][/tt]"
        }

        $ehtml smartalias mktree 1 1 {id} \
            [myproc mktree]

        $ehtml smartalias /mktree 0 0 {} \
            [myproc /mktree]
    }
    

    #-------------------------------------------------------------------
    # Javascripts
    
    # Begins a dynamic tree using the mktree script.
    proc mktree {id} {
        set mktreeFlag 1
        
        return "<ul class=\"mktree\" id=\"$id\">"
    }

    proc /mktree {} {
        return "</ul>"
    }

    #-------------------------------------------------------------------
    # Man Page Template

    # manpage nameList description
    #
    # nameList     List of man page names, from ancestor to this page
    # description  One line description of contents
    #
    # Begins a man page.

    template proc manpage {nameList description} {
        set name [lindex $nameList end]

        set currentManpage $name
        set info(imgcount) 0

        if {[llength $nameList] > 1} {
            set parent [lindex $nameList 0]
            set parentRef ", submodule of [$ehtml eval [list xref $parent]]"
            set titleParentRef ", submodule of $parent"
        } else {
            set parent ""
            set parentRef ""
            set titleParentRef ""
        }

        if {[$ehtml pass] == 1} {
            set items {}
            array unset itemtext
            array unset optsfor
            array unset opttext
            set sections {}
            array unset subsections
            set curSection {}
            set module($name) $description
            lappend submodule($parent) $name
        }

        set cssStyles "[::kitedocs::ehtml css]\n$css"
    } {
        |<--
        <html>
        <head>
        <title>$info(project) $info(version): $name -- $description$titleParentRef</title>
        <style type="text/css" media="screen,print">
        $cssStyles
        </style>
        
        [tif {$mktreeFlag} {
            |<--
            [readfile [file join $::kitedocs::library mktree.js]]
        }]

        </head>

        <body>
        [Banner]

        [section NAME]

        <b>$name</b> -- $description$parentRef
        
        [contents]
    }

    # Banner
    #
    # Returns the current project banner.
    #
    # TBD: Should be settable by the caller

    template proc Banner {} {
        |<--
        <h1 style="background: red;">
        &nbsp;$info(project) $info(version): $info(description)
        </h1>
    }

    # /manpage
    #
    # Terminates a man page

    template proc /manpage {} {
        |<--
        <hr>
        <i>$info(project) $info(version) Man page generated by manpage(n) on 
        [clock format [clock seconds]]</i>
        </body>
        </html>
    }

    # version
    #
    # Returns the -version.

    proc version {} {
        return $info(version)
    }

    # section name
    #
    # name    A section name
    #
    # Begins a major section.

    template proc section {name} {
        set name [string toupper $name]
        set id [textToID $name]
        if {[$ehtml pass] == 1} {
            lappend sections $name 
            $ehtml eval [list xrefset $name $name "#$id"]
        }

        set curSection $name
    } {
        |<--
        <h2><a name="$id">$name</a></h2>
    }

    # subsection name
    #
    # name     A subsection name
    #
    # Begins a subsection of a major section

    template proc subsection {name} {
        set id [textToID $name]
        if {[$ehtml pass] == 1} {
            lappend subsections($curSection) $name 
            $ehtml eval [list xrefset $name $name "#$id"]
        }
    } {
        |<--
        <h2><a name="$id">$name</a></h2>
    }

    # contents
    #
    # Produces a list of links to the sections and subsections.

    template proc contents {} {
        |<--
        <ul>
        [tforeach name $sections {
            <li><a href="#[textToID $name]">$name</a></li>
            [tif {[info exists subsections($name)]} {
                |<--
                <ul>
                [tforeach subname $subsections($name) {
                    <li><a href="#[textToID $subname]">$subname</a></li>
                }]
                </ul>
            }]
        }]
        </ul>
    }

    # defitem item text
    #
    # item     iref identifier for this item
    # text     Text to display
    #
    # Introduces an item in an item list, and provides the href 
    # anchor.

    template proc defitem {item text} {
        lappend items $item
        set text [$ehtml expandonce $text]
        set itemtext($item) $text
    } {
        |<--
        <dt><b><tt><a name="[textToID $item]">$text</a></tt></b></dt>
        <dd>
    }

    # defopt text
    #
    # text     Text defining an option, e.g., "-foo <i>bar</i>"
    #
    # An item in an item list that defines an option to a command.

    template proc defopt {text} {
        set opt [lindex $text 0]
        set lastItem [lindex $items end]
        set id "$lastItem$opt"
        lappend optsfor($lastItem) $opt
        set text [$ehtml expandonce $text]
        set opttext($id) $text
    } {
        |<--
        <dt><b><tt><a name="$id">$text</a></tt></b></dt>
        <dd>
    }

    # itemlist
    #
    # Produces a list of links to the defined items, for use in the
    # synopsis section of the man page.

    template proc itemlist {} {
        |<--
        [tforeach tag $items {
            |<--
            <tt><a href="#[textToID $tag]">$itemtext($tag)</a></tt><br>
            [tif {[info exists optsfor($tag)]} {
                |<--
                [tforeach opt $optsfor($tag) {
                    |<--
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <tt><a href="#$tag$opt">$opttext($tag$opt)</a></tt><br>
                }]
            }]
        }]<p>
    }

    # iref args
    #
    # args    An item ID, which might be multiple tokens.
    #
    # Creates a link to the item in this page.

    proc iref {args} {
        set tag $args

        if {[$ehtml pass] == 1} {
            return
        }

        if {[lsearch -exact $items $tag] != -1} {
            return "<tt><a href=\"#[textToID $tag]\">$tag</a></tt>"
        } else {
            puts stderr "Warning, iref not found: '$tag'"
            return "<tt>$tag</tt>"
        }
    }

    #-------------------------------------------------------------------
    # Index File Template

    # indexfile
    #
    # Template for the index file created for a directory full of 
    # man pages.

    template proc indexfile {} {
        # TODO: acquire the section title in a cleaner way.
        set title "Man Page Section $::kitedocs::manpage::info(section)"

        # FIRST, see if we've got any parents for which no man page exists.
        set hasparent [list]

        foreach mod [array names submodule] {
            lappend hasparent {*}$submodule($mod)
        }

        foreach mod [array names submodule] {
            if {$mod ne "" && $mod ni $hasparent} {
                lappend submodule() $mod
                set module($mod) "Unknown Man Page"
            }
        }
    } {
        |<--
        <head>
        <title>$title</title>
        <style>
        body {
            color: black;
            background: white;
            margin-left: 1%;
            margin-right: 1%;
        }
        </style>
        </head>
        <body>
        [Banner]
        <h2>$title</h2>
        <hr>

        [indexlist $submodule()]

        <hr>
        <i>Index generated on [clock format [clock seconds]]</i>
        </body>
        </html>
    }

    # indexlist modules
    #
    # modules    List of module names
    #
    # Produces a list of links to man pages

    template proc indexlist {modules} {
        |<--
        <ul>
        [tforeach mod [lsort $modules] {
            |<--
            <li>
            [$ehtml eval [list xref $mod]]: $module($mod)
            [tif {[info exists submodule($mod)]} {
                |<--
                [indexlist $submodule($mod)]
            }]
            </li>
            
        }]
        </ul>
    }

    #-------------------------------------------------------------------
    # Helpers

    proc textToID {text} {
        # First, trim any white space and convert to lower case
        set text [string trim [string tolower $text]]
        
        # Next, substitute "_" for internal whitespace, and delete any
        # non-alphanumeric characters (other than "_", of course)
        regsub -all {[ ]+} $text "_" text
        regsub -all {[^a-z0-9_/]} $text "" text
        
        return $text
    }

}






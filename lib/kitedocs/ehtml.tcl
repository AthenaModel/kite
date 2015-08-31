#-----------------------------------------------------------------------
# TITLE:
#    ehtml.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kitedocs(n) Package: ehtml(5) macro set
#
#    This module implements a macroset(i) extension for use with
#    macro(n).
#
#-----------------------------------------------------------------------

namespace eval ::kitedocs:: {
    namespace export ehtml
}

#-----------------------------------------------------------------------
# ehtml ensemble

snit::type ::kitedocs::ehtml {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Lookup Tables

    # css: Standard ehtml(5) CSS
    typevariable css {
        A {
            text-decoration: none;
        }

        TABLE {
            margin-top:    4px;
            margin-bottom: 4px;
        }

        TR {
            vertical-align: baseline;
        }

        TH {
            padding-left: 4px;
        }

        TD {
            padding-left: 4px;
        }

        /* Table Formatting Classes: "pretty" 
         * Border around the outside, even/odd striping, no internal
         * border lines.
         */
        TABLE.pretty {
            border: 1px solid black;
            border-spacing: 0;
        }

        TABLE.pretty TR.header {
            font-weight: bold;
            color: white;
            background-color: #000099;
        }

        TABLE.pretty TR.oddrow {
            color: black;
            background-color: white;
        }

        TABLE.pretty TR.evenrow {
            color: black;
            background-color: #EEEEEE;
        }

        /* Examples, listings, and marks */
        PRE.example {
            background:     #FFFDD1 ;
            border:         1px solid blue;
            padding-top:    2px;
            padding-bottom: 2px;
            padding-left:   4px;
        }

        PRE.listing {
            background:     #FFFDD1 ;
            border:         1px solid blue;
            padding-top:    4px;
            padding-bottom: 4px;
            padding-left:   4px;
        }

        SPAN.linenum {
            background:     #E3E08F ;
        }

        DIV.mark {
            display: inline;
            font-family: Verdana;
            font-size: 75%;
            background: black;
            color: white;
            border: 1px solid black;
            border-radius: 5px;
            padding-left: 2px;
            padding-right: 2px;
        }

        DIV.bigmark {
            display: inline;
            font-family: Verdana;
            font-size: 100%;
            background: black;
            color: white;
            border: 1px solid black;
            border-radius: 5px;
            padding-left: 2px;
            padding-right: 2px;
        }

        /* Topic Lists. */
        TR.topic {
            vertical-align: baseline;
        }

        TR.topicname {
            min-width: 1.5em;
        }

    }
    

    #-------------------------------------------------------------------
    # Configuration Type Variables

    # config: configuration array
    #
    # docroot - While processing an input string, the relative path
    #           to the root of the current documentation tree, i.e.,
    #           the parent path of the local man page directories.
    #           If docroot is "", docroot-based xrefs are disallowed.
    #
    # doctypes - Document file types recognized by <xref>.

    typevariable config -array {
        docroot  ""
        doctypes {
            .html .htm .txt .text .md .docx .xlsx .pptx .pdf
        }
    }

    #-------------------------------------------------------------------
    # Transient Data
    #
    # These variables are copied into the macro interpreter by 
    # "::ehtml install", which is called on every macro(n) "reset", i.e., 
    # initially and before processing each subsequent document.

    # trans array
    #
    #   dlstack   -  Stack of nested deflist names.  The "end" is the
    #                top of the stack.
    #   itemLists -  Dictionary, lists of item names by deflist name
    #   itemText  -  Dictionary, item display text by item name
    #   optsFor   -  Dictionary, lists of option names by item name
    #   optText   -  Dictionary, option text by option name
    #   lastItem  -  The last item seen; used to relate options to
    #                items.

    typevariable trans {
        dlstack   {}
        itemLists {}
        itemText  {}
        optsFor   {}
        optText   {}
        lastItem  ""
    }
    
    #-------------------------------------------------------------------
    # Public Methods

    # install macro
    #
    # macro   - The macro(n) instance
    #
    # Installs macros into the the macro(n) instance, and resets 
    # transient data.

    typemethod install {macro} {
        # FIRST, save the config data.
        $macro eval [list array set ::ehtml [array get config]]
        $macro eval [list array set ::trans $trans]

        # NEXT, define HTML equivalents.
        StyleMacro $macro b
        StyleMacro $macro i
        StyleMacro $macro code
        StyleMacro $macro tt
        StyleMacro $macro em
        StyleMacro $macro strong
        StyleMacro $macro sup
        StyleMacro $macro sub
        StyleMacro $macro pre
        StyleMacro $macro h1
        StyleMacro $macro h2
        StyleMacro $macro h3
        StyleMacro $macro h4
        StyleMacro $macro h5
        StyleMacro $macro h6

        HtmlTag $macro blockquote /blockquote
        HtmlTag $macro ol /ol
        HtmlTag $macro ul /ul
        HtmlTag $macro li /li
        HtmlTag $macro p /p
        HtmlTag $macro table /table
        HtmlTag $macro tr /tr
        HtmlTag $macro th /th
        HtmlTag $macro td /td
        HtmlTag $macro br

        $macro proc img {attrs} { return "<img $attrs>" }

        # NEXT, define basic macros.
        $macro proc hrule {} { return "<p><hr><p>" }
        $macro proc lb    {} { return "&lt;"       }
        $macro proc rb    {} { return "&gt;"       }

        $macro proc tag {name {arglist ""}} {
            if {$arglist ne ""} {
                return "[tt][lb]$name [expand $arglist][rb][/tt]"
            } else {
                return "[tt][lb]$name[rb][/tt]"
            }
        }

        $macro template link {url {anchor ""}} {
            if {$anchor eq ""} {
                set anchor $url
            }
        } {<a href="$url">$anchor</a>}

        $macro proc nbsp {text} {
            set text [string trim $text]
            regsub {\s\s+} $text " " text
            return [string map {" " &nbsp;} $text]
        }

        $macro proc quote {text} {
            string map {& &amp; < &lt; > &gt;} $text
        }


        $macro proc textToID {text} {
            # First, trim any white space
            set text [string trim $text]
            
            # Next, substitute "_" for internal whitespace
            regsub -all {[ ]+} $text "_" text
            
            return $text
        }


        # NEXT, cross-references        
        $macro proc xrefset {id anchor url} {
            variable xreflinks

            set xreflinks($id) [dict create id $id anchor $anchor url $url]
            
            # Return the link.
            return [xref $id]
        }


        $macro proc xref {id {anchor ""}} {
            variable xreflinks
            variable ehtml

            if {[pass] == 1} {
                return
            }

            set url ""

            # FIRST, is it an explicit xrefset?
            if {[info exists xreflinks($id)]} {
                set url [dict get $xreflinks($id) url]

                if {$anchor eq ""} {
                    set anchor [dict get $xreflinks($id) anchor]
                }

                return [link $url $anchor]
            }

            # NEXT, it may be a reference based on docroot.
            if {$ehtml(docroot) ne ""} {
                # FIRST, get the root.  If the ID begins with "<project>:" 
                # assume that "<project>" is the name of a sibling project
                # hosted in the same directory as this project.
                set relroot $ehtml(docroot)

                if {[regexp {^([^:]+):(.*)$} $id dummy sibling id]} {
                    # Assume the xref is in a sibling project.
                    set relroot $relroot/../../$sibling/docs
                }

                # NEXT, is it a man page?
                if {[regexp {^([^()]+)\(([1-9a-z]+)\)$} $id \
                         dummy name section]
                } {
                    set url $relroot/man$section/$name.html

                    if {$anchor ne ""} {
                        append url "#[textToID $anchor]"
                    } else {
                        set anchor "${name}($section)"                    
                    }

                    return [link $url $anchor]
                }

                # NEXT, does it look like a doc file?
                set idx [string last . $id]

                if {$idx != -1} {
                    set ext [string tolower [string range $id $idx end]]

                    if {$ext in $ehtml(doctypes)} {
                        set idlist [split $id /]

                        set url $relroot/[join $idlist /]

                        if {$anchor eq ""} {
                            set anchor $id
                        }

                        return [link $url $anchor]
                    }
                }
            }

            # NEXT, we don't know what it is.
            macro warn "xref: unknown xrefid '$id'"
            return "[b][tag xref $id][/b]"
        }

        # NEXT, define definition list macros.
        $macro proc deflist {args}  {
            variable trans
            lappend trans(dlstack) $args

            return "<dl>" 
        }

        $macro proc /deflist {args} {
            variable trans
            set trans(dlstack) [lrange $trans(dlstack) 0 end-1]

            return "</dl>" 
        }

        $macro template def {text} {
            set text [expand $text]
        } {
            |<--
            <dt><b>$text</b></dt>
            <dd>
        }

        $macro template defitem {item text} {
            variable trans
            set text [expand $text]
            set trans(lastItem) $item

            if {[macro pass] == 1} {
                dict lappend trans(itemLists) * $item

                foreach listname $trans(dlstack) {
                    if {$listname ne ""} {
                        dict lappend trans(itemLists) $listname $item
                    }
                }

                dict set trans(itemText) $item $text
            }
        } {
            |<--
            <dt><b><tt><a name="[textToID $item]">$text</a></tt></b></dt>
            <dd>      
        }

        $macro template defopt {text} {
            variable trans

            set opt [lindex $text 0]
            set id "$trans(lastItem)$opt"
            set text [expand $text]

            if {[macro pass] == 1} {
                dict lappend trans(optsFor) $trans(lastItem) $opt
                dict set trans(optText) $id $text
            }
        } {
            |<--
            <dt><b><tt><a name="$id">$text</a></tt></b></dt>
            <dd>
        }

        # iref args
        #
        # args    An item ID, which might be multiple tokens.
        #
        # Creates a link to the item in this page.

        $macro proc iref {args} {
            variable trans

            set tag $args

            if {[macro pass] == 1} {
                return
            }

            if {[dict exists $trans(itemText) $tag]} {
                return "<tt><a href=\"#[textToID $tag]\">$tag</a></tt>"
            } else {
                macro warn "iref not found, '$tag'"
                return "<tt>$tag</tt>"
            }
        }

        $macro proc itag {args} {
            return "[tt][lb][iref {*}$args][rb][/tt]"
        }


        $macro template itemlist {{listname *}} {
            variable trans

            set items [list]

            if {[macro pass] == 2} {
                if {[dict exists $trans(itemLists) $listname]} {
                    set items [dict get $trans(itemLists) $listname]
                }
            }
        } {
            |<--
            [tforeach tag $items {
                |<--
                <tt><a href="#[textToID $tag]">[dict get $trans(itemText) $tag]</a></tt><br>
                [tif {[dict exists $trans(optsFor) $tag]} {
                    |<--
                    [tforeach opt [dict get $trans(optsFor) $tag] {
                        |<--
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <tt><a href="#$tag$opt">[dict get $trans(optText) $tag$opt]</a></tt><br>
                    }]
                }]
            }]<p>
        }


        # Topic Lists

        $macro template topiclist {{h1 Topic} {h2 Description}} {
            variable itemCounter
            set itemCounter 0
        } {
            |<--
            <table class="pretty">
            <tr class="header">
            <th align="left">$h1</th> 
            <th align="left">$h2</th>
            </tr>
        }

        $macro template topic {topic} {
            variable itemCounter
            if {[incr itemCounter] % 2 == 0} {
                set rowclass evenrow
            } else {
                set rowclass oddrow
            }
        } {
            |<--
            <tr class="$rowclass" valign="baseline">
            <td>$topic</td>
            <td>
        }

        $macro template /topic {} {
            |<--
            </td>
            </tr>
        }
        
        # /topiclist
        #
        # Terminates a topic list.

        $macro template /topiclist {} {
            |<--
            </table>
        }


        # Examples, listings, and marks
        
        $macro proc example  {} { return "<pre class=\"example\">" }
        $macro proc /example {} { return "</pre>" }


        $macro proc listing {{firstline 1}} {
            # FIRST, push the context.
            macro cpush listing
            macro cset firstline $firstline

            return
        }

        $macro proc /listing {} {
            # FIRST, get the first line number.
            set firstline [macro cget firstline]

            # NEXT, pop the context.
            set text [string trim [macro cpop listing]]

            # NEXT, number the lines!
            set codelist [list "<pre class=\"listing\">"]

            set i $firstline
            foreach line [split $text \n] {
                set line [format "<span class=\"linenum\">%04d</span> %s" \
                                $i $line]
                lappend codelist $line
                incr i
            }

            lappend codelist "</pre>"

            return "[join $codelist \n]\n"
        }

        $macro proc mark {symbol} { 
            return "<div class=\"mark\">$symbol</div>" 
        }

        $macro proc bigmark {symbol} { 
            return "<div class=\"bigmark\">$symbol</div>"
        }

        # NEXT, define changelog macros
        $macro template changelog {} {
            variable changeCounter
            set changeCounter 0
        } {
            |<--
            <table class="pretty" width="100%" cellpadding="5" cellspacing="0">
            <tr class="header">
            <th align="left" width="10%">Status</th>
            <th align="left" width="70%">Nature of Change</th>
            <th align="left" width="10%">Date</th>
            <th align="left" width="10%">Initiator</th>
            </tr>
        }

        $macro proc /changelog {} { return "</table><p>" }

        $macro proc change {date status initiator} {
            macro cpush change
            macro cset date      [nbsp $date]
            macro cset status    [nbsp $status]
            macro cset initiator [nbsp $initiator]
            return
        }

        $macro template /change {} {
            variable changeCounter

            if {[incr changeCounter] % 2 == 0} {
                set rowclass evenrow
            } else {
                set rowclass oddrow
            }

            set date        [macro cget date]
            set status      [macro cget status]
            set initiator   [macro cget initiator]

            set description [macro cpop change]
        } {
            |<--
            <tr class="$rowclass" valign=top>
            <td>$status</td>
            <td>$description</td>
            <td>$date</td>
            <td>$initiator</td>
            </tr>
        }

        # NEXT,  Define Procedure Macros

        $macro template procedure {} {
            variable procedureCounter
            set procedureCounter 0
        } {
            |<--
            <table border="1" cellspacing="0" cellpadding="2">
        }

        $macro template step {} {
            variable procedureCounter
            incr procedureCounter
        } {
            |<--
            <tr valign="top">
            <td><b>$procedureCounter.</b></td>
            <td>
        }

        $macro proc /step/     {} { return "</td><td>"  }
        $macro proc /step      {} { return "</td></tr>" }
        $macro proc /procedure {} { return "</table>"   }
    }

    # css
    #
    # Return standard ehtml(5) CSS styles.

    typemethod css {} {
        return $css
    }

    #-------------------------------------------------------------------
    # Configuration

    # configure opt val
    #
    # opt - A configuration value
    # val - Its value
    #
    # The configuration option is added to the config array, which
    # is copied to the "ehtml" array in the macro interpreter on 
    # reset.
    #
    # The key name in the config/ehtml array is the option name minus
    # the hyphen.
    #
    # The following options are available:
    #
    # -docroot   - This is the relative path from the document file
    #              being processed to the root of the documentation
    #              tree.  This is used by xref.
    #
    # -doctypes  - List of document file extensions recognized by
    #              xref.

    typemethod configure {opt val} {
        switch -exact -- $opt {
            -docroot  { set config(docroot)  $val        }
            -doctypes { set config(doctypes) $val        }
            default   { error "Unknown option: \"$opt\"" }
        }

        return
    }

    #-------------------------------------------------------------------
    # Macro Definition Helpers
    

    # HtmlTag macro tag
    #
    # macro     - The macro processor
    # tag       - An html tag name, e.g,. "p"
    # closetag  - The matching close tag, or ""
    #
    # Translates the tag macro back to the equivalent HTMl tag.

    proc HtmlTag {macro tag {closetag ""}} {
        $macro proc $tag {} [format { 
            return "<%s>" 
        } $tag]

        if {$closetag ne ""} {
            $macro proc $closetag {} [format { 
                return "<%s>" 
            } $closetag]
        }
    }

    # StyleMacro macro tag
    #
    # macro - The macro processor
    # tag   - A tag: i, b, pre, etc.
    #
    # Defines a style macro, e.g., <i>...</i> or <i ...>.

    proc StyleMacro {macro tag} {
        $macro proc $tag {args} [format {
            if {[llength $args] == 0} {
                return "<%s>"
            } else {
                return "<%s>$args</%s>"
            }
        } $tag $tag $tag]

        $macro proc /$tag {} [format { 
            return "</%s>" 
        } $tag]
    }

}


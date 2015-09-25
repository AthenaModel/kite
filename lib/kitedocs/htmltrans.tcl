#-----------------------------------------------------------------------
# TITLE:
#   htmltrans.tcl
#
# AUTHOR:
#   Will Duquette
#
# PROJECT:
#   Kite - Tcl Project Management Tool
#
# DESCRIPTION:
#   kitedocs(n) Package: htmltrans(n) HTML Transformation toolkit.
#
#   This module provides tools for transforming HTML and HTML-like
#   files.
#
#-----------------------------------------------------------------------

namespace eval ::kitedocs:: {
    namespace export htmltrans
}

snit::type ::kitedocs::htmltrans {
    pragma -hasinstances no

    #-------------------------------------------------------------------
    # Type Variables

    # braceMap
    #
    # string map mapping to reconvert HTML entities back to braces.

    typevariable braceMap {
        &#123; \{ &#125; \}
    }

    # tagmeta
    #
    # HTML tag metadata
    #
    #   context    - Dictionary of contexts by tag name
    #   single     - Tags with has no closing tag

    typevariable tagmeta -array {
        context {}
        single {
            !DOCTYPE !--
            area base basefont br col embed hr img input keygen link meta
            param source track wbr
        }
    }

    # containers
    #
    # For "item" tags, the tags they can be contained in.
    typevariable containers {
        dd dl
        dt dl
        li {ol ul}
        td tr
        th tr
        tr {table thead tfoot tbody}
    }


    # bycontext
    #
    # HTML tags by context
    #
    #   BLOCK      - Tag introduces BLOCK context
    #   OPAQUE     - Tag begins an opaque element
    #   PARAGRAPH  - Explicitly begin paragraph
    #   PROSE      - Tag can be used in prose without changing context
    #   STRUCTURAL - Tag introduces STRUCTURE context
    #   TEXTONLY   - Tag introduces TEXTONLY context
    #   TEXTBLOCK  - Tag introduces TEXTBLOCK context

    typevariable bycontext -array {
        BLOCK {
            article aside body details dialog figure footer form frame
            main noframes noscript section
        }

        OPAQUE {
            applet audio area base basefont button canvas col colgroup
            datalist embed head hr iframe img input keygen link map menu
            menuitem meta object optgroup option output param pre progress
            rp rt ruby script select source style textarea title track
            video
        }

        PARAGRAPH {
            p
        }

        PROSE {
            a abbr acronym address b bdi bdo big br cite code del dfn em
            font i ins kbd mark meter q s samp small span strike strong
            sub sup time tt u var wbr
        }

        STRUCTURAL {
            dir dl fieldset frameset html nav ol table tbody tfoot thead tr
            ul
        }

        TEXTONLY {
            caption dt figcaption h1 h2 h3 h4 h5 h6 label legend
            summary
        }

        TEXTBLOCK {
            blockquote center dd div li td th
        }
    }

    # trans array: transient data

    typevariable trans -array {}

    #-------------------------------------------------------------------
    # Type Constructor

    typeconstructor {
        # FIRST, build the context mapping.
        set tagmeta(context) [dict create]
        foreach context [array names bycontext] {
            foreach tag $bycontext($context) {
                dict set tagmeta(context) $tag $context
            } 
        }
    }
    
    #-------------------------------------------------------------------
    # Parser

    # parse html command
    #
    #   html     - An HTML string
    #   command  - A callback command prefix
    #
    # Parses the html string, calling the given command for each tag
    # and the text following it.  The command is a prefix to which
    # 5 additional arguments will be added:
    #
    #    full   - The complete tag, with attributes and angle brackets
    #    tag    - The tag name, minus slash
    #    slash  - The slash flag, which is 1 for end tags and 0 for 
    #             start tags
    #    attrs  - The unparsed attribute text
    #    text   - The text immediately following the tag's closing
    #             angle bracket, up until the opening bracket of the
    #             next tag.
    #
    # The command is called for pseudotag "hmstart" before the beginning
    # of the real input and for "/hmstart" after; this allows the 
    # command to do special things at the beginning and end of the input.
    #
    # In addition to normal tags, the command also handles the 
    # <tag !DOCTYPE> directive and HTML comments; in the latter case,
    # the "attrs" argument will contain the comment text.
    #
    # Returns the empty string; it is up to the command to save 
    # the text for later use.

    typemethod parse {html command} {
        array unset trans
        set trans(cmd) $command
        namespace eval :: [ToScript $html]
        return
    }

    # ToScript html
    #
    # Converts the HTML text into a script you can execute

    proc ToScript {html} {
        # FIRST, convert characters that will cause us trouble.
        set html [string map \
            [list "\{" "&#123;" "\}" "&#125;" "\\" "&#92;"] $html]

        # NEXT, Convert tags to commands.
        set t [myproc TagCmd]
        set sub "\}\n${t} {\\2} {\\1} {\\3} \{"
        regsub -all -- {<()(!DOCTYPE)\s*([^>]*)>} $html $sub html
        regsub -all -- {<()(!--)(.*?)-->} $html $sub html
        regsub -all -- {<(/?)([^\s>]+)\s*([^>]*)>} $html $sub html


        set start "${t} {hmstart} {} {} \{"
        set end   "\}\n${t} {hmstart} {/} {} {}"

        return "$start$html$end"
    }

    # TagCmd tag slash attrs text
    #
    # tag    - The HTML tag name, !DOCTYPE, or !--
    # slash  - "/" or ""
    # attrs  - Tag attribute text, unparsed
    # text   - Text following the ">", up until the next HTML tag.
    #
    # This command is called once for each HTML tag in the input;
    # it recomputes the "full" formatted tag, (more or less)
    # as it would have appeared in the input, the slash flag, and
    # undoes the parser's brace mapping; then calls the user's
    # callback.

    proc TagCmd {tag slash attrs text} {
        if {$tag eq "hmstart"} {
            set full ""
        } elseif {$tag eq "!--"} {
            set full "<$tag$attrs-->"
        } elseif {$attrs ne ""} {
            set full "<$slash$tag $attrs>"
        } else {
            set full "<$slash$tag>"
        }

        set slash [expr {$slash eq "/"}]
        set text [string map $braceMap $text]

        uplevel #0 [list $trans(cmd) $full $tag $slash $attrs $text]
    }

    # script html
    #
    # Transforms the HTML text into a script that can be executed to
    # parse the input, TagCmd by TagCmd.  It's made public to ease
    # testing.

    typemethod script {html} {
        return [ToScript $html]
    }

    # Swallow args...
    #
    # Swallows its arguments, returning nothing.  Used as a default
    # callback command.

    proc Swallow {args} {}
    

    #-------------------------------------------------------------------
    # fix: Clean up HTML, closing open elements.
    
    # fix html
    #
    # Cleans up HTML text, closing open elements.

    typemethod fix {html} {
        array unset trans

        set trans(output)  ""
        set trans(stack) {}

        $type parse $html [myproc Fixer]

        return $trans(output)
    }

    # Fixer full tag slash params text
    #
    # full   - The full text from the input
    # tag    - The element name
    # slash  - "" if it's a closing tag, "" otherwise.
    # attrs - Unparsed element attribute list
    # text   - Text following the element, up to the next element.
    #
    # Adds the element and text to the output, handling context and
    # closing tags.

    proc Fixer {full tag slash attrs text} {
        # FIRST, Handle closing tags.
        if {$slash} {
            # FIRST, close tags back to the matching open tag.
            # If there is none, throw an error.
            set last [lpop trans(stack)]
            
            while {$last ne $tag} {
                if {$last eq ""} {
                    throw {SYNTAX UNOPENED} \
                        "Closing tag with no opening tag: $full"
                }
                Emit "</$last>"
                set last [lpop trans(stack)]
            }

            # NEXT, don't emit /hmstart.
            if {$tag ne "hmstart"} {
                Emit "$full"
                Emit "$text"
            }

            return
        }

        # NEXT, single tags 
        if {[issingle $tag]} {
            Emit $full
            Emit $text
            return
        }

        # NEXT, if this tag is a list item, make sure previous items
        # are closed.
        set clist [containers $tag]

        if {[llength $clist] > 0} {
            set last [lindex $trans(stack) end]

            while {$last ni $clist} {
                lpop trans(stack)
                if {$last eq ""} {
                    throw {SYNTAX MISPLACED} "Item tag with no container: $full"                    
                }

                Emit "</$last>"
                set last [lindex $trans(stack) end]
            }
        }

        # NEXT, push the opening item on the stack.
        lpush trans(stack) $tag

        if {$tag ne "hmstart"} {
            Emit $full            
        }
        Emit "$text"
    }

    # Emit args
    #
    # Append the arguments to the output.

    proc Emit {args} {
        append trans(output) {*}$args
    }

    #-------------------------------------------------------------------
    # Paragraph Detection: Insert <p>...</p> tags where they are needed,
    # based on document structure and blank lines in prose.

    # para html
    #
    # html   - HTML input.
    #
    # Detects paragraphs and inserts <p>...</p> tags where needed.
    # The elements must all be properly closed; run 'fix' first if 
    # need be.

    typemethod para {html} {
        array unset trans

        set trans(output)    ""
        set trans(stack)     [list]

        dbg "===Start====================================="
        $type parse $html [myproc Paragrapher]

        dbg "===End======================================="
        return $trans(output)
    }

    # Paragrapher full tag slash attrs text
    #
    # full   - The full text of the tag
    # tag    - The element name
    # slash  - 1 if it's a closing tag, "" otherwise.
    # attrs - Unparsed element attribute list
    # text   - Text following the element, up to the next element.
    #
    # Adds the <p></p> tags as needed.

    proc Paragrapher {full tag slash attrs text} {
        if {$tag eq "hmstart"} {
            if {!$slash} {
                lpush trans(stack) {tag hmstart context BLOCK output ""}
            } else {
                while {[Start] ne "hmstart"} {
                    CPop
                }
                set trans(output) [COutput]
            }
        } elseif {$tag in {"!DOCTYPE" "!--"}} {
            CEmit $full
        } elseif {![isknown $tag]} {
            throw {SYNTAX UNKNOWN} "Unknown HTML tag: \"$full\""
        } else {
            ParaTag $full $tag $slash $attrs
        }

        if {$text ne ""} {
            ParaText $text
        }
    }


    proc ParaTag {full tag slash attrs} {
        dbg "PTag  [Context] $full"
        set ctx    [contextof $tag]

        switch -exact -- [Context] {
            BLOCK {
                # FIRST, if this is a closing tag it has to match
                # the start tag.  The context has been closed, so
                # pop it off the stack.
                if {$slash} {
                    if {$tag ne [Start]} {
                        throw {SYNTAX MISPLACED} \
                            "Unclosed <[Start]> in $full"
                    }
                    CPop
                    return
                }

                # NEXT, we have a new tag, and it will determine
                # the new context.

                # If it's a prose tag we're starting a new paragraph
                if {[isprose $tag]} {
                    CPush p {}
                    CEmit $full
                    return
                }

                # Otherwise, it can be anything; push it on the stack.
                CPush $tag $attrs
                return
            }

            OPAQUE {
                # In OPAQUE context, we simply copy everything to the
                # output unchanged until we get to the closing tag.
                # If we get a new start tag that matches the original
                # start tag, push a new context so we don't get
                # confused.
                if {$tag eq [Start]} {
                    if {$slash} {
                        CPop
                    } else {
                        CPush $tag $attrs
                    }
                } else {
                    CEmit $full
                }
                return
            }

            PARAGRAPH {
                # In PARAGRAPH context, we copy input to output
                # unless we see a non-prose tag or an explicit
                # termination.

                # FIRST, if it's a prose tag just copy it to the
                # output.
                if {[isprose $tag]} {
                    CEmit $full
                    return
                }

                # NEXT, close the paragraph if it's explicitly
                # closed.
                if {$slash && $tag eq "p"} {
                    CPop
                    return
                }

                # NEXT, it's a non-prose tag; whether it's an
                # opener or a closer, the paragraph is over.
                # Close the paragraph, and then handle the tag
                # in the containing context.
                CPop
                CEmit \n\n
                ParaTag $full $tag $slash $attrs
                return
            }

            STRUCTURAL {
                # In STRUCTURAL context we should have no
                # prose tags.  Otherwise we just  push and pop the
                # context on and off the stack; there's nothing 
                # else to do.

                if {[isprose $tag]} {
                    throw {SYNTAX MISPLACED} \
                        "Prose tag in structural context: $full in <[Start]>"
                }

                if {$slash} {
                    CPop
                } else {
                    CPush $tag $attrs
                }
                return
            }

            TEXTONLY {
                # In TEXTONLY context, only prose tags are allowed.
                # Just copy input to output, closing the context
                # if appropriate.

                if {[isprose $tag]} {
                    CEmit $full
                    return
                }

                if {$slash && $tag eq [Start]} {
                    CPop
                    return
                }

                throw {SYNTAX MISPLACED} \
                    "Non-prose tag in text-only context: $full in <[Start]>"
                return
            }

            TEXTBLOCK {
                # In TEXTBLOCK context, we're going to have either a
                # single paragraph's worth of text, like a TEXTONLY,
                # or we're going to switch to BLOCK mode.

                # Just emit prose tags.
                if {[isprose $tag]} {
                    CEmit $full
                    return
                }

                # If we're closing this textblock, that's fine
                if {$slash && $tag eq [Start]} {
                    CPop
                    return
                }

                # Otherwise, we're converting to block context.  Handle
                # this tag in the new context.
                CBlock
                ParaTag $full $tag $slash $attrs
                return
            }

            default {
                error "Unknown context: \"[Context]\""
            }
        }
    }

    proc ParaText {text} {
        # FIRST, handle the text according to the context.
        set isWhite [expr {[string trim $text] eq ""}]

        dbg "PText [Context] <$text>"
        switch -exact -- [Context] {
            BLOCK {
                # In BLOCK context, non-whitespace text takes us to 
                # PARAGRAPH context.  Whitespace is simply retained.
                if {!$isWhite} {
                    CEmit \n
                    CPush p ""
                    CEmit [string trimleft $text]
                } else {
                    CEmit $text
                }
                
                return
            }

            OPAQUE     -
            PARAGRAPH  -
            STRUCTURAL -
            TEXTONLY   -
            TEXTBLOCK  {
                # In these contexts, text is simply retained.
                CEmit $text
                return
            }

            default {
                error "Unknown context: \"[Context]\""
            }
        }
    }

    # CEmit args
    #
    # Adds the args as output to the current context.

    proc CEmit {args} {
        dbg "CEmit $args"
        set record [lindex $trans(stack) end]

        dict with record {
            append output {*}$args
        }

        lset trans(stack) end $record
    }

    # CPush tag attrs
    #
    # Pushes a new context on the stack.

    proc CPush {tag attrs} {
        dbg "CPush $tag [contextof $tag] $attrs"

        # FIRST, emit the tag into the containing context.
        CEmit [fmttag $tag "" $attrs]

        # NEXT, if there's no end tag we're done.
        if {[issingle $tag]} {
            return
        }

        # NEXT, build the context record.
        dict set record tag     $tag
        dict set record context [contextof $tag]
        dict set record output  ""

        # NEXT, push the context record on the stack
        lpush trans(stack) $record
    }

    # CPop
    #
    # Pops the context from the stack.

    proc CPop {} {
        dbg "CPop [Start]"

        set record [lpop trans(stack)]

        dict with record {
            if {$context eq "PARAGRAPH"} {
                CEmit [InternalParagraphs $output]
            } elseif {$context eq "TEXTBLOCK"} {
                set paragraphed [InternalParagraphs $output]

                if {$paragraphed eq $output} {
                    CEmit $output
                } else {
                    CEmit "<p>$paragraphed</p>\n"
                }
            } else {
                CEmit $output
            }
            CEmit "</$tag>"
        }
    }

    # COutput
    #
    # Returns the output at the current context.

    proc COutput {} {
        dict get [lindex $trans(stack) end] output
    }

    # CBlock
    #
    # Convert TEXTBLOCK context to BLOCK context.

    proc CBlock {} {
        dbg "CBlock"
        set record [lindex $trans(stack) end]

        dict with record {
            assert {$context eq "TEXTBLOCK"}
            set context BLOCK

            if {[string trim $output] ne ""} {
                set output "<p>[InternalParagraphs $output]</p>"
            }
        }

        lset trans(stack) end $record
    }

    # Context
    #
    # Returns the current context.

    proc Context {} {
        dict get [lindex $trans(stack) end] context
    }

    # Start
    #
    # Returns the tag that started the current context.

    proc Start {} {
        dict get [lindex $trans(stack) end] tag
    }

    # HasContent
    #
    # Returns 1 if the current context has non-whitespace output,
    # and 0 otherwise.

    proc HasContent {} {
        iswhite [dict get [lindex $trans(stack) end] output]
    }

    # InternalParagraphs text
    #
    # Given a block of text, inserts "</p>\n\n<p>" in place of any internal
    # blank lines.

    proc InternalParagraphs {text} {
        regsub -all {(\S)\s*\n\s*\n\s*(\S)} $text "\\1</p>\n\n<p>\\2"
    }


    #-------------------------------------------------------------------
    # General Helpers

    # fmttag tag slash params
    #
    # Given the parser arguments, reproduce the tag.

    proc fmttag {tag slash params} {
        if {$slash eq "/"} {
            return "</$tag>"
        } else {
            set out "<$tag"
            if {$params ne ""} {
                append out " " $params
            }
            append out ">"

            return $out
        }
    }
    
    #-------------------------------------------------------------------
    # Predicates

    # contextof tag
    #
    # Returns the tag's context.

    proc contextof {tag} {
        dict get $tagmeta(context) $tag
    }

    # isknown tag
    #
    # Returns 1 if the tag is known to the module, and 0 otherwise.

    proc isknown {tag} {
        dict exists $tagmeta(context) $tag
    }

    # issingle tag
    #
    # Returns 1 if the tag takes no closing tag.

    proc issingle {tag} {
        expr {$tag in $tagmeta(single)}
    }

    # isprose tag
    #
    # Returns 1 if the tag can be used in prose without changing the
    # context.

    proc isprose {tag} {
        expr {[dict get $tagmeta(context) $tag] eq "PROSE"}
    }

    # iswhite text
    #
    # Returns 1 if the text is all whitespace, and 0 otherwise.

    proc iswhite {text} {
        expr {[string trim $text] eq ""}
    }

    # containers tag
    #
    # tag   - An arbitrary tag
    #
    # If the tag represents an item in a container (e.g., an li in 
    # a ul or a tr in a tbody), returns the list of valid container tags.
    # Otherwise, returns the empty string.

    proc containers {tag} {
        if {[dict exists $containers $tag]} {
            return [dict get $containers $tag]
        } else {
            return ""
        }
    }

    #-------------------------------------------------------------------
    # Debugging Output

    proc dbg {text} {
        # Uncomment for debugging trace
        # puts $text
    }
}

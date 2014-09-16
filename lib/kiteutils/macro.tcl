#-----------------------------------------------------------------------
# TITLE:
#    macro.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n) Package: macro processor
#
#    This module pairs a textutil::expander object with a 
#    smartinterp(5) to process Tcl-based macros safely.
#
#-----------------------------------------------------------------------

namespace eval ::kiteutils:: {
    namespace export macro
}

#-----------------------------------------------------------------------
# macro ensemble

snit::type ::kiteutils::macro {
    #-------------------------------------------------------------------
    # Components

    component interp ;# The smartinterp for macros

    delegate method alias       to interp
    delegate method ensemble    to interp
    delegate method eval        to interp
    delegate method proc        to interp
    delegate method smartalias  to interp

    component exp    ;# The textutil::expander

    delegate method cget        to exp
    delegate method cis         to exp
    delegate method cname       to exp
    delegate method cpop        to exp
    delegate method cpush       to exp
    delegate method cset        to exp
    delegate method cvar        to exp
    delegate method errmode     to exp
    delegate method expandonce  to exp as expand
    delegate method lb          to exp
    delegate method rb          to exp
    delegate method setbrackets to exp
    delegate method where       to exp

    #-------------------------------------------------------------------
    # Type Variables

    # info Array, for scalars
    #
    #  pass      The pass number, 1 or 2 (while expanding, only)

    variable info -array {
        pass      1
        macrosets {}
    }

    #-------------------------------------------------------------------
    # Constructor

    # constructor
    #
    # Initialize the object.

    constructor {} {
        # FIRST, create the expander
        install exp using textutil::expander ${selfns}::exp

        # NEXT, macros appear in angle brackets by default.
        $exp setbrackets "<" ">"

        # NEXT, create the smartinterp
        set interp ""
        $self reset

    }

    #-------------------------------------------------------------------
    # Public Methods

    # reset
    #
    # Re-initializes the interpreter.

    method reset {} {
        # FIRST, reset the interpreter.
        if {$interp ne ""} {
            $interp destroy
        }

        install interp using smartinterp ${selfns}::interp \
            -cli     no                                    \
            -trusted no

        $exp evalcmd [list $interp eval]

        # NEXT, register the default macros
        $self RegisterMacros

        # NEXT, register the macro sets.
        foreach macroset $info(macrosets) {
            callwith $macroset install $self
        }
    }

    # register macroset
    #
    # macroset   - The name (or prefix) of a macroset(i) macro set.
    #
    # Registers a macro set with the macro object.  The registration
    # takes effect at the next reset.

    method register {macroset} {
        ladd info(macrosets) $macroset
    }

    # expand text
    #
    # text    A text string
    #
    # Expands a text string in two passes.

    method expand {text} {
        # Pass 1 -- for indexing
        set info(pass) 1
        $exp expand $text

        # Pass 2 -- for output
        set info(pass) 2
        return [$exp expand $text]
    }

    # expandfile name
    #
    # name    An input file name
    #
    # Process a file and return the expanded output.

    method expandfile {name} {
        $self expand [readfile $name]
    }

    # pass
    #
    # Returns the current pass number

    method pass {} {
        return $info(pass)
    }

    method template {name arglist initbody {template ""}} {
        $interp eval [list template $name $arglist $initbody $template]
    }

    #-------------------------------------------------------------------
    # Macro Registration


    # RegisterMacros
    #
    # Registers the base set of macros.

    method RegisterMacros {} {
        # expand
        $interp smartalias expand 1 1 {text} \
            [mymethod expandonce]


        # lb
        $interp proc lb {} { return "<"}

        # macro
        $interp smartalias macro 1 - {subcommand ?args...?} \
            $self

        # pass
        $interp smartalias pass 0 0 {} \
            [mymethod pass]

        # rb
        $interp proc rb {} { return ">"}

        # swallow
        $interp proc swallow {body} {
            uplevel 1 $body
            return
        }

        # template
        #
        # This is just template(n)'s "template" command
        $interp proc template {name arglist initbody {template ""}} {
            # FIRST, have we an initbody?
            if {"" == $template} {
                set template $initbody
                set initbody ""
            }

            # NEXT, define the body of the new proc so that the initbody, 
            # if any, is executed and then the substitution is 
            set body "$initbody\n    tsubst [list $template]\n"

            # NEXT, define
            uplevel 1 [list proc $name $arglist $body]
            return
        }

        # tsubst
        #
        # This is just template(n)'s "tsubst" command.
        $interp proc tsubst {tstring} {
            # If the string begins with the indent mark, process it.
            if {[regexp {^(\s*)\|<--[^\n]*\n(.*)$} $tstring dummy leader body]} {

                # Determine the indent from the position of the indent mark.
                if {![regexp {\n([^\n]*)$} $leader dummy indent]} {
                    set indent $leader
                }

                # Remove the ident spaces from the beginning of each indented
                # line, and update the template string.
                regsub -all -line "^$indent" $body "" tstring
            }

            # Process and return the template string.
            return [uplevel 1 [list subst $tstring]]
        }

    }
}


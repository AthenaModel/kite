#-----------------------------------------------------------------------
# TITLE:
#   helptool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(help) {
    usage       {0 1 "?<topic>?"}
    ensemble    helptool
    description "Display this help, or help for a given tool."
    intree      no
}

set ::khelp(help) {
    n/a - The "help" tool is a special case.
}


#-----------------------------------------------------------------------
# tool::help ensemble

snit::type helptool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no
    #-------------------------------------------------------------------
    # Execution

    # execute ?args?
    #
    # Displays the Kite help.

    typemethod execute {argv} {
        set topic [lindex $argv 0]

        if {$topic eq ""} {
            ShowTopicList
        } else {
            ShowTopic $topic
        }
    }

    # ShowTopicList 
    #
    # List all of the help topics (i.e., the tools and their descriptions).

    proc ShowTopicList {} {
        puts "Kite is a tool for working with Tcl projects.\n"

        puts "Several tools are available:\n"

        foreach tool [lsort [array names ::ktools]] {
            array set tdata $::ktools($tool)

            puts [format "%-10s - %s" $tool $tdata(description)]
        }

        puts ""

        puts "Enter 'kite help <topic>' for help on a given topic."

        puts ""

        puts [outdent {
            In addition, 'kite' can be used to execute scripts in
            the context of the current project's code base:

              $ kite myfile.tcl 1 2 3
        }]

        puts ""
    }

    # ShowTopic topic
    #
    # topic  - A help topic (possibly)

    proc ShowTopic {topic} {
        global khelp
        global ktools

        # For "help", all we can do is display the basic help again.
        if {$topic eq "help"} {
            ShowTopicList
            return
        }

        if {[info exists khelp($topic)]} {
            puts "\n"
            if {[info exists ktools($topic)]} {
                lassign [dict get $::ktools($topic) usage] min max argspec

                puts "kite $topic $argspec"
                puts [string repeat - 75]
            }
            puts [outdent $khelp($topic)]
            puts ""
        } else {
            puts "No help is currently available for that topic."
            puts ""
        }
    }
}







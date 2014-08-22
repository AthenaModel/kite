#-----------------------------------------------------------------------
# TITLE:
#   tool_help.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::HELP

tool define help {
    usage       {0 1 "?<topic>?"}
    description "Display this help, or help for a given tool."
    needstree      no
} {
    n/a - The "help" tool is a special case.
} {
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

        foreach tool [lsort [tool names]] {
            puts [format "%-10s - %s" $tool [tool description $tool]]
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

        # For "help", all we can do is display the basic help again.
        if {$topic eq "help"} {
            ShowTopicList
            return
        }

        if {[info exists khelp($topic)]} {
            puts "\n"
            if {[tool exists $topic]} {
                puts [tool usage $topic]
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







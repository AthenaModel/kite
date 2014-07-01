
    proc LinkedTeapots {} {
        set links [eval exec teacup link info [info nameofexecutable]]
        set links [string map {\\ /} $links] 

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

    LinkedTeapots

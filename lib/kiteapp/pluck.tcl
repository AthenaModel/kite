#-----------------------------------------------------------------------
# TITLE:
#   pluck.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Support for "pluckbing" files from an HTTP server.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# pluck ensemble.

snit::type pluck {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Public Methods

    # file fname url
    #
    # fname  - The file name at which to save the pluckbed document.
    # url    - The URL from which to pluck it.
    #
    # Retrieves the contents at the URL, and saves it in the named
    # file.  If there is an http error, or the URL is not found,
    # throws NOTFOUND.

    typemethod file {fname url} {
        # FIRST, retrieve the URL
        try {
            set token [http::geturl $url]
        } on error {result} {
            throw NOTFOUND $result
        }

        # NEXT, if it's not found, throw that.
        if {[http::status $token] ne "ok"} {
            throw NOTFOUND [http::error $token]
        }

        if {[http::ncode $token] != "200"} {
            throw NOTFOUND [http::code $token]
        }

        # NEXT, save the file.  
        #
        # TODO: text/* documents could be saved using 
        # writefile.

        vputs "pluck file: $fname $url"
        set f [open $fname wb]

        try {
            puts -nonewline $f [http::data $token]
        } finally {
            http::cleanup $token
            close $f
       }
    }
}







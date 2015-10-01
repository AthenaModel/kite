#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Kite: utility code used by kite.kit.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

# -kite-provide-start  DO NOT EDIT THIS BLOCK BY HAND
package provide app_kite 0.4.12
# -kite-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -kite-require-start ADD EXTERNAL DEPENDENCIES
package require snit 2.3
package require platform 1.0
package require zipfile::encode 0.3
package require tls 1.6
package require -exact kiteutils 0.4.12
package require -exact kitedocs 0.4.12
# -kite-require-end

# HTTP is always present, and we always want https.
package require http
::http::register https 443 ::tls::socket

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::app_kite:: {
    variable library [file dirname [info script]]
}

namespace import kiteutils::*


#-----------------------------------------------------------------------
# Submodules
#
# Note: modules may be listed in order of dependencies; be careful if you
# change the order!

# Main Routine
source [file join $::app_kite::library main.tcl            ]

# Application Infrastructure
source [file join $::app_kite::library misc.tcl            ]
source [file join $::app_kite::library zipper.tcl          ]
source [file join $::app_kite::library plat.tcl            ]
source [file join $::app_kite::library hook.tcl            ]

# Proxies for Helper Applications
source [file join $::app_kite::library tclsh.tcl           ]
source [file join $::app_kite::library teacup.tcl          ]

# Project Metadata
source [file join $::app_kite::library metadata.tcl        ]

# Tool Infrastructure
source [file join $::app_kite::library deps.tcl            ]
source [file join $::app_kite::library teapot.tcl          ]
source [file join $::app_kite::library docs.tcl            ]
source [file join $::app_kite::library project_macros.tcl  ]

# Project Trees and Subtrees
source [file join $::app_kite::library subtree.tcl         ]
source [file join $::app_kite::library subtree_kiteinfo.tcl]
source [file join $::app_kite::library subtree_proj.tcl    ]
source [file join $::app_kite::library subtree_app.tcl     ]
source [file join $::app_kite::library subtree_pkg.tcl     ]
source [file join $::app_kite::library trees.tcl           ]

# Kite tools (application subcommands)
source [file join $::app_kite::library tool.tcl            ]
source [file join $::app_kite::library tool_add.tcl        ]
source [file join $::app_kite::library tool_build.tcl      ]
source [file join $::app_kite::library tool_clean.tcl      ]
source [file join $::app_kite::library tool_compile.tcl    ]
source [file join $::app_kite::library tool_deps.tcl       ]
source [file join $::app_kite::library tool_dist.tcl       ]
source [file join $::app_kite::library tool_docs.tcl       ]
source [file join $::app_kite::library tool_env.tcl        ]
source [file join $::app_kite::library tool_help.tcl       ]
source [file join $::app_kite::library tool_info.tcl       ]
source [file join $::app_kite::library tool_install.tcl    ]
source [file join $::app_kite::library tool_new.tcl        ]
source [file join $::app_kite::library tool_replace.tcl    ]
source [file join $::app_kite::library tool_run.tcl        ]
source [file join $::app_kite::library tool_shell.tcl      ]
source [file join $::app_kite::library tool_teapot.tcl     ]
source [file join $::app_kite::library tool_test.tcl       ]
source [file join $::app_kite::library tool_version.tcl    ]
source [file join $::app_kite::library tool_wrap.tcl       ]
source [file join $::app_kite::library tool_xfiles.tcl     ]





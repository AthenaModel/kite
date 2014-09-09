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
package provide kiteapp 0.1.6a0
# -kite-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -kite-require-start ADD EXTERNAL DEPENDENCIES
package require snit 2.3
package require platform 1.0
package require zipfile::encode 0.3
package require tls 1.6
package require -exact kiteutils 0.1.6a0
package require -exact kitedocs 0.1.6a0
# -kite-require-end

# HTTP is always present, and we always want https.
package require http
::http::register https 443 ::tls::socket

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::kiteapp:: {
    variable library [file dirname [info script]]
}

namespace import kiteutils::*


#-----------------------------------------------------------------------
# Submodules
#
# Note: modules may be listed in order of dependencies; be careful if you
# change the order!

# Main Routine
source [file join $::kiteapp::library main.tcl            ]

# Application Infrastructure
source [file join $::kiteapp::library misc.tcl            ]
source [file join $::kiteapp::library zipper.tcl          ]
source [file join $::kiteapp::library plat.tcl            ]

# Proxies for Helper Applications
source [file join $::kiteapp::library tclsh.tcl           ]
source [file join $::kiteapp::library teacup.tcl          ]

# Project Metadata
source [file join $::kiteapp::library project.tcl         ]

# Tool Infrastructure
source [file join $::kiteapp::library deps.tcl            ]
source [file join $::kiteapp::library teapot.tcl          ]
source [file join $::kiteapp::library docs.tcl            ]

# Project Trees and Subtrees
source [file join $::kiteapp::library subtree.tcl         ]
source [file join $::kiteapp::library subtree_kiteinfo.tcl]
source [file join $::kiteapp::library subtree_proj.tcl    ]
source [file join $::kiteapp::library subtree_app.tcl     ]
source [file join $::kiteapp::library subtree_pkg.tcl     ]
source [file join $::kiteapp::library trees.tcl           ]

# Kite tools (application subcommands)
source [file join $::kiteapp::library tool.tcl            ]
source [file join $::kiteapp::library tool_add.tcl        ]
source [file join $::kiteapp::library tool_build.tcl      ]
source [file join $::kiteapp::library tool_clean.tcl      ]
source [file join $::kiteapp::library tool_compile.tcl    ]
source [file join $::kiteapp::library tool_deps.tcl       ]
source [file join $::kiteapp::library tool_dist.tcl       ]
source [file join $::kiteapp::library tool_docs.tcl       ]
source [file join $::kiteapp::library tool_env.tcl        ]
source [file join $::kiteapp::library tool_help.tcl       ]
source [file join $::kiteapp::library tool_info.tcl       ]
source [file join $::kiteapp::library tool_install.tcl    ]
source [file join $::kiteapp::library tool_new.tcl        ]
source [file join $::kiteapp::library tool_replace.tcl    ]
source [file join $::kiteapp::library tool_run.tcl        ]
source [file join $::kiteapp::library tool_shell.tcl      ]
source [file join $::kiteapp::library tool_teapot.tcl     ]
source [file join $::kiteapp::library tool_test.tcl       ]
source [file join $::kiteapp::library tool_version.tcl    ]





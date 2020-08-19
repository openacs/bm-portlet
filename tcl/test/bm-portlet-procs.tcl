ad_library {
    Automated tests for the bm-portlet package.

    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 2020-08-19
    @cvs-id $Id$
}

aa_register_case -procs {
        bm_portlet::link
    } -cats {
        api
        production_safe
    } bm_portlet_link {
        Test link proc.
} {
    aa_equals "BM portlet link" "[bm_portlet::link]" ""
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

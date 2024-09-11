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

aa_register_case -procs {
        bm_portlet::add_self_to_page
        bm_portlet::remove_self_from_page
        dotlrn_community::new
    } -cats {
        api
    } bm_portlet_add_remove_from_page {
        Test add/remove portlet procs.
} {

    #
    # Start the tests
    #
    if {[info commands ::dotlrn_community::new] eq ""} {
        aa_log "Can't test community creating without dotlrn installed"
    } else {
        aa_run_with_teardown -rollback -test_code {
            #
            # Create a community.
            #
            # As this is running in a transaction, it should be cleaned up
            # automatically.
            #
            set community_id [dotlrn_community::new -community_type dotlrn_community -pretty_name foo]
            if {$community_id ne ""} {
                aa_log "Community created: $community_id"
                set portal_id [dotlrn_community::get_admin_portal_id -community_id $community_id]
                set package_id [dotlrn::instantiate_and_mount $community_id [bm_portlet::my_package_key]]
                #
                # Add portlet.
                #
                bm_portlet::add_self_to_page -portal_id $portal_id -package_id $package_id
                aa_true "Portlet is in community portal after addition" "[bm_portlet::portlet_exists_p $portal_id]"
                #
                # Remove portlet.
                #
                bm_portlet::remove_self_from_page -portal_id $portal_id -package_id $package_id
                aa_false "Portlet is in community portal after removal" "[bm_portlet::portlet_exists_p $portal_id]"
                #
                # Add portlet.
                #
                bm_portlet::add_self_to_page -portal_id $portal_id -package_id $package_id
                aa_true "Portlet is in community portal after addition" "[bm_portlet::portlet_exists_p $portal_id]"
            } else {
                aa_error "Community creation failed"
            }
        }
    }
}

aa_register_case -procs {
        bm_portlet::get_pretty_name
    } -cats {
        api
        production_safe
    } bm_portlet_pretty_name {
        Test get_pretty_name proc.
} {
    set pretty_name [parameter::get_from_package_key -package_key [bm_portlet::my_package_key] -parameter pretty_name]
    aa_equals "bm_portlet pretty name" "[bm_portlet::get_pretty_name]" "$pretty_name"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

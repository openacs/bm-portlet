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
    } -cats {
        api
    } bm_portlet_add_remove_from_page {
        Test add/remove portlet procs.
} {
    #
    # Helper proc to check portal elements
    #
    proc portlet_exists_p {portal_id} {
        set portlet_name [bm_portlet::get_my_name]
        return [db_0or1row portlet_in_portal {
            select 1 from dual where exists (
              select 1
                from portal_element_map pem,
                     portal_pages pp
               where pp.portal_id = :portal_id
                 and pp.page_id = pem.page_id
                 and pem.name = :portlet_name
            )
        }]
    }
    #
    # Start the tests
    #
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
            aa_true "Portlet is in community portal after addition" "[portlet_exists_p $portal_id]"
            #
            # Remove portlet.
            #
            bm_portlet::remove_self_from_page -portal_id $portal_id -package_id $package_id
            aa_false "Portlet is in community portal after removal" "[portlet_exists_p $portal_id]"
            #
            # Add portlet.
            #
            bm_portlet::add_self_to_page -portal_id $portal_id -package_id $package_id
            aa_true "Portlet is in community portal after addition" "[portlet_exists_p $portal_id]"
        } else {
            aa_error "Community creation failed"
        }
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

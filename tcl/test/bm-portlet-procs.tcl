ad_library {
    Automated tests for the bm-portlet package.

    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 2020-08-19
    @cvs-id $Id$
}

aa_register_case -procs {
    bm_portlet::show
} -cats {
    api
    smoke
} bm_render_portlet {
    Test the rendering of the portlet
} {
    aa_run_with_teardown -rollback -test_code {
        set package_id [site_node::instantiate_and_mount \
                            -package_key bulk-mail \
                            -node_name __test_bm_portlet]

        foreach shaded_p {true false} {
            set portlet bm_portlet
            set section_name $portlet
            if {$shaded_p} {
                append section_name " (shaded)"
            }
            aa_section $section_name

            set cf [list \
                        package_id $package_id \
                        shaded_p $shaded_p \
                        scoped_p false \
                       ]

            set portlet [acs_sc::invoke \
                             -contract portal_datasource \
                             -operation Show \
                             -impl $portlet \
                             -call_args [list $cf]]

            aa_log "Portlet returns: [ns_quotehtml $portlet]"

            aa_false "No error was returned" {
                [string first "Error in include template" $portlet] >= 0
            }

            aa_false "No unresolved message keys" {
                [string first "MESSAGE KEY MISSING: " $portlet] >= 0
            }

            aa_true "Portlet contains something" {
                [string length [string trim $portlet]] > 0
            }
        }
    }
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

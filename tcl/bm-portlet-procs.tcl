#
#  Copyright (C) 2001, 2002 MIT
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_library {

    Procedures to support the bulk-mail portlet

    @author yon (yon@openforce.net)
    @creation-date 2002-05-13
    @cvs-id $Id$

}

namespace eval bm_portlet {

    ad_proc -private my_package_key {
    } {
        return "bm-portlet"
    }

    ad_proc -private get_my_name {
    } {
        return "bm_portlet"
    }

    ad_proc -public get_pretty_name {
    } {
        Gets portlet pretty name.
    } {
        return [parameter::get_from_package_key -package_key [my_package_key] -parameter pretty_name]
    }

    ad_proc -public link {
    } {
        Gets portlet link (empty).
    } {
        return ""
    }

    ad_proc -public add_self_to_page {
        {-portal_id:required}
        {-page_name ""}
        {-package_id:required}
        {-extra_params ""}
        {-force_region ""}
    } {
        Add the portlet element to the given portal.
    } {
        return [portal::add_element_parameters \
            -portal_id $portal_id \
            -page_name $page_name \
            -pretty_name [get_pretty_name] \
            -portlet_name [get_my_name] \
            -key package_id \
            -value $package_id \
            -force_region $force_region \
            -extra_params $extra_params
        ]
    }

    ad_proc -public remove_self_from_page {
        {-portal_id:required}
        {-package_id:required}
        {-extra_params ""}
    } {
        Remove the portal element from the given portal.
    } {
        portal::remove_element_parameters \
            -portal_id $portal_id \
            -portlet_name [get_my_name] \
            -value $package_id \
            -key package_id \
            -extra_params $extra_params
    }

    ad_proc -private show {
         cf
    } {
        Show the portal element.
    } {
        portal::show_proc_helper \
            -package_key [my_package_key] \
            -config_list $cf
    }
    
    ad_proc -private portlet_exists_p {portal_id} {
        Helper proc to check portal elements.         
    } {
        set portlet_name [get_my_name]
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
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

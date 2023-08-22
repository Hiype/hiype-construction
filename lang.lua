local Translations = {
    info = {
        signing_contract = 'Signing contract',
        request_build = 'Request build',
        build_location_marked = 'Build location marked on map',
        construction_sites_header = 'Construction sites',
        craft = 'Craft',
        crafting = 'Crafting',
        signup = 'Sign up',
        signout = 'Sign out',
        cancel_build = 'Cancel build',
        rent_truck = 'Rent truck',
        return_truck = 'Return truck',
        interact = 'Interact',
        deliver_deliverables = 'Deliver necessary objects',
        preparation_work = 'Preparation work',
        unpack_deliverables = 'Unpack deliverables',
        job_done = 'Build completed',
        signing_job_documents = 'Signing job documents'
    },
    error = {
        you_have_an_active_build = 'You already have an active build',
        already_active = 'You already work as a construction worker',
        not_active = 'You need to work as construction worker first',
        not_all_items_in_inventory = 'Not all required items are in your inventory',
        no_active_build = 'There are no currently active builds',
        truck_already_rented_set_waypoint = 'The truck has already been rented, waypoint to it has been set',
        truck_not_close_enough = 'Rented truck is not close enough',
        you_dont_have_item = 'You dont have %s',
        out_of_range = 'Out of range',
        not_in_range_of_destination = 'Not in range of destination'
    }
}

Lang = nil


Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
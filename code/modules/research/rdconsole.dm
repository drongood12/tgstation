
/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The only thing that requires toxins access is locking and unlocking the console on the settings menu.
Nothing else in the console has ID requirements.

*/
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	desc = "A console used to interface with R&D tools."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/disk/tech_disk/t_disk	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

	req_access = list(ACCESS_RND)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	//UI VARS
	var/screen = RDSCREEN_MENU
	var/back = RDSCREEN_MENU
	var/locked = FALSE
	var/tdisk_uple = FALSE
	var/ddisk_uple = FALSE
	var/datum/selected_node_id
	var/datum/selected_design_id
	var/selected_category
	var/disk_slot_selected
	var/searchstring = ""
	var/searchtype = ""
	var/ui_mode = RDCONSOLE_UI_MODE_NORMAL

	var/research_control = TRUE

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(istype(D, /obj/item/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='warning'>A technology disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='warning'>[D] is stuck to your hand!</span>")
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='warning'>A design disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='warning'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='warning'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
		return
	return ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		investigate_log("[key_name(user)] researched [id]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id))
			say("Successfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			var/i = stored_research.research_logs.len
			stored_research.research_logs += null
			stored_research.research_logs[++i] = list(TN.display_name, price["General Research"], logname, "[get_area(src)] ([src.x],[src.y],[src.z])")
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>You disable the security protocols[locked? " and unlock the console":""].</span>")
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		obj_flags |= EMAGGED
		locked = FALSE
	return ..()

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Techweb")
		ui.open()

/obj/machinery/computer/rdconsole/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	)

// heavy data from this proc should be moved to static data when possible
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	. = list(
		"nodes" = list(),
		"experiments" = list(),
		"researched_designs" = stored_research.researched_designs,
		"points" = stored_research.research_points,
		"points_last_tick" = stored_research.last_bitcoins,
		"web_org" = stored_research.organization,
		"sec_protocols" = !(obj_flags & EMAGGED),
		"t_disk" = null,
		"d_disk" = null,
		"locked" = locked
	)

	if (t_disk)
		.["t_disk"] = list (
			"stored_research" = t_disk.stored_research.researched_nodes
		)
	if (d_disk)
		.["d_disk"] = list (
			"max_blueprints" = d_disk.max_blueprints,
			"blueprints" = list()
		)
		for (var/i in 1 to d_disk.max_blueprints)
			if (d_disk.blueprints[i])
				var/datum/design/D = d_disk.blueprints[i]
				.["d_disk"]["blueprints"] += D.id
			else
				.["d_disk"]["blueprints"] += null


	// Serialize all nodes to display
	for(var/v in stored_research.tiers)
		var/datum/techweb_node/n = SSresearch.techweb_node_by_id(v)

		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[v])
			continue

		.["nodes"] += list(list(
			"id" = n.id,
			"can_unlock" = stored_research.can_unlock_node(n),
			"tier" = stored_research.tiers[n.id]
		))

	// Get experiments and serialize them
	var/list/exp_to_process = stored_research.available_experiments.Copy()
	for (var/e in stored_research.completed_experiments)
		exp_to_process += stored_research.completed_experiments[e]
	for (var/e in exp_to_process)
		var/datum/experiment/ex = e
		.["experiments"][ex.type] = list(
			"name" = ex.name,
			"description" = ex.description,
			"tag" = ex.exp_tag,
			"progress" = ex.check_progress(),
			"completed" = ex.completed
		)

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	. = list(
		"node_cache" = list(),
		"design_cache" = list()
	)

	// Build node cache
	for (var/nid in SSresearch.techweb_nodes)
		var/datum/techweb_node/n = SSresearch.techweb_nodes[nid] || SSresearch.error_node
		.["node_cache"][n.id] = list(
			"id" = n.id,
			"name" = n.display_name,
			"description" = n.description,
			"category" = n.category,
			"costs" = n.research_costs,
			"starting_node" = n.starting_node,
			"prereq_ids" = n.prereq_ids,
			"design_ids" = n.design_ids,
			"unlock_ids" = n.unlock_ids,
			"boost_item_paths" = n.boost_item_paths,
			"autounlock_by_boost" = n.autounlock_by_boost,
			"required_experiments" = n.required_experiments,
			"discount_experiments" = n.discount_experiments
		)

	// Build design cache
	var/datum/asset/spritesheet/research_designs/ss = get_asset_datum(/datum/asset/spritesheet/research_designs)
	for (var/did in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[did] || SSresearch.error_design
		.["design_cache"][d.id] = list(
			"name" = d.name,
			"class" = ss.icon_class_name(d.id)
		)

/obj/machinery/computer/rdconsole/ui_act(action, list/params)
	if (..())
		return

	add_fingerprint(usr)

	// Check if the console is locked to block any actions occuring
	if (locked && action != "toggleLock")
		say("Console is locked, cannot perform further actions.")
		return

	switch (action)
		if ("toggleLock")
			if(obj_flags & EMAGGED)
				to_chat(usr, "<span class='boldwarning'>Security protocol error: Unable to access locking protocols.</span>")
				return
			if(allowed(usr))
				locked = !locked
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if ("researchNode")
			if(!SSresearch.science_tech.available_nodes[params["node_id"]])
				return
			research_node(params["node_id"], usr)
		if ("ejectDisk")
			eject_disk(params["type"])
		if ("writeDesign")
			if(QDELETED(d_disk))
				say("No Design Disk Inserted!")
				return
			var/slot = text2num(params["slot"])
			var/datum/design/D = SSresearch.techweb_design_by_id(params["selectedDesign"])
			if(D)
				var/autolathe_friendly = TRUE
				if(D.reagents_list.len)
					autolathe_friendly = FALSE
					D.category -= "Imported"
				else
					for(var/x in D.materials)
						if( !(x in list(/datum/material/iron, /datum/material/glass)))
							autolathe_friendly = FALSE
							D.category -= "Imported"

				if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
					D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
					D.category |= "Imported"
				d_disk.blueprints[slot] = D
		if ("uploadDesignSlot")
			if(QDELETED(d_disk))
				say("No design disk found.")
				return
			var/n = text2num(params["slot"])
			stored_research.add_design(d_disk.blueprints[n], TRUE)
		if ("clearDesignSlot")
			if(QDELETED(d_disk))
				say("No design disk inserted!")
				return
			var/n = text2num(params["slot"])
			var/datum/design/D = d_disk.blueprints[n]
			say("Wiping design [D.name] from design disk.")
			d_disk.blueprints[n] = null
		if ("eraseDisk")
			if (params["type"] == "design")
				if(QDELETED(d_disk))
					say("No design disk inserted!")
					return
				say("Wiping design disk.")
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			if (params["type"] == "tech")
				if(QDELETED(t_disk))
					say("No tech disk inserted!")
					return
				qdel(t_disk.stored_research)
				t_disk.stored_research = new
				say("Wiping technology disk.")
		if ("uploadDisk")
			if (params["type"] == "design")
				if(QDELETED(d_disk))
					say("No design disk inserted!")
					return
				for(var/D in d_disk.blueprints)
					if(D)
						stored_research.add_design(D, TRUE)
			if (params["type"] == "tech")
				if (QDELETED(t_disk))
					say("No tech disk inserted!")
					return
				say("Uploading technology disk.")
				t_disk.stored_research.copy_research_to(stored_research)
		if ("loadTech")
			if(QDELETED(t_disk))
				say("No tech disk inserted!")
				return
			stored_research.copy_research_to(t_disk.stored_research)
			say("Downloading to technology disk.")

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design" && d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech" && t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null

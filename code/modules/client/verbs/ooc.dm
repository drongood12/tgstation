GLOBAL_VAR_INIT(OOC_COLOR, null)//If this is null, use the CSS for OOC. Otherwise, use a custom colour.
GLOBAL_VAR_INIT(normal_ooc_colour, "#002eb8")

GLOBAL_VAR_INIT(LOOC_COLOR, null)//If this is null, use the CSS for OOC. Otherwise, use a custom colour.
GLOBAL_VAR_INIT(normal_looc_colour, "#6699CC")

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(SSticker.HasRoundStarted() && (msg[1] in list(".",";",":","#") || findtext_char(msg, "say", 1, 5)))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "Yes", "No") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	mob.log_talk(raw_msg, LOG_OOC)

	var/keyname = key
	if(prefs.hearted)
		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
		keyname = "[sheet.icon_tag("emoji-heart")][keyname]"
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url
	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder?.fakekey in C.prefs.ignoring)
				continue
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<span class='adminooc'>[CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>")
					else
						to_chat(C, "<span class='adminobserverooc'><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>")
				else
					if(GLOB.OOC_COLOR)
						to_chat(C, "<font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></b></font>")
					else
						to_chat(C, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span>")

			else if(!(key in C.prefs.ignoring))
				if(GLOB.OOC_COLOR)
					to_chat(C, "<font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font>")
				else
					to_chat(C, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>")

/proc/toggle_ooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.ooc_allowed)
			GLOB.ooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.ooc_allowed = !GLOB.ooc_allowed
	to_chat(world, "<B>The OOC channel has been globally [GLOB.ooc_allowed ? "enabled" : "disabled"].</B>")

/proc/toggle_dooc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.dooc_allowed)
			GLOB.dooc_allowed = toggle
		else
			return
	else
		GLOB.dooc_allowed = !GLOB.dooc_allowed


/client/proc/set_ooc()
	set name = "Set Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Server"
	if(IsAdminAdvancedProcCall())
		return
	var/newColor = input(src, "Please select the new player OOC color.", "OOC color") as color|null
	if(isnull(newColor))
		return
	if(!check_rights(R_FUN))
		message_admins("[usr.key] has attempted to use the Set Player OOC Color verb!")
		log_admin("[key_name(usr)] tried to set player ooc color without authorization.")
		return
	var/new_color = sanitize_ooccolor(newColor)
	message_admins("[key_name_admin(usr)] has set the players' ooc color to [new_color].")
	log_admin("[key_name_admin(usr)] has set the player ooc color to [new_color].")
	GLOB.OOC_COLOR = new_color


/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Server"
	if(IsAdminAdvancedProcCall())
		return
	if(alert(usr, "Are you sure you want to reset the OOC color of all players?", "Reset Player OOC Color", "Yes", "No") != "Yes")
		return
	if(!check_rights(R_FUN))
		message_admins("[usr.key] has attempted to use the Reset Player OOC Color verb!")
		log_admin("[key_name(usr)] tried to reset player ooc color without authorization.")
		return
	message_admins("[key_name_admin(usr)] has reset the players' ooc color.")
	log_admin("[key_name_admin(usr)] has reset player ooc color.")
	GLOB.OOC_COLOR = null


/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(isnull(new_ooccolor))
		return
	new_ooccolor = sanitize_ooccolor(new_ooccolor)
	prefs.ooccolor = new_ooccolor
	prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set OOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

		prefs.ooccolor = initial(prefs.ooccolor)
		prefs.save_preferences()

/client/verb/looc(msg as text)
	set name = "LOOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.looc_allowed)
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_LOOC)
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return
	if(is_banned_from(ckey, "LOOC"))
		to_chat(src, "<span class='danger'>You have been banned from LOOC.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(SSticker.HasRoundStarted() && (msg[1] in list(".",";",":","#") || findtext_char(msg, "say", 1, 5)))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in LOOC?", "Meant for LOOC?", "Yes", "No") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_LOOC))
		to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
		return

	mob.log_talk(raw_msg, LOG_LOOC)

	var/keyname = key

	if(prefs.hearted)
		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
		keyname = "[sheet.icon_tag("emoji-heart")][keyname]"
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.looccolor ? prefs.looccolor : GLOB.normal_looc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"

	var/mob/source = mob.get_looc_source()
	var/list/heard = get_hearers_in_view(7, source)

	for(var/client/target in GLOB.clients)
		if(target.prefs.chat_toggles & CHAT_LOOC)
			if(holder?.fakekey in target.prefs.ignoring)
				continue
			var/send = 0

			if(target.mob in heard)
				send = 1

			else if(isAI(target.mob)) // Special case
				var/mob/living/silicon/ai/A = target.mob
				if(A.eyeobj in hearers(7, source))
					send = 1

			if(!send && (target in GLOB.admins))
				if(check_rights(R_ADMIN,0,target.mob))
					send = 1

			if(holder && send)
				if(!holder.fakekey || target.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(target, "<span class='adminlooc'>[CONFIG_GET(flag/allow_admin_looccolor) && prefs.looccolor ? "<font color=[prefs.looccolor]>" :"" ]<span class='prefix'>LOOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>")
					else
						to_chat(target, "<span class='adminobserverlooc'><span class='prefix'>LOOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>")
				else
					if(GLOB.LOOC_COLOR)
						to_chat(target, "<font color='[GLOB.LOOC_COLOR]'><b><span class='prefix'>LOOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></b></font>")
					else
						to_chat(target, "<span class='looc'><span class='prefix'>LOOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span>")

			else if(!(key in target.prefs.ignoring) && send)
				if(GLOB.LOOC_COLOR)
					to_chat(target, "<font color='[GLOB.LOOC_COLOR]'><b><span class='prefix'>LOOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font>")
				else
					to_chat(target, "<span class='looc'><span class='prefix'>LOOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>")


/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj
	return src

/client/proc/set_looc()
	set name = "Set Player LOOC Color"
	set desc = "Modifies player LOOC Color"
	set category = "Server"
	if(IsAdminAdvancedProcCall())
		return
	var/newColor = input(src, "Please select the new player LOOC color.", "OLOC color") as color|null
	if(isnull(newColor))
		return
	if(!check_rights(R_FUN))
		message_admins("[usr.key] has attempted to use the Set Player LOOC Color verb!")
		log_admin("[key_name(usr)] tried to set player looc color without authorization.")
		return
	var/new_color = sanitize_looccolor(newColor)
	message_admins("[key_name_admin(usr)] has set the players' looc color to [new_color].")
	log_admin("[key_name_admin(usr)] has set the player looc color to [new_color].")
	GLOB.LOOC_COLOR = new_color

/client/proc/reset_looc()
	set name = "Reset Player LOOC Color"
	set desc = "Returns player LOOC Color to default"
	set category = "Server"
	if(IsAdminAdvancedProcCall())
		return
	if(alert(usr, "Are you sure you want to reset the LOOC color of all players?", "Reset Player LOOC Color", "Yes", "No") != "Yes")
		return
	if(!check_rights(R_FUN))
		message_admins("[usr.key] has attempted to use the Reset Player LOOC Color verb!")
		log_admin("[key_name(usr)] tried to reset player looc color without authorization.")
		return
	message_admins("[key_name_admin(usr)] has reset the players' looc color.")
	log_admin("[key_name_admin(usr)] has reset player looc color.")
	GLOB.OOC_COLOR = null

/client/verb/colorlooc()
	set name = "Set Your LOOC Color"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

	var/new_looccolor = input(src, "Please select your LOOC color.", "LOOC color", prefs.ooccolor) as color|null
	if(isnull(new_looccolor))
		return
	new_looccolor = sanitize_looccolor(new_looccolor)
	prefs.looccolor = new_looccolor
	prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set LOOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/resetcolorlooc()
	set name = "Reset Your LOOC Color"
	set desc = "Returns your LOOC Color to default"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

		prefs.looccolor = initial(prefs.ooccolor)
		prefs.save_preferences()

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(GLOB.admin_notice)
		to_chat(src, "<span class='boldnotice'>Admin Notice:</span>\n \t [GLOB.admin_notice]")
	else
		to_chat(src, "<span class='notice'>There are no admin notices at the moment.</span>")

/proc/toggle_looc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.looc_allowed)
			GLOB.looc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed
	to_chat(world, "<B>The LOOC channel has been globally [GLOB.looc_allowed ? "enabled" : "disabled"].</B>")

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)
	else
		to_chat(src, "<span class='notice'>The Message of the Day has not been set.</span>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	browse_messages(null, usr.ckey, null, TRUE)

/client/proc/self_playtime()
	set name = "View tracked playtime"
	set category = "OOC"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='notice'>Sorry, tracking is currently disabled.</span>")
		return

	new /datum/job_report_menu(src, usr)

// Ignore verb
/client/verb/select_ignore()
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"

	// Make a list to choose players from
	var/list/players = list()

	// Use keys and fakekeys for the same purpose
	var/displayed_key = ""

	// Try to add every player who's online to the list
	for(var/client/C in GLOB.clients)
		// Don't add ourself
		if(C == src)
			continue

		// Don't add players we've already ignored if they're not using a fakekey
		if((C.key in prefs.ignoring) && !C.holder?.fakekey)
			continue

		// Don't add players using a fakekey we've already ignored
		if(C.holder?.fakekey in prefs.ignoring)
			continue

		// Use the player's fakekey if they're using one
		if(C.holder?.fakekey)
			displayed_key = C.holder.fakekey

		// Use the player's key if they're not using a fakekey
		else
			displayed_key = C.key

		// Check if both we and the player are ghosts and they're not using a fakekey
		if(isobserver(mob) && isobserver(C.mob) && !C.holder?.fakekey)
			// Show us the player's mob name in the list in front of their displayed key
			// Add the player's displayed key to the list
			players["[C.mob]([displayed_key])"] = displayed_key

		// Add the player's displayed key to the list if we or the player aren't a ghost or they're using a fakekey
		else
			players[displayed_key] = displayed_key

	// Check if the list is empty
	if(!players.len)
		// Express that there are no players we can ignore in chat
		to_chat(src, "There are no other players you can ignore!")

		// Stop running
		return

	// Sort the list
	players = sortList(players)

	// Request the player to ignore
	var/selection = input("Please, select a player!", "Ignore", null, null) as null|anything in players

	// Stop running if we didn't receieve a valid selection
	if(!selection || !(selection in players))
		return

	// Store the selected player
	selection = players[selection]

	// Check if the selected player is on our ignore list
	if(selection in prefs.ignoring)
		// Express that the selected player is already on our ignore list in chat
		to_chat(src, "You are already ignoring [selection]!")

		// Stop running
		return

	// Add the selected player to our ignore list
	prefs.ignoring.Add(selection)

	// Save our preferences
	prefs.save_preferences()

	// Express that we've ignored the selected player in chat
	to_chat(src, "You are now ignoring [selection] on the OOC channel.")

// Unignore verb
/client/verb/select_unignore()
	set name = "Unignore"
	set category = "OOC"
	set desc = "Stop ignoring a player's messages on the OOC channel"

	// Check if we've ignored any players
	if(!prefs.ignoring.len)
		// Express that we haven't ignored any players in chat
		to_chat(src, "You haven't ignored any players!")

		// Stop running
		return

	// Request the player to unignore
	var/selection = input("Please, select a player!", "Unignore", null, null) as null|anything in prefs.ignoring

	// Stop running if we didn't receive a selection
	if(!selection)
		return

	// Check if the selected player is not on our ignore list
	if(!(selection in prefs.ignoring))
		// Express that the selected player is not on our ignore list in chat
		to_chat(src, "You are not ignoring [selection]!")

		// Stop running
		return

	// Remove the selected player from our ignore list
	prefs.ignoring.Remove(selection)

	// Save our preferences
	prefs.save_preferences()

	// Express that we've unignored the selected player in chat
	to_chat(src, "You are no longer ignoring [selection] on the OOC channel.")

/client/proc/show_previous_roundend_report()
	set name = "Your Last Round"
	set category = "OOC"
	set desc = "View the last round end report you've seen"

	SSticker.show_roundend_report(src, TRUE)

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's
	// CRASH with some info.
	if(!sizes["mapwindow.size"])
		CRASH("sizes does not contain mapwindow.size key. This means a winget failed to return what we wanted. --- sizes var: [sizes] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["mapwindow.size"], "x")

	// Looks like we expect mapwindow.size to be "ixj" where i and j are numbers.
	// If we don't get our expected 2 outputs, let's give some useful error info.
	if(length(map_size) != 2)
		CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")

	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Avoid auto-resizing the statpanel and chat into nothing.
	desired_width = min(desired_width, split_width - 300)

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.split", "splitter=[pct]")


/client/verb/policy()
	set name = "Show Policy"
	set desc = "Show special server rules related to your current character."
	set category = "OOC"

	//Collect keywords
	var/list/keywords = mob.get_policy_keywords()
	var/header = get_policy(POLICY_VERB_HEADER)
	var/list/policytext = list(header,"<hr>")
	var/anything = FALSE
	for(var/keyword in keywords)
		var/p = get_policy(keyword)
		if(p)
			policytext += p
			policytext += "<hr>"
			anything = TRUE
	if(!anything)
		policytext += "No related rules found."

	usr << browse(policytext.Join(""),"window=policy")

/client/verb/fix_stat_panel()
	set name = "Fix Stat Panel"
	set hidden = TRUE

	init_verbs()

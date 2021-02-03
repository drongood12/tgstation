/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */

/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/card/data
	name = "data card"
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has a stripe running down the middle."
	icon_state = "data_1"
	obj_flags = UNIQUE_RENAME
	var/function = "storage"
	var/data = "null"
	var/special = null
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/detail_color = COLOR_ASSEMBLY_ORANGE

/obj/item/card/data/Initialize()
	.=..()
	update_icon()

/obj/item/card/data/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	. += detail_overlay

/obj/item/card/data/full_color
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has the entire card colored."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one inexplicibly looks like a floppy disk."
	icon_state = "data_3"

/*
 * ID CARDS
 */

/obj/item/card/id
	name = "retro identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "card_grey"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	/// How many magical mining Disney Dollars this card has for spending at the mining equipment vendors.
	var/mining_points = 0
	/// The name registered on the card (for example: Dr Bryan See)
	var/registered_name = null
	/// Linked bank account.
	var/datum/bank_account/registered_account
	/// Linked paystand.
	var/obj/machinery/paystand/my_store
	/// Registered owner's age.
	var/registered_age = 13

	/// The job name registered on the card (for example: Assistant).
	var/assignment

	/// Trim datum associated with the card. Controls which job icon is displayed on the card and which accesses do not require wildcards.
	var/datum/id_trim/timberpoes_trim

	/// Access levels held by this card.
	var/list/timberpoes_access = list()

	/// List of access flag keys to number values controlling how many and which wildcards this card can have. Can have negative values if wildcards are forced onto cards.
	var/list/wildcard_limits = list()

/obj/item/card/id/Initialize(mapload)
	. = ..()

	if(ispath(timberpoes_trim))
		var/datum/new_trim = SSid_access.get_trim(timberpoes_trim)
		new_trim.apply_to_card(src)

	update_label()

	RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, .proc/update_in_wallet)

/obj/item/card/id/Destroy()
	if (registered_account)
		registered_account.bank_cards -= src
	if (my_store && my_store.my_card == src)
		my_store.my_card = null
	return ..()

/obj/item/card/id/proc/can_add_wildcards(list/wildcard_list)
	var/list/new_limits = wildcard_limits.Copy()

	var/wildcard_allocated
	for(var/wildcard in wildcard_list)
		var/wildcard_flag = SSid_access.get_access_flag(wildcard)
		wildcard_allocated = FALSE
		for(var/limit_flag in new_limits)
			if(!(wildcard_flag & limit_flag))
				continue
			if(new_limits[limit_flag] <= 0)
				continue
			new_limits[limit_flag]--
			wildcard_allocated = TRUE
			break
		if(!wildcard_allocated)
			return FALSE

	return TRUE

/obj/item/card/id/proc/add_wildcards(list/wildcard_list, force = FALSE)
	var/wildcard_allocated
	for(var/wildcard in wildcard_list)
		var/wildcard_flag = SSid_access.get_access_flag(wildcard)
		wildcard_allocated = FALSE
		for(var/limit_flag in wildcard_limits)
			if(!(wildcard_flag & limit_flag))
				continue
			if(wildcard_limits[limit_flag] <= 0)
				continue
			wildcard_limits[limit_flag]--
			timberpoes_access += wildcard
			wildcard_allocated = TRUE
			break
		if(!wildcard_allocated)
			if(!force)
				stack_trace("Wildcard could not be added to [src]. Use force = TRUE to force wildcard addition anyway.")
				continue
			wildcard_limits[wildcard_flag]--
			timberpoes_access += wildcard

/obj/item/card/id/proc/add_access()
/obj/item/card/id/proc/remove_access()
/obj/item/card/id/proc/set_access()

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		var/minor
		if(registered_name && registered_age && registered_age < AGE_MINOR)
			minor = " <b>(MINOR)</b>"
		user.visible_message("<span class='notice'>[user] shows you: [icon2html(src, viewers(user))] [src.name][minor].</span>", "<span class='notice'>You show \the [src.name][minor].</span>")
	add_fingerprint(user)

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, assignment), NAMEOF(src, registered_name), NAMEOF(src, registered_age))
				update_label()
			if(NAMEOF(src, timberpoes_trim))
				timberpoes_trim.apply_to_card(src)

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holochip))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/stack/spacecash))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/coin))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/storage/bag/money))
		var/obj/item/storage/bag/money/money_bag = W
		var/list/money_contained = money_bag.contents

		var/money_added = mass_insert_money(money_contained, user)

		if (money_added)
			to_chat(user, "<span class='notice'>You stuff the contents into the card! They disappear in a puff of bluespace smoke, adding [money_added] worth of credits to the linked account.</span>")
		return
	else
		return ..()

/obj/item/card/id/proc/insert_money(obj/item/I, mob/user, physical_currency)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit [I] into!</span>")
		return
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		return
	registered_account.adjust_money(cash_money)
	SSblackbox.record_feedback("amount", "credits_inserted", cash_money)
	log_econ("[cash_money] credits were inserted into [src] owned by [src.registered_name]")
	if(physical_currency)
		to_chat(user, "<span class='notice'>You stuff [I] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account.</span>")
	else
		to_chat(user, "<span class='notice'>You insert [I] into [src], adding [cash_money] credits to the linked account.</span>")

	to_chat(user, "<span class='notice'>The linked account now reports a balance of [registered_account.account_balance] cr.</span>")
	qdel(I)

/obj/item/card/id/proc/mass_insert_money(list/money, mob/user)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit into!</span>")
		return FALSE

	if (!money || !money.len)
		return FALSE

	var/total = 0

	for (var/obj/item/physical_money in money)
		total += physical_money.get_item_credit_value()
		CHECK_TICK

	registered_account.adjust_money(total)
	SSblackbox.record_feedback("amount", "credits_inserted", total)
	log_econ("[total] credits were inserted into [src] owned by [src.registered_name]")
	QDEL_LIST(money)

	return total

/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

// Returns true if new account was set.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account

	var/new_bank_id = input(user, "Enter your account ID number.", "Account Reclamation", 111111) as num | null

	if (isnull(new_bank_id))
		return

	if(!alt_click_can_use_id(user))
		return
	if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
		to_chat(user, "<span class='warning'>The account ID number needs to be between 111111 and 999999.</span>")
		return
	if (registered_account && registered_account.account_id == new_bank_id)
		to_chat(user, "<span class='warning'>The account ID was already assigned to this card.</span>")
		return

	var/datum/bank_account/B = SSeconomy.bank_accounts_by_id["[new_bank_id]"]
	if(B)
		if (old_account)
			old_account.bank_cards -= src

		B.bank_cards += src
		registered_account = B
		to_chat(user, "<span class='notice'>The provided account has been linked to this ID card.</span>")

		return TRUE

	to_chat(user, "<span class='warning'>The account ID number provided is invalid.</span>")
	return

/obj/item/card/id/AltClick(mob/living/user)
	if(!alt_click_can_use_id(user))
		return

	if(!registered_account)
		set_new_account(user)
		return

	if (registered_account.being_dumped)
		registered_account.bank_card_talk("<span class='warning'>内部服务器错误</span>", TRUE)
		return

	var/amount_to_remove =  FLOOR(input(user, "How much do you want to withdraw? Current Balance: [registered_account.account_balance]", "Withdraw Funds", 5) as num|null, 1)

	if(!amount_to_remove || amount_to_remove < 0)
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
		user.put_in_hands(holochip)
		to_chat(user, "<span class='notice'>You withdraw [amount_to_remove] credits into a holochip.</span>")
		SSblackbox.record_feedback("amount", "credits_removed", amount_to_remove)
		log_econ("[amount_to_remove] credits were removed from [src] owned by [src.registered_name]")
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk("<span class='warning'>ERROR: The linked account requires [difference] more credit\s to perform that withdrawal.</span>", TRUE)

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(registered_account)
		. += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
	. += "<span class='notice'><i>There's more information below, you can look again to take a closer look...</i></span>"

/obj/item/card/id/examine_more(mob/user)
	var/list/msg = list("<span class='notice'><i>You examine [src] closer, and note the following...</i></span>")

	if(registered_age)
		msg += "The card indicates that the holder is [registered_age] years old. [(registered_age < AGE_MINOR) ? "There's a holographic stripe that reads <b><span class='danger'>'MINOR: DO NOT SERVE ALCOHOL OR TOBACCO'</span></b> along the bottom of the card." : ""]"
	if(mining_points)
		msg += "There's [mining_points] mining equipment redemption point\s loaded onto this card."
	if(registered_account)
		msg += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				msg += "The [D.account_holder] reports a balance of [D.account_balance] cr."
		msg += "<span class='info'>Alt-Click the ID to pull money from the linked account in the form of holochips.</span>"
		msg += "<span class='info'>You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.</span>"
		if(registered_account.civilian_bounty)
			msg += "<span class='info'><b>There is an active civilian bounty.</b>"
			msg += "<span class='info'><i>[registered_account.bounty_text()]</i></span>"
			msg += "<span class='info'>Quantity: [registered_account.bounty_num()]</span>"
			msg += "<span class='info'>Reward: [registered_account.bounty_value()]</span>"
		if(registered_account.account_holder == user.real_name)
			msg += "<span class='boldnotice'>If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.</span>"
	else
		msg += "<span class='info'>There is no registered account linked to this card. Alt-Click to add one.</span>"

	return msg

/obj/item/card/id/GetAccess()
	return timberpoes_access

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/RemoveID()
	return src

/obj/item/card/id/proc/update_in_wallet()
	SIGNAL_HANDLER

	if(istype(loc, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/powergaming = loc
		if(powergaming.front_id == src)
			powergaming.update_label()
			powergaming.update_icon()

/obj/item/card/id/proc/update_label()
	var/blank = !registered_name
	name = "[blank ? initial(name) : "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/datum/id_trim/away
	basic_access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	timberpoes_trim = /datum/id_trim/away
	icon_state = "retro"
	registered_age = null

/datum/id_trim/away/hotel
	basic_access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	timberpoes_trim = /datum/id_trim/away/hotel

/datum/id_trim/away/hotel/security
	basic_access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/obj/item/card/id/away/hotel/securty
	name = "Officer ID"
	timberpoes_trim = /datum/id_trim/away/hotel/security

/obj/item/card/id/away/old
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."

/datum/id_trim/away/old/sec
	basic_access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)
	assignment = "Charlie Station Security Officer"

/obj/item/card/id/away/old/sec
	name = "Charlie Station Security Officer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Security Officer\"."
	timberpoes_trim = /datum/id_trim/away/old/sec

/datum/id_trim/away/old/sci
	basic_access = list(ACCESS_AWAY_GENERAL)
	assignment = "Charlie Station Scientist"

/obj/item/card/id/away/old/sci
	name = "Charlie Station Scientist's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Scientist\"."
	timberpoes_trim = /datum/id_trim/away/old/sci

/datum/id_trim/away/old/end
	basic_access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)
	assignment = "Charlie Station Engineer"

/obj/item/card/id/away/old/eng
	name = "Charlie Station Engineer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Station Engineer\"."
	timberpoes_trim = /datum/id_trim/away/old/eng

/datum/id_trim/away/old/apc
	basic_access = list(ACCESS_ENGINE_EQUIP)

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	timberpoes_trim = /datum/id_trim/away/old/apc

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "bunker access ID"

/obj/item/card/id/departmental_budget
	name = "departmental card (FUCK)"
	desc = "Provides access to the departmental budget."
	icon_state = "budgetcard"
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	registered_age = null

/obj/item/card/id/departmental_budget/Initialize()
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "departmental card ([department_name])"
		desc = "Provides access to the [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/update_label()
	return

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME
	icon_state = "car_budget" //saving up for a new tesla

/obj/item/card/id/departmental_budget/AltClick(mob/living/user)
	registered_account.bank_card_talk("<span class='warning'>Withdrawing is not compatible with this card design.</span>", TRUE) //prevents the vault bank machine being useless and putting money from the budget to your card to go over personal crates

/obj/item/card/id/advanced
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station. Has an integrated digital display and advanced microchips."
	icon_state = "card_grey"

	/// An overlay icon state for when the card is assigned to a name. Usually manifests itself as a little scribble to the right of the job icon.
	var/assigned_icon_state = "assigned"
	/// Cached icon that has been built for this card.
	var/icon/cached_flat_icon

/// If no cached_flat_icon exists, this proc creates it. This proc then returns the cached_flat_icon.
/obj/item/card/id/advanced/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

/obj/item/card/id/advanced/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]" //displays all overlays in chat

/obj/item/card/id/advanced/update_overlays()
	. = ..()

	cached_flat_icon = null
	if(registered_name && registered_name != "Captain")
		. += mutable_appearance(icon, assigned_icon_state)


	if(!(timberpoes_trim?.trim_state))
		return

	. += mutable_appearance(timberpoes_trim.trim_icon, timberpoes_trim.trim_state)

/obj/item/card/id/advanced/update_label()
	. = ..()
	update_icon()

/obj/item/card/id/advanced/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "card_silver"
	inhand_icon_state = "silver_id"

/datum/id_trim/maint_reaper
	basic_access = list(ACCESS_MAINT_TUNNELS)
	trim_state = "trim_janitor"
	assignment = "Reaper"

/obj/item/card/id/advanced/silver/reaper
	name = "Thirteen's ID Card (Reaper)"
	timberpoes_trim = /datum/id_trim/maint_reaper
	registered_name = "Thirteen"

/obj/item/card/id/advanced/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "card_gold"
	inhand_icon_state = "gold_id"

/obj/item/card/id/advanced/gold/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	registered_name = "Captain"
	timberpoes_trim = /datum/id_trim/job/captain
	registered_age = null

/obj/item/card/id/advanced/gold/captains_spare/update_label() //so it doesn't change to Captain's ID card (Captain) on a sneeze
	if(registered_name == "Captain")
		name = "[initial(name)][(!assignment || assignment == "Captain") ? "" : " ([assignment])"]"
		update_icon()
	else
		..()

/obj/item/card/id/advanced/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	registered_name = "Central Command"
	//assignment = "Central Command"
	registered_age = null

/obj/item/card/id/advanced/centcom/Initialize()
	//access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/advanced/centcom/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	registered_age = null

/obj/item/card/id/advanced/centcom/ert/Initialize()
	. = ..()
	//access = get_all_accesses() - ACCESS_CHANGE_IDS

/obj/item/card/id/advanced/centcom/ert/commander
	registered_name = "Emergency Response Team Commander"
	//assignment = "Emergency Response Team Commander"

/obj/item/card/id/advanced/centcom/ert/commander/Initialize()
	. = ..()
	//access += get_ert_access("commander")

/obj/item/card/id/advanced/centcom/ert/security
	registered_name = "Security Response Officer"
	//assignment = "Security Response Officer"

/obj/item/card/id/advanced/centcom/ert/security/Initialize()
	. = ..()
	//access += get_ert_access("sec")

/obj/item/card/id/advanced/centcom/ert/engineer
	registered_name = "Engineering Response Officer"
	//assignment = "Engineering Response Officer"

/obj/item/card/id/advanced/centcom/ert/engineer/Initialize()
	. = ..()
	//access += get_ert_access("eng")

/obj/item/card/id/advanced/centcom/ert/medical
	registered_name = "Medical Response Officer"
	//assignment = "Medical Response Officer"

/obj/item/card/id/advanced/centcom/ert/medical/Initialize()
	. = ..()
	//access |= get_ert_access("med")

/obj/item/card/id/advanced/centcom/ert/chaplain
	registered_name = "Religious Response Officer"
	//assignment = "Religious Response Officer"

/obj/item/card/id/advanced/centcom/ert/chaplain/Initialize()
	. = ..()
	//access |= get_ert_access("sec")

/obj/item/card/id/advanced/centcom/ert/janitor
	registered_name = "Janitorial Response Officer"
	//assignment = "Janitorial Response Officer"

/obj/item/card/id/advanced/centcom/ert/clown
	registered_name = "Entertainment Response Officer"
	//assignment = "Entertainment Response Officer"

/obj/item/card/id/advanced/black
	name = "black identification card"
	desc = "This card is telling you one thing and one thing alone. The person holding this card is an utter badass."
	icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"

/obj/item/card/id/advanced/black/deathsquad
	name = "\improper Death Squad ID"
	desc = "A Death Squad ID card."
	registered_name = "Death Commando"
	//assignment = "Death Commando"

/obj/item/card/id/advanced/black/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	//assignment = "Syndicate Overlord"
	icon_state = "card_black"
	//access = list(ACCESS_SYNDICATE)
	//sticky_access = list(ACCESS_SYNDICATE)
	registered_age = null

/obj/item/card/id/advanced/black/syndicate_command/crew_id
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	//assignment = "Syndicate Operative"
	//access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	//sticky_access = list(ACCESS_SYNDICATE)

/obj/item/card/id/advanced/black/syndicate_command/captain_id
	name = "syndicate captain ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	//assignment = "Syndicate Ship Captain"
	//access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	//sticky_access = list(ACCESS_SYNDICATE)

/obj/item/card/id/advanced/black/deathsquad/Initialize(mapload)
	. = ..()
	//access = get_all_accesses() + get_all_centcom_access()

/obj/item/card/id/advanced/debug
	name = "\improper Debug ID"
	desc = "A debug ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	//assignment = "Jannie"

/obj/item/card/id/advanced/debug/Initialize()
	. = ..()
	//access = get_all_accesses() + get_all_centcom_access() + get_all_syndicate_access()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

/obj/item/card/id/advanced/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "card_prisoner"
	inhand_icon_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	//assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0
	registered_age = null

/obj/item/card/id/advanced/prisoner/attack_self(mob/user)
	to_chat(usr, "<span class='notice'>You have accumulated [points] out of the [goal] points you need for freedom.</span>")

/obj/item/card/id/advanced/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"
	//assignment = "Prisoner #13-001"

/obj/item/card/id/advanced/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"
	//assignment = "Prisoner #13-002"

/obj/item/card/id/advanced/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"
	//assignment = "Prisoner #13-003"

/obj/item/card/id/advanced/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"
	//assignment = "Prisoner #13-004"

/obj/item/card/id/advanced/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"
	//assignment = "Prisoner #13-005"

/obj/item/card/id/advanced/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"
	//assignment = "Prisoner #13-006"

/obj/item/card/id/advanced/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"
	//assignment = "Prisoner #13-007"

/obj/item/card/id/advanced/mining
	name = "mining ID"
	//access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

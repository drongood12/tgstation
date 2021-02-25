

/datum/ai_controller/dog
	blackboard = list(BB_FETCHING = FALSE,\
	BB_SIMPLE_CARRY_ITEM = null,\
	BB_FETCH_THROW_LISTENERS = list(),\
	BB_FETCH_IGNORE_LIST = list(),\
	BB_FETCH_TARGET = null,\
	BB_FETCH_DELIVER_TO = null,\
	BB_DOG_FRIENDS = list(),\
	BB_FETCH_RESET_IGNORE_CD = 0,\
	BB_DOG_ORDER_MODE = DOG_COMMAND_NONE,\
	BB_DOG_HEEL_CD = 0,\
	BB_DOG_PLAYING_DEAD = FALSE,\
	BB_DOG_HARASS_TARGET = null)
	ai_movement = /datum/ai_movement/jps


/datum/ai_controller/dog/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	. = ..()

/datum/ai_controller/dog/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_PARENT_EXAMINE, .proc/on_examined)
	return ..() //Run parent at end

/datum/ai_controller/dog/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE))
	return ..() //Run parent at end

/datum/ai_controller/dog/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/dog/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return

	return simple_pawn.access_card

/datum/ai_controller/dog/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	// occasionally reset our ignore list
	if((world.time > blackboard[BB_FETCH_RESET_IGNORE_CD] + AI_FETCH_IGNORE_DURATION) && length(blackboard[BB_FETCH_IGNORE_LIST]))
		blackboard[BB_FETCH_RESET_IGNORE_CD] = world.time
		blackboard[BB_FETCH_IGNORE_LIST] = list()

	// if we were just ordered to heel, chill out for a bit
	if((world.time < blackboard[BB_DOG_HEEL_CD] + AI_DOG_HEEL_DURATION))
		return

	// if we're not already carrying something and we have a fetch target (and we're not already doing something with it), see if we can eat/equip it
	if(!blackboard[BB_SIMPLE_CARRY_ITEM] && blackboard[BB_FETCH_TARGET])
		var/atom/movable/interact_target = blackboard[BB_FETCH_TARGET]
		if(in_range(living_pawn, interact_target) && (isturf(interact_target.loc)))
			current_movement_target = interact_target
			if(IS_EDIBLE(interact_target))
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/eat_snack)
			else
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/simple_equip)
			return

	// if we're carrying something and we have a destination to deliver it, do that
	if(blackboard[BB_SIMPLE_CARRY_ITEM] && blackboard[BB_FETCH_DELIVER_TO])
		var/atom/return_target = blackboard[BB_FETCH_DELIVER_TO]
		if(!(return_target in view(pawn, AI_DOG_VISION_RANGE)))
			// if the return target isn't in sight, we'll just forget about it and carry the thing around
			blackboard[BB_FETCH_DELIVER_TO] = null
			current_movement_target = null
			return
		current_movement_target = return_target
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/deliver_item)
		return

	var/list/old_throw_listeners = blackboard[BB_FETCH_THROW_LISTENERS]
	var/list/new_throw_listeners = list()

	// check around us for people who we can hear throw things for fetching
	// (would probably be smart to make this run less frequently than every tick)
	for(var/i in range(AI_DOG_VISION_RANGE, get_turf(living_pawn)))
		if(!iscarbon(i))
			continue
		var/mob/living/carbon/iter_carbon = i
		if(!(iter_carbon in old_throw_listeners))
			RegisterSignal(iter_carbon, COMSIG_MOB_THROW, .proc/listened_throw)
		new_throw_listeners += iter_carbon
		old_throw_listeners -= iter_carbon // we're still in, so remove them from the drop list

	for(var/i in old_throw_listeners)
		var/mob/living/carbon/lost_listener = i
		UnregisterSignal(lost_listener, COMSIG_MOB_THROW)
	blackboard[BB_FETCH_THROW_LISTENERS] = new_throw_listeners

	// see if there's any loose snacks in sight nearby
	for(var/obj/item/potential_snack in oview(living_pawn,3))
		if(IS_EDIBLE(potential_snack) && (isturf(potential_snack.loc) || ishuman(potential_snack.loc)))
			current_movement_target = potential_snack
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/eat_snack)
			return

/datum/ai_controller/dog/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	// if we were just ordered to heel, chill out for a bit
	if((world.time < blackboard[BB_DOG_HEEL_CD] + AI_DOG_HEEL_DURATION))
		return

	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(blackboard[BB_SIMPLE_CARRY_ITEM] && DT_PROB(5, delta_time))
		var/obj/item/carry_item = blackboard[BB_SIMPLE_CARRY_ITEM]
		living_pawn.visible_message("<span class='notice'>[living_pawn] gently teethes on \the [carry_item] in [living_pawn.p_their()] mouth.</span>", vision_distance=COMBAT_MESSAGE_RANGE)

	if(DT_PROB(15, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(10, delta_time))
		living_pawn.manual_emote(pick("dances around.","chases its tail!"))
		INVOKE_ASYNC(GLOBAL_PROC, .proc/dance_rotate, living_pawn)

/// Someone we were listening to throws for has thrown something, start listening to the thrown item so we can see if we want to fetch it when it lands
/datum/ai_controller/dog/proc/listened_throw(mob/living/carbon/carbon_thrower)
	SIGNAL_HANDLER

	if(blackboard[BB_FETCH_TARGET] || blackboard[BB_FETCH_DELIVER_TO]) // we're already busy
		return
	if((world.time < blackboard[BB_DOG_HEEL_CD] + AI_DOG_HEEL_DURATION)) // if we were just ordered to heel, chill out for a bit
		return
	var/obj/item/thrown_thing = carbon_thrower.get_active_held_item()
	if(!isitem(thrown_thing) || get_dist(carbon_thrower, pawn) > AI_DOG_VISION_RANGE)
		return
	var/list/thrown_ignorelist = blackboard[BB_FETCH_IGNORE_LIST]
	if(thrown_thing in thrown_ignorelist)
		return

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, .proc/listen_throw_land)

/// A throw we were listening to has finished, see if it's in range for us to try grabbing it
/datum/ai_controller/dog/proc/listen_throw_land(obj/thrown_thing, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	UnregisterSignal(thrown_thing, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_THROW_LANDED))
	if(!isitem(thrown_thing) || !isturf(thrown_thing.loc) || !(thrown_thing in view(pawn, AI_DOG_VISION_RANGE)))
		return

	current_movement_target = thrown_thing
	blackboard[BB_FETCH_TARGET] = thrown_thing
	blackboard[BB_FETCH_DELIVER_TO] = throwing_datum.thrower
	current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/fetch)

/// Someone's interacting with us by hand, see if they're being nice or mean
/datum/ai_controller/dog/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(user.combat_mode)
		unfriend(user)
	else
		if(prob(AI_DOG_PET_FRIEND_PROB))
			befriend(user)
		// if the dog has something in their mouth that they're not bringing to someone for whatever reason, have them drop it when pet by a friend
		var/list/friends = blackboard[BB_DOG_FRIENDS]
		if(blackboard[BB_SIMPLE_CARRY_ITEM] && !current_movement_target && friends[user])
			var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
			pawn.visible_message("<span='danger'>[pawn] drops [carried_item] at [user]'s feet!</span>")
			// maybe have a dedicated proc for dropping things
			carried_item.forceMove(get_turf(user))
			blackboard[BB_SIMPLE_CARRY_ITEM] = null

/// Someone is being nice to us, let's make them a friend!
/datum/ai_controller/dog/proc/befriend(mob/living/new_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	if(friends[new_friend])
		return
	if(in_range(pawn, new_friend))
		new_friend.visible_message("<b>[pawn]</b> licks at [new_friend] in a friendly manner!", "<span class='notice'>[pawn] licks at you in a friendly manner!</span>")
	friends[new_friend] = TRUE
	RegisterSignal(new_friend, COMSIG_MOB_POINTED, .proc/check_point)
	RegisterSignal(new_friend, COMSIG_MOB_SAY, .proc/check_command)

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/dog/proc/unfriend(mob/living/ex_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	friends[ex_friend] = null
	UnregisterSignal(ex_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_SAY))

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/dog/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	if(blackboard[BB_FETCH_TARGET] || !ismovable(pointed_movable) || blackboard[BB_DOG_ORDER_MODE] == DOG_COMMAND_NONE)
		return

	var/list/visible_things = view(pawn, AI_DOG_VISION_RANGE)
	if(!(pointing_friend in visible_things) || !(pointed_movable in visible_things))
		return

	switch(blackboard[BB_DOG_ORDER_MODE])
		if(DOG_COMMAND_FETCH)
			if(ismob(pointed_movable) || pointed_movable.anchored)
				return
			pawn.visible_message("<span class='notice'>[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and barks excitedly!</span>")
			current_movement_target = pointed_movable
			blackboard[BB_FETCH_TARGET] = pointed_movable
			blackboard[BB_FETCH_DELIVER_TO] = pointing_friend
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/fetch)
		if(DOG_COMMAND_ATTACK)
			pawn.visible_message("<span class='notice'>[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and growls intensely!</span>")
			current_movement_target = pointed_movable
			blackboard[BB_DOG_HARASS_TARGET] = pointed_movable
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)

/// Someone is looking at us, if we're currently carrying something then show what it is
/datum/ai_controller/dog/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if(!blackboard[BB_SIMPLE_CARRY_ITEM])
		return

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	examine_text += "<span class='notice'>[pawn.p_they(TRUE)] [pawn.p_are()] carrying [carried_item.get_examine_string(user)] in [pawn.p_their()] mouth.</span>"

/// If we died, drop anything we were carrying
/datum/ai_controller/dog/proc/on_death(mob/living/ol_yeller)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	ol_yeller.visible_message("<span='danger'>[ol_yeller] drops [carried_item] as [ol_yeller.p_they()] die[ol_yeller.p_s()].</span>")
	carried_item.forceMove(get_turf(ol_yeller))
	blackboard[BB_SIMPLE_CARRY_ITEM] = null

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/dog/proc/check_command(mob/speaker, speech_args)
	SIGNAL_HANDLER

	var/list/friends = blackboard[BB_DOG_FRIENDS]
	if(!friends[speaker] || !(speaker in view(pawn, AI_DOG_VISION_RANGE)))
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words

	testing("made it to before checks, text: [spoken_text]")
	// heel: stop what you're doing, relax and try not to do anything for a little bit
	if(findtext(spoken_text, "heel") || findtext(spoken_text, "sit"))
		pawn.visible_message("<span class='notice'>[pawn]'s ears prick up at [speaker]'s voice, and [pawn.p_they()] sit[pawn.p_s()] down obediently, awaiting further orders.</span>")
		blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
		blackboard[BB_DOG_HEEL_CD] = world.time
		CancelActions()
	// fetch: whatever the speaker points to, try and bring it back
	else if(findtext(spoken_text, "fetch") || findtext(spoken_text, "get it"))
		pawn.visible_message("<span class='notice'>[pawn]'s ears prick up at [speaker]'s voice, and [pawn.p_they()] bounce[pawn.p_s()] slightly in anticipation.</span>")
		blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_FETCH
	// attack: harass whoever the speaker points to
	else if(findtext(spoken_text, "attack") || findtext(spoken_text, "sic"))
		pawn.visible_message("<span class='danger'>[pawn]'s ears prick up at [speaker]'s voice, and [pawn.p_they()] growl[pawn.p_s()] intensely.</span>") // imagine getting intimidated by a corgi
		blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_ATTACK
	else if(findtext(spoken_text, "play dead") || findtext(spoken_text, "die"))
		blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
		CancelActions()
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/play_dead)

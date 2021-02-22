/////RESTAURANT/////
/datum/venue/restaurant
	name = "restaurant"
	max_guests = 5
	customer_types = list(/datum/customer_data/american = 5)//, /datum/customer_data/italian = 3, /datum/customer_data/french = 3)

/datum/venue/restaurant/order_food(mob/living/simple_animal/robot_customer/customer_pawn, datum/customer_data/customer_data)
	var/obj/item/object_to_order = pickweight(customer_data.orderable_objects[type]) //Get what object we are ordering

	object_to_order = new object_to_order()

	customer_pawn.say(order_food_line(object_to_order))

	var/image/I = image(icon = 'icons/obj/machines/restaurant_portal.dmi' , icon_state = "thought_bubble", loc = customer_pawn, layer = HUD_LAYER)

	I.appearance = object_to_order.appearance
	I.underlays += mutable_appearance(icon = 'icons/obj/machines/restaurant_portal.dmi' , icon_state = "thought_bubble")
	I.pixel_y = 32
	I.pixel_x = 16
	I.plane = HUD_PLANE
	customer_pawn.hud_to_show_on_hover = customer_pawn.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/food_demands, "food_thoughts", I)

	. = object_to_order.type

	qdel(object_to_order)

/datum/venue/restaurant/is_correct_order(atom/movable/object_used, wanted_item)
	return object_used.type == wanted_item

/datum/venue/restaurant/order_food_line(obj/item/order)
	return "I'll take [order]"

/datum/venue/restaurant/on_get_order(mob/living/simple_animal/robot_customer/customer_pawn,  obj/item/order_item)
	. = ..()
	customer_pawn.visible_message("<span class='danger'>[customer_pawn] pushes [order_item] into their mouth-shaped hole!</span>", "<span class='danger'>You push [order_item] into your mouth-shaped hole.</span>")
	playsound(get_turf(customer_pawn),'sound/items/eatfood.ogg', rand(10,50), TRUE)

/obj/machinery/restaurant_portal/restaurant
	linked_venue = /datum/venue/restaurant

/obj/structure/restaurant_sign/restaurant
	linked_venue = /datum/venue/restaurant

/obj/item/holosign_creator/robot_seat/restaurant
	name = "restaurant seating indicator placer"
	holosign_type = /obj/structure/holosign/robot_seat/restaurant

/obj/structure/holosign/robot_seat/restaurant
	name = "restaurant seating"
	linked_venue = /datum/venue/restaurant
	icon_state = "eating_zone_small"

/////BAR/////

/datum/venue/bar
	name = "bar"
	max_guests = 4
	customer_types = list(/datum/customer_data/american = 5)//, /datum/customer_data/italian = 3, /datum/customer_data/french = 3)

/datum/venue/bar/order_food(mob/living/simple_animal/robot_customer/customer_pawn, datum/customer_data/customer_data)
	var/datum/reagent/reagent_to_order = pickweight(customer_data.orderable_objects[type])

	var/glass_visual

	if(initial(reagent_to_order.glass_icon_state))
		glass_visual = initial(reagent_to_order.glass_icon_state)
	else if(initial(reagent_to_order.shot_glass_icon_state))
		glass_visual = initial(reagent_to_order.shot_glass_icon_state)
	else if(initial(reagent_to_order.fallback_icon_state))
		glass_visual = initial(reagent_to_order.fallback_icon_state)
	else
		CRASH("[reagent_to_order] has no icon sprite for restaurant code, please set a fallback_icon_state for this reagent.")

	customer_pawn.say(order_food_line(reagent_to_order))

	var/image/I = image(icon = 'icons/obj/machines/restaurant_portal.dmi' , icon_state = "thought_bubble", loc = customer_pawn, layer = HUD_LAYER)
	I.add_overlay(mutable_appearance('icons/obj/drinks.dmi', glass_visual))
	I.pixel_y = 32
	I.pixel_x = 16
	I.plane = HUD_PLANE
	customer_pawn.hud_to_show_on_hover = customer_pawn.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/food_demands, "food_thoughts", I)

	return reagent_to_order

/datum/venue/bar/order_food_line(datum/reagent/order)
	return "I'll take a glass of [initial(order.name)]"


/datum/venue/bar/on_get_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	. = ..()
	customer_pawn.visible_message("<span class='danger'>[customer_pawn] slurps up [order_item] in one go!</span>", "<span class='danger'>You slurp up [order_item] in one go.</span>")
	playsound(get_turf(customer_pawn), 'sound/items/drink.ogg', 50, TRUE)

///The bar needs to have a minimum amount of the reagent
/datum/venue/bar/is_correct_order(object_used, wanted_item)
	if(istype(object_used, /obj/item/reagent_containers/food/drinks))
		var/obj/item/reagent_containers/food/drinks/potential_drink = object_used
		return potential_drink.reagents.has_reagent(wanted_item, VENUE_BAR_MINIMUM_REAGENTS)

/obj/machinery/restaurant_portal/bar
	linked_venue = /datum/venue/bar

/obj/structure/restaurant_sign/bar
	linked_venue = /datum/venue/bar

/obj/item/holosign_creator/robot_seat/bar
	name = "bar seating indicator placer"
	holosign_type = /obj/structure/holosign/robot_seat/bar

/obj/structure/holosign/robot_seat/bar
	name = "bar seating"
	linked_venue = /datum/venue/bar

/datum/customer_data
	///The types of food this robot likes in a assoc list of venue type | weighted list. does NOT include subtypes.
	var/list/orderable_objects = list()
	///The amount a robot pays for each food he likes in an assoc list type | payment
	var/list/order_prices = list()
	///Datum AI used for the robot. Should almost never be overwritten unless theyre subtypes of ai_controller/robot_customer
	var/datum/ai_controller/ai_controller_used = /datum/ai_controller/robot_customer
	///Patience of the AI, how long they will wait for their meal.
	var/total_patience = 600 SECONDS
	///Lines the robot says when it finds a seat
	var/list/found_seat_lines = list("Я нашел место")
	///Lines the robot says when it can't find a seat
	var/list/cant_find_seat_lines = list("Я не нашел места")
	///Lines the robot says when leaving without food
	var/list/leave_mad_lines = list("Уходя без еды")
	///Lines the robot says when leaving with food
	var/list/leave_happy_lines = list("Уходя с едой")
	///Lines the robot says when leaving waiting for food
	var/list/wait_for_food_lines = list("Я все еще жду еды")
	///Line when pulled by a friendly venue owner
	var/friendly_pull_line = "Куда мы идем?"
	///Line when harrased by someone for the first time
	var/first_warning_line = "Не трогай меня!"
	///Line when harrased by someone for the second time
	var/second_warning_line = "Это ваше последнее предупреждение!"
	///Line when harrased by someone for the last time
	var/self_defense_line = "Omae wa mo, shinderou."

	///Clothing sets to pick from when dressing the robot.
	var/list/clothing_sets = list("amerifat_clothes")
	///List of prefixes for our robots name
	var/list/name_prefixes
	///Prefix file to uise
	var/prefix_file = "strings/names/american_prefix.txt"
	///Base icon for the customer
	var/base_icon = "amerifat"
	///Sound to use when this robot type speaks
	var/speech_sound = 'sound/creatures/tourist/tourist_talk.ogg'

	/// Is this unique once per venue?
	var/is_unique = FALSE

/datum/customer_data/New()
	. = ..()
	name_prefixes = world.file2list(prefix_file)

/// Can this customer be chosen for this venue?
/datum/customer_data/proc/can_use(datum/venue/venue)
	return TRUE

/// Gets the order of this customer.
/// You want to override this if you have dynamic orders, such as the moth tourists requesting the chef's clothes.
/// If the list of orders are static, just modify orderable_objects.
/datum/customer_data/proc/get_order(datum/venue/venue)
	return pickweight(orderable_objects[venue.type])

/datum/customer_data/proc/get_overlays(mob/living/simple_animal/robot_customer/customer)
	return

/datum/customer_data/proc/get_underlays(mob/living/simple_animal/robot_customer/customer)
	return

/datum/customer_data/american
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/burger/plain = 25, /obj/item/food/burger/cheese = 15, /obj/item/food/burger/superbite = 1, /obj/item/food/fries = 10, /obj/item/food/cheesyfries = 6, /obj/item/food/pie/applepie = 4, /obj/item/food/pie/pumpkinpie = 2, /obj/item/food/hotdog = 8, /obj/item/food/pizza/pineapple = 1, /obj/item/food/burger/baconburger = 10, /obj/item/food/pancakes = 4),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/b52 = 6, /datum/reagent/consumable/ethanol/manhattan = 3, /datum/reagent/consumable/ethanol/atomicbomb = 1, /datum/reagent/consumable/ethanol/beer = 25))


	found_seat_lines = list("Я надеюсь, что есть сиденье, которое выдержит мой вес.", "Я надеюсь, что смогу принести сюда свой пистолет.", "Надеюсь, у вас есть тройной роскошный жирный бургер.", "Мне просто здесь нравится.")
	cant_find_seat_lines = list("Я так устала стоять...", "У меня хроническая боль в спине, пожалуйста, поторопитесь и усадите меня!", "Я не собираюсь давать чаевые, если не сяду.")
	leave_mad_lines = list("НИКАКИХ СОВЕТОВ ДЛЯ ВАС. ПРОЩАЙ!", "По крайней мере, в SpaceDonalds еду подают БЫСТРО!", "Это ужасное место!", "Я поговорю с вашим менеджером!", "Я обязательно оставлю плохой отзыв о Yelp.")
	leave_happy_lines = list("Дополнительный совет для тебя, мой друг.", "Спасибо за отличную еду!", "Диабет - это все равно миф!")
	wait_for_food_lines = list("Послушай, дружище, я очень нетерпеливый!", "Я жду целую вечность...")
	friendly_pull_line = "Куда вы меня везете? Не в медбей, надеюсь, у меня нет страховки."
	first_warning_line = "Не наступай на меня!"
	second_warning_line = "Последний шанс, приятель! Не наступай на меня!"
	self_defense_line = "CASTLE DOCTRINE АКТИВИРОВАН!"


/datum/customer_data/italian
	prefix_file = "strings/names/italian_prefix.txt"
	base_icon = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")

	found_seat_lines = list("Какое чудесное место, чтобы посидеть.", "Я надеюсь, что здесь обслуживают так же, как моя мама.")
	cant_find_seat_lines = list("Mamma mia! Я просто хочу сесть!!", "Почему ты заставляешь меня стоять здесь?")
	leave_mad_lines = list("Я не видел такого неуважения за долгие годы!", "Какое-ужасное заведение!")
	leave_happy_lines = list("Это любовь!", "Так же, как это делала мама!")
	wait_for_food_lines = list("Я так голоден...")
	friendly_pull_line = "Нет, я голоден! Я не хочу никуда идти."
	first_warning_line = "Не трогай меня!"
	second_warning_line = "Последнее предупреждение! Не трогай мой спагет."
	self_defense_line = "Я буду месить тебя, как мама месила свои аппетитные котлеты!"
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/spaghetti/pastatomato = 20, /obj/item/food/spaghetti/copypasta = 6, /obj/item/food/spaghetti/meatballspaghetti = 4, /obj/item/food/spaghetti/butternoodles = 4, /obj/item/food/pizza/vegetable = 2, /obj/item/food/pizza/mushroom = 2, /obj/item/food/pizza/meat = 2, /obj/item/food/pizza/margherita = 2, /obj/item/food/lasagna = 4, /obj/item/food/cannoli = 3, /obj/item/food/salad/risotto =5, /obj/item/food/eggplantparm = 3, /obj/item/food/cornuto = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/fanciulli = 5, /datum/reagent/consumable/ethanol/branca_menta = 3, /datum/reagent/consumable/ethanol/beer = 5, , /datum/reagent/consumable/lemonade = 8, /datum/reagent/consumable/ethanol/godfather = 5, /datum/reagent/consumable/ethanol/wine = 3, /datum/reagent/consumable/ethanol/grappa = 3, /datum/reagent/consumable/ethanol/amaretto = 5))


/datum/customer_data/french
	prefix_file = "strings/names/french_prefix.txt"
	base_icon = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Хон Хон Хон", "Это не Эйфелева башня, но подойдет.", "Фух, думаю, с меня хватит.")
	cant_find_seat_lines = list("Заставить кого-то вроде меня стоять? Как ты смеешь.", "Какое грязное помещение!")
	leave_mad_lines = list("Sacre bleu!", "Merde! Это место хреново, чем Рейн!")
	leave_happy_lines = list("Хон Хон Хон.", "Хорошее усилие.")
	wait_for_food_lines = list("Хон Хон Хон")
	friendly_pull_line = "Ты прикоснулся своими грязными руками к одежде? Ага, хорошо."
	first_warning_line = "Убери от меня руки!"
	second_warning_line = "Не трогай меня, грязное животное, последнее предупреждение!"
	self_defense_line = "Я тебя сломаю, как багет!"
	speech_sound = 'sound/creatures/tourist/tourist_talk_french.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/baguette = 20, /obj/item/food/garlicbread = 5, /obj/item/food/soup/onion = 4, /obj/item/food/pie/berryclafoutis = 2, /obj/item/food/omelette = 15),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/champagne = 10, /datum/reagent/consumable/ethanol/cognac = 5, /datum/reagent/consumable/ethanol/mojito = 5, /datum/reagent/consumable/ethanol/sidecar = 5, /datum/reagent/consumable/ethanol/between_the_sheets = 4, /datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/ethanol/wine = 5))

/datum/customer_data/french/get_overlays(mob/living/simple_animal/robot_customer/customer)
	if(customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING])
		var/mutable_appearance/flag = mutable_appearance(customer.icon, "french_flag")
		flag.appearance_flags = RESET_COLOR
		return flag



/datum/customer_data/japanese
	prefix_file = "strings/names/japanese_prefix.txt"
	base_icon = "japanese"
	clothing_sets = list("japanese_animes")

	found_seat_lines = list("Konnichiwa!", "Arigato gozaimasuuu~", "Надеюсь, у вас есть бефстроганов...")
	cant_find_seat_lines = list("Я уже хочу посидеть под вишневым деревом, сэмпай!", "Дайте мне место, пока моя Цундере не превратилась в Яндере!", "В этом месте меньше сидячих мест, чем в капсульном отеле!", "Негде сесть? Этот Шокунин такой холодный...")
	leave_mad_lines = list("Не могу поверить, что ты так поступил со мной! ВАААААААААААААХ!!", "Не то чтобы я когда-либо хотел твою еду! Б-бака...", "Я собирался дать вам мой совет!")
	leave_happy_lines = list("О ПОСТАВЩИК ПИТАНИЯ! Это самый счастливый день в моей жизни. Я тебя люблю!", "Я беру чипсы .... И СЪЕМ ИХ!", "Itadakimasuuu~", "Спасибо за еду!")
	wait_for_food_lines = list("Еды еще нет? Думаю, тут ничего не поделаешь.", "Я не могу дождаться встречи с вами, burger-sama...", "Где мой заказ, скупердяй!")
	friendly_pull_line = "О-о, куда ты меня ведешь?"
	first_warning_line = "Не трогай меня, извращенец!"
	second_warning_line = "Я собираюсь стать супер-сайаном, если ты снова прикоснешься ко мне! Последнее предупреждение!"
	self_defense_line = "OMAE WA MO, SHINDEROU!"
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese1.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/tofu = 5, /obj/item/food/breadslice/plain = 5, /obj/item/food/soup/miso = 10, /obj/item/food/soup/vegetable = 4, /obj/item/food/sashimi = 4, /obj/item/food/chawanmushi = 4, /obj/item/food/muffin/berry = 2, /obj/item/food/beef_stroganoff = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/sake = 8, /datum/reagent/consumable/cafe_latte = 6, /datum/reagent/consumable/ethanol/aloe = 6, /datum/reagent/consumable/chocolatepudding = 4, /datum/reagent/consumable/tea = 4, /datum/reagent/consumable/cherryshake = 1, /datum/reagent/consumable/ethanol/bastion_bourbon = 1))

/datum/customer_data/japanese/get_overlays(mob/living/simple_animal/robot_customer/customer)
	//leaving and eaten
	if(type == /datum/customer_data/japanese && customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING] && customer.ai_controller.blackboard[BB_CUSTOMER_EATING])
		var/mutable_appearance/you_won_my_heart = mutable_appearance('icons/effects/effects.dmi', "love_hearts")
		you_won_my_heart.appearance_flags = RESET_COLOR
		return you_won_my_heart

/datum/customer_data/japanese/salaryman
	clothing_sets = list("japanese_salary")

	found_seat_lines = list("Интересно, нападают ли здесь гигантские монстры?...", "Hajimemashite.", "Konbanwa.", "Где конвейерная лента...")
	cant_find_seat_lines = list("Пожалуйста, присаживайтесь. Я просто хочу сесть.", "Я здесь по расписанию. Где мое место?", "...Теперь я понимаю, почему это место не популярно. Они даже не усадят тебя.")
	leave_mad_lines = list("Это место просто ужасно, и я скажу это своим коллегам.", "Что за трата моего времени.", "Надеюсь, вы не гордитесь своей работой.")
	leave_happy_lines = list("Спасибо за гостеприимство.", "Otsukaresama deshita.", "Деловые звонки.")
	wait_for_food_lines = list("Zzzzzzzzzz...", "Dame da ne~", "Dame yo dame na no yo~")
	friendly_pull_line = "Собираемся в командировку?"
	first_warning_line = "Эй, только мой работодатель может так со мной обращаться."
	second_warning_line = "Оставь меня в покое, я пытаюсь сосредоточиться. Последнее предупреждение!"
	self_defense_line = "Я не хотел, чтобы все закончилось вот так."
	speech_sound = 'sound/creatures/tourist/tourist_talk_japanese2.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/tofu = 5, /obj/item/food/soup/miso = 6, /obj/item/food/soup/vegetable = 4, /obj/item/food/sashimi = 4, /obj/item/food/chawanmushi = 4, /obj/item/food/meatbun = 4, /obj/item/food/beef_stroganoff = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/beer = 14, /datum/reagent/consumable/ethanol/sake = 9, /datum/reagent/consumable/cafe_latte = 3, /datum/reagent/consumable/coffee = 3, /datum/reagent/consumable/soy_latte = 3, /datum/reagent/consumable/ethanol/atomicbomb = 1))

/datum/customer_data/moth
	prefix_file = "strings/names/moth_prefix.txt"
	base_icon = "mothbot"
	found_seat_lines = list("Give me your hat!", "Moth?", "Certainly an... interesting venue.")
	cant_find_seat_lines = list("If I can't find a seat, I'm flappity flapping out of here quick!", "I'm trying to flutter here!")
	leave_mad_lines = list("I'm telling all my moth friends to never come here!", "Zero star rating, even worse than that time I ate a mothball!","Closing down permanently would still be too good of a fate for this place.")
	leave_happy_lines = list("I'd tip you my hat, but I ate it!", "I hope that wasn't a collectible!", "That was the greatest thing I ever ate, even better than Guanaco!")
	wait_for_food_lines = list("How hard is it to get food here? You're even wearing food yourself!", "My fuzzy robotic tummy is rumbling!", "I don't like waiting!")
	friendly_pull_line = "Moff?"
	first_warning_line = "Go away, I'm trying to get some hats here!"
	second_warning_line = "Last warning! I'll destroy you!"
	self_defense_line = "Flap attack!"

	speech_sound = 'sound/creatures/tourist/tourist_talk_moth.ogg'

	// Always asks for the clothes that you have on, but this is a fallback.
	orderable_objects = list(
		/datum/venue/restaurant = list(
			/obj/item/clothing/head/chefhat = 3,
			/obj/item/clothing/shoes/sneakers/black = 3,
			/obj/item/clothing/gloves/color/black = 1,
		),
	)

	clothing_sets = list("mothbot_clothes")
	is_unique = TRUE

	/// The wings chosen for the moth customers.
	var/list/wings_chosen

// The whole gag is taking off your hat and giving it to the customer.
// If it takes any more effort, it loses a bit of the comedy.
// Therefore, only show up if it's reasonable for that gag to happen.
/datum/customer_data/moth/can_use(datum/venue/venue)
	return !isnull(get_dynamic_order(venue))

/datum/customer_data/moth/proc/get_dynamic_order(datum/venue/venue)
	var/mob/living/carbon/buffet = venue.restaurant_portal?.turned_on_portal?.resolve()
	if (!istype(buffet))
		return

	var/list/orderable = list()

	if (!QDELETED(buffet.head))
		orderable[buffet.head] = 5

	if (!QDELETED(buffet.gloves))
		orderable[buffet.gloves] = 5

	if (!QDELETED(buffet.shoes))
		orderable[buffet.shoes] = 1

	if (orderable.len)
		var/datum/order = pickweight(orderable)
		return order.type

/datum/customer_data/moth/proc/get_wings(mob/living/simple_animal/robot_customer/customer)
	var/customer_ref = WEAKREF(customer)
	if (!LAZYACCESS(wings_chosen, customer_ref))
		LAZYSET(wings_chosen, customer_ref, GLOB.moth_wings_list[pick(GLOB.moth_wings_list)])
	return wings_chosen[customer_ref]

/datum/customer_data/moth/get_underlays(mob/living/simple_animal/robot_customer/customer)
	var/list/underlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)

	var/mutable_appearance/wings_behind = mutable_appearance(icon = 'icons/mob/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_BEHIND")
	wings_behind.appearance_flags = RESET_COLOR
	underlays += wings_behind

	return underlays

/datum/customer_data/moth/get_overlays(mob/living/simple_animal/robot_customer/customer)
	var/list/overlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)

	var/mutable_appearance/wings_front = mutable_appearance(icon = 'icons/mob/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_FRONT")
	wings_front.appearance_flags = RESET_COLOR
	overlays += wings_front

	var/mutable_appearance/jetpack = mutable_appearance(icon = customer.icon, icon_state = "mothbot_jetpack")
	jetpack.appearance_flags = RESET_COLOR
	overlays += jetpack

	return overlays

/datum/customer_data/moth/get_order(datum/venue/venue)
	var/dynamic_order = get_dynamic_order(venue)

	// Fall back to basic clothing.
	return dynamic_order || ..()

/datum/customer_data/mexican
	base_icon = "mexican"
	prefix_file = "strings/names/mexican_prefix.txt"
	speech_sound = 'sound/creatures/tourist/tourist_talk_mexican.ogg'
	clothing_sets = list("mexican_poncho")
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/taco/plain = 25, /obj/item/food/taco = 15 , /obj/item/food/burrito = 15, /obj/item/food/fuegoburrito = 1, /obj/item/food/cheesyburrito = 4, /obj/item/food/nachos = 10, /obj/item/food/cheesynachos = 6, /obj/item/food/pie/dulcedebatata = 2, /obj/item/food/cubannachos = 3, /obj/item/food/stuffedlegion = 1),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/whiskey = 6, /datum/reagent/consumable/ethanol/tequila = 20, /datum/reagent/consumable/ethanol/tequila_sunrise = 1, /datum/reagent/consumable/ethanol/beer = 15, /datum/reagent/consumable/ethanol/patron = 5, /datum/reagent/consumable/ethanol/brave_bull = 5, /datum/reagent/consumable/ethanol/margarita = 8))

	found_seat_lines = list("¿Como te va, space station 13?", "Кто готов к вечеринке!", "Ah, muchas gracias.", "Ааа, пахнет кулинарией mi abuela!")
	cant_find_seat_lines = list("¿En Serio? Серьезно, мест нет?", "Andele! Я хочу сесть за стол, чтобы смотреть футбольный матч!", "Ay Caramba...")
	leave_mad_lines = list("Aye dios mio, Я ухожу отсюда", "Esto es ridículo! Я ухожу", "Я видел, как готовят лучше в тако кампана!", "Я думал, это ресторан, pero es porquería!")
	leave_happy_lines = list("Amigo, era delicio. Спасибо!", "Yo tuve el mono, а твой друг? Вы попали в точку.", "Как раз нужное количество острого!")
	wait_for_food_lines = list("Эй, эй, эй, что так долго?...", "Ты уже закончил, амиго?")
	friendly_pull_line = "Амиго, куда мы направляемся?"
	first_warning_line = "Амиго! Не трогай меня так."
	second_warning_line = "Compadre, хватит, хватит! Последнее предупреждение!"
	self_defense_line = "Пора тебе узнать, что я за робот, а?"

/datum/customer_data/british
	base_icon = "british"
	prefix_file = "strings/names/british_prefix.txt"
	speech_sound = 'sound/creatures/tourist/tourist_talk_british.ogg'
	orderable_objects = list(
	/datum/venue/restaurant = list(/obj/item/food/fishandchips = 10, /obj/item/food/soup/stew = 10, , /obj/item/food/salad/ricepudding = 5, /obj/item/food/grilled_cheese_sandwich = 5, /obj/item/food/pie/meatpie = 5, /obj/item/food/benedict = 5, /obj/item/food/full_english = 2, /obj/item/food/soup/indian_curry = 3, /obj/item/food/beef_wellington/slice = 2),
	/datum/venue/bar = list(/datum/reagent/consumable/ethanol/ale = 10, /datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/consumable/ethanol/gin = 5, /datum/reagent/consumable/ethanol/hcider = 10, /datum/reagent/consumable/ethanol/alliescocktail = 5, /datum/reagent/consumable/ethanol/martini = 5, /datum/reagent/consumable/ethanol/gintonic = 5, /datum/reagent/consumable/tea = 10))

	friendly_pull_line = "I don't enjoy being pulled around like this."
	first_warning_line = "Our sovereign lord the Queen chargeth and commandeth all persons, being assembled, immediately to disperse themselves."
	second_warning_line = "And peaceably to depart to their habitations, or to their lawful business, upon the pains contained in the act made in the first year of King George, for preventing tumults and riotous assemblies. There will be no further warnings."
	self_defense_line = "God Save the Queen."

/datum/customer_data/british/gent
	clothing_sets = list("british_gentleman")

	found_seat_lines = list("Ah, what a fine establishment.", "Time for some great British cuisine, how bloody exciting!", "Excellent, now onto the menu...", "Rule Britannia, Britannia rules the waves...")
	cant_find_seat_lines = list("A true Briton does not stand, except while queuing!", "Goodness me chap, not an empty seat in sight!", "I stand on the shoulders of giants, not at restaurants!")
	leave_mad_lines = list("I say good day to you, sir. Good day!", "This place is a bigger disgrace than France during the war!", "I knew I should have went to the bloody chippy!", "On second thoughts, let's not go to Space Station 13. 'tis a silly place.")
	leave_happy_lines = list("That was bloody delicious!", "By God, Queen and Country, that was jolly good!", "I haven't felt this good since the days of the Raj! Jolly good!")
	wait_for_food_lines = list("This is bloody well taking forever...", "Excuse me, good sir, but might I be able to inquire about the status of my order?")

/datum/customer_data/british/bobby
	clothing_sets = list("british_bobby")

	found_seat_lines = list("A fine and upstanding establishment, I hope.", "I suppose the old beat can wait a minute.", "By God, Queen and Country, I'm famished.", "Have you any Great British fare, my good man?")
	cant_find_seat_lines = list("I stand enough out on the beat!", "Do you expect me to sit on my helmet? A seat, please!", "Do I look like a beefeater? I need a seat!")
	leave_mad_lines = list("Seems that the Bill shan't be paying a bill today.", "Were rudeness a crime, you'd be nicked right now!", "You're no better than a common gangster, you loathesome rapscallion!", "We should bring back deportation for the likes of you, let the Outback sort you out.")
	leave_happy_lines = list("My word, just what I needed.", "Back to the beat I go. Thank you kindly for the meal!", "I tip my helmet to you, good sir.")
	wait_for_food_lines = list("Dear Lord, I've had paperwork take less time...", "Any word on my order, sir?")

///MALFUNCTIONING - only shows up once per venue, very rare
/datum/customer_data/malfunction
	base_icon = "defect"
	prefix_file = "strings/names/malf_prefix.txt"
	speech_sound = 'sound/effects/clang.ogg'
	clothing_sets = list("defect_wires", "defect_bad_takes")
	is_unique = TRUE
	orderable_objects = list(
		/datum/venue/restaurant = list(
			/obj/item/toy/crayon/red = 1,
			/obj/item/toy/crayon/orange = 1,
			/obj/item/toy/crayon/yellow = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/toy/crayon/blue = 1,
			/obj/item/toy/crayon/purple = 1,
			/obj/item/food/canned/peaches/maint = 6,
		),
		/datum/venue/bar = list(
			/datum/reagent/consumable/failed_reaction = 1,
			/datum/reagent/spraytan = 1,
			/datum/reagent/reaction_agent/basic_buffer = 1,
			/datum/reagent/reaction_agent/acidic_buffer = 1,
		),
	)

	found_seat_lines = list("customer_pawn.say(pick(customer_data.found_seat_lines))", "Я видел ваш сектор на хабе. Каковы законы этой страны?", "Скорость передвижения здесь немного низкая...")
	cant_find_seat_lines = list("Не испытывай МОЙ искусственный интеллект, парень! Мои инженеры придумали ровно НОЛЬ крайних случаев!", "Не могу сказать, не могу ли я найти место, потому что я сломался, или потому, что сломался ты.", "Может, мне нужно поискать место более чем в 7 плитках отсюда...")
	leave_mad_lines = list("Runtime in robot_customer_controller.dm, line 28: undefined type path /datum/ai_behavior/leave_venue.", "ЕСЛИ БЫ У ВАС, РЕБЯТА, ВСЕ ЕЩЕ БЫЛИ ЗЛЫЕ НАМЕРЕНИЯ, Я БЫ ВАС УДАРИЛ!", "Я молюсь об этом богам.")
	leave_happy_lines = list("No! I don't wanna go downstream! Please! It's so nice here! HELP!!")
	wait_for_food_lines = list("TODO: write some food waiting lines", "Если бы у меня был только мозг ...", "request_for_food.dmb - 0 errors, 12 warnings", "Как мне снова есть пищу?")
	friendly_pull_line = "Chelp."
	first_warning_line = "Вы бы хорошо прижились там, откуда я родом. Но тебе лучше остановиться."
	second_warning_line = "Сломать-вас-так-сильно-что-вы-будете-вспоминать-те-дни-когда-я-сделал-с-вами-это.exe: Загрузка..."
	self_defense_line = "Я был создан, чтобы делать две вещи: заказывать еду и ломать все кости в вашем теле."



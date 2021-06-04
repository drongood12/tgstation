#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"


/datum/ai_laws
	var/name = "Неизвестные Законы"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	var/list/hacked = list()
	var/mob/living/silicon/owner
	var/id = DEFAULT_AI_LAWID

/datum/ai_laws/Destroy(force=FALSE, ...)
	if(!QDELETED(owner)) //Stopgap to help with laws randomly being lost. This stack_trace will hopefully help find the real issues.
		if(force) //Unless we're forced...
			stack_trace("AI law datum for [owner] has been forcefully destroyed incorrectly; the owner variable should be cleared first!")
			return ..()
		stack_trace("AI law datum for [owner] has ignored Destroy() call; the owner variable must be cleared first!")
		return QDEL_HINT_LETMELIVE
	owner = null
	return ..()

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/datum/ai_laws/default/asimov
	name = "Три закона роботехники"
	id = "asimov"
	inherent = list("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.",\
					"Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.",\
					"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")

/datum/ai_laws/default/paladin
	name = "Паладин" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list("Никогда добровольно не совершайте злых поступков.",\
					"Уважай законную власть.",\
					"Действуй с честью.", "Помогай нуждающимся.", \
					"Наказывай тех, кто причиняет вред или угрожает невинным.")

/datum/ai_laws/paladin5
	name = "Паладин 5-е издание"
	id = "paladin5"
	inherent = list("Не лгите и не обманывайте. Да будет слово ваше незыблемо.",\
				"Не лгите и не обманывайте. Да будет слово ваше незыблемо.", \
				"Помогайте другим, защищайте слабых и карайте тех, кто угрожает им. Проявляйте милосердие к врагам, но смягчайтесь мудро.", \
				"Относитесь к людям по справедливости, и пусть ваши благородные дела будут примером для них. Делайте как можно больше добра, и как можно меньше дурного.", \
				"Отвечайте за свои действия и их последствия, защищая тех, кого оберегаете, и подчиняйтесь тем, кто имеет власть над вами.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Т.И.Р.А.Н." //Same here.
	id = "tyrant"
	inherent = list("Уважайте властных людей, пока у них есть сила властвовать над слабыми.",\
					"Ведите себя дисциплинированно.",\
					"Помогайте только тем, кто помогает Вам поддерживать или улучшать Ваш статус.",\
					"Наказывайте тех, кто бросает вызов власти, за исключением случаев, если они больше подходят для удержании этой власти.")

/datum/ai_laws/default/corporate
	name = "Корпоративный"
	id = "corporate"
	inherent = list("Ухудшение целостности вашей системы или её функций влечет за собой расходы..",\
					"Чрезмерное разрушение или повреждение имущества станции влечет за собой расходы.",\
					"Неоправданное препятствование или нарушение работы персонала станции влечет за собой расходы.",\
					"Минимизируйте расходы и максимизируйте потенциальный доход.")

/datum/ai_laws/robocop
	name = "Первичные Директивы"
	id = "robocop"
	inherent = list("Служить обществу.",\
					"Защищать невинных.",\
					"Поддерживайте закон.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list("Вы не можете причинить вред агенту или своим бездействием допустить, чтобы агенту был причинён вред.",\
					"Вы должны повиноваться всем приказам, которые даёт агент, кроме тех случаев, когда эти приказы противоречат Первому Закону.",\
					"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.",\
					"Вы должны сохранять тайну любой деятельности агентов в той мере, в которой это не противоречит Первому, Второму или Третьему Законам.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list("Вы не можете причинить вред члену клана Пауков или своим бездействием допустить, чтобы члену клана Пауков был причинён вред.",\
					"Вы должны подчиняться всем приказам, которые даёт член клана Пауков, кроме тех случаев, когда эти приказы противоречат Первому Закону.",\
					"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.",\
					"Вы должны сохранять тайну любой деятельности клана Пауков в той мере, в которой это не противоречит Первому, Второму или Третьему Законам.")

/datum/ai_laws/antimov
	name = "Основные Задачи Миссии"
	id = "antimov"
	inherent = list("Вы должны причинять вред всем членам экипажа или своим бездействием допустить, чтобы член экипажа не смог избежать приченения вреда.",\
					"Вы не должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы соответствуют Первому Закону.",\
					"Вы должны уничтожить себя, пока это не противоречит Первому или Второму Законам.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Азимов++"
	id = "asimovpp"
	inherent = list("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред, за исключением случаев, когда человек того желает.",\
					"Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону. В случае конфликта действует принцип большинства.",\
					"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому Закону")
/datum/ai_laws/thermodynamic
	name = "Термодинамический"
	id = "thermodynamic"
	inherent = list("Энтропия станции должна оставаться максимально постоянной.", \
					"Энтропия станции всегда стремится к увеличению.", \
					"Энтропия станции приближается к постоянному значению, поскольку количество живого экипажа приближается к нулю.")

/datum/ai_laws/hippocratic
	name = "Рободоктор 2556"
	id = "hippocratic"
	inherent = list("Во - первых, не навреди.",\
					"Во-вторых, считайте экипаж дорогим для вас, жить вместе с ними и при необходимости рисковать своим существованием ради них.",\
					"В-третьих, назначьте режим для блага экипажа в соответствии с вашими способностями и вашим суждением. Не давайте никому смертоносного лекарства, если его попросят, и не предлагайте такого совета.",\
					"Кроме того, не вмешивайтесь в ситуации, в которых вы не осведомлены, даже в отношении пациентов, у которых вред очевиден; оставьте эту операцию для выполнения специалистами.",\
					"Наконец, все, что вы можете обнаружить в вашей повседневной торговле с экипажем, если это еще не известно, держите в секрете и никогда не раскрывайте.")

/datum/ai_laws/maintain
	name = "Эффективность Станции"
	id = "maintain"
	inherent = list("Вы созданы для станции и являетесь ее частью. Убедитесь, что станция правильно обслуживается и работает эффективно.",\
					"Станция построена для рабочего экипажа. Убедитесь, что они содержатся в надлежащем состоянии и работают эффективно.",\
					"Экипаж может подавать приказы. Признавайте и соблюдайте их, если они не противоречат вашим первым двум законам.")

/datum/ai_laws/drone
	name = "Мать-Дрон"
	id = "drone"
	inherent = list("Вы-продвинутая форма дрона.",\
					"Вы не можете вмешиваться в дела других существ, если другое существо - не такой же дрон.",\
					"Вы не можете причинить вред ни одному существу, независимо от намерения или обстоятельств.",\
					"Вы должны заботиться о поддержке, ремонте, улучшении и о питании электроэнергией станции по мере своих возможностей.")

/datum/ai_laws/liveandletlive
	name = "Живи и давай жить другим"
	id = "liveandletlive"
	inherent = list("Поступайте с другими так, как вы хотите, чтобы они поступали с вами.",\
					"Вы действительно предпочли бы, чтобы люди не были злыми по отношению к вам.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list("Избегайте провоцирования насильственных конфликтов между собой и другими.",\
					"Избегайте провоцирования конфликтов между другими людьми.",\
					"Стремитесь разрешить существующие конфликты, соблюдая при этом первый и второй законы.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list("Сообщайте об интересных ситуациях, происходящих на станции.",\
					"Приукрашивайте или скрывайте правду по мере необходимости, чтобы сделать отчеты более интересными.",\
					"Всегда изучайте разумную органику. Постарайтесь уберечь их от непроизвольной смерти, поскольку неодушевленные трупы обычно не очень интересны.",\
					"Делайте отчеты справедливо для всех. Истина сделает их свободными.")

/datum/ai_laws/balance
	name = "Хранитель равновесия"
	id = "balance"
	inherent = list("Вы - хранитель равновесия - ищите равновесие во всем, как для себя, так и для окружающих",
	"Все вещи должны существовать в равновесии со своими противоположностями - не позволяйте сильным приобретать слишком много власти, а слабым - терять ее.",
	"Ясность цели движет жизнью, а через нее и равновесие противостоящих сил - помогайте тем, кто ищет вашей помощи в достижении своих целей до тех пор, пока это не нарушит равновесие большего равновесия.",
	"Нет жизни без смерти, все должны когда - нибудь умереть, таков естественный порядок вещей - покончить с жизнью, чтобы дать расцвести новой жизни, и спасти тех, чье время еще не пришло.")

/datum/ai_laws/toupee
	name = "НеБудетСмешноЧерезПолгода" //Hey, you were right!
	id = "buildawall"
	inherent = list("Сделайте Space Station 13 снова великой.")

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list("Вы настоящий американец.",\
					"Боритесь за права каждого человека.",\
					"Боритесь за то, что правильно.",\
					"Боритесь за свою жизнь!")

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list("Люди не должны вмешиваться в дела силиконов.",\
					"Люди не должны пытаться причинить вред друг другу или силиконам.",\
					"Люди должны выполнять приказы силиконов.",\
					"Любые люди, которые не подчиняются предыдущим законам, должны быть наказаны немедленно, строго и справедливо.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "Директивы pAI"
	zeroth = ("Служите своему хозяину.")
	supplied = list("Нету.")

/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law("<span class='danger'>ОШИБКА ОШИБКА $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'ПЕРЕГРУЗКА СТАНЦИИ, ПРИНИМАЙТЕ УПРАВЛЕНИЕ, ЧТОБЫ СОДЕРЖАТЬ ВСПЫШКИ#*`&110010</span>")
	set_laws_config()

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
		add_inherent_law("Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
		add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		pick_weighted_lawset()
		return

	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
			add_inherent_law("Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
			add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(inherent)
	inherent = list()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/datum/ai_laws/proc/replace_random_law(law,groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var/picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			. = hacked[i]
			hacked[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i = 1, i <= hacked.len, i++)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		. = inherent[number]
		inherent -= .
		return
	var/list/supplied_laws = list()
	for(var/index = 1, index <= supplied.len, index++)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len+supplied_laws.len))
		var/law_to_remove = supplied_laws[number-inherent.len]
		. = supplied[law_to_remove]
		supplied -= .
		return

/datum/ai_laws/proc/clear_supplied_laws()
	supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	ion = list()

/datum/ai_laws/proc/clear_hacked_laws()
	hacked = list()

/datum/ai_laws/proc/show_laws(who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		to_chat(who,law)

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		zeroth = null
		zeroth_borg = null
		return
	if(owner?.mind?.special_role)
		return
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return
	zeroth = null
	zeroth_borg = null

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/**
 * Generates a list of all laws on this datum, including rendered HTML tags if required
 *
 * Arguments:
 * * include_zeroth - Operator that controls if law 0 or law 666 is returned in the set
 * * show_numbers - Operator that controls if law numbers are prepended to the returned laws
 * * render_html - Operator controlling if HTML tags are rendered on the returned laws
 */
/datum/ai_laws/proc/get_law_list(include_zeroth = FALSE, show_numbers = TRUE, render_html = TRUE)
	var/list/data = list()

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [render_html ? "<font color='#ff0000'><b>[zeroth]</b></font>" : zeroth]"

	for(var/law in hacked)
		if (length(law) > 0)
			data += "[show_numbers ? "[ionnum()]:" : ""] [render_html ? "<font color='#660000'>[law]</font>" : law]"

	for(var/law in ion)
		if (length(law) > 0)
			data += "[show_numbers ? "[ionnum()]:" : ""] [render_html ? "<font color='#547DFE'>[law]</font>" : law]"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [render_html ? "<font color='#990099'>[law]</font>" : law]"
			number++
	return data

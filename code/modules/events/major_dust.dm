/datum/round_event_control/meteor_wave/major_dust
	name = "Major Space Dust"
	typepath = /datum/round_event/meteor_wave/major_dust
	weight = 8

/datum/round_event/meteor_wave/major_dust
	wave_name = "space dust"

/datum/round_event/meteor_wave/major_dust/announce(fake)
	var/reason = pick(
		"Станция проходит сквозь облако обломков, ожидайте незначительных повреждений \
		внешней арматуры и оборудования.",
		"Подразделение Нанотразен Супероружие тестирует новый прототип \
		[pick("защитную","\[REDACTED\]","Икс","Супер-Коллапсную","Реактивную")] \
		[pick("пушку -","артилерийскую","управляемую","разрушающую","\[REDACTED\]")], \
		[pick("самонаводку","\[REDACTED\]")], \
		ожидается небольшой мусор.",
		"Соседняя станция запускает в вас камни. (Возможно, они \
		устали от ваших сообщений.)")
	priority_announce(pick(reason), "Предупреждение о столкновении")

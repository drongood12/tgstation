/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10

/datum/round_event/mice_migration
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce(fake)
	var/cause = pick("космической зимы", "сокращения бюджета", "космического скейтбордиста",
		"космического потепления", "\[REDACTED\]", "неизвестной причины",
		"bad luck")
	var/plural = pick("много", "очень много", "мало", "рой",
		"поток", "около [maximum_mice]")
	var/name = pick("грызунов", "мышей", "пищащих штук",
		"пожирателей проводов", "\[REDACTED\]", "любителей оставить станцию без электричества")
	var/movement = pick("мигрировали", "проникли", "\[REDACTED\]", "появились")
	var/location = pick("технических туннелях", "технических зонах",
		"\[REDACTED\]", "местах со всеми этими сочными проводами")

	priority_announce("Из-за [cause], [plural] [name] [movement] \
		в [location].", "Уведомление о миграции",
		'sound/effects/mousesqueek.ogg')

/datum/round_event/mice_migration/start()
	SSminor_mapping.trigger_migration(rand(minimum_mice, maximum_mice))

/datum/round_event_control/meteor_wave/meaty
	name = "Meteor Wave: Meaty"
	typepath = /datum/round_event/meteor_wave/meaty
	weight = 2
	max_occurrences = 1

/datum/round_event/meteor_wave/meaty
	wave_name = "meaty"

/datum/round_event/meteor_wave/meaty/announce(fake)
	priority_announce("На курсе столкновения со станцией были обнаружены мясистые метеоры.", "Вот дерьмо, тащите шварбру.",'sound/ai/meteors.ogg')

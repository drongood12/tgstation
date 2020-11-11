/**
  * An event which decreases the station target temporarily, causing the inflation var to increase heavily.
  *
  * Done by decreasing the station_target by a high value per crew member, resulting in the station total being much higher than the target, and causing artificial inflation.
  */
/datum/round_event_control/market_crash
	name = "Market Crash"
	typepath = /datum/round_event/market_crash
	weight = 10

/datum/round_event/market_crash
	var/market_dip = 0

/datum/round_event/market_crash/setup()
	startWhen = 1
	endWhen = rand(25, 50)
	announceWhen = 2

/datum/round_event/market_crash/announce(fake)
	var/list/poss_reasons = list("попыток стабилизировать цены",\
		"проблемм на рынке",\
		"ошибок B.E.P.I.S.",\
		"Terragov и её валюты",\
		"сильно преувеличенных сообщениях о массовых самоубийствах сотрудников бухгалтерии Нанотразен")
	var/reason = pick(poss_reasons)
	priority_announce("Из-за [reason], цены для продажи в торговых автоматах на станции будут повышены на короткий период.", "Отдел бухгалтерского учета Нанотразен")

/datum/round_event/market_crash/start()
	. = ..()
	market_dip = rand(1000,10000) * length(SSeconomy.bank_accounts_by_id)
	SSeconomy.station_target = max(SSeconomy.station_target - market_dip, 1)
	SSeconomy.price_update()
	SSeconomy.market_crashing = TRUE

/datum/round_event/market_crash/end()
	. = ..()
	SSeconomy.station_target += market_dip
	SSeconomy.market_crashing = FALSE
	SSeconomy.price_update()
	priority_announce("Цены для продажи были стабилизированы в торговых автоматах.", "Отдел бухгалтерского учета Нанотразен")


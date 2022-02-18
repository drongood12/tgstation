/// The color admins will speak in for OOC.
/datum/preference/color/ooc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ooccolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/ooc_color/create_default_value()
	return "#c43b23"

/datum/preference/color/ooc_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content

/datum/preference/color/looc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "looccolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/looc_color/create_default_value()
	return "#3846fd"

/datum/preference/color/looc_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content

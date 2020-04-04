/**
  * # Destructive Scanning Experiment
  *
  * This is the base implementation of destructive scanning experiments.
  *
  * This class should be subclassed for producing actual experiments. The
  * procs should be extended where necessary.
  */
/datum/experiment/scanning/destructive
	name = "Destructive Scanning Experiment"
	description = "Base experiment for destructively scanning atoms"
	exp_tag = "Destructive Scan"

/**
  * Initializes the scanned atoms lists
  *
  * Initializes the internal scanned atoms list to keep a counter for each atom
  * Note we do not keep track of items scanned as they are destroyed after scanning
  */
/datum/experiment/scanning/destructive/New()
	for (var/a in required_atoms)
		scanned[a] = 0

/datum/experiment/scanning/destructive/is_complete()
	. = TRUE
	for (var/a in required_atoms)
		if (!(a in scanned) || scanned[a] != required_atoms[a])
			return FALSE

/datum/experiment/scanning/destructive/check_progress()
	var/list/status = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		var/remaining = required_atoms[a] - (scanned[a] ? scanned[a] : 0)
		if (remaining)
			status += " - Scan [remaining] more sample[remaining > 1 ? "s" : ""] of \a [initial(a.name)]"
	return "The following items must be scanned:\n" + jointext(status, ", \n")

/**
  * Attempts to scan an atom towards the experiment's goal
  *
  * This proc attempts to scan an atom towards the experiment's goal,
  * and returns TRUE/FALSE based on success. It also deletes the item if
  * successfully scanned
  * Arguments:
  * * target - The atom to attempt to scan
  */
/datum/experiment/scanning/destructive/do_action(atom/target)
	var/idx = get_contributing_index(target)
	if (idx)
		scanned[idx]++
		qdel(target)
		return TRUE

/datum/experiment/scanning/destructive/get_contributing_index(atom/target)
	for (var/a in required_atoms)
		if (istype(target, a) && (a in scanned) && scanned[a] < required_atoms[a])
			return a

/datum/experiment/scanning/destructive/sabotage()
	var/list/valid_targets = list()
	for (var/a in scanned)
		if (scanned[a] > 0)
			valid_targets += a

	if (valid_targets.len > 0)
		scanned[pick(valid_targets)]--
		return TRUE

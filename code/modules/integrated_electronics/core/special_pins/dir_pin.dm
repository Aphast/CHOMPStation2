// These pins can only contain directions (1,2,4,8...) or null.
/datum/integrated_io/dir
	name = "dir pin"

/datum/integrated_io/dir/ask_for_pin_data(mob/user)
	var/new_data = tgui_input_number(user, "Please type in a valid dir number.  \
	Valid dirs are;\n\
	North/Fore = [NORTH],\n\
	South/Aft = [SOUTH],\n\
	East/Starboard = [EAST],\n\
	West/Port = [WEST],\n\
	Northeast = [NORTHEAST],\n\
	Northwest = [NORTHWEST],\n\
	Southeast = [SOUTHEAST],\n\
	Southwest = [SOUTHWEST],\n\
	Up = [UP],\n\
	Down = [DOWN]","[src] dir writing")
	if(isnum(new_data) && holder.check_interactivity(user) )
		to_chat(user, span_notice("You input [new_data] into the pin."))
		write_data_to_pin(new_data)

/datum/integrated_io/dir/write_data_to_pin(var/new_data)
	if(isnull(new_data) || (new_data in (GLOB.alldirs + list(UP, DOWN))))
		data = new_data
		holder.on_data_written()

/datum/integrated_io/dir/display_pin_type()
	return IC_FORMAT_DIR

/datum/integrated_io/dir/display_data(var/input)
	if(!isnull(data))
		return "([dir2text(data)])"
	return ..()

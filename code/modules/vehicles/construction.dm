/*
 * Construction!
 */

/obj/item/vehicle_assembly
	name = "vehicle assembly"
	desc = "The frame of some vehicle."
	icon = 'icons/obj/vehicles_64x64.dmi'
	icon_state = "quad-frame"
	item_state = "buildpipe"

	density = TRUE
	slowdown = 10 //It's a vehicle frame, what do you expect?
	w_class = 5

	var/build_stage = 0
	var/obj/item/cell/cell = null

/obj/item/vehicle_assembly/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)][build_stage]"
	update_icon()

/obj/item/vehicle_assembly/proc/increase_step(var/new_name = null)
	build_stage++
	if(new_name)
		name = new_name
	icon_state = "[initial(icon_state)][build_stage]"
	update_icon()
	return 1

/*
 * Quadbike and trailer.
 */

/obj/item/vehicle_assembly/quadbike
	name = "all terrain vehicle assembly"
	desc = "The frame of an ATV."
	icon_state = "quad-frame"
	pixel_x = -16

/obj/item/vehicle_assembly/quadbike/attackby(var/obj/item/W as obj, var/mob/user as mob)
	..()

	switch(build_stage)
		if(0)
			if(istype(W, /obj/item/stack/material/plastic))
				var/obj/item/stack/material/plastic/P = W
				if (P.get_amount() < 8)
					to_chat(user, span_warning("You need eight sheets of plastic to add tires to \the [src]."))
					return
				to_chat(user, span_notice("You start to add tires to [src]."))
				if(do_after(user, 40) && build_stage == 0)
					if(P.use(8))
						to_chat(user, span_notice("You add tires to \the [src]."))
						increase_step("wheeled [initial(name)]")
				return

		if(1)
			if(istype(W, /obj/item/stock_parts/console_screen))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the lights to \the [src]."))
				increase_step()
				return

		if(2)
			if(istype(W, /obj/item/stock_parts/spring))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the control system to \the [src]."))
				increase_step()
				return
			if(istype(W, /obj/item/stack/material/steel))
				var/obj/item/stack/material/steel/S = W
				if(S.get_amount() < 5)
					to_chat(user, span_warning("You need five sheets of steel to convert \the [src] into a trailer."))
				if(do_after(user, 80) && build_stage == 2)
					if(S.use(5))
						var/obj/item/vehicle_assembly/quadtrailer/Trailer = new(src)
						Trailer.forceMove(get_turf(src))
						Trailer.increase_step("framed [initial(Trailer.name)]")
						to_chat(user, span_notice("You convert \the [src] into \the [Trailer]."))
						user.drop_from_inventory(src)
						qdel(src)
				return

		if(3)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if (C.get_amount() < 2)
					to_chat(user, span_warning("You need two coils of wire to wire [src]."))
					return
				to_chat(user, span_notice("You start to wire [src]."))
				if(do_after(user, 40) && build_stage == 3)
					if(C.use(2))
						to_chat(user, span_notice("You wire \the [src]."))
						increase_step("wired [initial(name)]")
				return

		if(4)
			if(istype(W, /obj/item/cell))
				user.drop_item()
				W.forceMove(src)
				cell = W
				to_chat(user, span_notice("You add the power supply to \the [src]."))
				increase_step("powered [initial(name)]")
				return

		if(5)
			if(istype(W, /obj/item/stock_parts/motor))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the motor to \the [src]."))
				increase_step()
				return

		if(6)
			if(istype(W, /obj/item/stack/material/plasteel))
				var/obj/item/stack/material/plasteel/PL = W
				if (PL.get_amount() < 2)
					to_chat(user, span_warning("You need two sheets of plasteel to add reinforcement to \the [src]."))
					return
				to_chat(user, span_notice("You start to add reinforcement to [src]."))
				if(do_after(user, 40) && build_stage == 6)
					if(PL.use(2))
						to_chat(user, span_notice("You add reinforcement to \the [src]."))
						increase_step("reinforced [initial(name)]")
					return

		if(7)
			if(W.has_tool_quality(TOOL_WRENCH) || W.has_tool_quality(TOOL_SCREWDRIVER))
				playsound(src, W.usesound, 50, 1)
				to_chat(user, span_notice("You begin your finishing touches on \the [src]."))
				if(do_after(user, 20) && build_stage == 7)
					playsound(src, W.usesound, 30, 1)
					var/obj/vehicle/train/engine/quadbike/built/product = new(src)
					to_chat(user, span_notice("You finish \the [product]"))
					product.loc = get_turf(src)
					product.cell = cell
					cell.forceMove(product)
					cell = null
					user.drop_from_inventory(src)
					qdel(src)
				return
	..()

/obj/item/vehicle_assembly/quadtrailer
	name = "all terrain trailer"
	desc = "The frame of a small trailer."
	icon_state = "quadtrailer-frame"
	pixel_x = -16

/obj/item/vehicle_assembly/quadtrailer/attackby(var/obj/item/W as obj, var/mob/user as mob)
	..()

	switch(build_stage)
		if(0)
			if(istype(W, /obj/item/vehicle_assembly/quadbike))
				var/obj/item/vehicle_assembly/quadbike/Q = W
				if(Q.build_stage > 2)
					to_chat(user, span_notice("\The [Q] is too advanced to be of use with \the [src]"))
					return
				user.drop_item()
				qdel(W)
				increase_step("framed [initial(name)]")

		if(1)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if (C.get_amount() < 2)
					to_chat(user, span_warning("You need two coils of wire to wire [src]."))
					return
				to_chat(user, span_notice("You start to wire [src]."))
				if(do_after(user, 40) && build_stage == 1)
					if(C.use(2))
						to_chat(user, span_notice("You wire \the [src]."))
						increase_step("wired [initial(name)]")
				return

		if(2)
			if(W.has_tool_quality(TOOL_SCREWDRIVER))
				playsound(src, W.usesound, 50, 1)
				to_chat(user, span_notice("You close up \the [src]."))
				var/obj/vehicle/train/trolley/trailer/product = new(src)
				product.loc = get_turf(src)
				user.drop_from_inventory(src)
				qdel(src)
				return

/*
 * Space bike.
 */

/obj/item/vehicle_assembly/spacebike
	name = "vehicle assembly"
	desc = "The frame of some vehicle."
	icon = 'icons/obj/bike.dmi'
	icon_state = "bike-frame"

	pixel_x = 0

/obj/item/vehicle_assembly/spacebike/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build_stage)
		if(0)
			if(istype(W, /obj/item/tank/jetpack) || istype(W, /obj/item/borg/upgrade/advanced/jetpack))
				user.drop_item()
				qdel(W)
				increase_step()

		if(1)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if (C.get_amount() < 2)
					to_chat(user, span_warning("You need two coils of wire to wire [src]."))
					return
				to_chat(user, span_notice("You start to wire [src]."))
				if(do_after(user, 40) && build_stage == 1)
					if(C.use(2))
						to_chat(user, span_notice("You wire \the [src]."))
						increase_step("wired [initial(name)]")
				return

		if(2)
			if(istype(W, /obj/item/stack/material/plastic))
				var/obj/item/stack/material/plastic/P = W
				if (P.get_amount() < 3)
					to_chat(user, span_warning("You need three sheets of plastic to add a seat to \the [src]."))
					return
				to_chat(user, span_notice("You start to add a seat to [src]."))
				if(do_after(user, 40) && build_stage == 2)
					if(P.use(3))
						to_chat(user, span_notice("You add a seat to \the [src]."))
						increase_step("seated [initial(name)]")
				return

		if(3)
			if(istype(W, /obj/item/stock_parts/console_screen))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the lights to \the [src]."))
				increase_step()
				return

		if(4)
			if(istype(W, /obj/item/stock_parts/spring))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the control system to \the [src]."))
				increase_step()
				return

		if(5)
			if(istype(W, /obj/item/cell))
				user.drop_item()
				W.forceMove(src)
				cell = W
				to_chat(user, span_notice("You add the power supply to \the [src]."))
				increase_step("powered [initial(name)]")
				return

		if(6)
			if(W.has_tool_quality(TOOL_WRENCH) || W.has_tool_quality(TOOL_SCREWDRIVER))
				playsound(src, W.usesound, 50, 1)
				to_chat(user, span_notice("You begin your finishing touches on \the [src]."))
				if(do_after(user, 20) && build_stage == 6)
					playsound(src, W.usesound, 30, 1)
					var/obj/vehicle/bike/built/product = new(src)
					to_chat(user, span_notice("You finish \the [product]"))
					product.loc = get_turf(src)
					product.cell = cell
					cell.forceMove(product)
					cell = null
					user.drop_from_inventory(src)
					qdel(src)
				return

/*
 * Snowmobile.
 */

/obj/item/vehicle_assembly/snowmobile
	name = "snowmobile assembly"
	desc = "The frame of a snowmobile."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snowmobile-frame"

/obj/item/vehicle_assembly/snowmobile/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build_stage)
		if(0)
			if(istype(W, /obj/item/stack/material/steel))
				var/obj/item/stack/material/steel/S = W
				if (S.get_amount() < 6)
					to_chat(user, span_warning("You need six sheets of steel to add treads to \the [src]."))
					return
				to_chat(user, span_notice("You start to add treads to [src]."))
				if(do_after(user, 40) && build_stage == 0)
					if(S.use(6))
						to_chat(user, span_notice("You add treads to \the [src]."))
						increase_step("tracked [initial(name)]")
				return

		if(1)
			if(istype(W, /obj/item/stock_parts/console_screen))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the lights to \the [src]."))
				increase_step()
				return

		if(2)
			if(istype(W, /obj/item/stock_parts/spring))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the control system to \the [src]."))
				increase_step()
				return

		if(3)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if (C.get_amount() < 2)
					to_chat(user, span_warning("You need two coils of wire to wire [src]."))
					return
				to_chat(user, span_notice("You start to wire [src]."))
				if(do_after(user, 40) && build_stage == 3)
					if(C.use(2))
						to_chat(user, span_notice("You wire \the [src]."))
						increase_step("wired [initial(name)]")
				return

		if(4)
			if(istype(W, /obj/item/cell))
				user.drop_item()
				W.forceMove(src)
				cell = W
				to_chat(user, span_notice("You add the power supply to \the [src]."))
				increase_step("powered [initial(name)]")
				return

		if(5)
			if(istype(W, /obj/item/stock_parts/motor))
				user.drop_item()
				qdel(W)
				to_chat(user, span_notice("You add the motor to \the [src]."))
				increase_step()
				return

		if(6)
			if(istype(W, /obj/item/stack/material/plasteel))
				var/obj/item/stack/material/plasteel/PL = W
				if (PL.get_amount() < 2)
					to_chat(user, span_warning("You need two sheets of plasteel to add reinforcement to \the [src]."))
					return
				to_chat(user, span_notice("You start to add reinforcement to [src]."))
				if(do_after(user, 40) && build_stage == 6)
					if(PL.use(2))
						to_chat(user, span_notice("You add reinforcement to \the [src]."))
						increase_step("reinforced [initial(name)]")
					return

		if(7)
			if(W.has_tool_quality(TOOL_WRENCH) || W.has_tool_quality(TOOL_SCREWDRIVER))
				playsound(src, W.usesound, 50, 1)
				to_chat(user, span_notice("You begin your finishing touches on \the [src]."))
				if(do_after(user, 20) && build_stage == 7)
					playsound(src, W.usesound, 30, 1)
					var/obj/vehicle/train/engine/quadbike/snowmobile/built/product = new(src)
					to_chat(user, span_notice("You finish \the [product]"))
					product.loc = get_turf(src)
					product.cell = cell
					cell.forceMove(product)
					cell = null
					user.drop_from_inventory(src)
					qdel(src)
				return
	..()

/obj/item/organ/genital
	var/fluid_cum_factor				= 0.8			//How much is expelled during orgasm




/obj/item/organ/genital/proc/climax_transfer(var/D) //proc fires from send organ, v1 assumes you're passing penis or vagina if linked organ
	var/obj/item/organ/genital/destination = D
	var/obj/item/organ/genital/origin
	if(get_linked_organ())				//Basic sanity check
		origin = get_linked_organ()
		
	if(destination.get_linked_organ())
		destination = destination.get_linked_organ()
		

	
	for(var/datum/reagent/R in origin.reagents.reagent_list) //R is a reagent object
		
		destination.reagents.add_reagent(	R.type, (R.volume * fluid_cum_factor) )
		origin.reagents.remove_reagent(		R.type, (R.volume * fluid_cum_factor) )







//--------Getter and setter methods--------
//proc idk lol

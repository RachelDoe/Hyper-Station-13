/obj/item/organ/genital/womb
	name 			= "womb"
	desc 			= "A female reproductive organ."
	icon			= 'modular_citadel/icons/obj/genitals/vagina.dmi'
	icon_state 		= "womb"
	zone 			= "groin"
	slot 			= "womb"
	internal 		= TRUE
	fluid_id 		= /datum/reagent/consumable/femcum
	producing		= TRUE
	var/pregnant	= FALSE //this is for pregnancy code
	dontlist		= TRUE


/obj/item/organ/genital/womb/on_life()
	update_link()
	if(!linked_organ)
		return FALSE
	genital_life()

/obj/item/organ/genital/womb/update_link()
	if(owner)
		linked_organ = (owner.getorganslot("vagina"))
		if(linked_organ)
			linked_organ.linked_organ = src
	else
		if(linked_organ)
			linked_organ.linked_organ = null
		linked_organ = null

/obj/item/organ/genital/womb/Destroy()
	return ..()

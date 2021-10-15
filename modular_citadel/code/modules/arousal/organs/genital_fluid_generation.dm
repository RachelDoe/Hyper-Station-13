/*
	Given the potential complexity to be implemented with fluid generation mechanics I feel it best to move this to a new file alltogether
	References: holder.dm (reagents methods), reagents.dm (reagent methods)
*/

/obj/item/organ/genital
	var/fluid_max_volume				= 0				//Maximum volume of fluids a genital can hold
	var/fluid_max_gen_vol				= 0				//Maximum volume till which a genital will produce fluid
	var/fluid_volume_base				= 0				//Base capacity for fluid in genital
	

	var/fluid_efficiency				= 0				//
	var/fluid_rate						= 0				//Base rate at which a genital produces fluid
	var/fluid_mult						= 0				//Modifyer of base rate at which a genital produces fluid
	var/fluid_max_vol_ratio				= 10			//max vol = max gen vol * max vol ratio

	var/fluid_flat_loss_rate			= 0.045
	var/fluid_absorb_rate				= 0.002			//
	var/producing						= FALSE			//
	var/list/datum/reagent/gen_reagents	= new/list()	//list of TYPES of reagents to generate
	var/fluid_cum_rate					= 0				//net fluid production per tick

""
//----------------------------Getter and setter methods-----------------------------
//set and get gen reagents
/obj/item/organ/genital/proc/set_gen_reagents(var/setReagents, append = FALSE)		//Set reagents via a list of reagents or just a single reagent type
																					//This will IGNORE any ammounts in reagents passed to the pro
	//-----If it is a single type-----
	if( ispath( setReagents, /datum/reagent ) )
		if(append)
			if(!(setReagents in gen_reagents))	//Simple duplication check
				gen_reagents += setReagents

		else//!Append
			gen_reagents.Cut()
			gen_reagents += setReagents

	//-----If it is a list-----
	else if( istype(setReagents, /list) )					
		//Sanitize, if R is not a reagent type, continue
		var/list/datum/reagent/reagentList = new/list()
		for(var/R in setReagents)
			if(ispath(R, /datum/reagent))
				reagentList += R
		//Sanitize end

		if(append)
			for(var/datum/reagent/R in reagentList)
				if(!(R in gen_reagents))		//If R exists in gen_reagents, continue
					gen_reagents += R

		else//!Append
			gen_reagents.Cut()
			gen_reagents += reagentList

	//-----Input didn't match list or reagent types-----
	else


/obj/item/organ/genital/proc/get_gen_reagents()										//I know, unsafe method as it returns the reference to gen_reagents
	return gen_reagents

//Max volumes
/obj/item/organ/genital/proc/set_max_vol(var/newMaxVol)
	fluid_max_volume = newMaxVol
	reagents.maximum_volume = fluid_max_volume

/obj/item/organ/genital/proc/get_max_vol()
	return fluid_max_volume

//Gen volumes
/obj/item/organ/genital/proc/set_gen_vol(var/newGenVol)
	fluid_max_gen_vol = newGenVol

/obj/item/organ/genital/proc/get_gen_vol()
	return fluid_max_gen_vol
//Fluid rate
/obj/item/organ/genital/proc/set_rate(var/newRateVol)
	fluid_rate = newRateVol
/obj/item/organ/genital/proc/get_rate()
	return fluid_rate
//Producing
/obj/item/organ/genital/proc/set_producing(var/newProducingStat)
	producing = newProducingStat
/obj/item/organ/genital/proc/get_producing()
	return producing
//Fluid mult
/obj/item/organ/genital/proc/set_mult(var/newMult)
	fluid_mult = newMult
/obj/item/organ/genital/proc/get_mult()
	return fluid_mult
//Efficiency
/obj/item/organ/genital/proc/set_efficiency(var/newEfficiency)
	fluid_efficiency = newEfficiency
/obj/item/organ/genital/proc/get_efficiency()
	return fluid_efficiency
//Max Vol Ratio
/obj/item/organ/genital/proc/set_max_vol_ratio(var/newMaxVolRatio)
	fluid_max_vol_ratio = newMaxVolRatio
/obj/item/organ/genital/proc/get_max_vol_ratio()
	return fluid_max_vol_ratio
//Volume Base
/obj/item/organ/genital/proc/set_volume_base(var/newVolumeBase)
	fluid_volume_base = newVolumeBase
/obj/item/organ/genital/proc/get_volume_base()
	return fluid_volume_base
//
/obj/item/organ/genital/proc/get_reagents()
	return reagents
//
/obj/item/organ/genital/proc/set_flat_fluid_loss_rate(var/newLossRate)
	 fluid_flat_loss_rate = newLossRate


//
/obj/item/organ/genital/proc/update_fluids()
	fluid_max_volume 		= fluid_volume_base * cached_size * fluid_max_vol_ratio
	fluid_max_gen_vol 		= fluid_volume_base * cached_size
	reagents.maximum_volume = fluid_max_volume
	fluid_cum_rate 			= fluid_rate * fluid_mult * cached_size

//----------------------------Adjustment-----------------------------

/obj/item/organ/genital/proc/process_genital_reagents()
	

	//Remove reagents not native to organ
	for(var/datum/reagent/R in reagents.reagent_list) 		//for each reagent in reagents
		if( !(R.type in gen_reagents) )							//remove this reagent if not in the gen list
			reagents.remove_reagent(R.type, (R.volume * fluid_absorb_rate - fluid_flat_loss_rate) )	//Yes, I understand the graph is like, 98% linear

	//Add reagents native to organ
	var/uniqueGens = gen_reagents.len				//How many unique reagents are generated

	//Remaining volume for gen vol calc
	var/genVolRem = fluid_max_gen_vol					//How much generation volume remains
	for(var/R in gen_reagents)				
		genVolRem -= reagents.get_reagent_amount(R)

	//Adding reagents to organ
	if(genVolRem < CHEMICAL_QUANTISATION_LEVEL)								//If it's a ridiculously small remaining vol just return
		return
	if( genVolRem < fluid_cum_rate )											//If the remaining volume is smaller than fluid_rate
		for(var/R in gen_reagents)	//(note; this is passing a type, not an instance)
			reagents.add_reagent(R, genVolRem/uniqueGens )					//Add whats left of the remaining volume divided by the amount of unique gen reagents			
	else if( genVolRem >= fluid_cum_rate )																	//remaining volume > fluid rate	
		for(var/R in gen_reagents)					//For each unique reagent
			reagents.add_reagent(R, fluid_cum_rate/uniqueGens )			//Add that reagent but as a fraction dependant on unique generated chems

script "cc_twilight.ash"

void twilight_initializeSettings()
{
	if(my_class() == $class[Vampyre])
	{
		set_property("cc_100familiar", $familiar[Egg Benedict]);
		set_property("cc_getBeehive", true);
		set_property("cc_getBoningKnife", true);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", false);
		set_property("cc_wandOfNagamar", false);
		set_property("cc_familiarChoice", "");
		//set_property("cc_loveTunnelOverride", ",3");
	}
}

void twilight_startAscension(string page)
{
	if(my_class() != $class[Vampyre])
	{
		cli_execute("refresh all");
		if(my_class() != $class[Vampyre])
		{
			abort("We invoked Sparkly Vampire Twilight but we are not a sparkle and refreshing does not help.");
		}
	}

	if(get_property("lastEncounter") == "Intro: View of a Vampire")
	{
		page = visit_url("choice.php?pwd=&whichchoice=1343&option=1", true);
		page = visit_url("main.php");
	}
	if(get_property("lastEncounter") == "Torpor")
	{
		twilight_buySkills(page);
	}
}

boolean twilight_buySkills()
{
	if(my_class() != $class[Vampyre])
	{
		return false;
	}

	//If beaten-up, we should consider going here.

	//Visit skill page and pass that along.
	//campground.php?action=coffin
	//This costs a turn.
		//Losing a combat takes you to your coffin, you can use the science tentacle for this at 0 adventures.

	string page = "";
	if((last_choice() == 1342) && (get_property("lastEncounter") == "Torpor"))
	{
		//page = visit_url("campground.php?action=coffin");
		page = visit_url("main.php");
	}
	else
	{
		boolean changeSkills = false;
		if((my_adventures() > 0) && changeSkills)
		{
			page = visit_url("campground.php?action=coffin");
		}
	}

	if(page != "")
	{
		return twilight_buySkills(page);
	}
	return false;
}

boolean twilight_buySkills(string page)
{
	if(my_class() != $class[Vampyre])
	{
		return false;
	}

	matcher baseHPMatcher = create_matcher("<center>Base HP: (\\d\+)<br />", page);
	int baseHP = 0;
	if(baseHPMatcher.find())
	{
		baseHP = baseHPMatcher.group(1).to_int();
	}
	else
	{
		print("Could not detect Base HP", "red");
		return false;
	}

	print("Base HP: " + baseHP, "green");

	int leftHP = baseHP;
	int minHP = 0;
	switch(my_level())
	{
	case 1:	minHP = 10;	break;
	case 2:	minHP = 5;	break;
	}

	int[int] skillGoal;
	boolean getBlood = false;

	if((my_adventures() <= 2) && (item_amount($item[Blood Bag]) == 0) && !get_property("_cc_intimidatedBlood").to_boolean())
	{
		if(leftHP > 30)
		{
			skillGoal[18] = 0;		//Intimidating Aura
			leftHP -= 30;
			getBlood = true;
		}
	}

	//In the beginning, Chill of the Tomb is usually sufficient
	//Once we get to monsters with baseHP commonly above 100, we want to change combat strats.
	while(leftHP > minHP)
	{
		if(!(skillGoal contains 26) && (leftHP > (5 + minHP)))
		{
			skillGoal[26] = 0;		//Hypnotic Eyes
			leftHP -= 5;
		}
		else if(!(skillGoal contains 22) && (leftHP > (10 + minHP)))
		{
			skillGoal[22] = 0;		//Chill of the Tomb
			leftHP -= 10;
		}
		else if(!(skillGoal contains 37) && (leftHP > (30 + minHP)))
		{
			skillGoal[37] = 0;		//Sharp Eyes
			leftHP -= 30;
		}
		else if(!(skillGoal contains 36) && (leftHP > (15 + minHP)))
		{
			skillGoal[36] = 0;		//Batlike Reflexes
			leftHP -= 15;
		}
		else if(!(skillGoal contains 30) && (leftHP > (20 + minHP)))
		{
			skillGoal[30] = 0;		//Piercing Gaze
			leftHP -= 20;
		}
		else if(!(skillGoal contains 35) && (leftHP > (35 + minHP)))
		{
			skillGoal[35] = 0;		//Sinister Charm
			leftHP -= 15;
		}
		else if(!(skillGoal contains 25) && (leftHP > (35 + minHP)))
		{
			skillGoal[25] = 0;		//Madness of Untold Aeons
			leftHP -= 25;
		}
		else
		{
			break;
		}
	}


	if(!(skillGoal contains 16) && (leftHP > 5) && (my_maxhp() > (baseHP - 10)))
	{
		skillGoal[16] = 0;				//Fresh Scent
		leftHP -= 5;
	}

	if(get_property("darkGyfftePoints").to_int() >= 23)
	{
		for(int i=10; i<=38; i++)
		{
			if(!($ints[11, 19, 20, 29] contains i))
			{
				skillGoal[i] = 0;
			}
		}
	}
	else
	{
		int penalty = 0;
		if(!possessEquipment($item[Lil\' Doctor&trade; Bag]))
		{
			penalty += 20;
		}
		if(!possessEquipment($item[Vampyric Cloake]))
		{
			penalty += 20;
		}
		if((my_level() >= 12) && (get_property("flyeredML").to_int() < 10000) && (leftHP > (20 + penalty + minHP)))
		{
			skillGoal[21] = 0;			//Blood Chains
			leftHP -= 15;
		}
		if(leftHP > (10 + penalty + minHP))
		{
			skillGoal[33] = 0;			//Spectral Awareness
			leftHP -= 10;
		}
		if((leftHP > (20 + penalty + minHP)) && (my_level() < 12))
		{
			skillGoal[27] = 0;			//Macabre Cunning
			leftHP -= 20;
		}
		if(leftHP > (30 + penalty + minHP))
		{
			skillGoal[12] = 0;			//Baleful Howl
			leftHP -= 30;
		}
		if((leftHP > (15 + penalty + minHP)) && (my_level() < 13))
		{
			skillGoal[31] = 0;			//Perceive Soul
			leftHP -= 15;
		}
		if((leftHP > (20 + penalty + minHP)) && (my_level() < 12))
		{
			skillGoal[23] = 0;			//Blood Cloak
			leftHP -= 20;
		}
		if((leftHP > (15 + penalty + minHP)) && (my_level() < 12))
		{
			skillGoal[13] = 0;			//Ceaseless Snarl
			leftHP -= 15;
		}
		if((leftHP > (30 + penalty + minHP)) && (my_level() < 7))
		{
			skillGoal[24] = 0;			//Mist Form
			leftHP -= 30;
		}
		if(leftHP > (20 + penalty + minHP))
		{
			skillGoal[34] = 0;			//Flock of Bats Form
			leftHP -= 20;
		}
		if(leftHP > (20 + penalty + minHP))
		{
			skillGoal[32] = 0;			//Ensorcel
			leftHP -= 20;
		}
		if(leftHP > (15 + penalty + minHP))
		{
			skillGoal[38] = 0;			//Spot Weakness
			leftHP -= 15;
		}
		if(leftHP > (20 + penalty + minHP))
		{
			skillGoal[14] = 0;			//Wolf Form
			leftHP -= 20;
		}
		if(leftHP > (15 + penalty + minHP))
		{
			skillGoal[28] = 0;			//Sanguine Magnetism
			leftHP -= 15;
		}
		if(leftHP > (10 + penalty + minHP))
		{
			skillGoal[17] = 0;			//Ferocity
			leftHP -= 10;
		}
		if(leftHP > (15 + penalty + minHP))
		{
			skillGoal[15] = 0;			//Preternatural Strength
			leftHP -= 15;
		}
		if(leftHP > (10 + penalty + minHP))
		{
			skillGoal[10] = 0;			//Savage Bite
			leftHP -= 10;
		}
		if(!get_property("_cc_intimidatedBlood").to_boolean() && (leftHP > (30 + penalty + minHP)))
		{
			skillGoal[18] = 0;		//Intimidating Aura
			leftHP -= 30;
			getBlood = true;
		}
	}

	if(count(skillGoal) == 0)
	{
		page = visit_url("choice.php?whichchoice=1342&pwd&option=1");
		return false;
	}

	string goal = "choice.php?whichchoice=1342&pwd&option=2";
	foreach sk in skillGoal
	{
		goal += "&sk[]=" + sk;
	}

	page = visit_url(goal);
	page = visit_url("choice.php?whichchoice=1342&pwd&option=1");

	if(getBlood)
	{
		page = visit_url("place.php?whichplace=town_right&action=town_bloodbank");
		set_property("_cc_intimidatedBlood", true);
		set_property("_cc_gotBlood", true);
	}

	return true;
}

boolean twilightDayDone()
{
	if(my_class() != $class[Vampyre])
	{
		return false;
	}

	if(item_amount($item[Blood Bag]) > 0)
	{
		return false;
	}

	if(inebriety_left() < 0)
	{
		return true;
	}

	if(get_property("_cc_intimidatedBlood").to_boolean())
	{
		return true;
	}

	return false;
}

void twilight_initializeDay(int day)
{
	if(my_class() != $class[Vampyre])
	{
		return;
	}

	string temp = visit_url("place.php?whichplace=town_right&action=town_bloodbank");


	int bloodCapacity = 7;
	if(my_daycount() == 1)
	{
		pullXWhenHaveY($item[Gauze Garter], (fullness_left() + 1) / 2, 0);
		pullXWhenHaveY($item[Dieting Pill], fullness_left() / 2, 0);
		int toPull = inebriety_left();
		if(possessEquipment($item[Lil\' Doctor&trade; Bag]))
		{
			bloodCapacity = 8;
			toPull += 1;
		}

		int milks = item_amount($item[Carbonated Soy Milk]);
		int monstars = item_amount($item[Monstar Energy Beverage]);

		if(toPull > (milks + monstars))
		{
			pullXWhenHaveY($item[Carbonated Soy Milk], toPull - monstars, 0);
			milks = item_amount($item[Carbonated Soy Milk]);
		}
		if(toPull > (milks + monstars))
		{
			pullXWhenHaveY($item[Monstar Energy Beverage], toPull - milks, 0);
		}
	}

	switch(day)
	{
	case 1:
		pullXWhenHaveY($item[17-Ball], 1, 0);
		pullXWhenHaveY($item[The Nuge\'s Favorite Crossbow], 1, 0);
		pullXWhenHaveY($item[Platinum Yendorian Express Card], 1, 0);
		if(item_amount($item[Platinum Yendorian Express Card]) == 0)
		{
			pullXWhenHaveY($item[Pick-O-Matic Lockpicks], 1, 0);
		}
		pullXWhenHaveY($item[Ring Of Detect Boring Doors], 1, 0);
		pullXWhenHaveY($item[Eleven-Foot Pole], 1, 0);
		pullXWhenHaveY($item[License To Chill], 1, 0);
		pullXWhenHaveY($item[Blackberry Galoshes], 1, 0);
		if(possessEquipment($item[Vampyric Cloake]) && possessEquipment($item[Lil\' Doctor&trade; Bag]))
		{
			pullXWhenHaveY($item[Mime Army Shotglass], 1, 0);
			if(my_turncount() == 0)
			{
				put_closet(item_amount($item[Mime Army Shotglass]), $item[Mime Army Shotglass]);
			}
		}
		else
		{
			pullXWhenHaveY($item[Spice Melange], 1, 0);
		}
		pullXWhenHaveY($item[Giant Pearl], 1, 0);
		if((my_turncount() == 0) && (my_meat() < 5000) && (item_amount($item[Giant Pearl]) == 1) && possessEquipment($item[Vampyric Cloake]))
		{
			autosell(1, $item[Giant Pearl]);
		}
		break;
	case 2:
		pullXWhenHaveY($item[Nurse\'s Hat], 1, 0);
		pullXWhenHaveY($item[Halibut], 1, 0);
		pullXWhenHaveY($item[Shield Of The Skeleton Lord], 1, 0);
		pullXWhenHaveY($item[Dallas Dynasty Falcon Crest shield], 1, 0);
#		pullXWhenHaveY($item[Spice Melange], 1, 0);
		if(have_skill($skill[Torso Awareness]))
		{
			pullXWhenHaveY($item[Sea Salt Scrubs], 1, 0);
		}
		if(is_unrestricted($item[Pantsgiving]))
		{
			pullXWhenHaveY($item[Pantsgiving], 1, 0);
		}

		switch(get_property("nsChallenge2").to_element())
		{
		case $element[cold]:
			pullXWhenHaveY($item[Pristine Walrus Tusk], 1, 0);
			pullXWhenHaveY($item[Cold Water Bottle], 1, 0);
			break;
		case $element[hot]:
			pullXWhenHaveY($item[Nozzle Of The Phoenix], 1, 0);
			pullXWhenHaveY($item[Ring Of Fire], 1, 0);
			break;
		case $element[spooky]:
			pullXWhenHaveY($item[Black Catseye Marble], 1, 0);
			pullXWhenHaveY($item[The Ring], 1, 0);
			//We are using The Ring for 12 Spooky. If we get a Red Masque, we do not need it.
			break;
		//case $element[sleaze]:	//Covered by Halibut
		//case $element[stench]:	//Covered by Halibut
		}
		break;
	case 3:
#		pullXWhenHaveY($item[Dallas Dynasty Falcon Crest shield], 1, 0);
		break;
	default:
		break;
	}
	return;
}

boolean LM_twilight()
{
	if(my_class() != $class[Vampyre])
	{
		return false;
	}

	if(have_effect($effect[Wolf Form]) == 2147483647)
	{
		if(!($locations[The Themthar Hills] contains my_location()))
		{
			if(get_property("lastVoteMonsterTurn").to_int() != total_turns_played())
			{
				abort("Have form of wolf.");
			}
		}
	}
	if(have_effect($effect[Mist Form]) == 2147483647)
	{
		if(!($locations[A-Boo Peak, The Haunted Kitchen] contains my_location()))
		{
			if(get_property("lastVoteMonsterTurn").to_int() != total_turns_played())
			{
				abort("Have form of mist.");
			}
		}
	}
	if(have_effect($effect[Bats Form]) == 2147483647)
	{
		if(get_property("pyramidBombUsed").to_boolean() && (my_location() == $location[The Lower Chambers]))
		{
			if(!get_property("ensorcelModifiers:").contains_text("Meat Drop"))
			{
				use_skill(1, $skill[Flock Of Bats Form]);
				if(have_effect($effect[Bats Form]) != 0)
				{
					abort("Could not uneffect Bats Form");
				}
				int wishes = get_property("_genieWishesUsed").to_int();
				if((wishes == 2) && (have_effect($effect[Bats Form]) == 0))
				{
					set_property("cc_combatDirective", "start;skill ensorcel");
					makeGenieCombat($monster[Black Crayon Beast]);
				}
				return true;
			}
		}


		if(!($locations[The Defiled Alcove, The Defiled Nook, The Feeding Chamber, The Hatching Chamber, The Middle Chamber, The Royal Guard Chamber, The Upper Chamber] contains my_location()))
		{
			if(get_property("lastVoteMonsterTurn").to_int() != total_turns_played())
			{
				abort("Have form of bats.");
			}
		}
	}

	if(!get_property("_cc_intimidatedBlood").to_boolean() && have_skill($skill[Intimidating Aura]))
	{
		string page = visit_url("place.php?whichplace=town_right&action=town_bloodbank");
		set_property("_cc_intimidatedBlood", true);
		set_property("_cc_gotBlood", true);
	}
	if(!get_property("_cc_gotBlood").to_boolean())
	{
		string page = visit_url("place.php?whichplace=town_right&action=town_bloodbank");
		set_property("_cc_gotBlood", true);
	}

	if(contains_text(get_property("latteUnlocks"), "chili") && (my_location() == $location[The Haunted Kitchen]) && (get_property("manorDrawerCount").to_int() < 21))
	{
		if((my_daycount() == 1) && (get_property("_latteRefillsUsed").to_int() == 0))
		{
			latteRefill("chili", "pumpkin", "vanilla", false, false);
		}
	}

	if(my_turncount() < 1000)
	{
		foreach it in $items[Affirmation Cookie, Badge Of Authority, Black Eyedrops, Boiling Broth, Bottle Of Antifreeze, C.A.R.N.I.V.O.R.E. button, Dogsgotnonoz Pills, Eaves Droppers, Glowing Red Eye, Grue Egg, Handful Of Tips, Heart Cozy, Imp Unity Ring, Interrogative Elixir, Mysterious Black Box, Mysterious Blue Box, Mysterious Red Box, Newbiesport&trade; Tent, Note From Clancy, Personal Graffiti Kit, Porquoise, Red Money Bag, Rubee&trade;, Sharkfin Gumbo, Shiny Ring, Stuffed Angry Cow, Tonic Djinn, Very Overdue Library Book, White Money Bag]
		{
			closet_all(it);
		}
		if(my_meat() < 20000)
		{
			foreach it in $items[Antique Helmet, Antique Shield, Awful Poetry Journal, Black Label, Chaos Butterfly, Cocoa Eggshell Fragment, Demon Skin, Disintegrating Quill Pen, Energy Drink IV, Fabric Hardener, Fancy Bath Salts, Furry Fur, Heavy D, Inkwell, Lolsipop, Metallic A, Mick\'s IcyVapoHotness Rub, Molotov Cocktail Cocktail, Mother\'s Little Helper, Moxie Weed, Original G, Photoprotoneutron Torpedo, Plot Hole, Probability Potion, Strongness Elixir, Thin Black Candle, Tiny House]
			{
				if(item_amount(it) > 0)
				{
					autosell(1, it);
				}
			}
		}
		foreach it in $items[Golden Gum, Golden Gun]
		{
			if(item_amount(it) > 0)
			{
				cli_execute("mallsell " + it);
			}
		}
	}

	if((item_amount($item[Pok&eacute;-Gro fertilizer]) > 0) && (my_level() < 13))
	{
		use(1, $item[Pok&eacute;-Gro fertilizer]);
	}

	if((cc_get_campground() contains $item[packet of tall grass seeds]) && (cc_get_campground()[$item[packet of tall grass seeds]] > 0))
	{
		cli_execute("garden pick");

		foreach it in $items[Glum Berry, Jamocha Berry, Keese Berry, Nadsat Berry, Sitrep Berry, Snarf Berry]
		{
			if(item_amount(it) > 0)
			{
				use(1, it);
			}
		}
	}

	if(my_level() >= 13)
	{
		pullXWhenHaveY($item[Ring Of The Skeleton Lord], 1, 0);
	}
	if((get_property("hiddenTavernUnlock").to_int() < my_ascensions()) && (item_amount($item[Book Of Matches]) == 0))
	{
		if(get_property("cc_hiddenoffice") == "finished")
		{
			pullXWhenHaveY($item[Book Of Matches], 1, 0);
			use(1, $item[Book Of Matches]);
		}
		else if((get_property("cc_hiddenapartment") == "finished") && (get_property("relocatePygmyJanitor").to_int() == my_ascensions()))
		{
			pullXWhenHaveY($item[Book Of Matches], 1, 0);
			use(1, $item[Book Of Matches]);
		}
	}

	if((have_effect($effect[Tomes Of Opportunity]) > 0) && (item_amount($item[License To Chill]) > 0) && !get_property("_licenseToChillUsed").to_boolean())
	{
		use(1, $item[License To Chill]);
	}

	if((my_meat() > 20000) && (item_amount($item[Magical Sausage Casing]) > 0))
	{
		cli_execute("make 1 " + $item[Magical Sausage]);
	}

	foreach it in $items[Black Pension Check, Black Picnic Basket, Gathered Meat-Clip, Old Coin Purse, Red Box, Unremarkable Duffel Bag, Van Key]
	{
		if(item_amount(it) > 0)
		{
			use(1, it);
		}
	}

#	if((my_daycount() == 2) && (my_fullness() == 4) && (my_inebriety() >= 3) && !get_property("spiceMelangeUsed").to_boolean() && (item_amount($item[Spice Melange]) == 1) && (my_adventures() < 5) && (get_property("cc_sorceress") == ""))
#	{
#		use(1, $item[Spice Melange]);
#	}

	if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
		//Do we care about Weapon Damage Percent?
		if(contains_text(mod, "Weapon Damage Percent") && !contains_text(mod, "Combat Rate"))
		{
			string page = visit_url("place.php?whichplace=kgb");
			boolean flipped = false;
			if(contains_text(page, "handleup"))
			{
				page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
				flipped = true;
			}

			page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_button4", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_button1", false);

			if(flipped)
			{
				page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
			}
		}
	}

	if((my_meat() > 11000) && (my_level() >= 6))
	{
		if(LX_bitchinMeatcar())		return true;
	}

	//Use Free Hate for +30ML for Oil Peak (pull Shield of the Skeleton Lord too?) Let this carry over into the Fulminate?

	if(zone_isAvailable($location[Thugnderdome]) && !have_skill($skill[Torso Awareness]) && (my_meat() > 7500))
	{
		string temp = visit_url("gnomes.php?place=skills");
		temp = visit_url("gnomes.php?action=trainskill&pwd&whichskill=12");
		return true;
	}

	if((get_property("blackForestProgress").to_int() == 5) && (item_amount($item[Red Zeppelin Ticket]) == 0) && (my_meat() > 10000))
	{
		buyUpTo(1, $item[Red Zeppelin Ticket]);
	}

	if((have_skill($skill[Torso Awareness])) && (my_daycount() == 1) && (my_level() >= 8) && (item_amount($item[Genie Bottle]) > 0))
	{
		int wishes = get_property("_genieWishesUsed").to_int();
		if(wishes < 3)
		{
			if(!possessEquipment($item[Broken Champagne Bottle]))
			{
				cli_execute("fold " + $item[Broken Champagne Bottle]);
			}
			equip($slot[weapon], $item[Broken Champagne Bottle]);
			if(!have_equipped($item[Lil\' Doctor&trade; Bag]) && possessEquipment($item[Lil\' Doctor&trade; Bag]))
			{
				equip($slot[acc3], $item[Lil\' Doctor&trade; Bag]);
			}
			if(wishes < 2)
			{
				if(have_skill($skill[Wolf Form]) && (have_effect($effect[Wolf Form]) == 0))
				{
					use_skill(1, $skill[Wolf Form]);
				}
				set_property("cc_combatDirective", "start;skill otoscope");
				makeGenieCombat($monster[Mountain Man]);
			}
			else
			{
				if(have_skill($skill[Wolf Form]) && (have_effect($effect[Wolf Form]) == 0))
				{
					use_skill(1, $skill[Wolf Form]);
				}
				cli_execute("hermit 2 clover");
				set_property("cc_combatDirective", "start;skill otoscope; item lov enamorang");
				if(get_property("darkGyfftePoints").to_int() >= 23)
				{
					set_property("cc_combatDirective", "start;skill otoscope");
				}
				makeGenieCombat($monster[Naughty Sorority Nurse]);
			}

			if(have_skill($skill[Wolf Form]) && (have_effect($effect[Wolf Form]) != 0))
			{
				use_skill(1, $skill[Wolf Form]);
			}
			return true;
		}
	}

	if((my_daycount() == 1) && (my_level() >= 10))
	{
		if(!get_property("_missileLauncherUsed").to_boolean() && (cc_get_campground() contains $item[Asdon Martin Keyfob]))
		{
			asdonAutoFeed(110);
			if((my_location() == $location[The Penultimate Fantasy Airship]) && (get_fuel() < 100))
			{
				abort("Need more fuel for the airship!");
			}
		}
	}

	if((my_daycount() == 2) && (item_amount($item[Genie Bottle]) > 0))
	{
		asdonAutoFeed(100);
		asdonAutoFeed(100);
		if(!possessEquipment($item[Beer Helmet]) && (get_fuel() < 100))
		{
			abort("Not enough fuel for Ashton Kutcher");
		}
		if((get_fuel() >= 100) && !get_property("_missileLauncherUsed").to_boolean() && (get_property("_genieWishesUsed").to_int() == 0))
		{
			set_property("cc_combatDirective", "start;skill asdon martin: missile launcher");
			makeGenieCombat($monster[War Frat 151st Infantryman]);
			return true;
		}

		if((get_property("_genieWishesUsed").to_int() == 1) && (item_drop_modifier() >= 100.0) && (item_amount($item[Stone Wool]) == 0) && (internalQuestStatus("questL11Worship") < 3))
		{
			if(have_skill($skill[Wolf Form]) && (have_effect($effect[Wolf Form]) == 0))
			{
				use_skill(1, $skill[Wolf Form]);
			}

			makeGenieCombat($monster[Baa\'Baa\'Bu\'Ran]);

			if(have_skill($skill[Wolf Form]) && (have_effect($effect[Wolf Form]) != 0))
			{
				use_skill(1, $skill[Wolf Form]);
			}

			return true;
		}
	}


	int count = 0;
	foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope]
	{
		if(item_amount(it) > 0)
		{
			count++;
		}
	}

	if((internalQuestStatus("questL11Pyramid") >= 1) && (internalQuestStatus("questL11Pyramid") <= 2) && (my_daycount() <= 2))
	{
		while(kgbDiscovery());
		if(get_property("garbageChampagneCharge").to_int() > 0)
		{
			januaryToteAcquire($item[Broken Champagne Bottle]);
			equip($slot[weapon], $item[Broken Champagne Bottle]);
		}
		fightClubSpa($effect[Uncucumbered]);
		buffMaintain($effect[Eagle Eyes], 0, 1, 1);
		asdonBuff($effect[Driving Observantly]);

		int total = item_amount($item[Crumbling Wooden Wheel]);
		total = total + item_amount($item[Tomb Ratchet]);
		if(total < 10)
		{
			if(have_skill($skill[Flock of Bats Form]) && (have_effect($effect[Bats Form]) == 0))
			{
				use_skill(1, $skill[Flock Of Bats Form]);
			}
		}

		if(get_property("cc_orchard") == "")
		{
			set_property("cc_orchard", "start");
		}

		if(item_amount($item[Filthworm Royal Guard Scent Gland]) == 0)
		{
			if(item_amount($item[Latte Lovers Member\'s Mug]) > 0)
			{
				equip($slot[off-hand], $item[Latte Lovers Member\'s Mug]);
			}
			set_property("cc_combatDirective", "start;skill otoscope;skill chest x-ray");
			L12_filthworms();
			return true;
		}

		if(total < 10)
		{
			if(item_amount($item[Latte Lovers Member\'s Mug]) > 0)
			{
				equip($slot[off-hand], $item[Latte Lovers Member\'s Mug]);
			}
			L11_unlockEd();
		}

		total = item_amount($item[Crumbling Wooden Wheel]) + item_amount($item[Tomb Ratchet]);
		if((total >= 10) && !get_property("ensorcelModifiers:").contains_text("Meat Drop"))
		{
			if(have_skill($skill[Flock of Bats Form]) && (have_effect($effect[Bats Form]) != 0))
			{
				use_skill(1, $skill[Flock Of Bats Form]);
			}
			int wishes = get_property("_genieWishesUsed").to_int();
			if((wishes == 2) && (have_effect($effect[Bats Form]) == 0))
			{
				set_property("cc_combatDirective", "start;skill ensorcel");
				makeGenieCombat($monster[Black Crayon Beast]);
			}
		}

		if(get_property("cc_orchard") == "start")
		{
			set_property("cc_orchard", "");
		}
	}

	if((internalQuestStatus("questL11Shen") <= 4) && (get_property("shenQuestItem") == $item[The First Pizza]) && ((count < 3) || (item_amount($item[The First Pizza]) == 0)))
	{
		if(!zone_isAvailable($location[Lair Of The Ninja Snowmen]))
		{
			abort("Shen zone (Assassins) is not available");
		}


		if(possessEquipment($item[Kremlin\'s Greatest Briefcase]) && (count < 3))
		{
			string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
			if(contains_text(mod, "Combat Rate: -5"))
			{
				string page = visit_url("place.php?whichplace=kgb");
				boolean flipped = false;
				if(contains_text(page, "handleup"))
				{
					page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
					flipped = true;
				}

				page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);

				if(flipped)
				{
					page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
				}
			}
		}


		if(count < 3)
		{
			if(item_amount($item[Latte Lovers Member\'s Mug]) > 0)
			{
				equip($slot[off-hand], $item[Latte Lovers Member\'s Mug]);
			}
			if(item_amount($item[Knob Goblin Harem Pants]) > 0)
			{
				equip($slot[pants], $item[Knob Goblin Harem Pants]);
			}
			if(item_amount($item[Kremlin\'s Greatest Briefcase]) > 0)
			{
				equip($slot[acc2], $item[Kremlin\'s Greatest Briefcase]);
			}
			asdonBuff($effect[Driving Obnoxiously]);
			getHorse("resistance");

			if(get_property("latteModifier").contains_text("Combat Rate: 10"))
			{
				if(!get_property("_latteBanishUsed").to_boolean())
				{
					//TODO: This could banish an assassin
					set_property("cc_combatDirective", "start;skill throw latte on opponent");
				}
			}
			else
			{
				if(!get_property("_latteBanishUsed").to_boolean())
				{
					//TODO: This could banish an assassin
					set_property("cc_combatDirective", "start;skill throw latte on opponent");
				}
				else
				{
					if(get_property("latteUnlocks").contains_text("wing"))
					{
						latteRefill("wing", "hellion", "cajun", false, false);
						//TODO: This could banish an assassin
						set_property("cc_combatDirective", "start;skill throw latte on opponent");
					}
					else
					{
						latteRefill("pumpkin", "hellion", "cajun", false, false);
						//TODO: This could banish an assassin
						set_property("cc_combatDirective", "start;skill throw latte on opponent");
					}
				}
			}
		}

		if((count < 3) || (item_amount($item[The First Pizza]) == 0))
		{
			boolean result = ccAdv($location[Lair Of The Ninja Snowmen]);
			if(!result)
			{
				abort("Could not adventure in the Lair Of The Ninja Snowmen");
			}
		}

		int count = 0;
		foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope]
		{
			if(item_amount(it) > 0)
			{
				count++;
			}
		}
		if(possessEquipment($item[Kremlin\'s Greatest Briefcase]) && (count == 3))
		{
			string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
			if(contains_text(mod, "Combat Rate: 5"))
			{
				string page = visit_url("place.php?whichplace=kgb");
				boolean flipped = false;
				if(contains_text(page, "handleup"))
				{
					page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
					flipped = true;
				}

				page = visit_url("place.php?whichplace=kgb&action=kgb_button6", false);

				if(flipped)
				{
					page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
				}
			}
			if(get_property("latteModifier").contains_text("Combat Rate: 10"))
			{
				latteRefill("ink", "hellion", "cajun", false, false);
			}
		}

		return true;
	}

	if(zone_isAvailable($location[Thugnderdome]) && !have_skill($skill[Powers Of Observatiogn]) && (my_meat() > 7500))
	{
		string temp = visit_url("gnomes.php?place=skills");
		temp = visit_url("gnomes.php?action=trainskill&pwd&whichskill=10");
	}
	if(zone_isAvailable($location[Thugnderdome]) && !have_skill($skill[Gnefarious Pickpocketing]) && (my_meat() > 15000))
	{
		string temp = visit_url("gnomes.php?place=skills");
		temp = visit_url("gnomes.php?action=trainskill&pwd&whichskill=11");
	}
	return false;
}

void twilightConsume()
{
	if(my_class() != $class[Vampyre])
	{
		return;
	}
	if(my_adventures () < 5)
	{
		if((inebriety_left() <= 1) && (closet_amount($item[Mime Army Shotglass]) > 0) && (item_amount($item[Mime Army Shotglass]) == 0))
		{
			take_closet(1, $item[Mime Army Shotglass]);
		}

		if((inebriety_left() > 0) && !get_property("spiceMelangeUsed").to_boolean())
		{
			foreach it in twilightBoozeConsumables()
			{
				if(item_amount(it) > 0)
				{
					ccDrink(1, it);
					return;
				}
			}

			if(item_amount($item[Blood Bag]) > 0)
			{
				pullXWhenHaveY($item[Carbonated Soy Milk], 1, 0);
				if(item_amount($item[Carbonated Soy Milk]) == 0)
				{
					pullXWhenHaveY($item[Monstar Energy Beverage], 1, 0);
				}

				if(item_amount($item[Carbonated Soy Milk]) > 0)
				{
					ccCraft("cocktail", 1, $item[Blood Bag], $item[Carbonated Soy Milk]);
					ccDrink(1, $item[Vampagne]);
					return;
				}
				else if(item_amount($item[Monstar Energy Beverage]) > 0)
				{
					ccCraft("cocktail", 1, $item[Blood Bag], $item[Monstar Energy Beverage]);
					ccDrink(1, $item[Vampagne]);
					return;
				}
			}
		}
		if(fullness_left() > 0)
		{
			item foodGoal = $item[none];
			foreach it in twilightFoodConsumables()
			{
				if(item_amount(it) > 0)
				{
					foodGoal = it;
					break;
				}
			}

			if((item_amount($item[Blood Bag]) > 0) && (foodGoal == $item[none]))
			{
				pullXWhenHaveY($item[Gauze Garter], 1, 0);
				if(item_amount($item[Gauze Garter]) > 0)
				{
					ccCraft("cook", 1, $item[Blood Bag], $item[Gauze Garter]);
					foodGoal = $item[Blood-Soaked Sponge Cake];
				}
				else if(item_amount($item[Filthy Poultice]) > 0)
				{
					ccCraft("cook", 1, $item[Blood Bag], $item[Filthy Poultice]);
					foodGoal = $item[Blood-Soaked Sponge Cake];
				}
			}

			if((foodGoal == $item[none]) && (my_daycount() == 2) && ((my_fullness() == 1) || (my_fullness() == 3)) && get_property("spiceMelangeUsed").to_boolean() && (item_amount($item[Blood Bag]) > 0) && (item_amount($item[Blackberry]) > 0))
			{
				abort("blackberry check");
				ccCraft("cook", 1, $item[Blood Bag], $item[Blackberry]);
				foodGoal = $item[Blood Roll-Up];
			}

			if(foodGoal != $item[none])
			{
				if((spleen_left() >= 3) && (fullness_left() > 1) && (my_level() >= 7) && (foodGoal != $item[Magical Sausage]))
				{
					pullXWhenHaveY($item[Dieting Pill], 1, 0);
					chew(1, $item[Dieting Pill]);
				}
				ccEat(1, foodGoal);
			}
		}
	}
}


boolean[item] twilightFoodConsumables()
{
	return $items[Actual Blood Sausage, Bloodstick, Blood-Soaked Sponge Cake, Blood Roll-Up, Blood Snowcone, Magical Sausage];
}

boolean[item] twilightBoozeConsumables()
{
	return $items[Bottle Of Sanguiovese, Dusty Bottle Of Blood, Mulled Blood, Red Russian, Vampagne];
}


void twilightPostAdventure()
{
//	buffMaintain($effect[Wolf Form], 70, 1, 1);
//	buffMaintain($effect[Mist Form], 60, 1, 1);
//	buffMaintain($effect[Bats Form], 100, 1, 1);
	int maxTurns = 700 - my_turncount();
	maxTurns -= min(100, 10 * get_property("darkGyfftePoints").to_int());
	if((get_property("cc_blackmap") == "finished") && cc_have_skill($skill[Meteor Lore]) && (get_property("cc_trapper") == "finished") && possessEquipment($item[&quot;I voted!&quot; sticker]))
	{
		buffMaintain($effect[Cloak Of Shadows], 90, 1, max(5, maxTurns));
	}
	else if(my_level() <= 7)
	{
		buffMaintain($effect[Cloak Of Shadows], 90, 1, 5);
	}
	buffMaintain($effect[Spectral Awareness], 100, 1, max(5, maxTurns));
	if(my_level() < 13)
	{
		if(get_property("cc_highlandlord") != "")
		{
			buffMaintain($effect[Ceaseless Snarling], 120, 1, 1);
		}
		if((get_property("darkGyfftePoints").to_int() >= 8) && (internalQuestStatus("questL10Garbage") < 3))
		{
			buffMaintain($effect[Ceaseless Snarling], 120, 1, 1);
		}
	}
}

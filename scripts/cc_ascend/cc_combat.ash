script "cc_combat.ash"

monster ocrs_helper(string page);
void awol_helper(string page);
string ccsJunkyard(int round, string opp, string text);
string cc_edCombatHandler(int round, string opp, string text);
string cc_combatHandler(int round, string opp, string text);

/*
*	Advance combat round, nothing happens.
*	/goto fight.php?action=useitem&whichitem=1
*
*	Advance combat round, stuff happens: No longer works 21/5/2018
*	/goto fight.php?action=skill&whichskill=$1
*/

string cc_combatHandler(int round, string opp, string text)
{
	#print("cc_combatHandler: " + round, "brown");
	#Yes, round 0, really.
	monster enemy = to_monster(opp);
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if(round == 0)
	{
		print("cc_combatHandler: " + round, "brown");

		if(enemy == $monster[Government Agent])
		{
			set_property("_portscanPending", false);
		}

		set_property("cc_combatHandler", "");
		set_property("cc_funCombatHandler", "");
		set_property("cc_funPrefix", "");
		set_property("cc_combatHandlerThunderBird", "0");
		set_property("cc_combatHandlerFingernailClippers", "0");
		set_property("cc_combatHP", my_hp());

/*
		if(my_location() == $location[The Deep Machine Tunnels])
		{
			if(!($monsters[Perceiver of Sensations, Performer of Actions, Thinker of Thoughts] contains enemy))
			{
				print("In The Deep Machine Tunnels and did not encounter expected monster....", "red");
				//Digitize happens first, yay for someone asking!
				//We need to remove Corresponding Counter.
				if(isOverdueDigitize())
				{
					set_property("_sourceTerminalDigitizeMonsterCount", get_property("_sourceTerminalDigitizeMonsterCount").to_int() + 1);
					print("Looks like a digitize monster, adjusting monster count but can not restore tracker", "red");
				}
				else if(isExpectingArrow() || isOverdueArrow())
				{
					print("Probably an arrow encounter... trying to adjust...", "red");
					if(to_monster(get_property("romanticTarget")) == enemy)
					{
						if(get_property("_romanticFightsLeft").to_int() == 0)
						{
							print("Have a romantic target but no fights left... can not fix wanderers", "red");
						}
						else
						{
							set_property("_romanticFightsLeft", get_property("_romanticFightsLeft").to_int() - 1);
							print("Attempted to decrement romantic fights left, can not restore counter.", "red");
						}
					}
					else
					{
						print("Not an arrow encounter... can not fix wanderers...", "red");
					}
				}
			}
		}
*/
	}
	else
	{
		damageReceived = get_property("cc_combatHP").to_int() - my_hp();
		set_property("cc_combatHP", my_hp());
	}

	set_property("cc_diag_round", round);

	if(get_property("cc_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	if(my_path() == "One Crazy Random Summer")
	{
		enemy = ocrs_helper(text);
		enemy = last_monster();
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		awol_helper(text);
	}

	phylum type = monster_phylum(enemy);
	phylum current = to_phylum(get_property("dnaSyringe"));

	string combatState = get_property("cc_combatHandler");
	int thunderBirdsLeft = get_property("cc_combatHandlerThunderBird").to_int();
	int fingernailClippersLeft = get_property("cc_combatHandlerFingernailClippers").to_int();

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

	boolean doBanisher = !get_property("kingLiberated").to_boolean();


	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}
	if(have_equipped($item[Drunkula\'s Wineglass]))
	{
		return "attack with weapon";
	}


	if(get_property("cc_combatDirective") != "")
	{
		string directive = combat_handleDirective(round);
		if(directive != "")
		{
			return directive;
		}
	}

	string majora = combat_majora(text, round);
	if(majora != "")
	{
		return majora;
	}

	if($monsters[One Thousand Source Agents, Source Agent] contains enemy)
	{
		return combat_sourceBosses();
	}

	if((enemy == $monster[Your Shadow]) || (opp == "shadow cow puncher") || (opp == "shadow snake oiler") || (opp == "shadow beanslinger") || (opp == "shadow gelatinous noob"))
	{
		return combat_shadow();
	}

	if((enemy == $monster[Wall Of Meat]) && (cc_combatCanUse($skill[Make It Rain], true)))
	{
		return cc_combatUse($skill[Make It Rain], true);
	}

	if(enemy == $monster[Wall Of Skin])
	{
		return combat_wallOfSkin(round);
	}

	if(enemy == $monster[Wall Of Bones])
	{
		if(cc_combatCanUse($item[Electric Boning Knife]))
		{
			return cc_combatUse($item[Electric Boning Knife]);
		}
		foreach sk in $skills[Garbage Nova, Saucegeyser]
		{
			if(cc_combatCanUse(sk))
			{
				return cc_combatUse(sk);
			}
		}
	}

	if(!contains_text(combatState, "blackbox") && (my_path() != "Heavy Rains") && (get_property("_raindohCopiesMade").to_int() < 5))
	{
		if((enemy == $monster[Modern Zmobie]) && (get_property("cc_modernzmobiecount").to_int() < 3))
		{
			set_property("cc_doCombatCopy", "yes");
		}
	}

	if(my_location() == $location[The Daily Dungeon])
	{
		# If we are in The Daily Dungeon, assume we get 1 token, so only if we need more than 1.
		if((towerKeyCount(false) < 2) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && cc_combatCanUse($item[Daily Dungeon Malware], true))
		{
			if($monsters[Apathetic Lizardman, Dairy Ooze, Dodecapede, Giant Giant Moth, Mayonnaise Wasp, Pencil Golem, Sabre-Toothed Lime, Tonic Water Elemental, Vampire Clam] contains enemy)
			{
				return cc_combatUse($item[Daily Dungeon Malware], true);
			}
		}
	}
	if(!contains_text(combatState, "abstraction"))
	{
		if((item_amount($item[Abstraction: Sensation]) > 0) && (enemy == $monster[Performer of Actions]) && in_ronin() && (item_amount($item[Abstraction: Motion]) == 0))
		{
			#	Change +100% Moxie to +100% Init
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Sensation];
		}
		if((item_amount($item[Abstraction: Thought]) > 0) && (enemy == $monster[Perceiver of Sensations]))
		{
			# Change +100% Myst to +100% Items
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Thought];
		}
		if((item_amount($item[Abstraction: Action]) > 0) && (enemy == $monster[Thinker of Thoughts]))
		{
			# Change +100% Muscle to +10 Familiar Weight
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Action];
		}
	}

	if(!contains_text(combatState, "tunneldownwards") && (have_effect($effect[Shape of...Mole!]) > 0) && (my_location() == $location[Mt. Molehill]))
	{
		set_property("cc_combatHandler", combatState + "(tunneldownwards)");
		return "skill " + $skill[Tunnel Downwards];
	}

	if((my_familiar() == $familiar[Stocking Mimic]) && (round < 12) && canSurvive(1.5) && cc_combatCanUse($item[Dictionary]))
	{
		return cc_combatUse($item[Dictionary]);
	}

	if(cc_combatCanUse($item[Cigarette Lighter], true) && (my_location() == $location[A Mob Of Zeppelin Protesters]) && (get_property("questL11Ron") == "step1"))
	{
		return cc_combatUse($item[Cigarette Lighter]);
	}

	if(cc_combatCanUse($item[Glark Cable], true) && (my_location() == $location[The Red Zeppelin]) && (get_property("questL11Ron") == "step3") && (get_property("_glarkCableUses").to_int() < 5))
	{
		if($monsters[Man With The Red Buttons, Red Butler, Red Fox, Red Skeleton] contains enemy)
		{
			return cc_combatUse($item[Glark Cable]);
		}
	}

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0))
	{
		int maxAudience = 30;
		if($items[Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped)] contains equipped_item($slot[shirt]))
		{
			maxAudience = 50;
		}
		if(cc_combatCanUse($skill[Mug For The Audience], true) && (my_audience() < maxAudience))
		{
			return cc_combatUse($skill[Mug For The Audience], true);
		}
	}

	if(!contains_text(combatState, "pickpocket") && ($classes[Accordion Thief, Avatar of Sneaky Pete, Disco Bandit, Gelatinous Noob] contains my_class()) && contains_text(text, "value=\"Pick") && canSurvive(2.0))
	{
		boolean tryIt = false;
		foreach i, drop in item_drops_array(enemy)
		{
			if(drop.type == "0")
			{
				tryIt = true;
			}
			if((drop.rate > 0) && (drop.type != "n") && (drop.type != "c") && (drop.type != "b"))
			{
				tryIt = true;
			}
		}
		if(tryIt)
		{
			set_property("cc_combatHandler", combatState + "(pickpocket)");
			string attemptSteal = steal();
			return "pickpocket";
		}
	}

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0) && (my_level() < 13) && cc_combatCanUse($skill[Mug For The Audience], true))
	{
		return cc_combatUse($skill[Mug For The Audience], true);
	}

	if(cc_combatCanUse($skill[Steal Accordion], true) && canSurvive(2.0))
	{
		return cc_combatUse($skill[Steal Accordion], true);
	}

	//TODO: This should only be used via a directive
	if(get_property("cc_useTatter").to_boolean() && cc_combatCanUse($item[Tattered Scrap Of Paper]))
	{
		cc_combatUse($item[Tattered Scrap Of Paper]);
	}

	//TODO: This should only be used via a directive
	if(get_property("cc_usePowerPill").to_boolean() && (get_property("_powerPillUses").to_int() < 20) && instakillable(enemy) && cc_combatCanUse($item[Power Pill]))
	{
		return cc_combatUse($item[Power Pill]);
	}

	//TODO: This should only be used via a directive
	if(get_property("cc_useCleesh").to_boolean() && cc_combatCanUse($skill[CLEESH], true))
	{
		set_property("cc_useCleesh", false);
		return cc_combatUse($skill[CLEESH], true);
	}

	if(thunderBirdsLeft > 0)
	{
		thunderBirdsLeft = thunderBirdsLeft - 1;
		set_property("cc_combatHandlerThunderBird", "" + thunderBirdsLeft);
		if(thunderBirdsLeft == 0)
		{
			return cc_combatUse($skill[Thunder Bird], true);
		}
		return cc_combatUse($skill[Thunder Bird], false);
	}

	if(cc_combatCanUse($skill[Thunderstrike], true) && (monster_level_adjustment() <= 150) && cc_combatCanUse($skill[Thunder Bird], true))
	{
		if($monsters[Big Wisnaqua, The Aquaman, The Big Wisniewski, The Man, The Rain King] contains enemy)
		{
			set_property("cc_combatHandlerThunderBird", "5");
			if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && (my_mp() >= 60) && cc_have_skill($skill[Itchy Curse Finger]))
			{
				return cc_combatUse($skill[Curse Of Weaksauce], true);
			}
			return  cc_combatUse($skill[Thunderstrike], true);
		}
	}

	if((enemy == $monster[Dirty Thieving Brigand]) && cc_combatCanUse($skill[Make It Rain], true) && (my_rain() > 60))
	{
		return cc_combatUse($skill[Make It Rain], true);
	}

	if(my_class() == $class[Seal Clubber])
	{
		if((enemy == $monster[Hellseal Pup]) && cc_combatCanUse($skill[Clobber]))
		{
			return cc_combatUse($skill[Clobber]);
		}
		if((enemy == $monster[Mother Hellseal]) && cc_combatCanUse($skill[Lunging Thrust-Smack]))
		{
			if(cc_combatCanUse($item[Rain-Doh Indigo Cup], true))
			{
				return cc_combatUse($item[Rain-Doh Indigo Cup], true);
			}
			return cc_combatUse($skill[Lunging Thrust-Smack]);
		}
	}

	if((enemy == $monster[French Guard Turtle]) && cc_combatCanUse($skill[Apprivoisez La Tortue]))
	{
		return cc_combatUse($skill[Apprivoisez La Tortue]);
	}

	if(cc_combatCanUse($skill[Gulp Latte], true) && (get_property("_latteRefillsUsed").to_int() == 0) && !get_property("_latteDrinkUsed").to_boolean() && (my_class() != $class[Vampyre]))
	{
		return cc_combatUse($skill[Gulp Latte], true);
	}

	if(cc_combatCanUse($skill[Ensorcel], true) && (get_property("_ensorcelUses").to_int() < 3))
	{
		if((my_daycount() == 1) && (my_location() == $location[Lair Of The Ninja Snowmen]))
		{
			if($monsters[Ninja Snowman (Chopsticks), Ninja Snowman (Hilt), Ninja Snowman (Mask), Ninja Snowman Janitor, Ninja Snowman Weaponmaster] contains enemy)
			{
				return cc_combatUse($skill[Ensorcel], true);
			}
		}
	}

	if(cc_combatCanUse($skill[Ensorcel], true) && (get_property("_ensorcelUses").to_int() == 0))
	{
		if((my_daycount() == 2) && (enemy.base_attack > 100) && (enemy.phylum == $phylum[bug]) && !get_property("ensorcelModifiers").contains_text("Item Drop"))
		{
			return cc_combatUse($skill[Ensorcel], true);
		}
	}

	//TODO: Chest X-Ray preference?
	if(cc_combatCanUse($skill[Chest X-Ray], true))
	{
		if(my_class() == $class[Vampyre])
		{
			if(enemy == $monster[Ninja Snowman Assassin])
			{
				return cc_combatUse($skill[Chest X-Ray], true);
			}
		}
	}

	#Do not accidentally charge the nanorhino with a non-banisher
	if((my_familiar() == $familiar[Nanorhino]) && (have_effect($effect[Nanobrawny]) == 0))
	{
		foreach sk in $skills[Toss, Clobber, Shell Up, Lunge Smack, Thrust-Smack, Headbutt, Kneebutt, Lunging Thrust-Smack, Club Foot, Shieldbutt, Spirit Snap, Cavalcade Of Fury, Northern Explosion, Spectral Snapper, Harpoon!, Summon Leviatuga]
		{
			if(cc_combatCanUse(sk))
			{
				return cc_combatUse(sk);
			}
		}
	}

	if(cc_combatCanUse($skill[Unleash Nanites], true) && (have_effect($effect[Nanobrawny]) >= 40))
	{
		#if appropriate enemy, then banish
		if(enemy == $monster[Pygmy Janitor])
		{
			return cc_combatUse($skill[Unleash Nanites], true);
		}
	}

	if(cc_combatCanUse($skill[Wink At], true) && (my_familiar() == $familiar[Reanimated Reanimator]))
	{
		if($monsters[Lobsterfrogman, Modern Zmobie, Ninja Snowman Assassin] contains enemy)
		{
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (round <= 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have animator out but can not arrow");
			}
			if(enemy == $monster[modern zmobie])
			{
				set_property("cc_waitingArrowAlcove", get_property("cyrptAlcoveEvilness").to_int() - 20);
			}
			return cc_combatUse($skill[Wink At], true);
		}
	}

	if(cc_combatCanUse($item[Rain-Doh Black Box], true) && (get_property("cc_doCombatCopy") == "yes") && (enemy != $monster[gourmet gourami]))
	{
		set_property("cc_doCombatCopy", "no");
		if(get_property("_raindohCopiesMade").to_int() < 5)
		{
			return cc_combatUse($item[Rain-Doh Black Box], true);
		}
		print("Can not issue copy directive because we have no copies left", "red");
	}

	if(get_property("cc_doCombatCopy") == "yes")
	{
		set_property("cc_doCombatCopy", "no");
	}

	if((enemy == $monster[Plaid Ghost]) && cc_combatCanUse($item[T.U.R.D.S. Key]))
	{
		return cc_combatUse($item[T.U.R.D.S. Key]);
	}

	if((enemy == $monster[Tomb Rat]) && cc_combatCanUse($item[Tangle Of Rat Tails], true))
	{
		if((item_amount($item[Tomb Ratchet]) + item_amount($item[Crumbling Wooden Wheel])) < 10)
		{
			return cc_combatUse($item[Tangle Of Rat Tails], true);
		}
	}

	if((enemy == $monster[Storm Cow]) && cc_combatCanUse($skill[Unleash The Greash], true))
	{
		return cc_combatUse($skill[Unleash The Greash], true);
	}

	if(fingernailClippersLeft > 0)
	{
		fingernailClippersLeft = fingernailClippersLeft - 1;
		if(fingernailClippersLeft == 0)
		{
			set_property("cc_combatHandler", combatState + "(fingernail clippers)");
		}
		set_property("cc_combatHandlerFingernailClippers", "" + fingernailClippersLeft);
		return "item " + $item[Military-Grade Fingernail Clippers];
	}

	#Is $monster[one of doctor weirdeaux's creations valid yet?
	if((item_amount($item[military-grade fingernail clippers]) > 0)  && (my_location() == $location[The Mansion of Dr. Weirdeaux]))
	{
		if(!contains_text(combatState, "fingernail clippers"))
		{
			fingernailClippersLeft = 3;
			set_property("cc_combatHandlerFingernailClippers", "3");
		}
	}

	if(cc_combatCanUse($skill[Extract], true) && (my_mp() > (mp_cost($skill[Extract]) * 2)) && get_property("kingLiberated").to_boolean())
	{
		return cc_combatUse($skill[Extract], true);
	}


	if(cc_combatCanUse($skill[Summon Mayfly Swarm], true) && have_equipped($item[Mayfly Bait Necklace]))
	{
		if($locations[Dreadsylvanian Village, Dreadsylvanian Woods, The Ice Hole, The Ice Hotel, Sloppy Seconds Diner, VYKEA] contains my_location())
		{
			return cc_combatUse($skill[Summon Mayfly Swarm], true);
		}
	}

	if(cc_combatCanUse($skill[Transcendent Olfaction], true))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]) && (item_amount($item[soft green echo eyedrop antidote]) > 3) && (have_effect($effect[Thrice-Cursed]) == 0))
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("writingDesksDefeated").to_int() < 5))
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
		if($monsters[Bob Racecar, cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Tomb Rat] contains enemy)
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]))
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
		if((enemy == $monster[Gurgle the Turgle]) && get_property("kingLiberated").to_boolean())
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
		if((enemy == $monster[Smoke Monster]) && (item_amount($item[Pack Of Smokes]) > 0))
		{
			return cc_combatUse($skill[Transcendent Olfaction], true);
		}
	}

	if(cc_combatCanUse($skill[Gallapagosian Mating Call], true))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]) && (have_effect($effect[Thrice-Cursed]) == 0) && (get_property("_gallapagosMonster") != enemy))
		{
			return cc_combatUse($skill[Gallapagosian Mating Call], true);
		}
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("writingDesksDefeated").to_int() < 5) && (get_property("_gallapagosMonster") != enemy))
		{
			return cc_combatUse($skill[Gallapagosian Mating Call], true);
		}
		if(($monsters[cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Tomb Rat] contains enemy) && (get_property("_gallapagosMonster") != enemy))
		{
			return cc_combatUse($skill[Gallapagosian Mating Call], true);
		}
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]) && (get_property("_gallapagosMonster") != enemy))
		{
			return cc_combatUse($skill[Gallapagosian Mating Call], true);
		}
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			if((get_property("_gallapagosMonster") != $monster[Bob Racecar]) && (get_property("_gallapagosMonster") != $monster[Racecar Bob]))
			{
				return cc_combatUse($skill[Gallapagosian Mating Call], true);
			}
		}
	}

	if(cc_combatCanUse($skill[Offer Latte To Opponent], true))
	{
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]) && (get_property("_latteMonster") != enemy) && get_property("_latteCopyUsed").to_boolean())
		{
			return cc_combatUse($skill[Offer Latte To Opponent], true);
		}
	}

	if(cc_combatCanUse($skill[Perceive Soul], true))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]) && (have_effect($effect[Thrice-Cursed]) == 0) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		if((enemy == $monster[Pygmy Witch Accountant]) && (my_location() == $location[The Hidden Office Building]) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("writingDesksDefeated").to_int() < 5) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		if(($monsters[Animated Ornate Nightstand, Blooper, Blue Oyster Cultist, cabinet of Dr. Limpieza, Dairy Goat, Dirty Old Lihc, Gaunt Ghuol, Green Ops Soldier, Monstrous Boiler, Morbid Skull, Possessed Wine Rack, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Red Butler, Tomb Rat, Waiter Dressed As A Ninja] contains enemy) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		//Topiary?
		if(($monsters[Blur, Knob Goblin Harem Girl] contains enemy) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]) && (get_property("_perceiveSoulMonster") != enemy))
		{
			return cc_combatUse($skill[Perceive Soul], true);
		}
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			if((get_property("_perceiveSoulMonster") != $monster[Bob Racecar]) && (get_property("_perceiveSoulMonster") != $monster[Racecar Bob]))
			{
				return cc_combatUse($skill[Perceive Soul], true);
			}
		}
	}

	if(cc_combatCanUse($skill[Make Friends], true) && (get_property("makeFriendsMonster") != enemy) && (my_audience() >= 20))
	{
		if((enemy == $monster[Pygmy Shaman]) && (my_location() == $location[The Hidden Apartment Building]))
		{
			return cc_combatUse($skill[Make Friends], true);
		}
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("lastSecondFloorUnlock").to_int() < my_ascensions()))
		{
			return cc_combatUse($skill[Make Friends], true);
		}
		if($monsters[Blooper, Bob Racecar, cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Tomb Rat] contains enemy)
		{
			return cc_combatUse($skill[Make Friends], true);
		}
	}

	if((get_property("longConMonster") != enemy) && cc_combatCanUse($skill[Long Con], true) && (get_property("_longConUsed").to_int() < 5))
	{
		if($monsters[Blooper, cabinet of Dr. Limpieza, Dairy Goat, Dirty Old Lihc, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Tomb Rat, Writing Desk] contains enemy)
		{
			return cc_combatUse($skill[Long Con], true);
		}

		if(($monsters[Bob Racecar, Racecar Bob] contains enemy) && (get_property("palindomeDudesDefeated").to_int() < 5) && (get_property("longConMonster") != $monster[Racecar Bob]) && (get_property("longConMonster") != $monster[Bob Racecar]))
		{
			return cc_combatUse($skill[Long Con], true);
		}
	}

	string flyerString = combat_flyer();
	if(flyerString != "")
	{
		return flyerString;
	}

	if(cc_combatCanUse($item[Cocktail Napkin], true))
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return cc_combatUse($item[Cocktail Napkin], true);
		}
	}

	if(cc_combatCanUse($item[DNA Extraction Syringe], true) && (monster_level_adjustment() < 150))
	{
		if(type != current)
		{
			return cc_combatUse($item[DNA extraction syringe], true);
		}
	}

	if(!contains_text(combatState, "yellowray"))
	{
		boolean doYellow = false;
		if((enemy == $monster[burly sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doYellow = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]) && (get_property("cc_airship") == "finished"))
		{
			doYellow = true;
		}
		if((get_property("cc_filthwormGland") == "start") && (enemy == $monster[larval filthworm]))
		{
			doYellow = true;
		}
		if(($monsters[Orcish Frat Boy Spy, War Frat 151st Infantryman] contains enemy) && !have_outfit("Frat Warrior Fatigues"))
		{
			doYellow = true;
		}
		if(($monsters[Knob Goblin Harem Girl] contains enemy) && !have_outfit("Knob Goblin Harem Girl Disguise"))
		{
			doYellow = true;
		}
		if($monsters[Filthworm Royal Guard] contains enemy)
		{
			doYellow = true;
		}
		if(doYellow)
		{
			string combatAction = yellowRayCombatString();
			if(combatAction != "")
			{
				set_property("cc_combatHandler", combatState + "(yellowray)");
				itemSkill_t converted = cc_convertAction(combatAction);
				if(converted.sk != $skill[none])
				{
					return cc_combatUse(converted.sk, true);
				}
				else if(converted.it != $item[none])
				{
					return cc_combatUse(converted.it, true);
				}
				else
				{
					print("Unable to track yellow ray behavior: " + combatAction, "red");
				}
			}
			else
			{
				print("Wanted a yellow ray but we can not find one.", "red");
			}
		}
	}

	if(contains_text(combatState, "yellowray"))
	{
		abort("Ugh, where is my damn yellowray!!!");
	}

	if(cc_combatCanUse($skill[Hugs and Kisses!], true) && (my_familiar() == $familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() <= 10))
	{
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			return cc_combatUse($skill[Hugs and Kisses!], true);
		}

		if((internalQuestStatus("questL04Bat") < 3) && (item_drop_modifier() < 300.0))
		{
			if($monsters[Baseball Bat, Beanbat, Doughbat] contains enemy)
			{
				return cc_combatUse($skill[Hugs and Kisses!], true);
			}
		}

		if((item_amount($item[Killing Jar]) == 0) && (item_drop_modifier() < 800.0))
		{
			if($monsters[Banshee Librarian] contains enemy)
			{
				return cc_combatUse($skill[Hugs and Kisses!], true);
			}
		}

		if((item_amount($item[Knob Goblin Perfume]) == 0) && (item_drop_modifier() < 300.0) && (have_effect($effect[Knob Goblin Perfume]) == 0))
		{
			if($monsters[Knob Goblin Madam] contains enemy)
			{
				return cc_combatUse($skill[Hugs and Kisses!], true);
			}
		}

		if(get_property("_xoHugsUsed").to_int() <= 7)
		{
			if($monsters[Bearpig Topiary Animal, Eagle, Elephant (Meatcar?) Topiary Animal, Fleet Woodsman, Spider (Duck?) Topiary Animal] contains enemy)
			{
				return cc_combatUse($skill[Hugs and Kisses!], true);
			}
			if(!possessEquipment($item[Knob Goblin Harem Veil]) && !possessEquipment($item[Knob Goblin Harem Pants]))
			{
				if($monsters[Knob Goblin Harem Girl] contains enemy)
				{
					return cc_combatUse($skill[Hugs and Kisses!], true);
				}
			}
		}

		if(get_property("_xoHugsUsed").to_int() <= 4)
		{
			if($monsters[Bookbat, Gaunt Ghuol] contains enemy)
			{
				return cc_combatUse($skill[Hugs and Kisses!], true);
			}

			if(!possessEquipment($item[Mohawk Wig]))
			{
				if($monsters[Burly Sidekick] contains enemy)
				{
					return cc_combatUse($skill[Hugs and Kisses!], true);
				}
			}
		}

		//Hellion Cubes?

	}

	if(cc_combatCanUse($item[Green Smoke Bomb]))
	{
		if($monsters[Animated Possessions, Natural Spider] contains enemy)
		{
			return cc_combatUse($item[Green Smoke Bomb]);
		}
	}

	if(cc_combatCanUse($item[Short Writ Of Habeas Corpus], true) && !get_property("kingLiberated").to_boolean())
	{
		if($monsters[Pygmy Orderlies, Pygmy Witch Lawyer, Pygmy Witch Nurse] contains enemy)
		{
			return cc_combatUse($item[Short Writ Of Habeas Corpus], true);
		}
	}

	if(!contains_text(combatState, "banishercheck"))
	{
		string banishAction = banisherCombatString(enemy, my_location());
		if(banishAction != "")
		{
			print("Looking at banishAction: " + banishAction, "green");
		}
		if(banishAction != "")
		{
			set_property("cc_combatHandler", combatState + "(banisher)");
			itemSkill_t convert = cc_convertAction(banishAction);
			if(convert.sk != $skill[none])
			{
				return cc_combatUse(convert.sk, true);
			}
			else if(convert.it != $item[none])
			{
				return cc_combatUse(convert.it, true);
			}
			else
			{
				print("Unable to track banisher behavior: " + banishAction, "red");
			}
			//return banishAction;
		}
		set_property("cc_combatHandler", combatState + "(banishercheck)");
		combatState += "(banishercheck)";
	}

	if(cc_have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10) && cc_combatCanUse($skill[Macrometeorite], true) && (cc_my_path() != "G-Lover"))
	{
		if((enemy == $monster[Banshee Librarian]) && (item_amount($item[Killing Jar]) > 0))
		{
			return cc_combatUse($skill[Macrometeorite]);
		}
		if((enemy == $monster[Beefy Bodyguard Bat]) && ($location[The Boss Bat\'s Lair].turns_spent >= 4) && (my_location() == $location[The Boss Bat\'s Lair]) && (my_class() != $class[Vampyre]))
		{
			return cc_combatUse($skill[Macrometeorite]);
		}
		if(($monsters[Angry Ghost, Annoyed Snake, Government Agent, Government Bureaucrat, Sausage Goblin, Slime Blob, Terrible Mutant] contains enemy) && (my_location() == $location[Sonofa Beach]) && (item_amount($item[Barrel Of Gunpowder]) < 5))
		{
			return cc_combatUse($skill[Macrometeorite]);
		}
		if((enemy == $monster[Knob Goblin Madam]) && (item_amount($item[Knob Goblin Perfume]) > 0))
		{
			return cc_combatUse($skill[Macrometeorite]);
		}
		if($monsters[Bookbat, Craven Carven Raven, Drunk Goat, Knight In White Satin, Knob Goblin Harem Guard, Mad Wino, Plaid Ghost, Possessed Laundry Press, Sabre-Toothed Goat, Senile Lihc, Skeletal Sommelier, Slick Lihc, White Chocolate Golem] contains enemy)
		{
			return cc_combatUse($skill[Macrometeorite], true);
		}
		if((enemy == $monster[Stone Temple Pirate]) && possessEquipment($item[Eyepatch]))
		{
			return cc_combatUse($skill[Macrometeorite]);
		}
		if(my_location() == $location[The Obligatory Pirate\'s Cove])
		{
			if($monsters[Shady Pirate, Shifty Pirate] contains enemy)
			{
				return cc_combatUse($skill[Macrometeorite]);
			}
			if((enemy == $monster[Sassy Pirate]) && possessEquipment($item[Swashbuckling Pants]))
			{
				return cc_combatUse($skill[Macrometeorite]);
			}
			if((enemy == $monster[Smarmy Pirate]) && possessEquipment($item[Eyepatch]))
			{
				return cc_combatUse($skill[Macrometeorite]);
			}
			if((enemy == $monster[Swarthy Pirate]) && possessEquipment($item[Stuffed Shoulder Parrot]))
			{
				return cc_combatUse($skill[Macrometeorite]);
			}
		}
	}

	if(cc_combatCanUse($item[Disposable Instant Camera], true))
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			return cc_combatUse($item[Disposable Instant Camera], true);
		}
	}

	if(cc_combatCanUse($item[Duskwalker Syringe]) && (item_amount($item[Bubblin\' Crude]) < 11) && (item_amount($item[Jar Of Oil]) == 0))
	{
		boolean wantCrude = ((get_property("twinPeakProgress").to_int() & 4) == 0);
		if(($monsters[Oil Baron, Oil Cartel, Oil Slick, Oil Tycoon] contains enemy) && wantCrude)
		{
			return cc_combatUse($item[Duskwalker Syringe]);
		}
	}

	if(cc_combatCanUse($item[opium grenade], true))
	{
		if(enemy == $monster[pair of burnouts])
		{
			return cc_combatUse($item[opium grenade], true);
		}
	}

	string protonGhost = combat_protonicGhost(blocked, damageReceived);
	if(protonGhost != "")
	{
		return protonGhost;
	}

	# Instakill handler
	boolean doInstaKill = true;
	if($monsters[Lobsterfrogman, Ninja Snowman Assassin] contains enemy)
	{
		if(cc_have_skill($skill[Digitize]) && (get_property("_sourceTerminalDigitizeMonster") != enemy))
		{
			doInstaKill = false;
		}
	}



	if(instakillable(enemy) && !isFreeMonster(enemy) && doInstaKill)
	{
		if(cc_combatCanUse($skill[Lightning Strike], true))
		{
			return cc_combatUse($skill[Lightning Strike], true);
		}

		if(cc_combatCanUse($skill[Shattering Punch], true) && ((my_mp() / 2) > mp_cost($skill[Shattering Punch])) && (get_property("_shatteringPunchUsed").to_int() < 3))
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				return cc_combatUse($skill[Shattering Punch], true);
			}
		}
		if(cc_combatCanUse($skill[Gingerbread Mob Hit], true) && is_unrestricted($item[My Life of Crime\, a Memoir]) && ((my_mp() / 2) > mp_cost($skill[Gingerbread Mob Hit])) && !get_property("_gingerbreadMobHitUsed").to_boolean())
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				return cc_combatUse($skill[Gingerbread Mob Hit], true);
			}
		}

//		Can not use _usedReplicaBatoomerang if we have more than 1 because of the double item use issue...
//		Sure, we can try to use a second item (if we have it or are forced to buy it... ugh).
//		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0) && (get_property("_usedReplicaBatoomerang").to_int() < 3))
//		THIS IS COPIED TO THE ED SECTION, IF IT IS FIXED, FIX IT THERE TOO!
		if(cc_combatCanUse($item[Replica Bat-oomerang], true))
		{
			if(get_property("cc_batoomerangDay").to_int() != my_daycount())
			{
				set_property("cc_batoomerangDay", my_daycount());
				set_property("cc_batoomerangUse", 0);
			}
			if(get_property("cc_batoomerangUse").to_int() < 3)
			{
				set_property("cc_batoomerangUse", get_property("cc_batoomerangUse").to_int() + 1);
				return cc_combatUse($item[Replica Bat-oomerang], true);
			}
		}

		if(cc_combatCanUse($skill[Fire The Jokester\'s Gun], true) && (equipped_item($slot[Weapon]) == $item[The Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean())
		{
			return cc_combatUse($skill[Fire the Jokester\'s Gun], true);
		}
	}

	if(cc_combatCanUse($skill[Bad Medicine], true) && (my_mp() >= (3 * mp_cost($skill[Bad Medicine]))))
	{
		return cc_combatUse($skill[Bad Medicine], true);
	}

	boolean doWeaksauce = true;
	if((buffed_hit_stat() - 20) > monster_defense())
	{
		doWeaksauce = false;
	}
	if(my_class() == $class[Sauceror])
	{
		doWeaksauce = true;
	}

	if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
	{
		return cc_combatUse($skill[Curse Of Weaksauce], true);
	}

	if(cc_combatCanUse($skill[Intimidating Bellow], true) && (my_mp() >= 25) && cc_have_skill($skill[Louder Bellows]))
	{
		return cc_combatUse($skill[Intimidating Bellow], true);
	}

	if(enemy == $monster[Eldritch Tentacle])
	{
		mcd = 151;
	}

	#Default behaviors:
	if(mcd <= 150)
	{
		if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
		{
			return cc_combatUse($skill[Curse Of Weaksauce], true);
		}

		if(cc_combatCanUse($item[Daily Affirmation: Keep Free Hate In Your Heart], true) && hippy_stone_broken() && !get_property("_affirmationHateUsed").to_boolean() && get_property("kingLiberated").to_boolean())
		{
			return cc_combatUse($item[Daily Affirmation: Keep Free Hate In Your Heart], true);
		}

		if(cc_combatCanUse($skill[Canhandle], true))
		{
			if($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand]))
			{
				return cc_combatUse($skill[Canhandle], true);
			}
		}

		if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && (my_class() == $class[Sauceror]) && (my_mp() >= 20))
		{
			return cc_combatUse($skill[Curse Of Weaksauce], true);
		}

		foreach sk in $skills[Pocket Crumbs, Micrometeorite]
		{
			if(cc_combatCanUse(sk, true))
			{
				return cc_combatUse(sk, true);
			}
		}

		if(cc_combatCanUse($item[Cow Poker], true))
		{
			if($monsters[Caugr, Moomy, Pharaoh Amoon-Ra Cowtep, Pyrobove, Spidercow] contains enemy)
			{
				return cc_combatCanUse($item[Cow Poker], true);
			}
		}

		if(cc_combatCanUse($item[Western-Style Skinning Knife], true))
		{
			if($monsters[Caugr, Coal Snake, Diamondback Rattler, Frontwinder, Grizzled Bear, Mountain Lion] contains enemy)
			{
				return cc_combatUse($item[Western-Style Skinning Knife], true);
			}
		}

		foreach sk in $skills[Air Dirty Laundry, Cowboy Kick, Fire Death Ray, Ply Reality, Summon Love Mosquito]
		{
			if(cc_combatCanUse(sk, true))
			{
				return cc_combatUse(sk, true);
			}
		}

		foreach it in $items[Rain-Doh Indigo Cup, Tomayohawk-Style Reflex Hammer]
		{
			if(cc_combatCanUse(it, true))
			{
				return cc_combatUse(it, true);
			}
		}


		if(cc_combatCanUse($skill[Cadenza], true) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			if($items[Accordion of Jordion, Accordionoid Rocca, non-Euclidean non-accordion, Shakespeare\'s Sister\'s Accordion, zombie accordion] contains equipped_item($slot[weapon]))
			{
				return cc_combatUse($skill[Cadenza], true);
			}
		}

		if(cc_combatCanUse($skill[Extract], true) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && (item_amount($item[Source Essence]) <= 60))
		{
			return cc_combatUse($skill[Extract], true);
		}

		if(cc_combatCanUse($skill[Extract Jelly], true) && (my_mp() > (mp_cost($skill[Extract Jelly]) * 3)) && canSurvive(2.0) && (my_familiar() == $familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3) && ($elements[hot, spooky, stench] contains monster_element(enemy)))
		{
			return cc_combatUse($skill[Extract Jelly], true);
		}

		if(cc_combatCanUse($skill[Science! Fight With Medicine], true) && ((my_hp() * 2) < my_maxhp()))
		{
			return cc_combatUse($skill[Science! Fight With Medicine], true);
		}
		if(cc_combatCanUse($skill[Science! Fight With Rational Thought], true) && (have_effect($effect[Rational Thought]) < 10))
		{
			return cc_combatUse($skill[Science! Fight With Rational Thought], true);
		}

		if(cc_combatCanUse($item[Time-Spinner], true))
		{
			return cc_combatUse($item[Time-Spinner], true);
		}

		if(cc_combatCanUse($skill[Sing Along], true) && (get_property("boomBoxSong") == "Remainin\' Alive"))
		{
			return cc_combatUse($skill[Sing Along], true);
		}
		if(cc_combatCanUse($skill[Sing Along], true) && canSurvive(2.5) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat"))
		{
			return cc_combatUse($skill[Sing Along], true);
		}
	}

	#Default behaviors, multi-staggers when chance is 50% or greater
	if(mcd < 100)
	{
		if(cc_combatCanUse($item[Rain-Doh Blue Balls], true))
		{
			return cc_combatUse($item[Rain-Doh Blue Balls], true);
		}

		if(cc_combatCanUse($skill[Summon Love Gnats], true))
		{
			return cc_combatUse($skill[Summon Love Gnats], true);
		}

		if(cc_combatCanUse($skill[Summon Love Stinkbug], true) && contains_text(combatState, $skill[Summon Love Gnats]) && !contains_text(text, "STUN RESIST"))
		{
			return cc_combatUse($skill[Summon Love Stinkbug], true);
		}

		if(cc_combatCanUse($skill[Sing Along], true) && (get_property("boomBoxSong") == "Remainin\' Alive"))
		{
			return cc_combatUse($skill[Sing Along], true);
		}
		if(cc_combatCanUse($skill[Sing Along], true) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && canSurvive(2.5))
		{
			return cc_combatUse($skill[Sing Along], true);
		}
	}

	if((my_location() == $location[Super Villain\'s Lair]) && (cc_my_path() == "License to Adventure") && canSurvive(2.0) && (enemy == $monster[Villainous Minion]))
	{
		if(!get_property("_villainLairCanLidUsed").to_boolean() && (item_amount($item[Razor-Sharp Can Lid]) > 0))
		{
			return "item " + $item[Razor-Sharp Can Lid];
		}
		if(!get_property("_villainLairWebUsed").to_boolean() && (item_amount($item[Spider Web]) > 0))
		{
			return "item " + $item[Spider Web];
		}
		if(!get_property("_villainLairFirecrackerUsed").to_boolean() && (item_amount($item[Knob Goblin Firecracker]) > 0))
		{
			return "item " + $item[Knob Goblin Firecracker];
		}
	}

	if(cc_combatCanUse($skill[Portscan], true) && (my_location().turns_spent < 8) && (get_property("_sourceTerminalPortscanUses").to_int() < 3) && !get_property("_portscanPending").to_boolean())
	{
		if($locations[The Castle in the Clouds in the Sky (Ground Floor), The Haunted Bathroom, The Haunted Gallery] contains my_location())
		{
			set_property("_portscanPending", true);
			return cc_combatUse($skill[Portscan], true);
		}
	}

	if(cc_combatCanUse($skill[Candyblast], true) && (my_mp() > 60) && get_property("kingLiberated").to_boolean())
	{
		# We can get only one candy and we can detect it, if so desired:
		# "Hey, some of it is even intact afterwards!"
		return cc_combatUse($skill[Candyblast], true);
	}

	if(cc_combatCanUse($skill[Spirit Snap], true) && (my_class() == $class[Turtle Tamer]) && (my_mp() > 80))
	{
		if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
		{
			return cc_combatUse($skill[Spirit Snap], true);
		}
	}

	if(cc_combatCanUse($skill[Stuffed Mortar Shell], true) && (my_class() == $class[Sauceror]) && canSurvive(2.0))
	{
		return cc_combatUse($skill[Stuffed Mortar Shell], true);
	}

	if(cc_combatCanUse($skill[Duplicate], true) && (get_property("_sourceTerminalDuplicateUses").to_int() == 0) && !get_property("kingLiberated").to_boolean() && (cc_my_path() != "Nuclear Autumn"))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return cc_combatUse($skill[Duplicate], true);
		}
	}

	if(cc_combatCanUse($item[Exploding Cigar], true) && contains_text(combatState, $skill[duplicate]))
	{
		return cc_combatUse( $item[Exploding Cigar], true);
	}

	if(contains_text(combatState, $skill[Duplicate]) && cc_combatCanUse($skill[Gelatinous Kick]))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return cc_combatUse($skill[Gelatinous Kick]);
		}
	}

	if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && (my_class() == $class[Sauceror]) && (my_mp() >= 32))
	{
		return cc_combatUse($skill[Curse Of Weaksauce], true);
	}

	if(cc_combatCanUse($skill[Curse Of Weaksauce], true) && (my_class() == $class[Sauceror]) && (my_mp() >= 8) && contains_text(combatState, $skill[Stuffed Mortar Shell]))
	{
		return cc_combatUse($skill[Curse Of Weaksauce], true);
	}

	if(cc_combatCanUse($skill[Digitize], true) && (get_property("_sourceTerminalDigitizeUses").to_int() == 0) && !get_property("kingLiberated").to_boolean())
	{
		if($monsters[Ninja Snowman Assassin, Lobsterfrogman] contains enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				return cc_combatUse($skill[Digitize], true);
			}
		}
	}

	//TODO: This appears to use an older directive model
	if(cc_combatCanUse($skill[Digitize], true) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3) && !get_property("kingLiberated").to_boolean())
	{
		if(get_property("cc_digitizeDirective") == enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				return cc_combatUse($skill[Digitize], true);
			}
		}
	}

	if((enemy == $monster[LOV Enforcer]) && cc_combatCanUse($skill[Saucestorm]))
	{
		return cc_combatUse($skill[Saucestorm]);
	}

	string attackMinor = "attack with weapon";
	string attackMajor = "attack with weapon";
	int costMinor = 0;
	int costMajor = 0;
	string stunner = "";
	int costStunner = 0;

	switch(my_class())
	{
	case $class[Seal Clubber]:
		attackMinor = "attack with weapon";
		if(cc_combatCanUse($skill[Lunge Smack]) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMinor = "skill " + $skill[Lunge Smack];
			costMinor = mp_cost($skill[Lunge Smack]);
		}
		if(cc_combatCanUse($skill[Lunging Thrust-Smack]) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMajor = "skill " + $skill[Lunging Thrust-Smack];
			costMajor = mp_cost($skill[Lunging Thrust-Smack]);
		}
		if(cc_combatCanUse($skill[Club Foot], true))
		{
			stunner = "skill " + $skill[Club Foot];
			costStunner = mp_cost($skill[Club Foot]);
		}
		break;
	case $class[Turtle Tamer]:
		attackMinor = "attack with weapon";
		if((my_mp() > 150) && cc_combatCanUse($skill[Shieldbutt]))
		{
			attackMinor = "skill shieldbutt";
			costMinor = mp_cost($skill[Shieldbutt]);
		}
		else if((my_mp() > 80) && ((my_hp() * 2) < my_maxhp()) && cc_combatCanUse($skill[Kneebutt]))
		{
			attackMinor = "skill kneebutt";
			costMinor = mp_cost($skill[Kneebutt]);
		}
		if(((round > 15) || ((my_hp() * 2) < my_maxhp())) && cc_combatCanUse($skill[Kneebutt]))
		{
			attackMajor = "skill kneebutt";
			costMajor = mp_cost($skill[Kneebutt]);
		}
		if(cc_combatCanUse($skill[Shieldbutt]))
		{
			attackMajor = "skill shieldbutt";
			costMajor = mp_cost($skill[Shieldbutt]);
		}
		if(cc_combatCanUse($skill[Shell Up], true))
		{
			stunner = "skill shell up";
			costStunner = mp_cost($skill[Shell Up]);
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_combatCanUse($skill[Saucestorm]))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;
	case $class[Pastamancer]:
		if(cc_combatCanUse($skill[Cannelloni Cannon]))
		{
			attackMinor = "skill Cannelloni Cannon";
			costMinor = mp_cost($skill[Cannelloni Cannon]);
		}
		if(cc_combatCanUse($skill[Weapon of the Pastalord]))
		{
			attackMajor = "skill Weapon of the Pastalord";
			costMajor = mp_cost($skill[Weapon of the Pastalord]);
		}
		if(cc_combatCanUse($skill[Saucestorm]))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			attackMinor = "skill " + $skill[Saucestorm];
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		if(cc_combatCanUse($skill[Utensil Twist]) && (item_type(equipped_item($slot[weapon])) == "utensil"))
		{
			if(equipped_item($slot[weapon]) == $item[Hand That Rocks the Ladle])
			{
				attackMajor = "skill " + $skill[Utensil Twist];
				attackMinor = "skill " + $skill[Utensil Twist];
				costMinor = mp_cost($skill[Utensil Twist]);
				costMajor = mp_cost($skill[Utensil Twist]);
			}
			else if((enemy.physical_resistance <= 80) && (attackMinor != ("skill " + $skill[Saucestorm])))
			{
				attackMinor = "skill " + $skill[Utensil Twist];
				costMinor = mp_cost($skill[Utensil Twist]);
			}
		}
		if(cc_combatCanUse($skill[Entangling Noodles]))
		{
			stunner = "skill entangling noodles";
			costStunner = mp_cost($skill[Entangling Noodles]);
		}
		break;
	case $class[Sauceror]:
		if(cc_combatCanUse($skill[Saucegeyser]))
		{
			attackMinor = "skill saucegeyser";
			attackMajor = "skill saucegeyser";
			costMinor = mp_cost($skill[Saucegeyser]);
			costMajor = mp_cost($skill[Saucegeyser]);
		}
		else if(cc_combatCanUse($skill[Saucecicle]) && (monster_element(enemy) != $element[cold]))
		{
			attackMinor = "skill saucecicle";
			attackMajor = "skill saucecicle";
			costMinor = mp_cost($skill[Saucecicle]);
			costMajor = mp_cost($skill[Saucecicle]);
		}
		else if(cc_combatCanUse($skill[Saucestorm]))
		{
			attackMinor = "skill saucestorm";
			attackMajor = "skill saucestorm";
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		else if(cc_combatCanUse($skill[Wave of Sauce]) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = "skill wave of sauce";
			attackMajor = "skill wave of sauce";
			costMinor = mp_cost($skill[Wave of Sauce]);
			costMajor = mp_cost($skill[Wave of Sauce]);
		}
		else if(cc_combatCanUse($skill[Stream of Sauce]) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = "skill stream of sauce";
			attackMajor = "skill stream of sauce";
			costMinor = mp_cost($skill[Stream of Sauce]);
			costMajor = mp_cost($skill[Stream of Sauce]);
		}

		if(cc_combatCanUse($skill[Soul Bubble], true))
		{
			stunner = "skill soul bubble";
			costStunner = mp_cost($skill[Soul Bubble]);
		}

		if(!contains_text(combatState, "delaymortarshell") && contains_text(combatState, $skill[Stuffed Mortar Shell]) && (my_class() == $class[Sauceror]) && canSurvive(2.0) && cc_combatCanUse($skill[Salsaball]))
		{
			set_property("cc_combatHandler", combatState + "(delaymortarshell)");
			if(cc_combatCanUse($skill[Candyblast], true))
			{
				return cc_combatUse($skill[Candyblast], true);
			}
			return cc_combatUse($skill[Salsaball]);
		}

		break;

	case $class[Avatar of Boris]:
		if(cc_combatCanUse($skill[Heroic Belch]) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && (my_fullness() >= 5))
		{
			attackMinor = "skill " + $skill[Heroic Belch];
			attackMajor = "skill " + $skill[Heroic Belch];
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}

		if(cc_combatCanUse($skill[Broadside]))
		{
			stunner = "skill " + $skill[Broadside];
			costStunner = mp_cost($skill[Broadside]);
		}
		break;

	case $class[Avatar of Sneaky Pete]:
		if(cc_combatCanUse($skill[Peel Out], true))
		{
			if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, Tomb Asp, Tomb Servant,  W imp] contains enemy)
			{
				return cc_combatUse($skill[Peel Out]);
			}
		}


		if(cc_combatCanUse($item[Firebomb]) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]))
		{
			return cc_combatUse($item[Firebomb]);
		}

		if(cc_combatCanUse($skill[Pop Wheelie], true) && (my_mp() > 40))
		{
			return cc_combatUse($skill[Pop Wheelie], true);
		}

		if(cc_combatCanUse($skill[Snap Fingers], true))
		{
			stunner = $skill[Snap Fingers];
			costStunner = mp_cost($skill[Snap Fingers]);
		}

		break;

	case $class[Accordion Thief]:

		if(cc_combatCanUse($skill[Cadenza], true) && (item_type(equipped_item($slot[weapon])) == "accordion") && canSurvive(2.0))
		{
			if($items[accordion file, alarm accordion, autocalliope, bal-musette accordion, baritone accordion, cajun accordion, ghost accordion, peace accordion, pentatonic accordion, pygmy concertinette, skipper\'s accordion, squeezebox of the ages, the trickster\'s trikitixa] contains equipped_item($slot[weapon]))
			{
				return cc_combatUse($skill[Cadenza], true);
			}
		}

		if(cc_combatCanUse($skill[Accordion Bash], true) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			stunner = "skill " + $skill[Accordion Bash];
			costStunner = mp_cost($skill[Accordion Bash]);
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_combatCanUse($skill[Saucestorm]))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Disco Bandit]:

		// I have no idea how Disco Bandits fight, even less than AT.

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_combatCanUse($skill[Saucestorm]))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}
		break;
	case $class[Vampyre]:
			if((my_hp() < my_maxhp()) && cc_combatCanUse($skill[Dark Feast], true) && (enemy.base_hp > 0) && (my_location() != $location[The Smut Orc Logging Camp]))
			{
				//Current HP is what matters
				if(enemy.base_hp <= 30)
				{
					return cc_combatUse($skill[Dark Feast], true);
				}
				else if((enemy.base_hp <= 100) && have_skill($skill[Hypnotic Eyes]) && cc_combatCanUse($skill[Dark Feast], true))
				{
					return cc_combatUse($skill[Dark Feast], true);
				}
			}
			foreach sk in $skills[Chill Of The Tomb]
			{
				if(cc_combatCanUse(sk) && (enemy.defense_element != $element[cold]))
				{
					return cc_combatUse(sk);
				}
			}
			foreach sk in $skills[Piercing Gaze, Savage Bite]
			{
				if(cc_combatCanUse(sk))
				{
					return cc_combatUse(sk);
				}
			}
		break;
	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		if((my_hp() > 80) && cc_combatCanUse($skill[Extract Oil], true) && (my_mp() >= (3 * mp_cost($skill[Extract Oil]))))
		{
			if($monsters[Aggressive grass snake, Bacon snake, Batsnake, Black adder, Burning Snake of Fire, Coal snake, Diamondback rattler, Frontwinder, Frozen Solid Snake, King snake, Licorice snake, Mutant rattlesnake, Prince snake, Sewer snake with a sewer snake in it, Snakeleton, The Snake with Like Ten Heads, Tomb asp, Trouser Snake, Whitesnake] contains enemy)
			{

			}
			else if(($phylums[beast, dude, hippy, humanoid, orc, pirate] contains type) && (item_amount($item[Skin Oil]) < 3))
			{
				return cc_combatUse($skill[Extract Oil], true);
			}
			else if(($phylums[bug, construct, constellation, demon, elemental, elf, fish, goblin, hobo, horror, mer-kin, penguin, plant, slime, weird] contains type) && (item_amount($item[Unusual Oil]) < 4))
			{
				return cc_combatUse($skill[Extract Oil], true);
			}
			else if(($phylums[undead] contains type) && (item_amount($item[Skin Oil]) < 5))
			{
				return cc_combatUse($skill[Extract Oil], true);
			}
		}
		if(cc_combatCanUse($skill[Good Medicine], true) && (my_mp() >= (3 * mp_cost($skill[Good Medicine]))))
		{
			return cc_combatUse($skill[Good Medicine], true);
		}

		if(cc_combatCanUse($skill[Hogtie], true) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			return cc_combatUse($skill[Hogtie], true);
		}


		if(cc_combatCanUse($skill[One-Two Punch]) && (equipped_item($slot[Weapon]) == $item[none]))
		{
//			attackMajor = "skill " + $skill[One-Two Punch];
//			attackMinor = "skill " + $skill[One-Two Punch];
//			costMajor = mp_cost($skill[One-Two Punch]);
//			costMinor = mp_cost($skill[One-Two Punch]);
			//This does not seem to work.
		}



		if(cc_combatCanUse($skill[Lavafava]) && (enemy.defense_element != $element[hot]))
		{
			attackMajor = "skill " + $skill[Lavafava];
			attackMinor = "skill " + $skill[Lavafava];
			costMajor = mp_cost($skill[Lavafava]);
			costMinor = mp_cost($skill[Lavafava]);
		}

		foreach sk in $skills[Beanstorm, Fan Hammer]
		{
			if(cc_combatCanUse(sk))
			{
				attackMajor = "skill " + sk;
				attackMinor = "skill " + sk;
				costMajor = mp_cost(sk);
				costMinor = mp_cost(sk);
			}
		}

		if(cc_combatCanUse($skill[Snakewhip]) && (enemy.physical_resistance < 80))
		{
			attackMajor = "skill " + $skill[Snakewhip];
			attackMinor = "skill " + $skill[Snakewhip];
			costMajor = mp_cost($skill[Snakewhip]);
			costMinor = mp_cost($skill[Snakewhip]);
		}

		if(cc_combatCanUse($skill[Pungent Mung]) && (enemy.defense_element != $element[stench]))
		{
			attackMajor = "skill " + $skill[Pungent Mung];
			attackMinor = "skill " + $skill[Pungent Mung];
			costMajor = mp_cost($skill[Pungent Mung]);
			costMinor = mp_cost($skill[Pungent Mung]);
		}

		if(cc_combatCanUse($skill[Cowcall]) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (have_effect($effect[Cowrruption]) >= 60))
		{
			attackMajor = "skill " + $skill[Cowcall];
			attackMinor = "skill " + $skill[Cowcall];
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}

		if(cc_combatCanUse($skill[Cowcall]) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (my_class() == $class[Cow Puncher]))
		{
			attackMajor = "skill " + $skill[Cowcall];
			attackMinor = "skill " + $skill[Cowcall];
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}

		if(cc_combatCanUse($skill[Beanscreen], true) && canSurvive(2.0))
		{
			stunner = "skill " + $skill[Beanscreen];
			costStunner = mp_cost($skill[Beanscreen]);
		}

		if(cc_combatCanUse($skill[Hogtie], true) && (my_mp() >= (3 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			stunner = "skill " + $skill[Hogtie];
			costStunner = mp_cost($skill[Hogtie]);
		}
		break;
	}

	if(round <= 25)
	{
		if(((my_hp() * 10)/3) < my_maxhp())
		{
			if(cc_combatCanUse($skill[Thunderstrike], true) && (monster_level_adjustment() <= 150))
			{
				return cc_combatUse($skill[Thunderstrike], true);
			}

			//All of these stunners are skills, right?
			if((stunner != "") && cc_combatCanUse(to_skill(stunner.substring(6))) && (monster_level_adjustment() <= 50) && (my_mp() >= costStunner))
			{
				return cc_combatUse(to_skill(stunner.substring(6)));
			}

			if(cc_combatCanUse($skill[Unleash The Greash]) && (monster_element(enemy) != $element[sleaze]) && (have_effect($effect[Takin\' It Greasy]) > 100))
			{
				return cc_combatUse($skill[Unleash The Greash]);
			}
			if(cc_combatCanUse($skill[Thousand-Yard Stare]) && (monster_element(enemy) != $element[spooky]) && (have_effect($effect[Intimidating Mien]) > 100))
			{
				return cc_combatUse($skill[Thousand-Yard Stare]);
			}
			if($monsters[Aquagoblin, Lord Soggyraven] contains enemy)
			{
				return attackMajor;
			}
			if((my_class() == $class[Turtle Tamer]) && cc_combatCanUse($skill[Spirit Snap], true))
			{
				if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
				{
					return cc_combatUse($skill[Spirit Snap], true);
				}
			}
			if(cc_combatCanUse($skill[Northern Explosion], true) && (my_class() == $class[Seal Clubber]) && (monster_element(enemy) != $element[cold]))
			{
				return cc_combatUse($skill[Northern Explosion], true);
			}
			if((!contains_text(combatState, "last attempt")) && (my_mp() >= costMajor))
			{
				if(canSurvive(1.4))
				{
					set_property("cc_combatHandler", combatState + "(last attempt)");
					print("Uh oh, I'm having trouble in combat.", "red");
				}
				return attackMajor;
			}
			if(canSurvive(2.5))
			{
				print("Hmmm, I don't really know what to do in this combat but it looks like I'll live.", "red");
				if(my_mp() >= costMajor)
				{
					return attackMajor;
				}
				else if(my_mp() >= costMinor)
				{
					return attackMinor;
				}
				return "attack with weapon";
			}
			if(my_location() != $location[The Slime Tube])
			{
				abort("Could not handle monster, sorry");
			}
		}
		if((monster_level_adjustment() > 150) && (my_mp() >= 45) && cc_combatCanUse($skill[Shell Up], true) && (my_class() == $class[Turtle Tamer]))
		{
			return cc_combatUse($skill[Shell Up], true);
		}

		if(attackMinor == "attack with weapon")
		{
			if(cc_combatCanUse($skill[Summon Love Stinkbug], true))
			{
				return cc_combatUse($skill[Summon Love Stinkbug], true);
			}
			if(cc_combatCanUse($skill[Mighty Axing]) && (equipped_item($slot[Weapon]) != $item[none]))
			{
				return cc_combatUse($skill[Mighty Axing]);
			}
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[cold]) && cc_combatCanUse($skill[Throat Refrigerant]))
		{
			return cc_combatUse($skill[Throat Refrigerant]);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]) && cc_combatCanUse($skill[Boiling Tear Ducts]))
		{
			return cc_combatUse($skill[Boiling Tear Ducts]);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[sleaze]) && cc_combatCanUse($skill[Projectile Salivary Glands]))
		{
			return cc_combatUse($skill[Projectile Salivary Glands]);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[spooky]) && cc_combatCanUse($skill[Translucent Skin]))
		{
			return cc_combatUse($skill[Translucent Skin]);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && cc_combatCanUse($skill[Skunk Glands]))
		{
			return cc_combatUse($skill[Skunk Glands]);
		}

		if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod") && (my_mp() >= costMajor))
		{
			return attackMajor;
		}

		if((monster_level_adjustment() > 150) && (my_mp() >= costMajor) && (attackMajor != "attack with weapon"))
		{
			return attackMajor;
		}
		if(cc_combatCanUse($skill[Lunge Smack]) && (attackMinor != "attack with weapon") && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			return attackMinor;
		}
		if((my_mp() >= costMinor) && (attackMinor != "attack with weapon"))
		{
			return attackMinor;
		}

		if((round > 20) && cc_combatCanUse($skill[Saucestorm]))
		{
			return cc_combatUse($skill[Saucestorm]);
		}
		return "attack with weapon";
	}
	else
	{
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}

	if(attackMinor == "attack with weapon")
	{
		if(cc_combatCanUse($skill[Summon Love Stinkbug], true))
		{
			return cc_combatUse($skill[Summon Love Stinkbug]);
		}
	}

	return attackMinor;
#	return get_ccs_action(round);
}

string findBanisher(int round, string opp, string text)
{
	print("In findBanisher for: " + opp, "green");
	monster enemy = to_monster(opp);

	foreach itm in $items[Louder Than Bomb, Tennis Ball]
	{
		if(!contains_text(get_property("cc_gremlinBanishes"), itm) && cc_combatCanUse(itm, true))
		{
			set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + itm + ")");
			return cc_combatUse(itm, true);
		}
	}

	//We need to move this over to the banish checker.

	foreach act in $skills[Baleful Howl, Banishing Shout, Reflex Hammer, Throw Latte On Opponent, Asdon Martin: Spring-Loaded Front Bumper, Talk About Politics, Batter Up!, Thunder Clap, Curse of Vacation, Breathe Out, Snokebomb, KGB Tranquilizer Dart, Beancannon]
	{
		if(!contains_text(get_property("cc_gremlinBanishes"), act) && cc_have_skill(act) && (my_mp() >= mp_cost(act)) && (my_hp() > hp_cost(act)) && (my_thunder() >= thunder_cost(act)) && (get_fuel() >= fuel_cost(act)))
		{
			if((act == $skill[Banishing Shout]) && !cc_combatCanUse(act, true))
			{
				continue;
			}
			if((act == $skill[Baleful Howl]) && (get_property("_balefulHowlUses").to_int() >= 10))
			{
				continue;
			}
			if((act == $skill[Reflex Hammer]) && (get_property("_reflexHammerUsed").to_int() >= 3))
			{
				continue;
			}
			if((act == $skill[Throw Latte On Opponent]) && get_property("_latteBanishUsed").to_boolean())
			{
				continue;
			}
			if((act == $skill[Batter Up!]) && ((my_fury() < 5) || (item_type(equipped_item($slot[weapon])) != "club")))
			{
				continue;
			}
			if((act == $skill[Asdon Martin: Spring-Loaded Front Bumper]) && contains_text(get_property("banishedMonsters"),"Spring-Loaded Front Bumper"))
			{
				continue;
			}
			if((act == $skill[Talk About Politics]) && (get_property("_pantsgivingBanish").to_int() >= 5))
			{
				continue;
			}
			if((act == $skill[Beancannon]) && (get_property("_beancannonUses").to_int() >= 5))
			{
				continue;
			}
			if((act == $skill[Beancannon]) && !($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand])))
			{
				continue;
			}
			if((act == $skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() >= 3))
			{
				continue;
			}
			set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + act + ")");

			//TODO: Remove this, see if we get matching banishers or something.
			string banishAction = banisherCombatString(enemy, my_location());
			print("banisherCombatString decided: " + banishAction, "green");
			print("Gremlin Handler (to be deprecated) decided: " + act);


			return cc_combatUse(act, true);
		}
	}

	if(cc_have_skill($skill[Storm of the Scarab]) && (my_mp() >= mp_cost($skill[Storm of the Scarab])))
	{
		return "skill Storm of the Scarab";
	}
	return cc_combatHandler(round, opp, text);
}

string ccsJunkyard(int round, string opp, string text)
{
	monster enemy = to_monster(opp);

	if(!($monsters[A.M.C. gremlin, batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin] contains enemy))
	{
		return cc_combatHandler(round, opp, text);
	}

	if(round == 0)
	{
		print("ccsJunkyard: " + round, "brown");
		set_property("cc_gremlinMoly", true);
		set_property("cc_combatHandler", "");
	}
	else
	{
		print("cc_Junkyard: " + round, "brown");
	}
	string combatState = get_property("cc_combatHandler");
	string edCombatState = get_property("cc_edCombatHandler");

	if(my_class() == $class[Ed])
	{
		if(contains_text(edCombatState, "gremlinNeedBanish"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}

	if(enemy == $monster[A.M.C. gremlin])
	{
		set_property("cc_gremlinMoly", false);
	}

	if(my_location() == $location[Next To That Barrel With Something Burning In It])
	{
		if(enemy == $monster[vegetable gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It does a bombing run over your head"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Out By That Rusted-Out Car])
	{
		if(enemy == $monster[erudite gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It picks a beet off of itself and beats you with it"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Over Where The Old Tires Are])
	{
		if(enemy == $monster[spider gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "He uses the random junk around him"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Near an Abandoned Refrigerator])
	{
		if(enemy == $monster[batwinged gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It bites you in the fibula with its mandibles"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}

	if(!contains_text(edCombatState, "gremlinNeedBanish") && !get_property("cc_gremlinMoly").to_boolean() && (my_class() == $class[Ed]))
	{
		set_property("cc_edCombatHandler", "(gremlinNeedBanish)");
	}

	if(round >= 28)
	{
		if(cc_combatCanUse($skill[Lunging Thrust-Smack]))
		{
			return cc_combatUse($skill[Lunging Thrust-Smack]);
		}
		return "attack with weapon";
	}

	if(contains_text(text, "It whips out a hammer") || contains_text(text, "He whips out a crescent") || contains_text(text, "It whips out a pair") || contains_text(text, "It whips out a screwdriver"))
	{
		return cc_combatUse($item[Molybdenum Magnet]);
	}

	foreach sk in $skills[Curse Of Weaksauce, Curse Of the Marshmallow, Summon Love Scarabs, Summon Love Gnats, Bad Medicine, Good Medicine]
	{
		if(cc_combatCanUse(sk, true))
		{
			return cc_combatUse(sk, true);
		}
	}

	if(!get_property("cc_gremlinMoly").to_boolean() && (my_class() == $class[Ed]))
	{
		if((get_property("cc_edCombatStage").to_int() >= 2) || (get_property("cc_edStatus") == "dying"))
		{
			string banisher = findBanisher(round, opp, text);
			if(banisher != "attack with weapon")
			{
				return banisher;
			}
			else if(cc_combatCanUse($skill[Storm Of The Scarab]))
			{
				return cc_combatUse($skill[Storm Of The Scarab]);
			}
			return banisher;
		}
	}

	string flyerString = combat_flyer();
	if(flyerString != "")
	{
		return flyerString;
	}

	if(!get_property("cc_gremlinMoly").to_boolean())
	{
		if(my_class() == $class[Ed])
		{
			if((get_property("cc_edCombatStage").to_int() >= 2) || (get_property("cc_edStatus") == "dying"))
			{
				return findBanisher(round, opp, text);
			}
			foreach it in $items[Dictionary, Seal Tooth]
			{
				if(cc_combatCanUse(it))
				{
					return cc_combatUse(it);
				}
			}
		}
		else
		{
			return findBanisher(round, opp, text);
		}
	}

	if(!get_property("cc_gremlinMoly").to_boolean())
	{
		foreach sk in $skills[Lunging Thrust-Smack, Storm Of The Scarab, Lunge Smack]
		{
			if(cc_combatCanUse(sk))
			{
				return cc_combatUse(sk);
			}
		}
		return "attack with weapon";
	}

	foreach it in $items[Dictionary, Seal Tooth, Spectre Scepter, Doc Galaktik\'s Pungent Unguent]
	{
		if(cc_combatCanUse(it))
		{
			return cc_combatUse(it);
		}
	}
	if(cc_combatCanUse($skill[Toss]))
	{
		return cc_combatUse($skill[Toss]);
	}
	return "attack with weapon";
}

string cc_edCombatHandler(int round, string opp, string text)
{
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if(my_path() != "Actually Ed the Undying")
	{
		abort("Not in Actually Ed the Undying, this combat filter will result in massive suckage.");
	}
	if(round == 0)
	{
		print("cc_combatHandler: " + round, "brown");
		set_property("cc_combatHandler", "");
		if(get_property("cc_edCombatStage").to_int() == 0)
		{
			set_property("cc_edCombatCount", 1 + get_property("cc_edCombatCount").to_int());
			set_property("cc_edCombatStage", 1);
			set_property("cc_edStatus", "UNDYING!");
		}
		else
		{
			set_property("cc_edCombatStage", 1 + get_property("cc_edCombatStage").to_int());
		}
	}
	else
	{
		damageReceived = get_property("cc_combatHP").to_int() - my_hp();
		set_property("cc_combatHP", my_hp());
	}

	set_property("cc_edCombatRoundCount", 1 + get_property("cc_edCombatRoundCount").to_int());


	if(my_location() == $location[Hippy Camp])
	{
		if(!ed_needShop())
		{
			set_property("cc_edStatus", "dying");
			if(my_mp() < 5)
			{
				foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
				{
					if(item_amount(it) > 0)
					{
						return "item " + it;
					}
				}
			}
		}
	}

	if(get_property("cc_edCombatStage").to_int() == 3)
	{
		set_property("cc_edStatus", "dying");
		set_property("cc_edCombatStage", 0);
	}
	set_property("cc_diag_round", round);

	if(get_property("cc_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	phylum type = monster_phylum(enemy);
	string combatState = get_property("cc_combatHandler");
	string edCombatState = get_property("cc_edCombatHandler");
	if($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy)
	{
		set_property("cc_edStatus", "dying");
	}

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}

	foreach sk in $skills[Pocket Crumbs, Micrometeorite, Air Dirty Laundry, Summon Love Scarabs]
	{
		if(cc_combatCanUse(sk, true))
		{
			return cc_combatUse(sk, true);
		}
	}

	if(cc_combatCanUse($item[Time-Spinner], true))
	{
		return cc_combatUse($item[Time-Spinner], true);
	}

	if(((get_property("edPoints").to_int() <= 4) && (my_daycount() == 1)) || !get_property("lovebugsUnlocked").to_boolean())
	{
		if(!ed_needShop() || (get_property("cc_edCombatStage").to_int() > 1))
		{
			set_property("cc_edStatus", "dying");
		}
	}

	if(cc_combatCanUse($skill[Sing Along], true))
	{
		if((get_property("boomBoxSong") == "Remainin\' Alive") || ((get_property("boomBoxSong") == "Total Eclipse of Your Meat") && canSurvive(2.0)))
		{
			return cc_combatUse($skill[Sing Along], true);
		}
	}


	string protonGhost = combat_protonicGhost(blocked, damageReceived);
	if(protonGhost != "")
	{
		return protonGhost;
	}

	# Instakill handler
	boolean doInstaKill = true;
	if($monsters[Lobsterfrogman, Ninja Snowman Assassin] contains enemy)
	{
		if(cc_have_skill($skill[Digitize]) && (get_property("_sourceTerminalDigitizeMonster") != enemy))
		{
			doInstaKill = false;
		}
	}

	if(instakillable(enemy) && !isFreeMonster(enemy) && doInstaKill)
	{
		if(cc_combatCanUse($item[Replica Bat-oomerang], true))
		{
			if(get_property("cc_batoomerangDay").to_int() != my_daycount())
			{
				set_property("cc_batoomerangDay", my_daycount());
				set_property("cc_batoomerangUse", 0);
			}
			if(get_property("cc_batoomerangUse").to_int() < 3)
			{
				set_property("cc_batoomerangUse", get_property("cc_batoomerangUse").to_int() + 1);
				return cc_combatUse($item[Replica Bat-oomerang], true);
			}
		}

		if(cc_combatCanUse($skill[Fire The Jokester\'s Gun], true) && (equipped_item($slot[Weapon]) == $item[The Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean())
		{
			return cc_combatUse($skill[Fire the Jokester\'s Gun], true);
		}
	}

	if(get_property("cc_edStatus") == "UNDYING!")
	{
		if(cc_combatCanUse($skill[Summon Love Gnats], true))
		{
			return cc_combatUse($skill[Summon Love Gnats], true);
		}
		if((item_amount($item[Ka Coin]) > 200) && cc_combatCanUse($skill[Curse of Fortune], true))
		{
			return cc_combatUse($skill[Curse of Fortune], true);
		}
	}
	else if(get_property("cc_edStatus") == "dying")
	{
		boolean doStunner = true;
		if((mcd > 50) && canSurvive(1.15))
		{
			doStunner = false;
		}
		if(doStunner)
		{
			if(cc_combatCanUse($skill[Summon Love Gnats], true))
			{
				return cc_combatUse($skill[Summon Love Gnats], true);
			}
		}
	}
	else
	{
		print("Ed combat state does not exist, winging it....", "red");
	}

	if(cc_combatCanUse($skill[Fire Sewage Pistol], true))
	{
		return cc_combatUse($skill[Fire Sewage Pistol], true);
	}

	if(enemy == $monster[Protagonist])
	{
		set_property("cc_edStatus", "dying");
	}

	string flyerString = combat_flyer();
	if(flyerString != "")
	{
		return flyerString;
	}

	if(cc_combatCanUse($item[Cocktail Napkin], true))
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return cc_combatUse($item[Cocktail Napkin], true);
		}
	}

	if((enemy == $monster[Dirty Thieving Brigand]) && cc_combatCanUse($skill[Curse Of Fortune], true) && (item_amount($item[Ka Coin]) > 0) && !contains_text(edCombatState, $skill[Curse Of Fortune]))
	{
		set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Curse Of Fortune] + ")");
		set_property("cc_edStatus", "dying");
		return cc_combatUse($skill[Curse Of Fortune], true);
	}

	if(cc_combatCanUse($skill[Curse Of Stench], true) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3) && !contains_text(edCombatState, $skill[Curse Of Stench]))
	{
		if($monsters[Bob Racecar, Cabinet of Dr. Limpieza, Dairy Goat, Dirty Old Lihc, Government Scientist,  Green Ops Soldier, Possessed Wine Rack, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Writing Desk] contains enemy)
		{
			set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Curse Of Stench] + ")");
			return cc_combatUse($skill[Curse Of Stench], true);
		}
	}

	if(my_location() == $location[The Secret Council Warehouse])
	{
		if(!contains_text(edCombatSTate, $skill[Curse Of Stench]) && cc_combatCanUse($skill[Curse Of Stench], true) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3))
		{
			boolean doStench = false;
			#	Rememeber, we are looking to see if we have enough of the opposite item here.
			int progress = get_property("warehouseProgress").to_int();
			if(enemy == $monster[Warehouse Guard])
			{
				progress += (8 * item_amount($item[Warehouse Inventory Page]));
			}
			else if(enemy == $monster[Warehouse Clerk])
			{
				progress += (8 * item_amount($item[Warehouse Map Page]));
			}
			if(progress >= 50)
			{
				doStench = true;
			}
			if(doStench)
			{
				set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Curse Of Stench] + ")");
				return cc_combatUse($skill[Curse Of Stench], true);
			}
		}
	}


	if(my_location() == $location[The Smut Orc Logging Camp])
	{
		if(!contains_text(edCombatState, $skill[Curse Of Stench]) && cc_combatCanUse($skill[Curse Of Stench], true) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3))
		{
			boolean doStench = false;
			monster stenched = to_monster(get_property("stenchCursedMonster"));

			if((fastenerCount() >= 30) && (stenched != $monster[Smut Orc Pipelayer]) && (stenched != $monster[Smut Orc Jacker]))
			{
				#	Sniff 100% lumber
				if((enemy == $monster[Smut Orc Pipelayer]) || (enemy == $monster[Smut Orc Jacker]))
				{
					doStench = true;
				}
			}
			if((lumberCount() >= 30) && (stenched != $monster[Smut Orc Screwer]) && (stenched != $monster[Smut Orc Nailer]))
			{
				#	Sniff 100% fastener
				if((enemy == $monster[Smut Orc Screwer]) || (enemy == $monster[Smut Orc Nailer]))
				{
					doStench = true;
				}
			}

			if(doStench)
			{
				set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Curse Of Stench] + ")");
				return cc_combatUse($skill[Curse Of Stench], true);
			}
		}
	}

	if(!contains_text(combatState, "yellowray"))
	{
		boolean doYellow = false;
		if((my_location() == $location[Hippy Camp]) && !have_outfit("Filthy Hippy Disguise"))
		{
			doYellow = true;
		}
		if((enemy == $monster[Burly sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doYellow = true;
		}
		if((enemy == $monster[Knob Goblin Harem Girl]) && !have_outfit("Knob Goblin Harem Girl Disguise"))
		{
			doYellow = true;
		}
		if((enemy == $monster[Mountain Man]) && (internalQuestStatus("questL08Trapper") < 2))
		{
			doYellow = true;
		}

		if((enemy == $monster[Frat Warrior Drill Sergeant]) || (enemy == $monster[War Pledge]))
		{
			if(!have_outfit("War Hippy Fatigues"))
			{
				doYellow = true;
			}
		}

		if(doYellow)
		{
			string combatAction = yellowRayCombatString();
			if(combatAction != "")
			{
				set_property("cc_combatHandler", combatState + "(yellowray)");
				itemSkill_t convert = cc_convertAction(combatAction);
				if(convert.sk != $skill[none])
				{
					return cc_combatUse(convert.sk, true);
				}
				else if(convert.it != $item[none])
				{
					return cc_combatUse(convert.it, true);
				}
				else
				{
					print("Unable to track yellow ray behavior: " + combatAction, "red");
				}
			}
			else
			{
				print("Wanted a yellow ray but we can not find one.", "red");
			}
		}
	}

	if(cc_combatCanUse($skill[Curse Of Vacation], true))
	{
		if((enemy == $monster[pygmy orderlies]) && (my_location() == $location[The Hidden Bowling Alley]))
		{
			return cc_combatUse($skill[Curse Of Vacation], true);
		}
		if((enemy == $monster[fallen archfiend]) && (my_location() == $location[The Dark Heart of the Woods]) && (get_property("cc_pirateoutfit") != "almost") && (get_property("cc_pirateoutfit") != "finished"))
		{
			return cc_combatUse($skill[Curse Of Vacation], true);
		}
		if($monsters[Animated Mahogany Nightstand, Coaltergeist, Crusty Pirate, Flock of Stab-Bats, Irritating Series of Random Encounters, Knob Goblin Harem Guard, Mad Wino, Mismatched Twins, Possessed Laundry Press, Procrastination Giant, Punk Rock Giant, Pygmy Witch Lawyer, Pygmy Witch Nurse, Sabre-Toothed Goat, Slick Lihc, Warehouse Janitor] contains enemy)
		{
			return cc_combatUse($skill[Curse Of Vacation], true);
		}
	}

	if(cc_combatCanUse($item[Disposable Instant Camera], true))
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			return cc_combatUse($item[Disposable Instant Camera], true);
		}
	}

	if(cc_combatCanUse($item[Duskwalker Syringe]) && (item_amount($item[Bubblin\' Crude]) < 11) && (item_amount($item[Jar Of Oil]) == 0))
	{
		boolean wantCrude = ((get_property("twinPeakProgress").to_int() & 4) == 0);
		if(($monsters[Oil Baron, Oil Cartel, Oil Slick, Oil Tycoon] contains enemy) && wantCrude)
		{
			return cc_combatUse($item[Duskwalker Syringe]);
		}
	}

	if(cc_combatCanUse($skill[Lash of the Cobra], true) && !contains_text(edCombatState, $skill[Lash Of The Cobra]) )
	{
		boolean doLash = false;
		if((enemy == $monster[Swarthy Pirate]) && !possessEquipment($item[Stuffed Shoulder Parrot]))
		{
			doLash = true;
		}
		if((enemy == $monster[Big Wheelin\' Twins]) && !possessEquipment($item[Badge Of Authority]))
		{
			doLash = true;
		}

		if((enemy == $monster[Fishy Pirate]) && !possessEquipment($item[Perfume-Soaked Bandana]))
		{
			doLash = true;
		}
		if((enemy == $monster[Funky Pirate]) && !possessEquipment($item[Sewage-Clogged Pistol]) && elementalPlanes_access($element[spooky]))
		{
			doLash = true;
		}
		if((enemy == $monster[Garbage Tourist]) && (item_amount($item[Bag of Park Garbage]) == 0))
		{
			doLash = true;
		}
		if((enemy == $monster[Sassy Pirate]) && !possessEquipment($item[Swashbuckling Pants]))
		{
			doLash = true;
		}
		if((enemy == $monster[Smarmy Pirate]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[One-eyed Gnoll]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[Stone Temple Pirate]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[Dairy Goat]) && (item_amount($item[Goat Cheese]) < 3))
		{
			doLash = true;
		}
		if((enemy == $monster[Renaissance Giant]) && (item_amount($item[Ye Olde Meade]) < 1) && (my_daycount() == 1))
		{
			doLash = true;
		}
		if((enemy == $monster[Protagonist]) && !possessEquipment($item[Ocarina of Space]))
		{
			doLash = true;
		}
		if($monsters[Bearpig Topiary Animal, Elephant (Meatcar?) Topiary Animal, Spider (Duck?) Topiary Animal] contains enemy)
		{
			doLash = true;
		}
		if($monsters[Beanbat, Bookbat] contains enemy)
		{
			doLash = true;
		}
		if(((enemy == $monster[Toothy Sklelton]) || (enemy == $monster[Spiny Skelelton])) && (get_property("cyrptNookEvilness").to_int() > 26))
		{
			doLash = true;
		}
		if((enemy == $monster[Oil Baron]) && (item_amount($item[Bubblin\' Crude]) < 12) && (item_amount($item[Jar of Oil]) == 0))
		{
			doLash = true;
		}
		if((enemy == $monster[Blackberry Bush]) && (item_amount($item[Blackberry]) < 3) && !possessEquipment($item[Blackberry Galoshes]))
		{
			doLash = true;
		}
		if((enemy == $monster[Pygmy Bowler]) && (get_property("_edLashCount").to_int() < 26))
		{
			doLash = true;
		}
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			doLash = true;
		}
		if(enemy == $monster[Knob Goblin Madam])
		{
			if(item_amount($item[Knob Goblin Perfume]) == 0)
			{
				doLash = true;
			}
		}
		if(enemy == $monster[Knob Goblin Harem Girl])
		{
			if(!possessEquipment($item[Knob Goblin Harem Veil]) || !possessEquipment($item[Knob Goblin Harem Pants]))
			{
				doLash = true;
			}
		}

		if(((my_location() == $location[Hippy Camp]) || (my_location() == $location[Wartime Hippy Camp])) && contains_text(enemy, "hippy"))
		{
			if(!possessEquipment($item[Filthy Knitted Dread Sack]) || !possessEquipment($item[Filthy Corduroys]))
			{
				if(get_property("cc_edStatus") != "dying")
				{
					doLash = true;
				}
			}
		}

		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doLash = true;
			}
		}

		if((enemy == $monster[Dopey 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Helmet]))
		{
			doLash = true;
		}

		if((enemy == $monster[Grumpy 7-Foot Dwarf]) && !possessEquipment($item[7-Foot Dwarven Mattock]))
		{
			doLash = true;
		}

		if((enemy == $monster[Sleepy 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Pants]))
		{
			doLash = true;
		}

		if((enemy == $monster[Burly Sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doLash = true;
		}

		if((enemy == $monster[Spunky Princess]) && !possessEquipment($item[Titanium Assault Umbrella]))
		{
			doLash = true;
		}

		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doLash = true;
		}

		if((enemy == $monster[P Imp]) || (enemy == $monster[G Imp]))
		{
			if((get_property("cc_pirateoutfit") != "finished") && (get_property("cc_pirateoutfit") != "almost") && (item_amount($item[Hot Wing]) < 3))
			{
				doLash = true;
			}
		}

		int progress = get_property("warehouseProgress").to_int();
		if(enemy == $monster[Warehouse Clerk])
		{
			progress += (8 * item_amount($item[Warehouse Inventory Page]));
		}
		if(enemy == $monster[Warehouse Guard])
		{
			progress += (8 * item_amount($item[Warehouse Map Page]));
		}
		if((progress < 50) && (progress > 0))
		{
			doLash = true;
		}

		if(doLash)
		{
			handleTracker(enemy, "cc_lashes");
			set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Lash Of The Cobra] + ")");
			return cc_combatUse($skill[Lash Of The Cobra], true);
		}
	}

	if(cc_combatCanUse($item[Tattered Scrap of Paper], true))
	{
		if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, W imp] contains enemy)
		{
			return cc_combatUse($item[Tattered Scrap Of Paper], true);
		}
	}

	if(cc_combatCanUse($item[Talisman Of Renenutet], true) && !contains_text(edCombatState, $item[Talisman Of Renenutet]))
	{
		boolean doRenenutet = false;
		if((enemy == $monster[Cabinet of Dr. Limpieza]) && ($location[The Haunted Laundry Room].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Possessed Wine Rack]) && ($location[The Haunted Wine Cellar].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Baa\'baa\'bu\'ran]) && (item_amount($item[Stone Wool]) < 2))
		{
			doRenenutet = true;
		}
		if($monsters[Mountain Man, Warehouse Clerk, Warehouse Guard] contains enemy)
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Pygmy Janitor]) && (item_amount($item[Book of Matches]) == 0) && (get_property("relocatePygmyJanitor").to_int() != my_ascensions()))
		{
			doRenenutet = true;
		}
		if(enemy == $monster[Blackberry Bush])
		{
			if(!possessEquipment($item[Blackberry Galoshes]) && (item_amount($item[Blackberry]) < 3))
			{
				doRenenutet = true;
			}
		}
		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doRenenutet = true;
			}
		}
		if(doRenenutet)
		{
			if(cc_combatCanUse($skill[Curse Of Indecision], true) && !contains_text(edCombatSTate, $skill[Curse Of Indecision]))
			{
				set_property("cc_edCombatHandler", edCombatState + "(" + $skill[Curse Of Indecision] + ")");
				return cc_combatUse($skill[Curse Of Indecision], true);
			}
			handleTracker(enemy, "cc_renenutet");
			set_property("cc_edStatus", "dying");
			set_property("cc_edCombatHandler", edCombatState + "(" + $item[Talisman Of Renenutet] + ")");
			return cc_combatUse($item[Talisman Of Renenutet], true);
		}
	}

	if((enemy == $monster[Pygmy Orderlies]) && cc_combatCanUse($item[Short Writ of Habeas Corpus], true))
	{
		return cc_combatUse($item[Short Writ Of Habeas Corpus]);
	}

	if(!ed_needShop() && (my_level() >= 10) && (item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0) && (my_location() != $location[The Hidden Apartment Building]) && (type != $phylum[undead]) && (my_mp() > 20))
	{
		set_property("cc_edStatus", "dying");
	}

	if(get_property("cc_edStatus") == "UNDYING!")
	{
#		if((my_location() == $location[The Secret Government Laboratory]) || !ed_needShop())
		if(my_location() == $location[The Secret Government Laboratory])
		{
			if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
			{
				if(cc_combatCanUse($skill[Summon Love Stinkbug], true))
				{
					return cc_combatUse($skill[Summon Love Stinkbug], true);
				}
			}
		}

		if((item_amount($item[Ka Coin]) > 200) && cc_combatCanUse($skill[Curse of Fortune], true))
		{
			return cc_combatUse($skill[Curse of Fortune], true);
		}

		if(cc_combatCanUse($item[Dictionary]))
		{
#			string macro = "item dictionary; repeat";
#			visit_url("fight.php?action=macro&macrotext=" + url_encode(macro), true, true);
			return cc_combatUse($item[Dictionary]);
		}
		if(cc_combatCanUse($item[Seal Tooth]))
		{
			return cc_combatUse($item[Seal Tooth]);
		}

		return cc_combatUse($skill[Mild Curse]);
	}

	if(cc_combatCanUse($skill[Roar of the Lion]) && (my_location() == $location[The Secret Government Laboratory]))
	{
		if(cc_combatCanUse($skill[Storm Of The Scarab]) && (my_buffedstat($stat[Mysticality]) >= 60))
		{
			return cc_combatUse($skill[Storm Of The Scarab]);
		}
		return cc_combatUse($skill[Roar Of The Lion]);
	}
	if(cc_combatCanUse($skill[Storm Of The Scarab]) && ($locations[Pirates of the Garbage Barges, The SMOOCH Army HQ, VYKEA] contains my_location()))
	{
		return cc_combatUse($skill[Storm Of The Scarab]);
	}
	if(cc_combatCanUse($skill[Fist Of The Mummy]) && (my_location() == $location[Hippy Camp]))
	{
		return cc_combatUse($skill[Fist Of The Mummy]);
	}

	int fightStat = my_buffedstat(weapon_type(equipped_item($slot[weapon]))) - 20;
	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("cc_edStatus") == "UNDYING!"))
	{
		return "attack with weapon";
	}

	if(cc_combatCanUse($skill[Cowboy Kick], true))
	{
		return cc_combatUse($skill[Cowboy Kick], true);
	}

	if(cc_combatCanUse($item[Ice-Cold Cloaca Zero]) && (my_mp() < 15) && (my_maxmp() > 200))
	{
		return cc_combatUse($item[Ice-Cold Cloaca Zero]);
	}
	if(cc_combatCanUse($skill[Storm Of The Scarab]) && (my_buffedstat($stat[Mysticality]) > 35))
	{
		return cc_combatUse($skill[Storm Of The Scarab]);
	}

	if((enemy.physical_resistance >= 100) || (round >= 25) || canSurvive(1.25))
	{
		if(cc_combatCanUse($skill[Fist Of The Mummy]))
		{
			return cc_combatUse($skill[Fist Of The Mummy]);
		}
	}

	if(my_mp() < 8)
	{
		foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
		{
			if(cc_combatCanUse(it))
			{
				return cc_combatUse(it);
			}
		}
	}

	if(round >= 29)
	{
		print("About to UNDYING too much but have no other combat resolution. Please report this.", "red");
	}

	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("cc_edStatus") == "dying"))
	{
		print("Attacking with weapon because we don't have enough MP. Expected damage: " + expected_damage() + ", current hp: " + my_hp(), "red");
		return "attack with weapon";
	}

	return cc_combatUse($skill[Mild Curse]);
}



monster ocrs_helper(string page)
{
	if(my_path() != "One Crazy Random Summer")
	{
		abort("Should not be in ocrs_helper if not on the path!");
	}

	string combatState = get_property("cc_combatHandler");

	//	ghostly				physical resistance
	//	untouchable			damage reduced to 5, instant kills still good (much less of an issue now

	/*
		For no staggers, don\'t use staggers
		For blocks skills/combat items, we can probably set them all to used as well.
	*/

	//Initially, we are disabling options so we do not incorrectly use them
	if(isFreeMonster(last_monster()))
	{
		if(cc_combatCanUse($skill[CLEESH], true))
		{
			set_property("cc_useCleesh", false);
			cc_combatUse($skill[CLEESH], true);
		}
	}
	if(last_monster().random_modifiers["unstoppable"])
	{
		if(!contains_text(combatState, "unstoppable"))
		{
			#Block weaksauce and pocket crumbs? Probably incomplete.
			foreach it in $items[DNA Extraction Syringe, Rain-Doh Blue Balls, Rain-Doh Indigo Cup]
			{
				cc_combatUse(it, true);
			}
			foreach sk in $skills[Air Dirty Laundry, Micrometeorite, Ply Reality, Summon Love Gnats, Summon Love Mosquito]
			{
				cc_combatUse(sk, true);
			}
		}
	}

	if(last_monster().random_modifiers["annoying"])
	{
		if(contains_text(page, "makes the most annoying noise you've ever heard, stopping you in your tracks."))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["restless"])
	{
		if(contains_text(page, "moves out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		if(contains_text(page, "quickly moves out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		if(contains_text(page, "will have moved by the time"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}

		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["phase-shifting"])
	{
		if(contains_text(page, "blinks out of existence before"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["cartwheeling"])
	{
		if(contains_text(page, "cartwheels out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	set_property("cc_useCleesh", false);
	if((last_monster().random_modifiers["ticking"]) || (last_monster().random_modifiers["untouchable"]))
	{
		if(!contains_text(combatState, $skill[CLEESH]) && cc_have_skill($skill[CLEESH]) && (my_mp() > mp_cost($skill[CLEESH])))
		{
			set_property("cc_useCleesh", true);
		}
	}
	return last_monster();
}

void awol_helper(string page)
{
	//Let us self-contain this so it is quick to remove later.
	if((my_daycount() == 1) && (my_turncount() < 10))
	{
		set_property("cc_noSnakeOil", 0);
	}

	string combatState = get_property("cc_combatHandler");
	if(contains_text(page, "Your oil extractor is completely clogged up at this point"))
	{
		set_property("cc_noSnakeOil", my_daycount());
	}
	if(get_property("_oilExtracted").to_int() >= 100)
	{
		set_property("cc_noSnakeOil", my_daycount());
	}

	if(!contains_text(combatState, $skill[Extract Oil]) && (get_property("cc_noSnakeOil").to_int() == my_daycount()))
	{
		cc_combatUse($skill[Extract Oil], true);
	}
}

boolean canSurvive(float mult, int add)
{
	if(my_class() == $class[Vampyre])
	{
		mult += 2.0;
	}
	int damage = expected_damage();
	damage *= mult;
	damage += add;
	return (damage < my_hp());
}

boolean canSurvive(float mult)
{
	return canSurvive(mult, 0);
}

boolean cc_combatCanUse(item it)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), it, 1, false);
}
boolean cc_combatCanUse(string state, item it)
{
	return cc_combatCanUse(state, it, 1, false);
}

boolean cc_combatCanUse(item it, item em)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), it, em, false);
}
boolean cc_combatCanUse(string state, item it, item em)
{
	return cc_combatCanUse(state, it, em, false);
}

boolean cc_combatCanUse(item it, boolean tracked)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), it, 1, tracked);
}
boolean cc_combatCanUse(string state, item it, boolean tracked)
{
	return cc_combatCanUse(state, it, 1, tracked);
}

boolean cc_combatCanUse(item it, item em, boolean tracked)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), it, em, tracked);
}
boolean cc_combatCanUse(string state, item it, item em, boolean tracked)
{
	if(it == em)
	{
		return cc_combatCanUse(state, it, 2, tracked);
	}
	return cc_combatCanUse(state, it, 1, tracked) && cc_combatCanUse(state, em, 1, tracked);
}

boolean cc_combatCanUse(skill sk)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), sk, false);
}
boolean cc_combatCanUse(string state, skill sk)
{
	return cc_combatCanUse(state, sk, false);
}
boolean cc_combatCanUse(skill sk, boolean tracked)
{
	return cc_combatCanUse(get_property("cc_combatHandler"), sk, tracked);
}


string cc_combatUse(item it)
{
	return cc_combatuse(get_property("cc_combatHandler"), it, false);
}
string cc_combatUse(item it, item em)
{
	return cc_combatuse(get_property("cc_combatHandler"), it, em, false);
}
string cc_combatUse(string state, item it)
{
	return cc_combatuse(state, it, false);
}
string cc_combatUse(string state, item it, item em)
{
	return cc_combatuse(state, it, em, false);
}
string cc_combatUse(item it, boolean track)
{
	return cc_combatUse(get_property("cc_combatHandler"), it, track);
}
string cc_combatUse(item it, item em, boolean track)
{
	return cc_combatUse(get_property("cc_combatHandler"), it, em, track);
}


string cc_combatUse(skill sk)
{
	return cc_combatUse(get_property("cc_combatHandler"), sk, false);
}
string cc_combatUse(string state, skill sk)
{
	return cc_combatUse(state, sk, false);
}
string cc_combatUse(skill sk, boolean track)
{
	return cc_combatUse(get_property("cc_combatHandler"), sk, track);
}

//End of transfer functions

boolean cc_combatCanUse(string state, item it, int qty, boolean tracked)
{
	if((qty < 1) || (qty > 2))
	{
		abort("Invalid number of items selected " + it + " quantity: " + qty);
	}

	if(item_amount(it) < qty)
	{
		return false;
	}
	if(!glover_usable(it))
	{
		return false;
	}

	//Should we consider item blocking?

	if(tracked)
	{
		return !contains_text(state, "(" + it + ")");
	}
	return true;
}


boolean cc_combatCanUse(string state, skill sk, boolean tracked)
{
	if(!cc_have_skill(sk))
	{
		return false;
	}

	if(adv_cost(sk) > my_adventures())
	{
		return false;
	}
	if(lightning_cost(sk) > my_lightning())
	{
		return false;
	}
	if(mp_cost(sk) > my_mp())
	{
		return false;
	}
	if(rain_cost(sk) > my_rain())
	{
		return false;
	}
	if(soulsauce_cost(sk) > my_soulsauce())
	{
		return false;
	}
	if(thunder_cost(sk) > my_thunder())
	{
		return false;
	}
	if(hp_cost(sk) >= my_hp())
	{
		return false;
	}
	if(fuel_cost(sk) > get_fuel())
	{
		return false;
	}


	if((sk == $skill[Gulp Latte]) && (my_class() == $class[Vampyre]))
	{
		return false;
	}
	if($skills[Blood Chains, Blood Spike, Chill Of The Tomb] contains sk)
	{
		if((have_effect($effect[Wolf Form]) != 0) || (have_effect($effect[Bats Form]) != 0))
		{
			return false;
		}
	}
	if($skills[Ensorcel, Perceive Soul, Piercing Gaze] contains sk)
	{
		if((have_effect($effect[Wolf Form]) != 0) || (have_effect($effect[Mist Form]) != 0))
		{
			return false;
		}
	}
	if($skills[Baleful Howl, Crush, Savage Bite] contains sk)
	{
		if((have_effect($effect[Mist Form]) != 0) || (have_effect($effect[Bats Form]) != 0))
		{
			return false;
		}
	}
	if((sk == $skill[Shieldbutt]) && !hasShieldEquipped())
	{
		return false;
	}
	if((sk == $skill[Transcendent Olfaction]) && (have_effect($effect[On The Trail]) > 0))
	{
		return false;
	}

	//Should we consider?:
		//	Skill blocking
		//	Wrong damage type (physical on ghosts, matching element?)

	if(tracked)
	{
		return !contains_text(state, "(" + sk + ")");
	}
	return true;

}



string cc_combatUse(string state, item it, boolean track)
{
	if(it == $item[none])
	{
		abort("Can not be called with $item[none] as a selected item to use in combat");
	}

	if(track)
	{
		set_property("cc_combatHandler", state + "(" + it + ")");
	}

	if(getBanisherName(it) != "")
	{
		handleTracker(last_monster(), it, "cc_banishes");
	}
	if(isYellowRayAction(it))
	{
		handleTracker(last_monster(), it, "cc_yellowRays");
	}
	if(isInstaKillAction(it))
	{
		handleTracker(last_monster(), it, "cc_instakill");
	}

	return "item " + it;
}

string cc_combatUse(string state, item it, item em, boolean track)
{
	if(em == $item[none])
	{
		return cc_combatUse(state, it, track);
	}
	if(it == $item[none])
	{
		return cc_combatUse(state, em, track);
	}

	if(getBanisherName(it) != "")
	{
		handleTracker(last_monster(), it, "cc_banishes");
	}
	if(cc_have_skill($skill[Ambidextrous Funkslinging]))
	{
		if(getBanisherName(em) != "")
		{
			handleTracker(last_monster(), em, "cc_banishes");
		}
		if(track)
		{
			set_property("cc_combatHandler", state + "(" + it + ")(" + em + ")");
		}
		return "item " + it + ", " + em;
	}

	if(track)
	{
		set_property("cc_combatHandler", state + "(" + it + ")");
	}

	//Any once/combat items? They should probably be tracked always (state reverting needs to be cleaned up for combat failures)

	return "item " + it;
}

string cc_combatUse(string state, skill sk, boolean track)
{
	if(sk == $skill[none])
	{
		abort("Can not be called with $skill[none] as a selected skill to use in combat");
	}

	//Once/combat skills probably be tracked always (state reverting needs to be cleaned up for combat failures)


	if(getBanisherName(sk) != "")
	{
		handleTracker(last_monster(), sk, "cc_banishes");
	}
	if(isSniffAction(sk))
	{
		handleTracker(last_monster(), sk, "cc_sniffs");
	}
	if(isYellowRayAction(sk))
	{
		handleTracker(last_monster(), sk, "cc_yellowRays");
	}
	if(isInstaKillAction(sk))
	{
		handleTracker(last_monster(), sk, "cc_instakill");
	}


	if(track)
	{
		set_property("cc_combatHandler", state + "(" + sk + ")");
	}
	return "skill " + sk;

}

string combat_wallOfSkin(int round)
{
	if(cc_combatCanUse($item[Beehive], false))
	{
		return cc_combatUse($item[Beehive], false);
	}

//	if(cc_combatCanUse($skill[Summon Love Stinkbug], true))
//	{
//		return cc_combatUse($skill[Summon Love Stinkbug], true);
//	}

	if(cc_combatCanUse($skill[Shell Up], true) && (round >= 3))
	{
		return cc_combatUse($skill[Shell Up], true);
	}
	if(cc_combatCanUse($skill[Sauceshell], true) && (round >= 4))
	{
		return cc_combatUse($skill[Sauceshell], true);
	}

	int sources = cc_getElementalMods().weaponCount;
	if(sources >= 5)
	{
		foreach sk in $skills[Headbutt, Clobber]
		{
			if(cc_combatCanUse(sk))
			{
				return cc_combatUse(sk);
			}
		}
	}

	if(cc_combatCanUse($skill[Belch The Rainbow]))
	{
		return cc_combatUse($skill[Belch The Rainbow]);
	}
	return "attack with weapon";
}

string combat_sourceBosses()
{
	if(cc_have_skill($skill[Data Siphon]))
	{
		if(my_mp() < 50)
		{
			if(cc_combatCanUse($skill[Source Punch]))
			{
				return cc_combatUse($skill[Source Punch]);
			}
		}
		else if(my_mp() > 125)
		{
			if(cc_combatCanUse($skill[Reboot], true) && ((have_effect($effect[Latency]) > 0) || ((my_hp() * 2) < my_maxhp())))
			{
				return cc_combatUse($skill[Reboot], true);
			}
			foreach sk in $skills[Humiliating Hack, Disarmament]
			{
				if(cc_combatCanUse(sk, true))
				{
					return cc_combatUse(sk, true);
				}
			}
			if(cc_combatCanUse($skill[Big Guns], true) && (my_hp() < 100))
			{
				return cc_combatUse($skill[Big Guns], true);
			}
		}
		else if(my_mp() > 100)
		{
			foreach sk in $skills[Humiliating Hack, Disarmament]
			{
				if(cc_combatCanUse(sk, true))
				{
					return cc_combatUse(sk, true);
				}
			}
		}

		if(cc_combatCanUse($skill[Source Kick]))
		{
			return cc_combatUse($skill[Source Kick]);
		}
	}

	if(cc_combatCanUse($skill[Big Guns], true))
	{
		return cc_combatUse($skill[Big Guns], true);
	}

	if(cc_combatCanUse($skill[Source Punch]))
	{
		return cc_combatUse($skill[Source Punch]);
	}

	return "runaway";
}

string combat_shadow()
{
	//I guess we need to consider mummy wrappings or something like that?
	if(cc_combatCanUse($item[Gauze Garter], $item[Gauze Garter]))
	{
		return cc_combatUse($item[Gauze Garter], $item[Gauze Garter]);
	}
	if(cc_combatCanUse($item[Filthy Poultice], $item[Filthy Poultice]))
	{
		return cc_combatUse($item[Filthy Poultice], $item[Filthy Poultice]);
	}
	if(cc_combatCanUse($item[Gauze Garter], $item[Filthy Poultice]))
	{
		return cc_combatUse($item[Gauze Garter], $item[Filthy Poultice]);
	}
	if(cc_combatCanUse($item[Filthy Poultice]))
	{
		return cc_combatUse($item[Filthy Poultice]);
	}
	if(cc_combatCanUse($item[Gauze Garter]))
	{
		return cc_combatUse($item[Gauze Garter]);
	}
	abort("Do not have garters or poultices for the shadow");
	return "abort";
}

string combat_handleDirective(int round)
{
	string[int] actions = split_string(get_property("cc_combatDirective"), ";");
	int idx = 0;
	if(round == 0)
	{
		if(!actions[0].starts_with("start"))
		{
			set_property("cc_combatDirective", "");
			return "";
		}
		idx = 1;
	}
	string doThis = trim(actions[idx]);

	//Restrict these actions
	while(contains_text(doThis, "(") && contains_text(doThis, ")") && (idx < count(actions)))
	{
		string restrict = doThis.substring(1, doThis.length() - 1);
		itemSkill_t convert = cc_convertAction(restrict);
		if(convert.sk != $skill[none])
		{
			cc_combatUse(convert.sk);
		}
		else if(convert.it != $item[none])
		{
			cc_combatUse(convert.it);
		}
		else
		{
			abort("Nebulous directive restriction, we do not support '" + restrict + "' as a directive");
		}
		idx++;
		if(idx >= count(actions))
		{
			break;
		}
		doThis = actions[idx];
	}

	//Done with current restrictions, should be at the next valid action
	//Directives will assume nothing should be tracked. (We should probably handle that in some way but directives should not be used often either)
	string restore = "";
	for(int i=idx+1; i<count(actions); i++)
	{
		restore += actions[i];
		if((i+1) < count(actions))
		{
			restore += ";";
		}
	}
	set_property("cc_combatDirective", restore);
	if(idx < count(actions))
	{
		itemSkill_t convert = cc_convertAction(doThis);
		if(convert.sk != $skill[none])
		{
			return cc_combatUse(convert.sk);
		}
		else if(convert.it != $item[none])
		{
			if(convert.em != $item[none])
			{
				return cc_combatUse(convert.it, convert.em);
			}
			return cc_combatUse(convert.it);
		}
		else
		{
			abort("Nebulous combat direct, unable to use '" + doThis + "' as a directive");
		}
	}
	return "";
}

string combat_protonicGhost(boolean blocked, int damageReceived)
{
	if(!have_equipped($item[Protonic Accelerator Pack]) || !isGhost(last_monster()))
	{
		return "";
	}

	foreach sk in $skills[Beanscreen, Broadside, Snap Fingers, Summon Love Gnats]
	{
		if(cc_combatCanUse(sk, true))
		{
			return cc_combatUse(sk, true);
		}
	}

	if(cc_combatCanUse($skill[Soul Bubble], true) && (!get_property("lovebugsUnlocked").to_boolean() || blocked))
	{
		return cc_combatUse($skill[Soul Bubble], true);
	}

	string combatHandler = "cc_combatHandler";
	if(my_class() == $class[Ed])
	{
		combatHandler = "cc_edCombatHandler";
	}

	string combatState = get_property(combatHandler);
	if(combatState.contains_text($skill[Trap Ghost]))
	{
		return "";
	}

	//Must check for shootghost3, Mafia thinks we have Trap Ghost at the start of a Protonic Ghost combat.
	if(cc_combatCanUse($skill[Trap Ghost], true) && combatState.contains_text("shootghost3"))
	{
		print("Busting makes me feel good!!", "green");
		return cc_combatUse($skill[Trap Ghost], true);
	}
	else if(cc_combatCanUse($skill[Shoot Ghost]))
	{
		int stage = 1;
		if(contains_text(combatState, "shootghost2"))
		{
			stage = 3;
		}
		else if(contains_text(combatState, "shootghost1"))
		{
			stage = 2;
		}

		float adjust = 4.00 - (0.975 * stage);
		if((damageReceived * adjust) > my_hp())
		{
			set_property(combatHandler, combatState + "(" + $skill[Trap Ghost] + ")(" + $skill[Summon Love Stinkbug] + ")");
			return "";
		}

		set_property(combatHandler, combatState + "(shootghost" + stage + ")");
		return cc_combatUse($skill[Shoot Ghost]);
	}
	return "";
}


string combat_majora(string page, int round)
{
	if(my_path() != "Disguises Delimit")
	{
		return "";
	}
	if(!cc_combatCanUse($skill[Swap Mask], true))
	{
		return "";
	}

	int majora = -1;
	matcher maskMatch = create_matcher("mask(\\d+).png", page);
	if(maskMatch.find())
	{
		majora = maskMatch.group(1).to_int();
		if(round == 0)
		{
			print("Found mask: " + majora, "green");
		}
	}
	if(majora == 7)
	{
		return cc_combatUse($skill[Swap Mask], true);
	}
	if(round == 10)
	{
		return cc_combatUse($skill[Swap Mask], true);
	}
	if(majora == 3)
	{
		if(canSurvive(1.5))
		{
			return "attack with weapon";
		}
		abort("May not be able to survive combat. Is swapping protest mask still not allowing us to do anything?");
	}
	if(my_mask() == "protest mask")
	{
		return cc_combatUse($skill[Swap Mask], false);
	}
	return "";
}

string combat_flyer()
{
	string combatState = get_property("cc_combatHandler");

	item it = $item[Rock Band Flyers];
	if(!cc_combatCanUse(it, true))
	{
		it = $item[Jam Band Flyers];
		if(!cc_combatCanUse(it, true))
		{
			return "";
		}
	}

	if((my_location() != $location[The Battlefield (Frat Uniform)]) && (my_location() != $location[The Battlefield (Hippy Uniform)]) && !get_property("cc_ignoreFlyer").to_boolean() && (get_property("flyeredML").to_int() < 10000))
	{
		foreach sk in $skills[Beanscreen, Blood Chains, Broadside, Curse Of Indecision, Mind Bullets, Snap Fingers, Soul Bubble, Blood Chains]
		{
			if(cc_combatCanUse(sk, true))
			{
				return cc_combatUse(sk, true);
			}
		}

		if(!contains_text(combatState, "beanscreen") && cc_combatCanUse($skill[Hogtie], true) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(last_monster()))
		{
			return cc_combatUse($skill[Hogtie], true);
		}

		if(cc_have_skill($skill[Ambidextrous Funkslinging]) && cc_combatCanUse($item[Time-Spinner], true))
		{
			return cc_combatUse(it, $item[Time-Spinner], true);
		}
		return cc_combatUse(it, true);
	}
	return "";
}

itemSkill_t cc_convertAction(string action)
{
	itemSkill_t retval;
	action = trim(action);
	if(action.starts_with("skill"))
	{
		retval.sk = to_skill(action.substring(6));
	}
	else if(action.starts_with("item"))
	{
		action = action.substring(5);
		if(action.contains_text(","))
		{
			string[int] actions = split_string(action, ",");
			print("Contains! " + count(actions));
			if(count(actions) != 2)
			{
				abort("Expected 2 combat items but got " + count(actions) + " commas in item names do not play nicely.");
			}
			retval.it = to_item(actions[0]);
			retval.em = to_item(actions[1]);
		}
		else
		{
			retval.it = to_item(action);
		}
	}
//	else if(action == "runaway")
//	{
//		retval.sk = $skill[Run Away];
//	}
	else
	{
		abort("Can not convert action '" + action + "' into a skill or item.");
	}
	return retval;
}

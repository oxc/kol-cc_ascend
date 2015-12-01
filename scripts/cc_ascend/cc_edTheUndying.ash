script "cc_edTheUndying.ash"
import <cc_util.ash>
import <cc_equipment.ash>
import <cc_ascend/cc_eudora.ash>
import <cc_ascend/cc_clan.ash>

void ed_initializeSettings()
{
	if(my_path() == "Actually Ed the Undying")
	{
		set_property("cc_100familiar", true);
		set_property("cc_crackpotjar", "done");
		set_property("cc_cubeItems", "done");
		set_property("cc_day1_dna", "finished");
		set_property("cc_getBeehive", false);
		set_property("cc_getStarKey", false);
		set_property("cc_grimfairytale", "1");
		set_property("cc_grimstoneFancyOilPainting", false);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", false);
		set_property("cc_lashes_day1", "");
		set_property("cc_lashes_day2", "");
		set_property("cc_lashes_day3", "");
		set_property("cc_lashes_day4", "");
		set_property("cc_lashes", "");
		set_property("cc_renenutet_day1", "");
		set_property("cc_renenutet_day2", "");
		set_property("cc_renenutet_day3", "");
		set_property("cc_renenutet_day4", "");
		set_property("cc_renenutet", "");
		set_property("cc_semisub", "pantry");
		set_property("cc_useCubeling", false);
		set_property("cc_wandOfNagamar", false);

		set_property("cc_edSkills", -1);
		set_property("cc_chasmBusted", false);
		set_property("cc_renenutetBought", 0);

		set_property("cc_edCombatCount", 0);
		set_property("cc_edCombatRoundCount", 0);


		set_property("choiceAdventure1002", 1);
		set_property("choiceAdventure1023", "");
		set_property("desertExploration", 100);
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
	}
}

void ed_initializeDay(int day)
{
	if(my_path() != "Actually Ed the Undying")
	{
		return;
	}
	if(day == 1)
	{
		if(get_property("cc_day1_init") != "finished")
		{
			set_property("cc_renenutetBought", 0);
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}

			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter to Ed the Undying]), $item[Letter to Ed the Undying]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			equipBaseline();

			set_property("cc_day1_init", "finished");
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("cc_day2_init") == "")
		{

			if(get_property("cc_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			set_property("cc_renenutetBought", 0);
			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				hermit(1, $item[Seal Tooth]);
			}
			hermit(10, $item[ten-leaf clover]);
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);

			set_property("cc_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("cc_day3_init") == "")
		{
			set_property("cc_renenutetBought", 0);
			hermit(10, $item[ten-leaf clover]);
			set_property("cc_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("cc_day4_init") == "")
		{
			set_property("cc_renenutetBought", 0);
			hermit(10, $item[ten-leaf clover]);
			set_property("cc_day4_init", "finished");
		}
	}
}

boolean adjustEdHat(string goal)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(!possessEquipment($item[The Crown of Ed the Undying]))
	{
		return false;
	}
	int option = -1;
	goal = to_lower_case(goal);
	if(((goal == "muscle") || (goal == "bear")) && (get_property("edPiece") != "bear"))
	{
		option = 1;
	}
	else if(((goal == "myst") || (goal == "mysticality") || (goal == "owl")) && (get_property("edPiece") != "owl"))
	{
		option = 2;
	}
	else if(((goal == "moxie") || (goal == "puma")) && (get_property("edPiece") != "puma"))
	{
		option = 3;
	}
	else if(((goal == "ml") || (goal == "hyena")) && (get_property("edPiece") != "hyena"))
	{
		option = 4;
	}
	else if(((goal == "meat") || (goal == "item") || (goal == "items") || (goal == "drops") || (goal == "mouse")) && (get_property("edPiece") != "mouse"))
	{
		option = 5;
	}
	else if(((goal == "regen") || (goal == "regenerate") || (goal == "miss") || (goal == "dodge") || (goal == "weasel")) && (get_property("edPiece") != "weasel"))
	{
		option = 6;
	}
	else if(((goal == "breathe") || (goal == "underwater") || (goal == "fish")) && (get_property("edPiece") != "fish"))
	{
		option = 7;
	}

	if(option != -1)
	{
		visit_url("inventory.php?action=activateedhat");
		visit_url("choice.php?pwd=&whichchoice=1063&option=" + option, true);
		return true;
	}
	return false;
}

float edMeatBonus()
{
	if(my_class() != $class[Ed])
	{
		return 0.0;
	}
	if(have_skill($skill[Curse of Fortune]) && (item_amount($item[Ka Coin]) > 0))
	{
		return 200.0;
	}
	return 0.0;
}

boolean handleServant(servant who)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(who == $servant[none])
	{
		#use_servant($servant[none]);
		return false;
	}
	if(!have_servant(who))
	{
		return false;
	}
	if(my_servant() != who)
	{
		return use_servant(who);
	}
	return true;
}

boolean handleServant(string name)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	name = to_lower_case(name);
	if((name == "priest") || (name == "ka"))
	{
		return handleServant($servant[Priest]);
	}
	if((name == "maid") || (name == "meat"))
	{
		return handleServant($servant[Maid]);
	}
	if((name == "belly-dancer") || (name == "belly") || (name == "dancer") || (name == "bellydancer") || (name == "pickpocket") || (name == "steal"))
	{
		return handleServant($servant[Belly-Dancer]);
	}
	if((name == "cat") || (name == "item") || (name == "itemdrop"))
	{
		return handleServant($servant[Cat]);
	}
	if((name == "bodyguard") || (name == "block"))
	{
		return handleServant($servant[Bodyguard]);
	}
	if((name == "scribe") || (name == "stats") || (name == "stat"))
	{
		return handleServant($servant[Scribe]);
	}
	if((name == "assassin") || (name == "stagger"))
	{
		return handleServant($servant[Assassin]);
	}
	if(name == "none")
	{
		return handleServant($servant[None]);
	}
	return false;
}
boolean ed_doResting()
{
	if(my_class() == $class[Ed])
	{
		int maxBuff = 675 - my_turncount();
		while(get_property("timesRested").to_int() < total_free_rests())
		{
			doRest();
			buffMaintain($effect[Purr of the Feline], 30, 3, maxBuff);
			buffMaintain($effect[Hide of Sobek], 30, 3, maxBuff);
			buffMaintain($effect[Bounty of Renenutet], 30, 3, maxBuff);
			buffMaintain($effect[Prayer of Seshat], 15, 3, maxBuff);
			buffMaintain($effect[Wisdom of Thoth], 15, 3, maxBuff);
			buffMaintain($effect[Power of Heka], 15, 3, maxBuff);
		}
		return true;
	}
	return false;
}

boolean ed_buySkills()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(my_level() <= get_property("cc_edSkills").to_int())
	{
		return false;
	}
	int possEdPoints = 0;

	string page = visit_url("place.php?whichplace=edbase&action=edbase_book");
	matcher my_skillPoints = create_matcher("You may memorize (\\d\+) more page", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		print("Skill points found: " + skillPoints);
		possEdPoints = skillPoints - 1;
		if(have_skill($skill[Bounty of Renenutet]) && have_skill($skill[Wrath of Ra]) && have_skill($skill[Curse of Stench]))
		{
			skillPoints = 0;
		}
		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int skillid = 20;
			if(!have_skill($skill[Curse of Vacation]))
			{
				skillid = 19;
			}
			if(!have_skill($skill[Curse of Fortune]))
			{
				skillid = 18;
			}
			if(!have_skill($skill[Curse of Heredity]))
			{
				skillid = 17;
			}
			if(!have_skill($skill[Curse of Yuck]))
			{
				skillid = 16;
			}
			if(!have_skill($skill[Curse of Indecision]))
			{
				skillid = 15;
			}
			if(!have_skill($skill[Curse of the Marshmallow]))
			{
				skillid = 14;
			}
			if(!have_skill($skill[Wrath of Ra]))
			{
				skillid = 13;
			}
			if(!have_skill($skill[Bounty of Renenutet]))
			{
				skillid = 6;
			}
			if(!have_skill($skill[Shelter of Shed]))
			{
				skillid = 5;
			}
			if(!have_skill($skill[Blessing of Serqet]))
			{
				skillid = 4;
			}
			if(!have_skill($skill[Hide of Sobek]))
			{
				skillid = 3;
			}
			if(!have_skill($skill[Power of Heka]))
			{
				skillid = 2;
			}
			if(!have_skill($skill[Lash of the Cobra]))
			{
				skillid = 12;
			}
			if(!have_skill($skill[Purr of the Feline]))
			{
				skillid = 11;
			}
			if(!have_skill($skill[Storm of the Scarab]))
			{
				skillid = 10;
			}
			if(!have_skill($skill[Roar of the Lion]))
			{
				skillid = 9;
			}
			if(!have_skill($skill[Howl of the Jackal]))
			{
				skillid = 8;
			}
			if(!have_skill($skill[Wisdom of Thoth]))
			{
				skillid = 1;
			}
			if(!have_skill($skill[Fist of the Mummy]))
			{
				skillid = 7;
			}
			if(!have_skill($skill[Prayer of Seshat]))
			{
				skillid = 0;
			}

			visit_url("choice.php?pwd&skillid=" + skillid + "&option=1&whichchoice=1051");
		}
	}

	#adding this after skill purchase, is mafia not detecting our skills?
	visit_url("charsheet.php");


	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_imbuePoints = create_matcher("Impart Wisdom unto Current Servant ..100xp, (\\d\+) remain.", page);
	int imbuePoints = 0;
	if(my_imbuePoints.find())
	{
		imbuePoints = to_int(my_imbuePoints.group(1));
		print("Imbuement points found: " + imbuePoints);
	}
	possEdPoints += imbuePoints;

	if(possEdPoints > get_property("edPoints").to_int())
	{
		set_property("edPoints", possEdPoints);
	}

	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_servantPoints = create_matcher("You may release (\\d\+) more servant", page);
	if(my_servantPoints.find())
	{
		int servantPoints = to_int(my_servantPoints.group(1));
		print("Servants points found: " + servantPoints);
		while(servantPoints > 0)
		{
			servantPoints -= 1;
			int sid = -1;
			if(!have_servant($servant[Assassin]))
			{
				sid = 7;
			}
			if(!have_servant($servant[Bodyguard]))
			{
				sid = 4;
			}
			if(!have_servant($servant[Belly-Dancer]))
			{
				sid = 2;
			}
			if(!have_servant($servant[Scribe]))
			{
				sid = 5;
			}
			if(!have_servant($servant[Maid]))
			{
				sid = 3;
				if((my_level() >= 9) && (imbuePoints > 5) && !have_servant($servant[Scribe]))
				{
					#If we are at the third servant and have enough imbues, get the Scribe instead.
					sid = 5;
				}
			}
			if(!have_servant($servant[Cat]))
			{
				sid = 1;
			}
			if(!have_servant($servant[Priest]))
			{
				sid = 6;
			}
			if(sid != -1)
			{
				visit_url("choice.php?whichchoice=1053&option=3&pwd&sid=" + sid);
			}
		}
	}

	if((imbuePoints > 0) && (my_level() >= 3))
	{
		visit_url("charsheet.php");

		servant current = my_servant();
		while(imbuePoints > 0)
		{
			servant tryImbue = $servant[none];

			if(get_property("cc_dickstab").to_boolean())
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
			}
			else
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 199))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 199))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Belly-Dancer]) && ($servant[Belly-Dancer].experience < 341))
				{
					tryImbue = $servant[Belly-Dancer];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 99))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Scribe];
				}
				else
				{
					if((imbuePoints > 4) && (my_level() >= 9))
					{
						if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 341))
						{
							tryImbue = $servant[Scribe];
						}
					}
				}
			}

			if(tryImbue != $servant[none])
			{
				if(handleServant(tryImbue))
				{
					print("Trying to imbue " + tryImbue + " with glorious wisdom!!", "green");
					visit_url("choice.php?whichchoice=1053&option=5&pwd=");
				}
			}
			imbuePoints = imbuePoints - 1;
		}
		handleServant(current);
	}

	set_property("cc_edSkills", my_level());
	return true;
}

boolean ed_eatStuff()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = min(canEat, item_amount($item[Mummified Beef Haunch]));
	if(canEat > 0)
	{
		chew(canEat, $item[Mummified Beef Haunch]);
	}
	if((my_daycount() == 2) && (eudora_current() == $item[Xi Receiver Unit]) && possessEquipment($item[Xiblaxian holo-wrist-puter]) && ((my_fullness() + 4) <= fullness_limit()) && (item_amount($item[Xiblaxian Circuitry]) >= 1) && (item_amount($item[Xiblaxian Polymer]) >= 1) && (item_amount($item[Xiblaxian Alloy]) >= 3))
	{
		if(item_amount($item[Xiblaxian 5D Printer]) == 0)
		{
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
				use(1, $item[Xiblaxian Cache Locator Simcode]);
			}
		}
		if(item_amount($item[Xiblaxian 5D Printer]) > 0)
		{
			int[item] canMake = eudora_xiblaxian();
			if(canMake contains $item[Xiblaxian Ultraburrito])
			{
				if(canMake[$item[Xiblaxian Ultraburrito]] > 0)
				{
					visit_url("shop.php?pwd=&whichshop=5dprinter&action=buyitem&quantity=1&whichrow=339", true);
				}
			}
		}
	}

	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && ((my_fullness() == 0) || (my_fullness() == 3)) && (fullness_limit() >= 2))
	{
		eat(1, $item[Limp Broccoli]);
	}
	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && (my_fullness() == 2) && (fullness_limit() >= 5) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		eat(1, $item[Limp Broccoli]);
	}
	if((item_amount($item[Xiblaxian Ultraburrito]) > 0) && (my_fullness() == 0) && (fullness_limit() >= 4) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		eat(1, $item[Xiblaxian Ultraburrito]);
	}
	if((my_level() >= 11) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0))
	{
		eat(1, $item[Astral Hot Dog]);
	}
	if((my_level() >= 9) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0) && (my_adventures() < 4))
	{
		eat(1, $item[Astral Hot Dog]);
	}
	if(!get_property("_fancyHotDogEaten").to_boolean() && (my_daycount() == 1) && (my_level() >= 9) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) == 0) && (my_adventures() < 10) && (item_amount($item[Clan VIP Lounge Key]) > 0))
	{
		eatFancyDog("video games hot dog");
#		visit_url("clan_viplounge.php?action=hotdogstand");
#		buy_using_storage(3, $item[GameInformPowerDailyPro Magazine], 2500);
#		visit_url("clan_viplounge.php?preaction=hotdogsupply&hagnks=1&whichdog=-103&quantity=3");
#		cli_execute("eat 1 video games hot dog");
#		if(!get_property("_fancyHotDogEaten").to_boolean())
#		{
#			abort("Failed eating video games hot dog (already contributed, eat it manually I suppose)....");
#		}
	}

	if(get_property("cc_dickstab").to_boolean() && !get_property("_fancyHotDogEaten").to_boolean() && (my_daycount() == 1) && ((my_fullness() + 2) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) == 0) && (item_amount($item[Clan VIP Lounge Key]) > 0))
	{
		eatFancyDog("sleeping dog");
#		visit_url("clan_viplounge.php?action=hotdogstand");
#		buy_using_storage(10, $item[Gauze Hammock], 6000);
#		visit_url("clan_viplounge.php?preaction=hotdogsupply&hagnks=1&whichdog=-101&quantity=10");
#		cli_execute("eat 1 sleeping dog");
#		if(!get_property("_fancyHotDogEaten").to_boolean())
#		{
#			abort("Failed eating sleeping dog (already contributed, eat it manually I suppose)....");
#		}
	}


	if((my_daycount() >= 3) && (my_inebriety() == 0) && (inebriety_limit() == 4) && (item_amount($item[Xiblaxian Space-Whiskey]) > 0) && (my_adventures() < 10))
	{
		drink(1, $item[Xiblaxian Space-Whiskey]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 11))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 10) && (my_adventures() < 3))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 9) && (my_adventures() < 3) && (my_fullness() >= fullness_limit()))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Coinspiracy]) >= 6) && ((my_inebriety() + 3) <= inebriety_limit()) && (my_adventures() < 3) && (item_amount($item[Astral Pilsner]) == 0))
	{
		buy(1, $item[Highest Bitter]);
		drink(1, $item[Highest Bitter]);
	}

	string cookie = get_counters("Fortune Cookie", 0, 200);
	if((cookie != "Fortune Cookie") && (get_property("cc_semirare").to_int() < 2))
	{
		if((item_amount($item[Clan VIP Lounge Key]) > 0) && (my_meat() >= 500) && (inebriety_limit() == 4) && ((my_inebriety() == 0) || (my_inebriety() == 3)))
		{
			cli_execute("drink 1 lucky lindy");
		}
		else if((my_meat() >= 40) && (my_fullness() < fullness_limit()) && (my_fullness() >= 4))
		{
			buy(1, $item[Fortune Cookie]);
			eat(1, $item[Fortune Cookie]);
		}
	}
	return true;
}

boolean ed_needShop()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(item_amount($item[Ka Coin]) < 15)
	{
		return false;
	}
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = max(0, canEat - item_amount($item[Mummified Beef Haunch]));

	skill limiter = $skill[Even More Elemental Wards];
	if(my_daycount() >= 2)
	{
		limiter = $skill[Healing Scarabs];
	}

#	else if(my_daycount() > 2)
#	{
#		limiter = $skill[Upgraded Spine];
#	}

	if((canEat == 0) && have_skill(limiter) && (item_amount($item[Linen Bandages]) >= 4) && (get_property("cc_renenutetBought").to_int() >= 7) && (item_amount($item[Holy Spring Water]) >= 1) && (item_amount($item[Talisman of Horus]) >= 2))
	{
		if((item_amount($item[Ka Coin]) > 30) && (item_amount($item[Spirit Beer]) == 0))
		{
			return true;
		}
		if((item_amount($item[Ka Coin]) > 35) && !have_skill($skill[Upgraded Spine]))
		{
			return true;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (item_amount($item[Ka Coin]) > 30))
		{
			return true;
		}
		return false;
	}
	return true;
}


boolean ed_shopping()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(!ed_needShop())
	{
		return false;
	}
	print("Time to shop!", "red");
	wait(1);
	visit_url("choice.php?pwd=&whichchoice=1023&option=1", true);


	if(get_property("cc_breakstone").to_boolean())
	{
		visit_url("place.php?whichplace=edunder&action=edunder_hippy");
		visit_url("choice.php?pwd&whichchoice=1057&option=1", true);
		set_property("cc_breakstone", false);
	}

	int coins = item_amount($item[Ka Coin]);
	if((my_spleen_use() + 5) <= spleen_limit())
	{
		int canEat = (spleen_limit() - my_spleen_use()) / 5;
		canEat = canEat - item_amount($item[Mummified Beef Haunch]);
		while((coins >= 15) && (canEat > 0))
		{
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=428", true);
			#buy(1, $item[Mummified Beef Haunch]);
			print("Buying a mummified beef haunch!", "green");
			coins = coins - 15;
			canEat = canEat - 1;
		}
	}

	int skillBuy = 0;
	if(!have_skill($skill[Extra Spleen]))
	{
		if(coins >= 5)
		{
			print("Buying Extra Spleen", "green");
			skillBuy = 30;
		}
	}
	else if(!have_skill($skill[Another Extra Spleen]))
	{
		if(coins >= 10)
		{
			print("Buying Another Extra Spleen", "green");
			skillBuy = 31;
		}
	}
	else if(!have_skill($skill[Replacement Stomach]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Stomach", "green");
			skillBuy = 28;
		}
	}
	else if(!have_skill($skill[Upgraded Legs]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	}
	else if(!have_skill($skill[More Legs]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	}
	else if(!have_skill($skill[Yet Another Extra Spleen]))
	{
		if(coins >= 15)
		{
			print("Buying Yet Another Extra Spleen", "green");
			skillBuy = 32;
		}
	}
	else if(!have_skill($skill[Replacement Liver]) && get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 30)
		{
			print("Buying Replacement Liver", "green");
			skillBuy = 29;
		}
	}
	else if(!have_skill($skill[Still Another Extra Spleen]))
	{
		if(coins >= 20)
		{
			print("Buying Still Another Extra Spleen", "green");
			skillBuy = 33;
		}
	}
	else if(!have_skill($skill[Just One More Extra Spleen]))
	{
		if(coins >= 25)
		{
			print("Buying Just One More Extra Spleen", "green");
			skillBuy = 34;
		}
	}
	else if(!have_skill($skill[Replacement Liver]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Liver", "green");
			skillBuy = 29;
		}
	}
	else if(!have_skill($skill[Elemental Wards]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	}
	else if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{
		if(coins >= 30)
		{
			print("Buying Okay Seriously, This is the Last Spleen", "green");
			skillBuy = 35;
		}
	}
	else if((get_property("cc_renenutetBought").to_int() < 7) && (coins > 1))
	{
		while((get_property("cc_renenutetBought").to_int() < 7) && (coins > 1))
		{
			print("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			#buy(1, $item[Talisman of Renenutet]);
			set_property("cc_renenutetBought", 1 + get_property("cc_renenutetBought").to_int());
			coins = coins - 1;
			if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
			{
				break;
			}
		}
	}
	else if(!have_skill($skill[Upgraded Legs]))
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	}
	else if(!possessEquipment($item[The Crown of Ed the Undying]) && !have_skill($skill[Tougher Skin]) && (coins >= 10))
	{
		print("Buying Tougher Skin (10)", "green");
		skillBuy = 39;
	}
	else if(!have_skill($skill[More Legs]))
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	}
	else if(!have_skill($skill[Elemental Wards]))
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	}
	else if(!have_skill($skill[More Elemental Wards]))
	{
		if(coins >= 20)
		{
			print("Buying More Elemental Wards", "green");
			skillBuy = 45;
		}
	}
	else if(!have_skill($skill[Even More Elemental Wards]))
	{
		if(coins >= 30)
		{
			print("Buying Even More Elemental Wards", "green");
			skillBuy = 46;
		}
	}
	else if((!have_skill($skill[Healing Scarabs])) && (my_daycount() >= 2))
	{
		if(coins >= 10)
		{
			print("Buying Healing Scarabs", "green");
			skillBuy = 43;
		}
	}
	else if((!have_skill($skill[Arm Blade])) && (my_daycount() >= 2) && (coins >= 100))
	{
		print("Buying Arm Blade (20)", "green");
		skillBuy = 42;
	}
	else if(!have_skill($skill[Upgraded Arms]) && (my_daycount() >= 2) && (coins >= 100))
	{
		print("Buying Upgraded Arms (20)", "green");
		skillBuy = 37;
	}
	else if(!have_skill($skill[Tougher Skin]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Tougher Skin (10)", "green");
		skillBuy = 39;
	}
	else if(!have_skill($skill[Armor Plating]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Armor Plating (10)", "green");
		skillBuy = 40;
	}
	else if(!have_skill($skill[Upgraded Spine]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Upgraded Spine (20)", "green");
		skillBuy = 38;
	}
	else if(!have_skill($skill[Bone Spikes]) && (my_daycount() >= 4) && (coins >= 100))
	{
		print("Buying Bone Spikes (20)", "green");
		skillBuy = 41;
	}
	else if(have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{	//437 438?
		while((coins >= 1) && (get_property("cc_renenutetBought").to_int() < 7))
		{
			print("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			#buy(1, $item[Talisman of Renenutet]);
			set_property("cc_renenutetBought", 1 + get_property("cc_renenutetBought").to_int());
			coins = coins - 1;
		}
		while((item_amount($item[Linen Bandages]) < 4) && (coins >= 4))
		{
			print("Buying Linen Bandages", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=429", true);
			#buy(1, $item[Linen Bandages]);
			coins -= 1;
		}
		while((item_amount($item[Holy Spring Water]) < 1) && (coins >= 2))
		{
			print("Buying Holy Spring Water", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
			#buy(1, $item[Holy Spring Water]);
			coins -= 1;
		}
		while((item_amount($item[Talisman of Horus]) < 3) && (coins >= 5))
		{
			print("Buying Talisman of Horus", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=693", true);
			#buy(1, $item[Talisman of Horus]);
			coins -= 5;
		}
		while((item_amount($item[Spirit Beer]) == 0) && (coins >= 30))
		{
			print("Buying Spirit Beer", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
			#buy(1, $item[Spirit Beer]);
			coins -= 1;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (coins >= 30))
		{
			print("Buying Ancient Cure-all", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=435", true);
			#buy(1, $item[Ancient Cure-all]);
			coins -= 3;
		}
	}


	if(skillBuy != 0)
	{
		visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
		visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
		visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
	}
	visit_url("place.php?whichplace=edunder&action=edunder_leave");
	visit_url("choice.php?pwd=&whichchoice=1024&option=1", true);
	return true;
}

boolean ed_handleAdventureServant(int num, location loc, string option)
{
	handleServant($servant[Priest]);
	boolean reassign = false;
	if((!ed_needShop() && (my_spleen_use() == 35)) && (item_amount($item[Ka Coin]) > 15))
	{
		reassign = true;
	}
	if((my_daycount() >= 3) && (my_adventures() >= 20) && (my_level() >= 12))
	{
		reassign = true;
	}

	if(reassign)
	{
		if(!have_skill($skill[Gift of the Maid]) && have_servant($servant[Maid]) && (get_property("cc_nuns") != "finished") && (get_property("cc_nuns") != "done"))
		{
			handleServant($servant[Maid]);
		}
		else if((!have_skill($skill[Gift of the Scribe]) || (my_level() < 13)) && have_servant($servant[Scribe]))
		{
			handleServant($servant[Scribe]);
		}
		else if(!have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]))
		{
			handleServant($servant[Cat]);
		}
		else if((my_mp() < 20) && have_servant($servant[Belly-Dancer]))
		{
			handleServant($servant[Belly-Dancer]);
		}
		else
		{
			if(my_level() >= 13)
			{
				if(!handleServant($servant[Cat]))
				{
					if(!handleServant($servant[Maid]))
					{
						handleServant($servant[Scribe]);
					}
				}
			}
			else
			{
				if(!handleServant($servant[Scribe]))
				{
					if(!handleServant($servant[Cat]))
					{
						handleServant($servant[Maid]);
					}
				}
			}
		}
	}
	if((loc == $location[The Secret Government Laboratory]) && (my_daycount() == 1))
	{
		handleServant($servant[Priest]);
	}

	if((loc == $location[The Defiled Nook]) ||
		(loc == $location[The Haunted Library]) ||
		(loc == $location[The Haunted Laundry Room]) ||
		(loc == $location[The Haunted Wine Cellar]) ||
		(loc == $location[Oil Peak]) ||
		(loc == $location[The Hidden Bowling Alley]) ||
		(loc == $location[A-Boo Peak]))
	{
		if(!handleServant($servant[Cat]))
		{
			if(!handleServant($servant[Scribe]))
			{
				handleServant($servant[Maid]);
			}
		}
	}

	if((loc == $location[The Dark Neck of the Woods]) ||
		(loc == $location[The Dark Heart of the Woods]) ||
		(loc == $location[The Dark Elbow of the Woods]))
	{
		if((get_property("cc_pirateoutfit") != "finished") && (get_property("cc_pirateoutfit") != "almost") && (item_amount($item[Hot Wing]) < 3))
		{
			if(!handleServant($servant[Cat]))
			{
				if(!handleServant($servant[Scribe]))
				{
					handleServant($servant[Maid]);
				}
			}
		}
		else
		{
			if(!handleServant($servant[Scribe]))
			{
				if(!handleServant($servant[Cat]))
				{
					handleServant($servant[Maid]);
				}
			}
		}
	}

	if((loc == $location[The Defiled Alcove]) ||
		(loc == $location[The Defiled Cranny]) ||
		(loc == $location[The Defiled Niche]) ||
		(loc == $location[The Haunted Bedroom]) ||
		(loc == $location[The Haunted Ballroom]) ||
		(loc == $location[The Haunted Billiards Room]) ||
		(loc == $location[The Haunted Kitchen]) ||
		(loc == $location[The Haunted Bathroom]))
	{
		if(!have_skill($skill[Gift of the Maid]) && !handleServant($servant[Maid]))
		{
			if(!handleServant($servant[Scribe]))
			{
				handleServant($servant[Cat]);
			}
		}
	}

	if(loc == $location[The Themthar Hills])
	{
		handleServant($servant[Maid]);
	}

	if((loc == $location[Next To That Barrel With Something Burning In It]) ||
		(loc == $location[Out By That Rusted-Out Car]) ||
		(loc == $location[Over Where The Old Tires Are]) ||
		(loc == $location[Near an Abandoned Refrigerator]))
	{
		handleServant($servant[Cat]);
	}
	return false;
}

boolean ed_preAdv(int num, location loc, string option)
{
	ed_handleAdventureServant(num, loc, option);

	if((have_equipped($item[Xiblaxian Holo-Wrist-Puter])) && (howLongBeforeHoloWristDrop() <= 1))
	{
		string area = loc.environment;
		# This is an attempt to farm Ultraburrito stuff.

		item replace = $item[none];
		if((item_amount($item[Pirate Fledges]) > 0) && (can_equip($item[Pirate Fledges])))
		{
			replace = $item[Pirate Fledges];
		}

		# If we migrate all Ed workaround combats to the bypasser, we don't need to check main.php
		if(!contains_text(visit_url("main.php"), "Combat"))
		{
			if(loc == $location[Noob Cave])
			{
				equip($slot[acc3], replace);
				return true;
			}

			if((area == "indoor") && (item_amount($item[Xiblaxian Circuitry]) > 0))
			{
				equip($slot[acc3], replace);
			}
			else if((area == "outdoor") && (item_amount($item[Xiblaxian Polymer]) > 0))
			{
				equip($slot[acc3], replace);
			}
			else if((area == "underground") && (item_amount($item[Xiblaxian Alloy]) > 2))
			{
				equip($slot[acc3], replace);
			}
			else
			{
				print("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
			}
		}
	}
	return true;
}

boolean ed_ccAdv(int num, location loc, string option, boolean skipFirstLife)
{
	if((option == "") || (option == "cc_combatHandler"))
	{
		option = "cc_edCombatHandler";
	}

	if(!skipFirstLife)
	{
		ed_preAdv(num, loc, option);
	}

	boolean status = false;
	while(num > 0)
	{
		set_property("autoAbortThreshold", "-10.0");
		num = num - 1;
		if(num > 1)
		{
			print("This fight and " + num + " more left.", "blue");
		}
		set_property("cc_disableAdventureHandling", "yes");
		set_property("cc_edCombatHandler", "");

		if(!skipFirstLife)
		{
			set_property("cc_edCombatStage", 0);
			print("Starting Ed Battle at " + loc, "blue");
#			status = adv1(loc, 1, option);
			status = adv1(loc, 0, option);
			if(!status && (get_property("lastEncounter") == "Like a Bat Into Hell"))
			{
				set_property("cc_disableAdventureHandling", "no");
				abort("Either a) We had a connection problem and lost track of the battle, or we were defeated multiple times beyond our usual UNDYING. Manually handle the fight and rerun.");
			}
		}
		if(last_monster() == $monster[Crate])
		{
			abort("We went to the Noob Cave for reals... uh oh");
		}

		string page = visit_url("main.php");
		if(contains_text(page, "whichchoice value=1023"))
		{
			print("Ed has UNDYING once!" , "blue");
			if(!ed_shopping())
			{
				#If this visit_url results in the enemy dying, we don't want to continue
				visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
			}
			set_property("cc_edCombatStage", 1);
			print("Ed returning to battle Stage 1", "blue");

			if(get_property("_edDefeats").to_int() == 0)
			{
				print("Monster defeated in initialization, aborting attempt.", "red");
				set_property("cc_edCombatStage", 0);
				set_property("cc_disableAdventureHandling", "no");
				cli_execute("postcheese.ash");
				return true;
			}

			# Stop place.php redirected to fight page (issue from KoLAdventure.java?)
#			if(loc == $location[Inside the Palindome])
#			{
#				loc = $location[Noob Cave];
#			}

#			status = adv1(loc, 1, option);
			status = adv1(loc, 0, option);
			if(last_monster() == $monster[Crate])
			{
				abort("We went to the Noob Cave for reals... uh oh");
			}

			page = visit_url("main.php");
			if(contains_text(page, "whichchoice value=1023"))
			{
				print("Ed has UNDYING twice! Time to kick ass!" , "blue");
				if(!ed_shopping())
				{
					#If this visit_url results in the enemy dying, we don't want to continue
					visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
				}
				set_property("cc_edCombatStage", 2);
				print("Ed returning to battle Stage 2", "blue");

				if(get_property("_edDefeats").to_int() == 0)
				{
					print("Monster defeated in initialization, aborting attempt.", "red");
					set_property("cc_edCombatStage", 0);
					set_property("cc_disableAdventureHandling", "no");
					cli_execute("postcheese.ash");
					return true;
				}

#				status = adv1(loc, 1, option);
				status = adv1(loc, 0, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}
		}
		set_property("cc_edCombatStage", 0);
		set_property("cc_disableAdventureHandling", "no");
		cli_execute("postcheese.ash");
	}
	return status;
}

boolean ed_ccAdv(int num, location loc, string option)
{
	return ed_ccAdv(num, loc, option, false);
}

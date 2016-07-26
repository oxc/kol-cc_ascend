script "cc_sneakypete.ash"
import <cc_ascend/cc_util.ash>
import <cc_ascend/cc_equipment.ash>
import <cc_ascend/cc_eudora.ash>
import <cc_ascend/cc_clan.ash>
import <cc_ascend/cc_ascend_header.ash>
import <cc_ascend/cc_elementalPlanes.ash>
import <cc_ascend/cc_mr2014.ash>



void pete_initializeSettings()
{
	if(my_path() == "Avatar of Sneaky Pete")
	{
		set_property("cc_100familiar", true);
		set_property("cc_ballroomsong", "finished");
		set_property("cc_peteSkills", -1);
		set_property("cc_cubeItems", false);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", false);
		set_property("cc_wandOfNagamar", false);
	}
}


void pete_initializeDay(int day)
{
	if(my_path() != "Avatar of Sneaky Pete")
	{
		return;
	}
	if(day == 1)
	{
		if(get_property("cc_day1_init") != "finished")
		{
			#set_property("cc_day1_init", "finished");
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

			#set_property("cc_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("cc_day3_init") == "")
		{
			hermit(10, $item[ten-leaf clover]);
			set_property("cc_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("cc_day4_init") == "")
		{
			hermit(10, $item[ten-leaf clover]);
			set_property("cc_day4_init", "finished");
		}
	}
}

boolean pete_buySkills()
{
	if(my_class() != $class[Avatar of Sneaky Pete])
	{
		return false;
	}
	if(my_level() <= get_property("cc_peteSkills").to_int())
	{
		return false;
	}
	if(have_skill($skill[Natural Dancer]) && have_skill($skill[Flash Headlight]) && have_skill($skill[Walk Away From Explosion]) && (my_level() > 12))
	{
		return false;
	}

	string page = visit_url("da.php?place=gate3");
	matcher my_skillPoints = create_matcher("<b>(\\d\+)</b> skill point", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		print("Skill points found: " + skillPoints);

		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int tree = 1;

			if(!have_skill($skill[Flash Headlight]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Biker Swagger]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Riding Tall]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Check Mirror]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Easy Riding]))
			{
				tree = 2;
			}

			if(!have_skill($skill[Walk Away From Explosion]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Brood]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Unrepentant Thief]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Hard Drinker]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Smoke Break]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Animal Magnetism]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Jump Shark]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Incite Riot]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Live Fast]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Insult]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Natural Dancer]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Make Friends]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Cocktail Magic]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Check Hair]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Shake It Off]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Snap Fingers]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Fix Jukebox]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Throw Party]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Mixologist]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Catchphrase]))
			{
				tree = 1;
			}

			if(!have_skill($skill[Peel Out]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Rowdy Drinker]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Pop Wheelie]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Born Showman]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Rev Engine]))
			{
				tree = 2;
			}
			visit_url("choice.php?option=" + tree + "&whichchoice=867&pwd=");
		}
	}

	page = visit_url("main.php?action=motorcycle");
	matcher my_cyclePoints = create_matcher("Upping Your Grade", page);
	while(my_cyclePoints.find())
	{
		if(get_property("peteMotorbikeCowling") == "")
		{
			run_choice(4);
			run_choice(3);
		}
		else if(get_property("peteMotorbikeTires") == "")
		{
			run_choice(1);
			run_choice(1);
		}
		else if(get_property("peteMotorbikeMuffler") == "")
		{
			run_choice(5);
			run_choice(2);
		}
		else if(get_property("peteMotorbikeGasTank") == "")
		{
			run_choice(2);
			run_choice(2);
		}
		else if(get_property("peteMotorbikeHeadlight") == "")
		{
			run_choice(3);
			run_choice(3);
		}
		else if(get_property("peteMotorbikeSeat") == "")
		{
			run_choice(6);
			run_choice(1);
		}

		page = visit_url("main.php?action=motorcycle");
		my_cyclePoints = create_matcher("Upping Your Grade", page);
	}

	set_property("cc_peteSkills", my_level());
	return true;
}


boolean LM_pete()
{
	if(my_path() != "Avatar of Sneaky Pete")
	{
		return false;
	}

	pete_buySkills();

	return false;
}

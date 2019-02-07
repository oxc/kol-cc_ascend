script "standard.ash"
# Code here is supplementary handlers and specialized handlers

void standard_initializeSettings()
{
	if(cc_my_path() == "Standard")
	{
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_wandOfNagamar", true);
		set_property("cc_useCubeling", true);
	}
}

void standard_pulls()
{
	if(cc_my_path() == "Standard")
	{
		if(my_daycount() == 3)
		{
			#pullXWhenHaveY($item[Wand of Nagamar], 1, 0);		//Pull made obsolete by Questificaton
			#pullXWhenHaveY($item[Star Key Lime Pie], 3, 0);
			if((towerkeycount() < 3) && (fullness_left() >= 4))
			{
				pullXWhenHaveY($item[Boris\'s Key Lime Pie], 1, 0);
			}
			if(fullness_left() >= 5)
			{
				pullXWhenHaveY($item[Cold Hi Mein], fullness_left() / 5, 0);
			}
		}

	}
}


void setDecisionScope(string scope)
{
	set_property("cc_decisionLogScope", scope);
}
boolean logDecision(boolean decision, string reason)
{
	return logDecision(decision, reason, 1);
}
boolean logDecision(string reason, int level)
{
	return logDecision(false, reason, level);
}
boolean logDecision(boolean decision, string reason, int level)
{
	int logLevel = get_property("cc_printDecisionLog").to_int();
	if (logLevel >= level)
	{
		int c = max(1, 10-logLevel);
		string color = "#" + c + c + c + c + c + c;
		print("[" + get_property("cc_decisionLogScope") + "]: " + reason, color);
	}
	return decision;
}
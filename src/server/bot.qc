class
TFCBot:NSBot
{
	void TFCBot(void);

	//virtual void CreateObjective(void);
};

void CSEv_TeamJoin_f(float f);
void CSEv_ClassJoin_f(float f);

void
TFCBot::TFCBot(void)
{
	CSEv_TeamJoin_f(0);
	CSEv_ClassJoin_f(0);
}

#if 0
void
TFCBot::CreateObjective(void)
{
	super:: CreateObjective();
}
#endif
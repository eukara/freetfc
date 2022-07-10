
#define TFC_SENTRY_COST 130

class
TFCSentry:NSSurfacePropEntity
{
	NSSurfacePropEntity m_eHead;

	void(void) TFCSentry;

	virtual void(player) Place;
	virtual void(void) FinishPlacing;
};

void
TFCSentry::Place(player pl)
{
	SetAngles(pl.GetAngles());

	makevectors([0, pl.v_angle[1], 0]);
	SetOrigin(pl.origin + (v_forward * 48));
	DropToFloor();

	think = FinishPlacing;
	nextthink = time + 5.0f;
	real_owner = pl;

	env_message_single(real_owner, "#Engineer_building");
	Sound_Play(this, CHAN_BODY, "engineer.build");
}

void
TFCSentry::FinishPlacing(void)
{
	/* put the top on that spins */
	m_eHead.SetModel("models/sentry1.mdl");
	m_eHead.SetAngles(GetAngles());
	m_eHead.SetSolid(SOLID_BBOX);
	m_eHead.SetMovetype(MOVETYPE_NONE);
	m_eHead.SetSize([-16,-16,0], [16,16,32]);
	m_eHead.SetOrigin(GetOrigin() + [0,0,20]);

	env_message_single(real_owner, "#Sentry_finish");
	Sound_Play(this, CHAN_BODY, "engineer.turret_set");
}

void
TFCSentry::TFCSentry(void)
{
	m_eHead = spawn(NSSurfacePropEntity);
	SetModel("models/base.mdl");
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,20]);
}

void
CSEv_TFC_BuildSentry_(void)
{
	player pl = (player)self;

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs */
	if (pl.m_iAmmoCells < TFC_SENTRY_COST)
		return;

	pl.m_iAmmoCells -= TFC_SENTRY_COST;

	/* deploy */
	TFCSentry sentry = spawn(TFCSentry);
	sentry.Place(pl);
} 

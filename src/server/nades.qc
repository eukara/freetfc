void
TFCNade_ThrowCaltrop(player pl)
{
	vector vecNadeVelocity;

	static void TFCNade_ThrowHandGrenade_Touch(void) {

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowHandGrenade_Explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		NSEntity::Destroy();
	}

	for (int i = 0; i < 6; i++) {
	makevectors([0, random() * 360, 0]);
	vecNadeVelocity = v_forward * 50 + v_up * 150 + crandom() * v_right * 10 + crandom() * v_up * 10;

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/caltrop.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_TRIGGER);
	eNade.SetSize([-6,-6,-6], [6,6,6]);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([300, 300, 300]);

	eNade.touch = TFCNade_ThrowHandGrenade_Touch;
	}
}

void
TFCNade_ThrowHandGrenade(player pl)
{
	vector vecNadeVelocity;
	float flTimer;

	static void TFCNade_ThrowHandGrenade_Touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowHandGrenade_Explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		NSEntity::Destroy();
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	flTimer = max(0.0, pl. gren1.GetNextThinkTime() - time);

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/w_grenade.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([300, 300, 300]);
	eNade.SetAngles(vectoangles(eNade.GetVelocity()));

	eNade.touch = TFCNade_ThrowHandGrenade_Touch;
	eNade.ScheduleThink(TFCNade_ThrowHandGrenade_Explode, flTimer);
}

void
TFCNade_ThrowConcussion(player pl)
{
	vector vecNadeVelocity;
	float flTimer;

	static void TFCNade_ThrowConcussion_Touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowConcussion_Explode(void) {
		NSEntity::Destroy();
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	flTimer = max(0.0, pl.gren2.GetNextThinkTime() - time);

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/conc_grenade.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([0, 600, 0]);

	eNade.touch = TFCNade_ThrowConcussion_Touch;
	eNade.ScheduleThink(TFCNade_ThrowConcussion_Explode, flTimer);
}

void
TFCNade_ThrowNail(player pl)
{

	print("Throwing Nail grenade!\n");
}

void
TFCNade_ThrowMIRVBomblet(NSEntity bomb)
{
	vector vecNadeVelocity;

	static void TFCNade_ThrowMIRVBomblet_Touch(void) {

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowMIRVBomblet_Explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		NSEntity::Destroy();
	}

	player pl = (player)bomb.owner;

	makevectors([0, random() * 360, 0]);
	vecNadeVelocity = v_forward * 100 + v_up * 350 + crandom() * v_right * 10 + crandom() * v_up * 10;

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/bomblet.mdl");
	eNade.SetOrigin(bomb.origin + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_TRIGGER);
	eNade.SetSize([-6,-6,-6], [6,6,6]);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([300, 300, 300]);
	eNade.SetAngles(vectoangles(eNade.GetVelocity()));

	eNade.touch = TFCNade_ThrowMIRVBomblet_Touch;
	eNade.ScheduleThink(TFCNade_ThrowMIRVBomblet_Explode, 1.5f + random());
}

void
TFCNade_ThrowMIRV(player pl)
{
	vector vecNadeVelocity;
	float flTimer;

	static void TFCNade_ThrowMIRV_Touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowMIRV_Explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);

		for (int i = 0; i < 4; i++) {
			TFCNade_ThrowMIRVBomblet((NSEntity)self);
		}

		NSEntity::Destroy();
	}

	Weapons_MakeVectors(pl);

	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	flTimer = max(0.0, pl. gren2.GetNextThinkTime() - time);

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/mirv_grenade.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetSkin(1);
	eNade.ScheduleThink(TFCNade_ThrowMIRV_Explode, flTimer);
	eNade.touch = TFCNade_ThrowMIRV_Touch;
}

void
TFCNade_ThrowNapalm(player pl)
{

	print("Throwing Napalm grenade!\n");
}

void
TFCNade_ThrowHallucination(player pl)
{

	print("Throwing Hallucination grenade!\n");
}

void
TFCNade_ThrowEMP(player pl)
{
	vector vecNadeVelocity;
	float flTimer;

	static void TFCNade_ThrowEMP_Touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void TFCNade_ThrowEMP_Explode(void) {
		NSEntity::Destroy();
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	flTimer = max(0.0, pl.gren2.GetNextThinkTime() - time);

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/emp_grenade.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([0, 600, 0]);

	eNade.touch = TFCNade_ThrowEMP_Touch;
	eNade.ScheduleThink(TFCNade_ThrowEMP_Explode, flTimer);
}

void
TFCNade_ThrowSecondary(player pl)
{
	switch (pl.classtype) {
	case CLASS_SCOUT:
	case CLASS_MEDIC:
		TFCNade_ThrowConcussion(pl);
		break;
	case CLASS_SOLDIER:
		TFCNade_ThrowNail(pl);
		break;
	case CLASS_DEMO:
	case CLASS_HVYWEAPON:
		TFCNade_ThrowMIRV(pl);
		break;
	case CLASS_PYRO:
		TFCNade_ThrowNapalm(pl);
		break;
	case CLASS_SPY:
		TFCNade_ThrowHallucination(pl);
		break;
	case CLASS_ENGINEER:
		TFCNade_ThrowEMP(pl);
		break;
	case CLASS_SNIPER:
	default:
		break;
	}
}

void
TFCNade_SelfExplode(player pl)
{
	float dmg = 100;
	FX_Explosion(pl.origin);
	Damage_Radius(pl.origin, pl, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
	sound(pl, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
}
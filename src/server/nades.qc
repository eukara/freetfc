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
	vector vecNadeVelocity;
	float flTimer;

	static void TFCNade_ThrowNail_Touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (!vlen(self.velocity))
			self.avelocity = g_vec_null;
	}
	static void TFCNade_ThrowNail_Explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		NSEntity::Destroy();
	}
	static void TFCNade_ThrowNail_Shoot(entity source, vector euler_dir) {

		static void TFCNade_ThrowNail_Shoot_Touch(void) {
			if (trace_ent.iBleeds == 0) {
				DecalGroups_Place("Impact.BigShot", trace_endpos + (v_forward * -2));
				SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
			}
			if (trace_ent.takedamage == DAMAGE_YES) {
				Damage_Apply(trace_ent, self.owner.owner, 9, WEAPON_NAILGUN, DMG_BULLET);
			}
			remove(self);
		}

		makevectors(source.angles + euler_dir);
		entity p = spawn();
		setmodel(p, "models/nail.mdl");
		setorigin(p, source.origin + (v_forward * 8) + (v_up * 2));
		p.owner = source;
		p.movetype = MOVETYPE_FLYMISSILE;
		p.solid = SOLID_BBOX;
		p.gravity = 0.5f;
		p.velocity = (v_forward * 1000);
		p.angles = vectoangles(p.velocity);
		p.touch = TFCNade_ThrowNail_Shoot_Touch;
		p.think = Util_Destroy;
	}
	static void TFCNade_ThrowNail_Unload(void) {
		if (self.ammo_nails <= 0) {
			TFCNade_ThrowNail_Explode();
			return;
		}

		self.angles[1] += 15.0;
		TFCNade_ThrowNail_Shoot(self, [0, 0, 0]);
		TFCNade_ThrowNail_Shoot(self, [0, 60, 0]);
		TFCNade_ThrowNail_Shoot(self, [0, 120, 0]);
		TFCNade_ThrowNail_Shoot(self, [0, 180, 0]);
		TFCNade_ThrowNail_Shoot(self, [0, 240, 0]);
		TFCNade_ThrowNail_Shoot(self, [0, 300, 0]);
		self.ammo_nails -= 6;
		
		self.nextthink = time + 0.15f;
	}

	static void TFCNade_ThrowNail_Deploy(void) {
		self.solid = SOLID_BBOX;
		self.movetype = MOVETYPE_NONE;
		self.velocity = [0,0,0];
		setorigin(self, self.origin + [0,0, 32]);
		self.think = TFCNade_ThrowNail_Unload;
		self.nextthink = time + 1.0f;
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	flTimer = max(0.0, pl.gren2.GetNextThinkTime() - time);

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/ngrenade.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([0, 600, 0]);
	eNade.ammo_nails = 200;

	eNade.touch = TFCNade_ThrowNail_Touch;
	eNade.ScheduleThink(TFCNade_ThrowNail_Deploy, flTimer);
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
	eNade.SetModel("models/napalm.mdl");
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
TFCNade_ThrowHallucination(player pl)
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
	eNade.SetModel("models/spy_grenade.mdl");
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
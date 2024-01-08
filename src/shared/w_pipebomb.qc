/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

void
w_pipebomb_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_handgrenade.bounce");
	Sound_Precache("weapon_mp5.gl");
	precache_model("models/w_pipebomb.mdl");
	precache_model("models/p_pipebomb.mdl");
	precache_model("models/pipebomb.mdl");
#else
	precache_model("models/v_tfgl.mdl");
#endif
}

void
w_pipebomb_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mag_glauncher, pl.m_iAmmoRockets, __NULL__);
}

int
w_pipebomb_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	pl.mag_glauncher = bound(0, pl.mag_glauncher + 6, 6);
#endif
	return (1);
}

string
w_pipebomb_wmodel(void)
{
	return "models/p_glauncher.mdl";
}
string
w_pipebomb_pmodel(player pl)
{
	return "models/p_glauncher.mdl";
}

string
w_pipebomb_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_pipebomb_draw(player pl)
{
	Weapons_SetModel("models/v_tfgl.mdl");
	Weapons_ViewAnimation(pl, GLAUNCHER_PDRAW);
}

#ifdef SERVER
void w_pipebomb_explode(void)
{
	pointparticles(particleeffectnum("fx_explosion.main"), self.origin, [0,0,0], 1);

	/* dmg/radius taken from http://web.archive.org/web/20030323072941fw_/http://www.planetfortress.com/tfce/grenades/pipebomb.htm */
	Damage_Radius(self.origin, self.owner, 80, 128, TRUE, WEAPON_GLAUNCHER);
	Sound_Play(self, CHAN_VOICE, "fx.explosion");
	NSEntity::Destroy();
}
#endif

void
w_pipebomb_shootnade(player pl)
{
	vector vecNadeVelocity;
	NSEntity first_nade;
	int known_nades = 0i;
	float oldest_time = 0.0f;

	static void w_pipebomb_shootnade_touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.classname = "pipebomb";
	eNade.SetModel("models/pipebomb.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([300, 300, 300]);
	eNade.SetAngles(vectoangles(eNade.GetVelocity()));
	eNade.SetSkin(0);

	eNade.touch = w_pipebomb_shootnade_touch;
	
	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.gl");

#ifdef SERVER
	/* iterate through and mark the first nade we own */
	for (entity e = world; (e = find(e, ::classname, "pipebomb"));) {
		NSEntity pb = (NSEntity)e;

		if (pb.GetOwner() == pl) {
			if (pb.GetSpawnAge() > oldest_time) {
				first_nade = pb;
				oldest_time = pb.GetSpawnAge();
			}

			known_nades++;
		}
	}

	/* if we have more than 8, destroy the first one we placed */
	if (known_nades > 8) {
		first_nade.ScheduleThink(w_pipebomb_explode, 0.0f);
	}
#endif

	//eNade.traileffectnum = particleeffectnum("weapon_rpg.trail");
}

void
w_pipebomb_reload(player pl)
{
	w_baseshotgun_reload(player::mag_glauncher, player::m_iAmmoRockets, 6);
}

void
w_pipebomb_release(player pl)
{
	int s = w_baseshotgun_release(player::mag_glauncher, player::m_iAmmoRockets, 6);

	switch (s) {
	case SHOTGUN_IDLE:
		Weapons_ViewAnimation(pl, GLAUNCHER_PIDLE);
		pl.w_idle_next = 5.0f;
		break;
	case SHOTGUN_BUSY:
		break;
	case SHOTGUN_START_RELOAD:
		Weapons_ViewAnimation(pl, GLAUNCHER_PRELOAD1);
		break;
	case SHOTGUN_RELOAD:
		break;
	case SHOTGUN_END_RELOAD:
		Weapons_ViewAnimation(pl, GLAUNCHER_PRELOAD2);
		break;
	}
}

void
w_pipebomb_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_PIPEBOMB, player::mag_glauncher, w_pipebomb_shootnade);

	switch (s) {
	case AUTO_FIRE_FAILED:
		w_pipebomb_release(pl);
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, GLAUNCHER_PFIRE);
		Weapons_ViewPunchAngle(pl, [-1,0,0]);

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, TFCANIM_CR_SHOOTSHOTGUN, 0.45f);
		else
			Animation_PlayerTop(pl, TFCANIM_SHOOTSHOTGUN, 0.45f);

		pl.w_attack_next = 0.6f;
		break;
	case AUTO_EMPTY:
		Weapons_ViewAnimation(pl, GLAUNCHER_PIDLE);
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 0.6f;
}

void
w_pipebomb_secondary(player pl)
{
	float pb_timer = 0.0f;

	if (pl.w_attack_next > 0)
		return;

#ifdef SERVER
	for (entity e = world; (e = find(e, ::classname, "pipebomb"));) {
		NSEntity pb = (NSEntity)e;

		if (pb.GetOwner() == pl) {
			pb.ScheduleThink(w_pipebomb_explode, pb_timer);
			pb_timer += 0.1f;
		}
	}
#endif

	pl.w_attack_next = 0.5f;
}

void
w_pipebomb_postdraw(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	Cross_DrawSub(g_cross_spr, [24,24], [24/128,48/128], [0.1875, 0.1875]);

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[120/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_pipebomb_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMSHOTGUN : TFCANIM_AIMSHOTGUN;
}

void
w_pipebomb_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud2_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud1_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_pipebomb =
{
	.name		= "pipebomb",
	.id		= ITEM_PIPEBOMB,
	.slot		= 4,
	.slot_pos	= 1,
	.weight		= WEIGHT_PIPEBOMB,
	.draw		= w_pipebomb_draw,
	.holster	= __NULL__,
	.primary	= w_pipebomb_primary,
	.secondary	= w_pipebomb_secondary,
	.reload		= w_pipebomb_reload,
	.release	= w_pipebomb_release,
	.postdraw	= w_pipebomb_postdraw,
	.precache	= w_pipebomb_precache,
	.pickup		= w_pipebomb_pickup,
	.updateammo	= w_pipebomb_updateammo,
	.wmodel		= w_pipebomb_wmodel,
	.pmodel		= w_pipebomb_pmodel,
	.deathmsg	= w_pipebomb_deathmsg,
	.aimanim	= w_pipebomb_aimanim,
	.hudpic		= w_pipebomb_hudpic,
	.isempty	= w_asscan_isempty
};

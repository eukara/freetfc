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

typedef enum
{
	GLAUNCHER_GIDLE,
	GLAUNCHER_PIDLE,
	GLAUNCHER_GFIRE,
	GLAUNCHER_PFIRE,
	GLAUNCHER_GRELOAD1,
	GLAUNCHER_GRELOAD2,
	GLAUNCHER_PRELOAD1,
	GLAUNCHER_PRELOAD2,
	GLAUNCHER_GDRAW,
	GLAUNCHER_PDRAW,
	GLAUNCHER_GHOLSTER,
	GLAUNCHER_PHOLSTER
} w_glauncher_anims_t;

void
w_glauncher_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_handgrenade.bounce");
	Sound_Precache("weapon_mp5.gl");
	precache_model("models/w_glauncher.mdl");
	precache_model("models/p_glauncher.mdl");
	precache_model("models/pipebomb.mdl");
#else
	precache_model("models/v_tfgl.mdl");
#endif
}

void
w_glauncher_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mag_glauncher, pl.m_iAmmoRockets, __NULL__);
}

int
w_glauncher_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	pl.mag_glauncher = bound(0, pl.mag_glauncher + 6, 6);
#endif
	return (1);
}

string
w_glauncher_wmodel(void)
{
	return "models/w_glauncher.mdl";
}
string
w_glauncher_pmodel(player pl)
{
	return "models/p_glauncher.mdl";
}

string
w_glauncher_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_glauncher_draw(player pl)
{
	Weapons_SetModel("models/v_tfgl.mdl");
	Weapons_ViewAnimation(pl, GLAUNCHER_GDRAW);
}

void
w_glauncher_shootnade(player pl)
{
	vector vecNadeVelocity;

	static void w_glauncher_shootnade_touch(void) {
		Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		if (vlen(self.velocity))
			self.avelocity = g_vec_null;
	}

	static void w_glauncher_explode(void) {
		float dmg = 100;
		FX_Explosion(self.origin);
		//Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_GLAUNCHER);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		NSEntity::Destroy();
	}

	Weapons_MakeVectors(pl);
	vecNadeVelocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;

	NSRenderableEntity eNade = spawn(NSRenderableEntity);
	eNade.SetModel("models/pipebomb.mdl");
	eNade.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	eNade.SetOwner(pl);
	eNade.SetMovetype(MOVETYPE_BOUNCE);
	eNade.SetSolid(SOLID_BBOX);
	eNade.SetGravity(1.0f);
	eNade.SetVelocity(vecNadeVelocity);
	eNade.SetAngularVelocity([300, 300, 300]);
	eNade.SetAngles(vectoangles(eNade.GetVelocity()));
	eNade.SetSkin(1);

	eNade.touch = w_glauncher_shootnade_touch;
	eNade.think = w_glauncher_explode;
	eNade.nextthink = time + 2.5f;
	
	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.gl");

	//eNade.traileffectnum = particleeffectnum("weapon_rpg.trail");
}

void
w_glauncher_reload(player pl)
{
	w_baseshotgun_reload(player::mag_glauncher, player::m_iAmmoRockets, 6);
}

void
w_glauncher_release(player pl)
{
	int s = w_baseshotgun_release(player::mag_glauncher, player::m_iAmmoRockets, 6);

	switch (s) {
	case SHOTGUN_IDLE:
		Weapons_ViewAnimation(pl, GLAUNCHER_GIDLE);
		pl.w_idle_next = 5.0f;
		break;
	case SHOTGUN_BUSY:
		break;
	case SHOTGUN_START_RELOAD:
		Weapons_ViewAnimation(pl, GLAUNCHER_GRELOAD1);
		break;
	case SHOTGUN_RELOAD:
		break;
	case SHOTGUN_END_RELOAD:
		Weapons_ViewAnimation(pl, GLAUNCHER_GRELOAD2);
		break;
	}
}

void
w_glauncher_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_GLAUNCHER, player::mag_glauncher, w_glauncher_shootnade);

	switch (s) {
	case AUTO_FIRE_FAILED:
		w_glauncher_release(pl);
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, GLAUNCHER_GFIRE);
		Weapons_ViewPunchAngle(pl, [-1,0,0]);
		pl.w_attack_next = 0.6f;
		break;
	case AUTO_EMPTY:
		Weapons_ViewAnimation(pl, GLAUNCHER_GIDLE);
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 0.6f;
}

void
w_glauncher_postdraw(player pl)
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
w_glauncher_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_glauncher_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud02.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud01.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_glauncher =
{
	.name		= "glauncher",
	.id		= ITEM_GLAUNCHER,
	.slot		= 3,
	.slot_pos	= 1,
	.draw		= w_glauncher_draw,
	.holster	= __NULL__,
	.primary	= w_glauncher_primary,
	.secondary	= __NULL__,
	.reload		= w_glauncher_reload,
	.release	= w_glauncher_release,
	.postdraw	= w_glauncher_postdraw,
	.precache	= w_glauncher_precache,
	.pickup		= w_glauncher_pickup,
	.updateammo	= w_glauncher_updateammo,
	.wmodel		= w_glauncher_wmodel,
	.pmodel		= w_glauncher_pmodel,
	.deathmsg	= w_glauncher_deathmsg,
	.aimanim	= w_glauncher_aimanim,
	.hudpic		= w_glauncher_hudpic,
	.isempty	= w_asscan_isempty
};

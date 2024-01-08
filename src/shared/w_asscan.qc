/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 * Copyright (c) 2019-2020 Gethyn ThomasQuail <xylemon@posteo.net>
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

/* Animations */
enum
{
	ASSCAN_IDLE1,
	ASSCAN_IDLE2,
	ASSCAN_SPINUP,
	ASSCAN_SPINDOWN,
	ASSCAN_FIRE,
	ASSCAN_DRAW,
	ASSCAN_HOLSTER
};

#ifdef CLIENT
void w_asscan_ejectshell(void)
{
	static void w_asscan_ejectshell_death(void) {
		remove(self);
	}
	static void w_asscan_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_asscan_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_asscan_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_up * -15));
}
#endif

void
w_asscan_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_asscan.fire");
	Sound_Precache("weapon_asscan.reload");
	Sound_Precache("weapon_asscan.spindown");
	Sound_Precache("weapon_asscan.spinup");
	precache_model("models/w_tfac.mdl");
	precache_model("models/p_tfac.mdl");
#endif

#ifdef CLIENT
	precache_model("models/v_tfac.mdl");
	Sound_Precache("modelevent_shell.land");
#endif
}

int
w_asscan_pickup(player pl, int new, int startammo)
{
	return (1);
}

void
w_asscan_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.m_iAmmoShells, -1);
}

string
w_asscan_wmodel(void)
{
	return "models/w_tfac.mdl";
}

string
w_asscan_pmodel(player pl)
{
	return "models/p_mini2.mdl";
}

string
w_asscan_deathmsg(void)
{
	return "%s was rolled over by %s' Chaingun.";
}

void
w_asscan_draw(player pl)
{
	pl.mode_tempstate = 0;
	Weapons_SetModel("models/v_tfac.mdl");
	Weapons_ViewAnimation(pl, ASSCAN_DRAW);
}

void
w_asscan_holster(player pl)
{
	Weapons_ViewAnimation(pl, ASSCAN_HOLSTER);
}

void
w_asscan_release(player pl)
{
	/* end firing */
	if (pl.mode_tempstate == 1) {
		pl.mode_tempstate = 0;
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_asscan.spindown");
		Weapons_ViewAnimation(pl, ASSCAN_SPINDOWN);
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 4.0f;
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	int r = (float)input_sequence % 2;
	if (r) {
		Weapons_ViewAnimation(pl, ASSCAN_IDLE1);
	} else {
		Weapons_ViewAnimation(pl, ASSCAN_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_asscan_primary(player pl)
{
	/* rate check */
	if (pl.w_attack_next > 0.0)
		return;

	/* ammo check */
	if (pl.m_iAmmoShells <= 0) {
		w_asscan_release(pl);
		return;
	}

	/* spin up first */
	if (pl.mode_tempstate == 0) {
		pl.mode_tempstate = 1;
		Weapons_ViewAnimation(pl, ASSCAN_SPINUP);
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_asscan.spinup");
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	/* from now on we're just going rambo */
	pl.m_iAmmoShells--;

	Weapons_ViewAnimation(pl, ASSCAN_FIRE);
	Weapons_ViewPunchAngle(pl, [random(-2, 2),0,0]);
	Weapons_Sound(pl, CHAN_WEAPON, "weapon_asscan.fire");

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, TFCANIM_CR_SHOOTASSCAN, 0.1f);
	else
		Animation_PlayerTop(pl, TFCANIM_SHOOTASSCAN, 0.1f);

#ifdef CLIENT
	View_AddEvent(w_asscan_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_WEIRD);
#else
	TraceAttack_FireBullets(1, Weapons_GetCameraPos(pl), 8, [0.15,0.15], WEAPON_ASSCAN);
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 0.0f;
}

void
w_asscan_hud(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	Cross_DrawSub(g_cross_spr, [24,24], [48/128,24/128], [0.1875, 0.1875]);

	HUD_DrawAmmo2();

	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_asscan_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMASSCAN : TFCANIM_AIMASSCAN;
}

void
w_asscan_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.m_iAmmoShells == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.m_iAmmoShells, 200, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud4_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud3_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_asscan_isempty(player pl)
{
	if (pl.m_iAmmoShells <= 0)
		return 1;

	return 0;
}

weapontype_t
w_asscan_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_asscan =
{
	.name		= "asscan",
	.id			= ITEM_ASSCAN,
	.slot		= 3,
	.slot_pos	= 3,
	.weight		= WEIGHT_ASSCAN,
	.draw		= w_asscan_draw,
	.holster	= w_asscan_holster,
	.primary	= w_asscan_primary,
	.secondary	= w_asscan_release,
	.reload		= __NULL__,
	.release	= w_asscan_release,
	.postdraw	= w_asscan_hud,
	.precache	= w_asscan_precache,
	.pickup		= w_asscan_pickup,
	.updateammo	= w_asscan_updateammo,
	.wmodel		= w_asscan_wmodel,
	.pmodel		= w_asscan_pmodel,
	.deathmsg	= w_asscan_deathmsg,
	.aimanim	= w_asscan_aimanim,
	.isempty	= w_asscan_isempty,
	.type		= w_asscan_type,
	.hudpic		= w_asscan_hudpic
};

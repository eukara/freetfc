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
#endif
	precache_model("models/v_tfac.mdl");
	precache_model("models/w_tfac.mdl");
	precache_model("models/p_tfac.mdl");
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
	return "models/p_tfac.mdl";
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
	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.m_iAmmoShells > 0) {
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	/* end firing */
	if (pl.mode_tempstate == 1) {
		pl.mode_tempstate = 0;
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_asscan.spindown");
#endif
		Weapons_ViewAnimation(pl, ASSCAN_SPINDOWN);
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

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
	if (pl.w_attack_next > 0.0)
		return;

	/* ammo check */
	if (pl.m_iAmmoShells <= 0)
		return;

	/* spin up first */
	if (pl.mode_tempstate == 0) {
		pl.mode_tempstate = 1;
		Weapons_ViewAnimation(pl, ASSCAN_SPINUP);
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_asscan.spinup");
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}
	pl.m_iAmmoShells--;

	Weapons_ViewAnimation(pl, ASSCAN_FIRE);
	Weapons_ViewPunchAngle(pl, [random(-2, 2),0,0]);

#ifdef CLIENT
	View_AddEvent(w_asscan_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, Weapons_GetCameraPos(pl), 8, [0.15,0.15], WEAPON_ASSCAN);
	Sound_Play(pl, CHAN_WEAPON, "weapon_asscan.fire");
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

	Cross_DrawSub(g_cross_spr, [24,24], [0.1875,0], [0.1875, 0.1875]);

	HUD_DrawAmmo2();


	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_asscan_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
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
			"sprites/tfchud04.spr_0.tga",
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
			"sprites/tfchud03.spr_0.tga",
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

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

#define PMOVE_AIRSTEPHEIGHT 0
#define PMOVE_STEPHEIGHT 18
#define PMOVE_FRICTION 4
#define PMOVE_EDGEFRICTION 1
#define PMOVE_STOPSPEED 100
#define PMOVE_GRAVITY 800
#define PMOVE_AIRACCELERATE 10
#define PMOVE_WATERACCELERATE 10
#define PMOVE_ACCELERATE 10
#define PMOVE_MAXSPEED 320
#define PMOVE_STEP_WALKSPEED 135
#define PMOVE_STEP_RUNSPEED 220
#define PHY_VIEWPOS [0,0,28]
#define PHY_VIEWPOS_CROUCHED [0,0,12]

void
player::Physics_Jump(void)
{
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		if (flags & FL_ONGROUND) {
#ifdef SERVER
			Sound_Play(this, CHAN_VOICE, "player_tfc.jump");
#endif
			velocity[2] += 265;
		}
	}
}

float
player::Physics_MaxSpeed(void)
{
	float desiredspeed = 300.0f;

	/* values courtesy of https://wiki.teamfortress.com/ */
	switch (classtype) {
	case CLASS_SCOUT:
		desiredspeed = 400.0f;
		break;
	case CLASS_SNIPER:
		desiredspeed = 300.0f;
		break;
	case CLASS_SOLDIER:
		desiredspeed = 240.0f;
		break;
	case CLASS_DEMO:
		desiredspeed = 280.0f;
		break;
	case CLASS_MEDIC:
		desiredspeed = 320.0f;
		break;
	case CLASS_HVYWEAPON:
		desiredspeed = 228.0f;
		break;
	case CLASS_PYRO:
		desiredspeed = 300.0f;
		break;
	case CLASS_SPY:
		desiredspeed = 300.0f;
		break;
	case CLASS_ENGINEER:
		desiredspeed = 300.0f;
		break;
	default:
		desiredspeed = 300.0f;
	}

	if (GetFlags() & FL_CROUCHING)
		desiredspeed /= 3;

	return desiredspeed;
}
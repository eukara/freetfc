/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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
	CLASS_SCOUT = 1,
	CLASS_SNIPER,
	CLASS_SOLDIER,
	CLASS_DEMO,
	CLASS_MEDIC,
	CLASS_HVYWEAPON,
	CLASS_PYRO,
	CLASS_SPY,
	CLASS_ENGINEER
} classtype_e;

string g_teammodels[] = {
	"",
	"models/player/scout/scout.mdl",
	"models/player/sniper/sniper.mdl",
	"models/player/soldier/soldier.mdl",
	"models/player/demo/demo.mdl",
	"models/player/medic/medic.mdl",
	"models/player/hvyweapon/hvyweapon.mdl",
	"models/player/pyro/pyro.mdl",
	"models/player/spy/spy.mdl",
	"models/player/engineer/engineer.mdl"
};

string g_teammodels_hd[] = {
	"",
	"models/player/scout/scout2.mdl",
	"models/player/sniper/sniper2.mdl",
	"models/player/soldier/soldier2.mdl",
	"models/player/demo/demo2.mdl",
	"models/player/medic/medic2.mdl",
	"models/player/hvyweapon/hvyweapon2.mdl",
	"models/player/pyro/pyro2.mdl",
	"models/player/spy/spy2.mdl",
	"models/player/engineer/engineer2.mdl"
};

/* are we using a later build of TF? */
bool
TFC_IsLaterBuild(void)
{
	if (whichpack(g_teammodels_hd[1]))
		return true;

	return false;
}

/* stuff */
string
TFC_GetModelForClasstype(classtype_e type)
{
	if (TFC_IsLaterBuild() == true)
		if (autocvar(tfc_newmodels, 0) == 1)
			return g_teammodels[type];	/* on later versions, the old names are the HD ones */
		else
			return g_teammodels_hd[type];

	return g_teammodels[type];
}
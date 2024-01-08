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

#include "gamerules.h"
#include "../../../valve/src/server/items.h"
#include "../../../valve/src/server/flashlight.h"
#include "sentry.h"

var bool g_tfcHasBlueTeam = false;
var bool g_tfcHasRedTeam = false;
var bool g_tfcHasYellowTeam = false;
var bool g_tfcHasGreenTeam = false;

/* returns if a player already has a teleporter/exit built */
bool
TFC_ExistsForPlayer(entity pl, string cname)
{
	/* loop through all exits */
	for (entity e = world; (e = find(e, ::classname, cname));) {
		/* if it's not places by our owner... */
		if (e.real_owner != pl)
			continue;

		return true;
	}

	return false;
}

void
TFC_DetonateTypeForPlayer(entity pl, string cname)
{
	/* loop through all exits */
	for (entity e = world; (e = find(e, ::classname, cname));) {
		/* if it's not places by our owner... */
		if (e.real_owner != pl)
			continue;

		NSSurfacePropEntity targ = (NSSurfacePropEntity)e;
		targ.Destroy();
	}
}

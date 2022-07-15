/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED info_areadef (0 0 0.8) (-16 -16 -36) (16 16 36)

TEAM FORTRESS (1996) ENTITY

Describes an area's bounds and description/name.

-------- KEYS --------
"targetname" : Name
"areaname"   : Name of the specified area
"mins"       : Mins of the area's bounding box
"maxs"       : Maxs of the area's bounding box
*/

class
info_areadef:NSPointTrigger
{
	string m_strDescription;
	vector m_vecMins;
	vector m_vecMaxs;

	void(void) info_areadef;

	virtual void(void) Respawn;
	virtual void(string,string) SpawnKey;
	virtual void(entity) Touch;
};

void
info_areadef::Touch(entity eToucher)
{
	if (!(eToucher.flags & FL_CLIENT))
		return;

	forceinfokey(eToucher, "*areadef", strtoupper(m_strDescription));
}

void
info_areadef::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "areaname":
		m_strDescription = strValue;
		break;
	case "mins":
		m_vecMins = stov(strValue);
		break;
	case "maxs":
		m_vecMaxs = stov(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
info_areadef::Respawn(void)
{
	/* set up our volume */
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetOrigin(GetSpawnOrigin());
	SetSize(m_vecMins, m_vecMaxs);
}

void
info_areadef::info_areadef(void)
{
	forceinfokey(world, "areadefs", "1");
}
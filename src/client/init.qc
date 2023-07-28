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

/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("build");
	registercommand("dismantle");
	registercommand("+gren1");
	registercommand("-gren1");
	registercommand("+gren2");
	registercommand("-gren2");
	registercommand("chooseclass");
	registercommand("changeclass");
	registercommand("chooseteam");
	registercommand("changeteam");
	Obituary_Init();
}

void VGUI_ChooseTeam(void);
void
ClientGame_InitDone(void)
{
	VGUI_ChooseTeam();
}

void
ClientGame_RendererRestart(string rstr)
{
	Obituary_Precache();
	Damage_Precache();

	FX_Blood_Init();

	/* HUD selection icons */
	g_dmsg_spr = spriteframe("sprites/tfc_dmsg.spr", 0, 0.0f);
	g_tfchud1_spr = spriteframe("sprites/tfchud01.spr", 0, 0.0f);
	g_tfchud2_spr = spriteframe("sprites/tfchud02.spr", 0, 0.0f);
	g_tfchud3_spr = spriteframe("sprites/tfchud03.spr", 0, 0.0f);
	g_tfchud4_spr = spriteframe("sprites/tfchud04.spr", 0, 0.0f);
	g_tfchud5_spr = spriteframe("sprites/tfchud05.spr", 0, 0.0f);
	g_tfchud6_spr = spriteframe("sprites/tfchud06.spr", 0, 0.0f);
	g_tfchud7_spr = spriteframe("sprites/tfchud07.spr", 0, 0.0f);

	/* there's also muzzleflash.spr, but that's just MUZZLE_SMALL again */
	MUZZLE_RIFLE = (int)getmodelindex("sprites/muzzleflash1.spr");
	MUZZLE_SMALL = (int)getmodelindex("sprites/muzzleflash2.spr");
	MUZZLE_WEIRD = (int)getmodelindex("sprites/muzzleflash3.spr");
	MUZZLE_ROUND = (int)getmodelindex("sprites/muzzleflash.spr");
}

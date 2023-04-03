/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#define TFC_HUD_TEAM_COLOR_RED [1, 0.15, 0.15]
#define TFC_HUD_TEAM_COLOR_BLUE [0.15, 0.15, 1.0]
#define TFC_HUD_TEAM_COLOR_GREEN [0.15, 1.0, 0.15]
#define TFC_HUD_TEAM_COLOR_YELLOW [1.0, 1.0, 0.15]

void
ClientGame_PreDraw(void) 
{
	/* color the HUD according to the team we're on */
	switch (getplayerkeyfloat(player_localnum, "*team")) {
	case 1:
		g_hud_color = TFC_HUD_TEAM_COLOR_BLUE;
		break;
	case 2:
		g_hud_color = TFC_HUD_TEAM_COLOR_RED;
		break;
	case 3:
		g_hud_color = TFC_HUD_TEAM_COLOR_GREEN;
		break;
	case 4:
		g_hud_color = TFC_HUD_TEAM_COLOR_YELLOW;
		break;
	}
}

void
ClientGame_PostDraw(void)
{
	player pl = (player)pSeat->m_ePlayer;

	if (serverkeyfloat("areadefs") == 1) {
		string strArea = getplayerkeyvalue(player_localnum, "*areadef");
		float flOffset = Font_StringWidth(strArea, TRUE, FONT_20) / 2;
		Font_DrawText_A([g_hudmins[0] + 16, g_hudmins[1] + g_hudres[1] - 70], strArea, 0.75, FONT_20);
	}

	if (pl.g_items & ITEM_GOALITEM) {
		vector vecGoalItemPos;
		int iGoalItemTeam = (int)getplayerkeyfloat(player_localnum, "*goalitem_t");

		vecGoalItemPos = g_hudmins + [16, (g_hudres[1] / 2) - 32];

		if (iGoalItemTeam == 1) { /* blue */
			drawsubpic(
				vecGoalItemPos,
				[64,64],
				g_tfchud1_spr,
				[192/256,0/256],
				[64/256, 64/256],
				TFC_HUD_TEAM_COLOR_BLUE,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		} else if (iGoalItemTeam == 2) { /* red */
			drawsubpic(
				vecGoalItemPos,
				[64,64],
				g_tfchud1_spr,
				[192/256, 62/256],
				[64/256, 64/256],
				TFC_HUD_TEAM_COLOR_RED,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		} else if (iGoalItemTeam == 3) { /* green */
			drawsubpic(
				vecGoalItemPos,
				[64,64],
				g_tfchud6_spr,
				[192/256, 62/256],
				[64/256, 136/256],
				TFC_HUD_TEAM_COLOR_GREEN,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		} else { /* yellow */
			drawsubpic(
				vecGoalItemPos,
				[64,64],
				g_tfchud1_spr,
				[0/256,136/256],
				[64/256, 64/256],
				TFC_HUD_TEAM_COLOR_YELLOW,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
	}
}

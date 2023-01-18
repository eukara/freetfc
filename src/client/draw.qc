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

void
ClientGame_PreDraw(void) 
{
	/* color the HUD according to the team we're on */
	switch (getplayerkeyfloat(player_localnum, "*team")) {
	case 1:
		g_hud_color = [0.15, 0.15, 1.0];
		break;
	case 2:
		g_hud_color = [1, 0.15, 0.15];
		break;
	case 3:
		g_hud_color = [1.0, 1.0, 0.15];
		break;
	case 4:
		g_hud_color = [0.15, 1.0, 0.15];
		break;
	}
}

void
ClientGame_PostDraw(void)
{
	if (serverkeyfloat("areadefs") == 1)
		Font_DrawText([16,16], getplayerkeyvalue(player_localnum, "*areadef"), FONT_CON);
}

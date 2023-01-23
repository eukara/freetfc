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

void VGUI_ChooseClass(void);

int
ClientGame_ConsoleCommand(void)
{
	switch(argv(0)) {
	case "build":
		sendevent("TFCBuild", "i", stoi(argv(1)));
		break;
	case "dismantle":
		sendevent("TFCDismantle", "i", stoi(argv(1)));
		break;
	case "chooseclass":
	case "changeclass":
		VGUI_ChooseClass();
		break;
	case "chooseteam":
	case "changeteam":
		VGUI_ChooseTeam();
		break;
	default:
		return (0);
	}
	return (1);
}

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

int
ClientGame_ConsoleCommand(void)
{
	switch(argv(0)) {
	case "build":
		int type = stoi(argv(1));
		
		switch (type) {
		case 1:
			sendevent("TFC_BuildDispenser", "");
			break;
		case 2:
			sendevent("TFC_BuildSentry", "");
			break;
		case 4:
			sendevent("TFC_BuildTele", "");
			break;
		case 5:
			sendevent("TFC_BuildTeleExit", "");
			break;
		}
		break;
	default:
		return (0);
	}
	return (1);
}

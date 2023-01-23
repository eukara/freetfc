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

static CUIWindow winChooseTeam;

void
VGUI_ChooseTeam_Blue(void)
{
	localcmd("changeclass\n");
	sendevent("TeamJoin", "f", 1);
	winChooseTeam.Hide();
}

void
VGUI_ChooseTeam_Red(void)
{
	localcmd("changeclass\n");
	sendevent("TeamJoin", "f", 2);
	winChooseTeam.Hide();
}

void
VGUI_ChooseTeam_Green(void)
{
	localcmd("changeclass\n");
	sendevent("TeamJoin", "f", 3);
	winChooseTeam.Hide();
}

void
VGUI_ChooseTeam_Yellow(void)
{
	localcmd("changeclass\n");
	sendevent("TeamJoin", "f", 4);
	winChooseTeam.Hide();
}

void 
VGUI_GoSpectator(void)
{
	//VGUI_TeamJoin(0);
	sendevent("TeamJoin", "f", 0);
	winChooseTeam.Hide();
}

void
VGUI_ChooseTeam(void)
{
	static int initialized;
	static CUIButton btnGoSpectator;

	if (!initialized) {
		vector btnpos = [16,48];

		initialized = TRUE;
		winChooseTeam = spawn(CUIWindow);
		winChooseTeam.SetTitle("Choose Team");
		winChooseTeam.SetSize('420 320');

		for (int t = 1; t <= serverkeyfloat("teams"); t++) {
			CUIButton btnForTeam;
			string team_name = serverkey(sprintf("team_%i", t));

			btnForTeam = spawn(CUIButton);
			btnForTeam.SetTitle(team_name);
			btnForTeam.SetPos(btnpos);

			switch (team_name) {
			case "Blue":
				btnForTeam.SetFunc(VGUI_ChooseTeam_Blue);
				break;
			case "Red":
				btnForTeam.SetFunc(VGUI_ChooseTeam_Red);
				break;
			case "Green":
				btnForTeam.SetFunc(VGUI_ChooseTeam_Green);
				break;
			case "Yellow":
				btnForTeam.SetFunc(VGUI_ChooseTeam_Yellow);
				break;
			}

			winChooseTeam.Add(btnForTeam);
			btnpos[1] += 30;
		}


		btnGoSpectator = spawn(CUIButton);
		btnGoSpectator.SetTitle("Spectator");
		btnGoSpectator.SetPos('8 252');
		btnGoSpectator.SetFunc(VGUI_GoSpectator);

		g_uiDesktop.Add(winChooseTeam);
		winChooseTeam.Add(btnGoSpectator);
	}

	winChooseTeam.Show();
	winChooseTeam.SetPos((video_res / 2) - (winChooseTeam.GetSize() / 2));
}

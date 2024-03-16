/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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
	TFDFL_CIVILIANONLY = -1,
	TFDFL_NONE = 0,
	TFDFL_NOSCOUNT = 1,
	TFDFL_NOSNIPER = 2,
	TFDFL_NOSOLDIER = 4,
	TFDFL_NODEMOMAN = 8,
	TFDFL_NOMEDIC = 16,
	TFDFL_NOHEAVY = 32,
	TFDFL_NOPYRO = 64,
	TFDFL_NORANDOM = 128,
	TFDFL_NOSPY = 256,
	TFDFL_NOENGINEER = 512,
} tfdetectTeamFlags_t;

/*QUAKED info_tfdetect (0 0 0.8) (-16 -16 -16) (16 16 16)
# OVERVIEW

# KEYS
- "broadcast" : ???
- "number_of_teams" : Number of teams.
- "team1_name" : Name of team blue.
- "team2_name" : Name of team red.
- "team3_name" : Name of team yellow.
- "team4_name" : Name of team green.
- "impulse" : Game settings field.
- "message" : commands to insert into the server console.
- "maxammo_shells" : Blue team flags bitfield.
- "maxammo_nails" : Red team flags bitfield.
- "maxammo_rockets" : Yellow team flags bitfield.
- "maxammo_cells" : Green team flags bitfield.
- "ammo_medikit" : Blue team max player count.
- "ammo_detpack" : Red team max player count.
- "maxammo_medikit" : Yellow team max player count.
- "maxammo_detpack" : Green team max player count.
- "team1_allies" : Blue team ally bitfield.
- "team2_allies" : Red team ally bitfield.
- "team3_allies" : Yellow team ally bitfield.
- "team4_allies" : Green team ally bitfield.

# NOTES


# TRIVIA
This entity was introduced in Team Fortress (1996).
*/
class
info_tfdetect:NSPointTrigger
{
public:
	void info_tfdetect(void);

	virtual void SpawnKey(string, string);
	virtual void Respawn(void);

	nonvirtual void Setup(void);

private:
	string m_strTeam1Name;
	string m_strTeam2Name;
	string m_strTeam3Name;
	string m_strTeam4Name;
	string m_strLocalCommand;

	tfdetectTeamFlags_t m_bfTeam1Flags;
	tfdetectTeamFlags_t m_bfTeam2Flags;
	tfdetectTeamFlags_t m_bfTeam3Flags;
	tfdetectTeamFlags_t m_bfTeam4Flags;
};

void
info_tfdetect::info_tfdetect(void)
{
	m_strTeam1Name = "Blue";
	m_strTeam2Name = "Red";
	m_strTeam3Name = "Yellow";
	m_strTeam4Name = "Green";
	m_strLocalCommand = "";
	m_bfTeam1Flags = TFDFL_NONE;
	m_bfTeam2Flags = TFDFL_NONE;
	m_bfTeam3Flags = TFDFL_NONE;
	m_bfTeam4Flags = TFDFL_NONE;
}

void
info_tfdetect::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "team1_name":
		m_strTeam1Name = ReadString(setValue);
		break;
	case "team2_name":
		m_strTeam2Name = ReadString(setValue);
		break;
	case "team3_name":
		m_strTeam3Name = ReadString(setValue);
		break;
	case "team4_name":
		m_strTeam4Name = ReadString(setValue);
		break;
	case "message":
		m_strLocalCommand = ReadString(setValue);
		break;
	case "maxammo_shells":
		m_bfTeam1Flags = ReadFloat(setValue);
		break;
	case "maxammo_nails":
		m_bfTeam2Flags = ReadFloat(setValue);
		break;
	case "maxammo_rockets":
		m_bfTeam3Flags = ReadFloat(setValue);
		break;
	case "maxammo_cells":
		m_bfTeam4Flags = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
info_tfdetect::Respawn(void)
{

}

void
info_tfdetect::Setup(void)
{
	int team_count = 0i;
	entity e = __NULL__;
	info_tfdetect globalTFD = (info_tfdetect)find(world, ::classname, "info_tfdetect");

	/* populate the serverinfo field with the teams we have on the map */
	e = find(world, ::classname, "info_teamspawn_blue");
	if (e) {
		team_count += 1;
		forceinfokey(world, sprintf("team_%i", team_count), "Blue");
		forceinfokey(world, sprintf("teamscore_%i", team_count), "0");
		g_tfcHasBlueTeam = true;
	}

	e = find(world, ::classname, "info_teamspawn_red");
	if (e) {
		team_count += 1;
		forceinfokey(world, sprintf("team_%i", team_count), "Red");
		forceinfokey(world, sprintf("teamscore_%i", team_count), "0");
		g_tfcHasRedTeam = true;
	}

	e = find(world, ::classname, "info_teamspawn_green");
	if (e) {
		team_count += 1;
		forceinfokey(world, sprintf("team_%i", team_count), "Green");
		forceinfokey(world, sprintf("teamscore_%i", team_count), "0");
		g_tfcHasGreenTeam = true;
	}

	e = find(world, ::classname, "info_teamspawn_yellow");
	if (e) {
		team_count += 1;
		forceinfokey(world, sprintf("team_%i", team_count), "Yellow");
		forceinfokey(world, sprintf("teamscore_%i", team_count), "0");
		g_tfcHasYellowTeam = true;
	}
	forceinfokey(world, "teams", itos(team_count));

	if (!globalTFD) {
		NSLog("No info_tfdetect in level.");
		forceinfokey(world, "teamflags_1", "0");
		forceinfokey(world, "teamflags_2", "0");
		forceinfokey(world, "teamflags_3", "0");
		forceinfokey(world, "teamflags_4", "0");
		return;
	}

	forceinfokey(world, "team_1", globalTFD.m_strTeam1Name);
	forceinfokey(world, "team_2", globalTFD.m_strTeam2Name);
	forceinfokey(world, "team_3", globalTFD.m_strTeam3Name);
	forceinfokey(world, "team_4", globalTFD.m_strTeam4Name);

	forceinfokey(world, "teamflags_1", ftos(globalTFD.m_bfTeam1Flags));
	forceinfokey(world, "teamflags_2", ftos(globalTFD.m_bfTeam1Flags));
	forceinfokey(world, "teamflags_3", ftos(globalTFD.m_bfTeam1Flags));
	forceinfokey(world, "teamflags_4", ftos(globalTFD.m_bfTeam1Flags));

	/* the evil localcmd feature of this entity. */
	if (m_strLocalCommand) {
		localcmd(m_strLocalCommand);
		localcmd("\n");
	}
}
class
TFCHallucination:NSEntity
{

};

void
TFCHallucination_Insert(vector viewPosition, vector viewDirection)
{
	int r = 0i;
	vector halluPos = viewPosition;

	halluPos += v_forward * random(8, 128);
	halluPos += v_up * random(-64, 128);
	halluPos += v_right * random(-256, 256);

	traceline(viewPosition, halluPos, MOVE_NORMAL, pSeat->m_ePlayer);
	halluPos = trace_endpos;

	makevectors([0, viewDirection[1], 0]);

	r = (int)(floor(random(0, 10)));

	switch (r) {
	case 1:	/* blood splats */
		for (int i = 0; i < 3; i++) {
			halluPos = viewPosition;
			halluPos += v_forward * random(8, 64);
			halluPos += v_up * random(-64, 64);
			halluPos += v_right * random(-64, 64);
			FX_Blood(halluPos, [1,0,0]);
		}
		pointsound(viewPosition, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
		break;
	case 2: /* explosions */
		pointparticles(particleeffectnum("fx_explosion.main"), halluPos, [0,0,0], 1);
		pSeat->m_flShakeDuration = 2;
		pSeat->m_flShakeAmp = 5.0;
		pSeat->m_flShakeFreq = 2;
		pSeat->m_flShakeTime = 2;
		pointsound(halluPos, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		break;
	case 3:	/* shotgun impact */
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/sbarrel1.wav", 1, ATTN_NORM);
		break;
	case 4:	/* being hit by a crowbar */
		pSeat->m_flShakeDuration = 1;
		pSeat->m_flShakeAmp = 1.0;
		pSeat->m_flShakeFreq = 2;
		pSeat->m_flShakeTime = 2;
		pointsound(halluPos, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
		break;
	case 5:	/* sniper impact */
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/sniper.wav", 1, ATTN_NORM);
		break;
	case 6: /* nailgun impact */
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/airgun_1.wav", 1, ATTN_NORM);
		break;
	case 7:	/* nade thrown about */
		int nadeSelection = (int)floor(random(0, 8));
		NSRenderableEntity eNade = spawn(NSRenderableEntity);

		switch (nadeSelection) {
		case 1:
			eNade.SetModel("models/emp_grenade.mdl");
			break;
		case 2:
			eNade.SetModel("models/spy_grenade.mdl");
			break;
		case 3:
			eNade.SetModel("models/napalm.mdl");
			break;
		case 4:
			eNade.SetModel("models/mirv_grenade.mdl");
			break;
		case 5:
			eNade.SetModel("models/ngrenade.mdl");
			break;
		case 6:
			eNade.SetModel("models/conc_grenade.mdl");
			break;
		case 7:
			eNade.SetModel("models/caltrop.mdl");
			break;
		default:
			eNade.SetModel("models/w_grenade.mdl");
		}
		eNade.SetOrigin(viewPosition + (v_forward * -32) + (v_right * random(-64, 64)));
		eNade.SetMovetype(MOVETYPE_BOUNCE);
		eNade.SetSolid(SOLID_NOT);
		eNade.SetGravity(1.0f);
		eNade.SetVelocity(v_forward * 300 + v_right * random(-64, 64) + v_up * 200);
		eNade.SetAngularVelocity([300, 300, 300]);
		eNade.SetAngles(vectoangles(eNade.GetVelocity()));
		eNade.ScheduleThink(eNade.Destroy, 5.0f);
		eNade.drawmask = MASK_ENGINE;
		pointsound(halluPos, "weapons/grenade_hit3.wav", 1, ATTN_NORM);
		break;
	case 8: /* nail shot around */
		halluPos = viewPosition + (v_forward * -32) + (v_right * random(-64, 64));
		NSRenderableEntity eNail = spawn(NSRenderableEntity);
		eNail.SetModel("models/nail.mdl");
		eNail.SetOrigin(halluPos);
		eNail.SetMovetype(MOVETYPE_NOCLIP);
		eNail.SetSolid(SOLID_NOT);
		eNail.SetGravity(1.0f);
		eNail.SetVelocity(v_forward * 800 + v_right * random(-800, 800));
		eNail.SetAngles(vectoangles(eNail.GetVelocity()));
		eNail.ScheduleThink(eNail.Destroy, 5.0f);
		eNail.drawmask = MASK_ENGINE;
		pointsound(halluPos, "weapons/airgun_1.wav", 1, ATTN_NORM);
		break;
	case 9: /* fire eruption */
		/* get it close to the player than usual */
		halluPos = viewPosition;
		halluPos += v_forward * random(8, 64);
		halluPos += v_up * random(-16, 16);
		halluPos += v_right * random(-64, 64);

		env_sprite eFired = spawn(env_sprite);
		eFired.SetOrigin(halluPos);
		eFired.SetModel("sprites/fthrow.spr");
		eFired.SetMaxFrame(modelframecount(eFired.modelindex));
		eFired.SetFramerate(20);
		eFired.SetLoopFlag(false);
		eFired.SetRenderMode(RM_ADDITIVE);
		eFired.SetRenderAmt(1.0f);
		eFired.nextthink = time + 0.05f;
		pointsound(halluPos, "weapons/flmfire2.wav", 1, ATTN_NORM);
		break;
	default:
		/* rocket launcher firing */
		pointsound(halluPos, "weapons/rocketfire1.wav", 1, ATTN_NORM);
		break;
	}
};
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

	makevectors(viewDirection);

	r = (int)(floor(random(0, 8)));

	switch (r) {
	case 1:
		for (int i = 0; i < 3; i++) {
			FX_Blood(halluPos, [1,0,0]);
			halluPos += v_forward * random(8, 128);
			halluPos += v_up * random(-64, 128);
			halluPos += v_right * random(-256, 256);
		}
		break;
	case 2:
		pointparticles(particleeffectnum("fx_explosion.main"), halluPos, [0,0,0], 1);
		pSeat->m_flShakeDuration = 2;
		pSeat->m_flShakeAmp = 5.0;
		pSeat->m_flShakeFreq = 2;
		pSeat->m_flShakeTime = 2;
		pointsound(halluPos, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		break;
	case 3:
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/sbarrel1.wav", 1, ATTN_NORM);
		break;
	case 4:
		pSeat->m_flShakeDuration = 1;
		pSeat->m_flShakeAmp = 1.0;
		pSeat->m_flShakeFreq = 2;
		pSeat->m_flShakeTime = 2;
		pointsound(halluPos, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
		break;
	case 5:
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/sniper.wav", 1, ATTN_NORM);
		break;
	case 6:
		traceline(viewPosition, halluPos + (v_forward * 1024), MOVE_NORMAL, pSeat->m_ePlayer);
		SurfData_Impact(world, trace_endpos, [0,0,0]);
		DecalGroups_Place("Impact.Shot", trace_endpos);
		pointsound(halluPos, "weapons/airgun_1.wav", 1, ATTN_NORM);
		break;
	case 7:
		NSRenderableEntity eNade = spawn(NSRenderableEntity);
		eNade.SetModel("models/w_grenade.mdl");
		eNade.SetOrigin(halluPos);
		eNade.SetMovetype(MOVETYPE_BOUNCE);
		eNade.SetSolid(SOLID_NOT);
		eNade.SetGravity(1.0f);
		eNade.SetVelocity(v_forward * random(-320,320) + v_right * random(-64, 64) + v_up * 200);
		eNade.SetAngularVelocity([300, 300, 300]);
		eNade.SetAngles(vectoangles(eNade.GetVelocity()));
		eNade.ScheduleThink(eNade.Destroy, 5.0f);
		eNade.drawmask = MASK_ENGINE;
		pointsound(halluPos, "weapons/grenade_hit3.wav", 1, ATTN_NORM);
		break;
	default:
		pointsound(halluPos, "weapons/rocketfire1.wav", 1, ATTN_NORM);
		break;
	}
};
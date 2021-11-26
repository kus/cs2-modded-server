int PredictSeekerShot(int iClient)
{
	float fAng[3];
	GetClientEyeAngles(iClient, fAng);
	
	float fPosEye[3];
	GetClientEyePosition(iClient, fPosEye);
	
	float fPosEnd[3];
	MoveRelative(fPosEye, fAng, 2048.0, fPosEnd);
	
	// Try a simple shot trace ray
	int iHit;
	Handle trace = TR_TraceRayFilterEx(fPosEye, fPosEnd, MASK_SHOT, RayType_EndPoint, Trace_IgnorePlayers);
	if (TR_DidHit(trace)) 
	{
		iHit = TR_GetEntityIndex(trace);
		TR_GetEndPosition(fPosEnd, trace);
	}
	delete trace;
	
	// Check all alive hider's fake props
	LoopAlivePlayers(i)
	{
		// Ignore seekers
		if(GetClientTeam(i) != CS_TEAM_T)
			continue;
		
		// Has fake prop
		int iFakeProp = Client_GetFakeProp(i);
		if(iFakeProp <= 0 || !IsValidEntity(iFakeProp))
			continue;
		
		// We hit the player's fake prop
		if(iHit == iFakeProp)
			return i;
		
		// We crossed the player's bounding box
		// This is needed for models without a collisionbox
		// TODO flag settings to enable this check for req models only? + optionally settings to set bbox
		if(FakeProp_IsLineInBoundingBox(iFakeProp, i, fPosEye, fPosEnd))
			return i;
	}
	
	return -1;
}

public bool Trace_IgnorePlayers(int iEntity, int contentsMask, any data)
{
	// TODO what else to ignore?
	return iEntity > MaxClients;
}

bool FakeProp_IsLineInBoundingBox(int iEntity, int iClient, float P1[3], float P2[3])
{
	// Setup points in space
	
	float fPos[3];
	GetClientAbsOrigin(iClient, fPos);
	
	float fAng[3];
	
	for (int i = 0; i < 3; i++)
		fAng[i] = m_fFreezeAngle[iClient][i] - m_fAngle[iClient][i];
	
	MoveRelative(fPos, fAng, m_fOffset[iClient][0], fPos); // X
	
	fAng[1] += 90.0;
	MoveRelative(fPos, fAng, m_fOffset[iClient][1], fPos); // Y
	fAng[1] -= 90.0;
	
	fPos[2] += m_fOffset[iClient][2]; // Z
	
	float P1S[3], P2S[3];
	
	for (int i; i < 3; i++)
	{
		P1S[i] = P1[i] - fPos[i];
		P2S[i] = P2[i] - fPos[i];
		fAng[i] = -fAng[i];
	}
	
	// Rotate line start & end points in space
	
	float P1SR[3], P2SR[3];
	P1SR = RotatePoint(P1S, fAng);
	P2SR = RotatePoint(P2S, fAng);
	
	// Setup boundingbox
	
	float fMins[3], fMaxs[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecMins", fMins);
	GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", fMaxs);
	
	// TODO auto safe mins/maxs per model and make them adjustable via config
	
	// Extend BBOX if it's 2 small (min 32 units per axis)
	
	for (int i; i < 3; i++)
	{
		float fR = (-fMins[i] + fMaxs[i]) / 32.0;
		
		if(fR >= 1.0)
			continue;
		
		fMins[i] /= fR;
		fMaxs[i] /= fR;
	}
	
	// Setup matrix
	
	float mf[16];
	Matrix_Identity(mf);
	
	float fExtend[3];
	BBox_Set(mf, fMins, fMaxs, fExtend);
	
	// Lets see if the line hits the box in space
	
	return BBox_IsLineInBox(mf, fExtend, P1SR, P2SR);
}
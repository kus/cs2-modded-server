#if defined _smlib_effects_included
	#endinput
#endif
#define _smlib_effects_included

#include <sourcemod>
#include <sdktools_entinput>
#include <sdktools_tempents>
#include <sdktools_tempents_stocks>
#include <smlib/clients>
#include <smlib/effects>
#include <smlib/entities>
#include <smlib/math>



// Entity Dissolve types
enum DissolveType
{
	DISSOLVE_NORMAL = 0,
	DISSOLVE_ELECTRICAL,
	DISSOLVE_ELECTRICAL_LIGHT,
	DISSOLVE_CORE
};

/**
 * Dissolves a player
 *
 * @param client		Client Index.
 * @param dissolveType	Dissolve Type, use the DissolveType enum.
 * @param magnitude		How strongly to push away from the center.
 * @return				True on success, otherwise false.
 */
stock bool:Effect_DissolveEntity(entity, DissolveType:dissolveType=DISSOLVE_NORMAL, magnitude=1)
{
	new env_entity_dissolver = CreateEntityByName("env_entity_dissolver");

	if (env_entity_dissolver == -1) {
		return false;
	}

	Entity_PointAtTarget(env_entity_dissolver, entity);
	SetEntProp(env_entity_dissolver, Prop_Send, "m_nDissolveType", _:dissolveType);
	SetEntProp(env_entity_dissolver, Prop_Send, "m_nMagnitude", magnitude);
	AcceptEntityInput(env_entity_dissolver,	"Dissolve");
	Entity_Kill(env_entity_dissolver);

	return true;
}

/**
 * Dissolves a player's Ragdoll
 *
 * @param client		Client Index.
 * @param dissolveType	Dissolve Type, use the DissolveType enum.
 * @return				True on success, otherwise false.
 */
stock bool:Effect_DissolvePlayerRagDoll(client, DissolveType:dissolveType=DISSOLVE_NORMAL)
{
	new m_hRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");

	if (m_hRagdoll == -1) {
		return false;
	}
	
	return Effect_DissolveEntity(m_hRagdoll, dissolveType);
}

functag EffectCallback public(entity, any:data);

/**
 * Fades an entity in our out.
 * You can specifiy a callback function which will get called
 * when the fade is finished.
 * Important: The callback will be called if it is passed,
 * no matter if the entity is still valid or not. That means you
 * have to check if the entity is valid yourself.
 *
 * @param entity		Entity Index.
 * @param fadeOut		Optional: Fade the entity out (true) or in (false).
 * @param kill			Optional: If to kill the entity when the fade is finished.
 * @param fast			Optional: Fade the entity fast (~0.7 secs) or slow (~3 secs)
 * @param callback		Optional: You can specify a callback Function that will get called when the fade is finished.
 * @param data			Optional: You can pass any data to the callback.
 * @return				True on success, otherwise false.
 */
stock Effect_Fade(entity, fadeOut=true, kill=false, fast=true, EffectCallback:callback=INVALID_FUNCTION, any:data=0)
{
	new Float:timerTime = 0.0;
	
	if (fast) {
		timerTime = 0.6;

		if (fadeOut) {
			SetEntityRenderFx(entity, RENDERFX_FADE_FAST);
		}
		else {
			SetEntityRenderFx(entity, RENDERFX_SOLID_FAST);
		}
	}
	else {
		timerTime = 3.0;

		if (fadeOut) {
			SetEntityRenderFx(entity, RENDERFX_FADE_SLOW);
		}
		else {
			SetEntityRenderFx(entity, RENDERFX_SOLID_SLOW);
		}
	}

	ChangeEdictState(entity, GetEntSendPropOffs(entity, "m_nRenderFX", true));

	if (kill || callback != INVALID_FUNCTION) {
		new Handle:dataPack = INVALID_HANDLE;
		CreateDataTimer(timerTime, _smlib_Timer_Effect_Fade, dataPack, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
		
		WritePackCell(dataPack, EntIndexToEntRef(entity));
		WritePackCell(dataPack, kill);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
		WritePackFunction(dataPack, callback);
#else
		WritePackCell(dataPack, _:callback);
#endif
		WritePackCell(dataPack, data);
		ResetPack(dataPack);
	}
}

/**
 * Fades the entity in.
 *  A wrapper function around Effect_Fade().
 *
 * @param entity		Entity Index.
 * @param fast			Optional: Fade the entity fast (~0.7 secs) or slow (~3 secs)
 * @param callback		Optional: You can specify a callback Function that will get called when the fade is finished.
 * @param data			Optional: You can pass any data to the callback.
 * @return				True on success, otherwise false.
 */
stock Effect_FadeIn(entity, fast=true, EffectCallback:callback=INVALID_FUNCTION, any:data=0)
{
	Effect_Fade(entity, false, false, fast, callback, data);
}
	
/**
 * Fades the entity out.
 * A wrapper function around Effect_Fade().
 *
 * @param entity		Entity Index.
 * @param fadeOut		Optional: Fade the entity out (true) or in (false).
 * @param kill			Optional: If to kill the entity when the fade is finished.
 * @param fast			Optional: Fade the entity fast (~0.7 secs) or slow (~3 secs)
 * @param callback		Optional: You can specify a callback Function that will get called when the fade is finished.
 * @param data			Optional: You can pass any data to the callback.
 * @return				True on success, otherwise false.
 */
stock Effect_FadeOut(entity, kill=false, fast=true, EffectCallback:callback=INVALID_FUNCTION, any:data=0)
{
	Effect_Fade(entity, true, kill, fast, callback, data);
}

public Action:_smlib_Timer_Effect_Fade(Handle:Timer, Handle:dataPack)
{
	new entity = ReadPackCell(dataPack);
	new kill = ReadPackCell(dataPack);
#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 7
	new Function:callback = ReadPackFunction(dataPack);
#else
	new Function:callback = Function:ReadPackCell(dataPack);
#endif
	new any:data = any:ReadPackCell(dataPack);
	
	if (callback != INVALID_FUNCTION) {
		Call_StartFunction(INVALID_HANDLE, callback);
		Call_PushCell(entity);
		Call_PushCell(data);
		Call_Finish();
	}

	if (kill && IsValidEntity(entity)) {
		Entity_Kill(entity);
	}

	return Plugin_Stop;
}

/**
 * Sends a boxed beam effect to one player.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param client        The client to show the box to.
 * @param bottomCorner	One bottom corner of the box.
 * @param upperCorner	One upper corner of the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBoxToClient(
	client,
	const Float:bottomCorner[3],
	const Float:upperCorner[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
) {
    new clients[1];
    clients[0] = client;
    Effect_DrawBeamBox(clients, 1, bottomCorner, upperCorner, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
}

/**
 * Sends a boxed beam effect to all players.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param bottomCorner	One bottom corner of the box.
 * @param upperCorner	One upper corner of the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBoxToAll(
	const Float:bottomCorner[3],
	const Float:upperCorner[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
)
{
	new clients[MaxClients];
	new numClients = Client_Get(clients, CLIENTFILTER_INGAME);

	Effect_DrawBeamBox(clients, numClients, bottomCorner, upperCorner, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
}

/**
 * Sends a boxed beam effect to a list of players.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param clients       An array of clients to show the box to.
 * @param numClients    Number of players in the array.
 * @param bottomCorner	One bottom corner of the box.
 * @param upperCorner	One upper corner of the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBox(
	clients[],
	numClients,
	const Float:bottomCorner[3],
	const Float:upperCorner[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
) {
	// Create the additional corners of the box
	decl Float:corners[8][3];

	for (new i=0; i < 4; i++) {
		Array_Copy(bottomCorner,	corners[i],		3);
		Array_Copy(upperCorner,		corners[i+4],	3);
	}

	corners[1][0] = upperCorner[0];
	corners[2][0] = upperCorner[0]; 
	corners[2][1] = upperCorner[1];
	corners[3][1] = upperCorner[1];
	corners[4][0] = bottomCorner[0]; 
	corners[4][1] = bottomCorner[1];
	corners[5][1] = bottomCorner[1];
	corners[7][0] = bottomCorner[0];

    // Draw all the edges

	// Horizontal Lines
	// Bottom
	for (new i=0; i < 4; i++) {
		new j = ( i == 3 ? 0 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}

	// Top
	for (new i=4; i < 8; i++) {
		new j = ( i == 7 ? 4 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}

	// All Vertical Lines
	for (new i=0; i < 4; i++) {
		TE_SetupBeamPoints(corners[i], corners[i+4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}
}


/**
 * Sends a boxed beam effect to one player.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param client        The client to show the box to.
 * @param origin 		Origin/center of the box.
 * @param mins			Min size Vector
 * @param maxs			Max size Vector
 * @param angles 		Angles used to rotate the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBoxRotatableToClient(
	client,
	const Float:origin[3],
	const Float:mins[3],
	const Float:maxs[3],
	const Float:angles[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
) {
    new clients[1];
    clients[0] = client;
    Effect_DrawBeamBoxRotatable(clients, 1, origin, mins, maxs, angles, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
}



/**
 * Sends a boxed beam effect to all players.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param origin 		Origin/center of the box.
 * @param mins			Min size Vector
 * @param maxs			Max size Vector
 * @param angles 		Angles used to rotate the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBoxRotatableToAll(
	const Float:origin[3],
	const Float:mins[3],
	const Float:maxs[3],
	const Float:angles[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
)
{
	new clients[MaxClients];
	new numClients = Client_Get(clients, CLIENTFILTER_INGAME);

	Effect_DrawBeamBoxRotatable(clients, numClients, origin, mins, maxs, angles, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
}

/**
 * Sends a boxed beam effect to a list of players.
 * 
 * Ported from eventscripts vecmath library.
 *
 * @param clients       An array of clients to show the box to.
 * @param numClients    Number of players in the array.
 * @param origin 		Origin/center of the box.
 * @param mins			Min size Vector
 * @param maxs			Max size Vector
 * @param angles 		Angles used to rotate the box.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawBeamBoxRotatable(
	clients[],
	numClients,
	const Float:origin[3],
	const Float:mins[3],
	const Float:maxs[3],
	const Float:angles[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	const color[4]={ 255, 0, 0, 255 },
	speed=0
) {
	// Create the additional corners of the box
	decl Float:corners[8][3];
	Array_Copy(mins, corners[0], 3);
	Math_MakeVector(maxs[0], mins[1], mins[2], corners[1]);
	Math_MakeVector(maxs[0], maxs[1], mins[2], corners[2]);
	Math_MakeVector(mins[0], maxs[1], mins[2], corners[3]);
	Math_MakeVector(mins[0], mins[1], maxs[2], corners[4]);
	Math_MakeVector(maxs[0], mins[1], maxs[2], corners[5]);
	Array_Copy(maxs, corners[6], 3);
	Math_MakeVector(mins[0], maxs[1], maxs[2], corners[7]);

	// Rotate all edges
	for (new i=0; i < sizeof(corners); i++) {
		Math_RotateVector(corners[i], angles, corners[i]);
	}

	// Apply world offset (after rotation)
	for (new i=0; i < sizeof(corners); i++) {
		AddVectors(origin, corners[i], corners[i]);
	}

    // Draw all the edges
	// Horizontal Lines
	// Bottom
	for (new i=0; i < 4; i++) {
		new j = ( i == 3 ? 0 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}

	// Top
	for (new i=4; i < 8; i++) {
		new j = ( i == 7 ? 4 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}

	// All Vertical Lines
	for (new i=0; i < 4; i++) {
		TE_SetupBeamPoints(corners[i], corners[i+4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, color, speed);
		TE_Send(clients, numClients);
	}
}

/**
 * Displays the given axis of rotation as beam effect to one player.
 * 
 * @param client        The client to show the box to.
 * @param origin 		Origin/center of the box.
 * @param angles 		Angles used to rotate the box.
 * @param length 		The length in each direction.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawAxisOfRotationToClient(
	client,
	const Float:origin[3],
	const Float:angles[3],
	const Float:length[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	speed=0
) {
    new clients[1];
    clients[0] = client;
    Effect_DrawAxisOfRotation(clients, 1, origin, angles, length, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, speed);
}

/**
 * Displays the given axis of rotation as beam effect to all players.
 *
 * @param origin 		Origin/center of the box.
 * @param angles 		Angles used to rotate the box.
 * @param length 		The length in each direction.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawAxisOfRotationToAll(
	const Float:origin[3],
	const Float:angles[3],
	const Float:length[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	speed=0
)
{
	new clients[MaxClients];
	new numClients = Client_Get(clients, CLIENTFILTER_INGAME);

	Effect_DrawAxisOfRotation(clients, numClients, origin, angles, length, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, speed);
}

/**
 * Displays the given axis of rotation as beam effect to a list of players.
 *
 * @param clients       An array of clients to show the box to.
 * @param numClients    Number of players in the array.
 * @param origin 		Origin/center of the box.
 * @param angles 		Angles used to rotate the box.
 * @param length 		The length in each direction.
 * @param modelIndex	Precached model index.
 * @param haloIndex		Precached model index.
 * @param startFrame	Initital frame to render.
 * @param frameRate		Beam frame rate.
 * @param life			Time duration of the beam.
 * @param width			Initial beam width.
 * @param endWidth		Final beam width.
 * @param fadeLength	Beam fade time duration.
 * @param amplitude		Beam amplitude.
 * @param color			Color array (r, g, b, a).
 * @param speed			Speed of the beam.
 * @noreturn
 */
stock Effect_DrawAxisOfRotation(
	clients[],
	numClients,
	const Float:origin[3],
	const Float:angles[3],
	const Float:length[3],
	modelIndex,
	haloIndex,
	startFrame=0,
	frameRate=30,
	Float:life=5.0,
	Float:width=5.0,
	Float:endWidth=5.0,
	fadeLength=2,
	Float:amplitude=1.0,
	speed=0
) {
	// Create the additional corners of the box
	new Float:xAxis[3], Float:yAxis[3], Float:zAxis[3];
	xAxis[0] = length[0];
	yAxis[1] = length[1];
	zAxis[2] = length[2];

	// Rotate all edges
	Math_RotateVector(xAxis, angles, xAxis);
	Math_RotateVector(yAxis, angles, yAxis);
	Math_RotateVector(zAxis, angles, zAxis);

	// Apply world offset (after rotation)
	AddVectors(origin, xAxis, xAxis);
	AddVectors(origin, yAxis, yAxis);
	AddVectors(origin, zAxis, zAxis);

    // Draw all
	TE_SetupBeamPoints(origin, xAxis, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, {255, 0, 0, 255}, speed);
	TE_Send(clients, numClients);

	TE_SetupBeamPoints(origin, yAxis, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, {0, 255, 0, 255}, speed);
	TE_Send(clients, numClients);

	TE_SetupBeamPoints(origin, zAxis, modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, {0, 0, 255, 255}, speed);
	TE_Send(clients, numClients);
}


/**
 * Creates an env_sprite.
 *
 * @param origin			Origin of the Sprite.
 * @param modelIndex		Precached model index.
 * @param color				Color array (r, g, b, a).
 * @param scale				Scale (Note: many materials ignore a lower value than 0.25).
 * @param targetName		Targetname of the sprite.
 * @param parent			Entity Index of this sprite's parent in the movement hierarchy.
 * @param renderMode		Render mode (use the enum).
 * @param renderFx			Render fx (use the enum).
 * @param glowProxySize		Radius size of the glow when to be rendered, if inside a geometry. Ex: a block 2x2x2 units big, if the glowProxySize is between 0.0 and 2.0 the sprite will not be rendered, even if the actual size of the sprite is bigger, everything above 2.0 will render the sprite. Using an abnormal high value will render Sprites trough walls.
 * @param frameRate			Sprite frame rate.
 * @param hdrColorScale 	Float value to multiply sprite color by when running with HDR.
 * @param receiveShadows	When false then this prevents the sprite from receiving shadows.
 * @return					Entity Index of the created Sprite.
 */
stock Effect_EnvSprite(
	const Float:origin[3],
	modelIndex, 
	const color[4]={255, 255, 255, 255},
	Float:scale=0.25, 
	const String:targetName[MAX_NAME_LENGTH]="",
	parent=-1,
	RenderMode:renderMode=RENDER_WORLDGLOW, 
	RenderFx:renderFx=RENDERFX_NONE, 
	Float:glowProxySize=2.0, 
	Float:framerate=10.0, 
	Float:hdrColorScale=1.0,
	bool:receiveShadows = true
) {
	new entity = Entity_Create("env_sprite");
	
	if (entity == INVALID_ENT_REFERENCE) {
		return INVALID_ENT_REFERENCE;
	}
	
	DispatchKeyValue		(entity, "disablereceiveshadows", (receiveShadows) ? "0" : "1");
	DispatchKeyValueFloat	(entity, "framerate", framerate);
	DispatchKeyValueFloat	(entity, "GlowProxySize", glowProxySize);
	DispatchKeyValue		(entity, "spawnflags", "1");
	DispatchKeyValueFloat	(entity, "HDRColorScale", hdrColorScale);
	DispatchKeyValue		(entity, "maxdxlevel", "0");
	DispatchKeyValue		(entity, "mindxlevel", "0");
	DispatchKeyValueFloat	(entity, "scale", scale);
	
	DispatchSpawn(entity);
	
	SetEntityRenderMode(entity, renderMode);
	SetEntityRenderColor(entity, color[0], color[1], color[2], color[3]);
	SetEntityRenderFx(entity, renderFx);
	
	Entity_SetName(entity, targetName);
	Entity_SetModelIndex(entity, modelIndex);
	Entity_SetAbsOrigin(entity, origin);
	
	if (parent != -1) {
		Entity_SetParent(entity, parent);
	}
	
	return entity;
}


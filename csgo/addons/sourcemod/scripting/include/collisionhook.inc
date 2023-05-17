
#if defined _collisionhook_included
 #endinput
#endif
#define _collisionhook_included


// called when the game is performing vphysics collision checks between entities
// return something other than Plugin_Continue to have the game use the result parameter
forward Action:CH_ShouldCollide( ent1, ent2, &bool:result );

// called when the game performs collision checks through traces (only for traces using filters)
// return something other than Plugin_Continue to have the game use the result parameter
// note: any code in this forward should be very performant, the game will use many filtered traces per player per game frame
forward Action:CH_PassFilter( ent1, ent2, &bool:result );


public Extension:__ext_collisionhook = 
{
	name = "CollisionHook",
	file = "collisionhook.ext",
	
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
	
};

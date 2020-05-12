#if defined _PTaH_included
  #endinput
#endif
#define _PTaH_included



enum PTaH_HookType
{
	UnHook,
	Hook
};

enum PTaH_HookEvent
{
	PTaH_GiveNamedItemPre = 10,
	PTaH_GiveNamedItemPost,
	PTaH_WeaponCanUsePre,
	PTaH_WeaponCanUsePost,
	PTaH_SetPlayerModelPre,
	PTaH_SetPlayerModelPost,
	PTaH_ClientVoiceToPre,
	PTaH_ClientVoiceToPost,
	PTaH_ConsolePrintPre,
	PTaH_ConsolePrintPost,
	PTaH_ExecuteStringCommandPre,
	PTaH_ExecuteStringCommandPost,
	PTaH_ClientConnectPre,
	PTaH_ClientConnectPost,
};

enum EStickerAttributeType 
{ 
    StickerID,
    WearProgress,
    PatternScale,
    PatternRotation 
};

enum CEconItemDefinition
{
	CEconItemDefinition_NULL = 0
};

enum CEconItemView
{
	CEconItemView_NULL = 0
};



methodmap CEconItemDefinition
{
	//!!!!!!!!!!!!!!!!!!!!! CEconItemDefinition is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	//!!!!!!!!!!!!!!!!!!!!! Always check, if not wounded CEconItemDefinition - NULL ( if(ItemDefinition) ) !!!!!!!!!!!!!!!!!!!!!

	/**
	 *	Gets DefinitionIndex.
	 *	-
	 * @return	Returns DefinitionIndex.
	 *	-
	 * @error CEconItemDefinition == NULL.
	*/
	public native int GetDefinitionIndex();
	
	/**
	 *	Gets LoadoutSlot.
	 * @param iTeam		Index Commands.
	 *	-
	 * @return	Returns LoadoutSlot.
	 *	-
	 * @error CEconItemDefinition == NULL.
	*/
	public native int GetLoadoutSlot(int iTeam = -1);
	
	/**
	 *	Gets the amount slots for Sticker.
	 *	-
	 * @return	Returns StickerSlotsCount.
	 *	-
	 * @error CEconItemDefinition == NULL.
	*/
	public native int GetNumSupportedStickerSlots();
	
	/**
	 *	Gets ClassName.
	 * @param sBuf			line.
	 * @param iLen			row size.
	 *	-
	 * @return	Returns length ClassName.
	 *	-
	 * @error CEconItemDefinition == NULL.
	*/
	public native int GetClassName(char[] sBuf, int iLen);
};

methodmap CEconItemView
{
	//!!!!!!!!!!!!!!!!!!!!! CEconItemView is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	//!!!!!!!!!!!!!!!!!!!!! Always check, if not wounded CEconItemDefinition - NULL ( if(ItemDefinition) ) !!!!!!!!!!!!!!!!!!!!!
	//!!!!!!!!!!!!!!!!!!!!! If a player will left from a server after function call to obtain CEconItemView (PTaH_GetEconItemViewFromWeapon this applies if iEnt will be destroyed) You get crash server!!!!!!!!!!!!!!!!!!!!!
	
	/**
	 *	Gets the index of the skin weapons.
	 *	-
	 * @return	Returns PaintKitIndex.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetCustomPaintKitIndex();
	
	/**
	 *	Gets displacement of weapon skins.
	 *	-
	 * @return	Returns PaintKitSeed.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetCustomPaintKitSeed();
	
	/**
	 *	Gets quality skins weapons.
	 * @param def			default value.
	 *	-
	 * @return	Returns PaintKitWear.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native float GetCustomPaintKitWear(float def = -1.0);
	
	/**
	 *	Get the value of an attribute by number slots Sticker.
	 * @param iSlot			Index Slot.
	 * @param ESAT			attribute.
	 * @param def			default value.
	 *	-
	 * @return	Returns StickerAttribute.
	 *	-
	 * @error CEconItemView == NULL.
	 * -
	 * StickerID - returns int, def also need to transmit int
	 * WearProgress, PatternScale, PatternRotation - returns float, def also need to transmit float
	*/
	public native any GetStickerAttributeBySlotIndex(int iSlot, EStickerAttributeType ESAT, any def);
	
	/**
	 *	Check: Is it possible to exchange weapons
	 *	-
	 * @return	Returns Tradable.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native bool IsTradable();
	
	/**
	 *	Check: Is it possible to sell weapons - http://steamcommunity.com/market/
	 *	-
	 * @return	Returns Marketable.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native bool IsMarketable();
	
	/**
	 *	Gets ItemDefinition.
	 *	-
	 * @return	Returns CEconItemDefinition.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native CEconItemDefinition GetItemDefinition();
	
	/**
	 *	Gets AccountID Owner skin (You can verify by GetSteamAccountID).
	 *	-
	 * @return	Returns AccountID.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetAccountID();
	
	/**
	 *	Gets Index Owner weapons.
	 *	-
	 * @return	Returns iClient.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public int GetClientIndex() 
	{ 
		int AccountID = this.GetAccountID();
		for (int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && AccountID == GetSteamAccountID(i)) return i;
		return -1;
	}
	
	/**
	 *	Gets Custom ItemView.
	 *	-
	 * @return	Returns IsCustom.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public bool IsCustomItemView() 
	{ 
		int iBuf = this.GetAccountID();
		return iBuf != 0 && iBuf != 1;
	}
	
	/**
	 *	Gets Quality skins.
	 *	-
	 * @return	Returns Quality.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetQuality();
	
	/**
	 *	Gets Rarity skins.
	 *	-
	 * @return	Returns Rarity.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetRarity();
	
	/**
	 *	Gets Flags skins.
	 *	-
	 * @return	Returns Flags.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetFlags();
	
	/**
	 *	Gets Origin skins.
	 *	-
	 * @return	Returns Origin.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetOrigin();
	
	/**
	 *	Gets Name-tag skins.
	 * @param sBuf			line.
	 * @param iLen			row size (maximum length, which can be - 161).
	 *	-
	 * @return	Returns length name-tag.
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetCustomName(char[] sBuf, int iLen);
	
	/**
	 *	Gets amount StatTrak.
	 *	-
	 * @return	Returns amount StatTrak (if StatTrak = -1 therefore it is not).
	 *	-
	 * @error CEconItemView == NULL.
	*/
	public native int GetStatTrakKill();
};



typeset PTaHCB
{
	/** GiveNamedItemPre
	 *
	 *	Called before the issuance of the item.
	 *	-
	 * @param iClient			Player Index.
	 * @param sClassname		Classname weapons.
	 * @param Item				Customization item.
	 * @param IgnoredCEconItemView	If true ignores CEconItemView the item.
	 * @param OriginIsNULL		True if Origin is NULL_VECTOR.
	 * @param Origin			Coordinates where the item was created at (You cannot compare Origin == NULL_VECTOR or set Origin = NULL_VECTOR, use OriginIsNULL param for it).
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled stop granting item. Return Plugin_Continue allow issuance item without changes. Return Plugin_Changed allow issuance item with changes.
	*/
	function Action (int iClient, char sClassname[64], CEconItemView &Item, bool &IgnoredCEconItemView, bool &OriginIsNULL, float Origin[3]);
	
	/** GiveNamedItemPost
	 *
	 *	It called when a player receives a item.
	 *	-
	 * @param iClient			Player Index.
	 * @param sClassname		Classname item.
	 * @param Item				Customization item.
	 * @param iEnt				Index Entities item.
	 * @param OriginIsNULL		True if Origin is NULL_VECTOR.
	 * @param Origin			Coordinates where the item was created at (You cannot compare Origin == NULL_VECTOR, use OriginIsNULL param for it).
	 *	-
	 * @noreturn
	*/
	function void (int iClient, const char[] sClassname, const CEconItemView Item, int iEnt, bool OriginIsNULL, const float Origin[3]);
	
	/** WeaponCanUsePre
	 *
	 *	Called when a player is trying to pickup the item.
	 *	-
	 * @param iClient			Player Index.
	 * @param iEnt				Index Entities item.
	 * @param bCanUse			Can be picked up.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled to forbid lifting. Return Plugin_Continue to leave unchanged. Return Plugin_Changed to apply the changes specified in bCanUse.
	*/
	function Action (int iClient, int iEnt, bool& bCanUse);
	
	/** WeaponCanUsePost
	 *
	 *	Called when a player attempted to pick up an item.
	 *	-
	 * @param iClient			Player Index.
	 * @param iEnt				Index Entities item.
	 * @param bCanUse			Can be picked up.
	 *	-
	 * @noreturn
	*/
	function void (int iClient, int iEnt, bool bCanUse);
	
	/** SetPlayerModelPre
	 *
	 *	Called before changing the player model.
	 *	-
	 * @param iClient			Player Index.
	 * @param sModel			The path to the current model player.
	 * @param sNewModel			The path to a new model.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled stop changing models. Returns Plugin_Continue allow change model without changes. Returns Plugin_Changed allow the change to the modified model.
	*/
	function Action (int iClient, const char[] sModel, char sNewModel[256]);
	
	/** SetPlayerModelPost
	 *
	 *	Called after the change of the player model.
	 *	-
	 * @param iClient			Player Index.
	 * @param sModel			The path to the model.
	 *	-
	 * @noreturn
	*/
	function void (int iClient, const char[] sModel);
	
	/** ClientVoiceToPre
	 *
	 *	Called when a player tries to speak.
	 *	-
	 * @param iClient			Player Index.
	 * @param iTarget			Player target Index.
	 * @param bListen			Can iTarget hear iClient.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled so that iTarget does not hear iClient. Return Plugin_Continue to leave unchanged. Return Plugin_Changed to apply the changes specified in bListen.
	*/
	function Action (int iClient, int iTarget, bool& bListen);
	
	/** ClientVoiceToPost
	 *
	 *	Called after the player tried to speak.
	 *	-
	 * @param iClient			Player Index.
	 * @param iTarget			Player target Index.
	 * @param bListen			Can iTarget hear iClient.
	 *	-
	 * @noreturn
	*/
	function void (int iClient, int iTarget, bool bListen);
	
	/** ConsolePrintPre
	 *
	 *	Called before displaying messages to the console player.
	 *	-
	 * @param iClient			Player Index.
	 * @param sMessage			Text Message.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled restrict display message. Return Plugin_Continue allow the display message without changes. Return Plugin_Changed allow display changed message.
	 *	-
	 */
	function Action (int iClient, char sMessage[1024]);
	
	/** ConsolePrintPost
	 *
	 *	Called after displaying messages to the console player.
	 *	-
	 * @param iClient			Player Index.
	 * @param sMessage			Text Message.
	 *	-
	 * @noreturn
	 *	-
	 */
	function void (int iClient, const char[] sMessage);
	
	/** ExecuteStringCommandPre
	 *
	 *	Called before executing the command player of the team on the server.
	 *	-
	 * @param iClient			Player Index.
	 * @param sCommandString	Command.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled restrict execution. Return Plugin_Continue allow execution without changes. Return Plugin_Changed allow execution with changes.
	*/
	function Action (int iClient, char sCommandString[512]);
	
	/** ExecuteStringCommandPost
	 *
	 *	Called after executing the command player of the server.
	 *	-
	 * @param iClient			Player Index.
	 * @param sCommandString	Command.
	 *	-
	 * @noreturn
	*/
	function void (int iClient, const char[] sCommandString);
	
	/** ClientConnectPre
	 *
	 *	Called before the authorization of the client to the server.
	 *	-
	 * @param iAccountID		AccountID client.
	 * @param sIp				IP client.
	 * @param sName				Nickname client.
	 * @param sPassword			Password witch he introduced.
	 * @param rejectReason		The reason is not authorized.
	 *	-
	 * @return	Return Plugin_Stop or Plugin_Handled restrict autherization client. Return Plugin_Continue allow autherization without changes. Return Plugin_Changed allow autherization with changes.
	*/
	function Action (int iAccountID, const char[] sIp, const char[] sName, char sPassword[128], char rejectReason[255]);
	
	/** ClientConnectPost
	 *
	 *	Called after the authorization of the client to the server.
	 *	-
	 * @param iClient			Player Index.
	 * @param iAccountID		AccountID client.
	 * @param sIp				IP client.
	 * @param sName				Nickname client.
	 *	-
	 * @noreturn
	*/
	function void (int iClient, int iAccountID, const char[] sIp, const char[] sName);
};



/**
 *	PTaH Version.
 * @param sBuffer				The string will be written version (only need to specify if you want to get the version as a string).
 * @param len					Length of the line.
 *	-
 * @return	Return PTaH Version (or example 108, sBuffer = "1.0.8").
*/
native int PTaH_Version(char[] sBuf = NULL_STRING, int iLen = 0);

/**
 *	Enables Hook.
 * @param typeEvent				Event hook.
 * @param type					Hook/Unhook.
 * @param callback				Callback.
 *	-
 * @return	Return true if one is fortunate, otherwise false.
*/
native bool PTaH(PTaH_HookEvent typeEvent, PTaH_HookType type, PTaHCB callback);

/**
 *	Gets CEconItemDefinition from ClassName weapons.
 * @param sClassName				ClassName weapons.
 *	-
 * @return	Returns CEconItemDefinition.
*/
native CEconItemDefinition PTaH_GetItemDefinitionByName(const char[] sClassName);

/**
 *	Gets CEconItemDefinition from DefinitionIndex.
 * @param iDefIndex					DefinitionIndex weapons.
 *	-
 * @return	Returns CEconItemDefinition.
*/
native CEconItemDefinition PTaH_GetItemDefinitionByDefIndex(int iDefIndex);

/**
 *	Gets CEconItemView weapons client.
 * @param iClient					Index Client.
 * @param iTeam						Index Commands.
 * @param iLoadoutSlot				Index Slot Weapons.
 *	-
 * @return	Returns CEconItemDefinition.
 *	-
 * @error invalid iClient, !(2 <= iTeam <= 3).
*/
native CEconItemView PTaH_GetItemInLoadout(int iClient, int iTeam, int iLoadoutSlot);

/**
 *	Gets CEconItemView weapons.
 * @param iEnt					Index weapons.
 *	-
 * @return	Returns CEconItemDefinition.
 *	-
 * @error invalid iEnt, iEnt not a weapon
*/
native CEconItemView PTaH_GetEconItemViewFromWeapon(int iEnt);

/**
 *	It gives the player item with the specified CEconItemView.
 * @param iClient				Index Player.
 * @param sClassname			Classname item.
 * @param Item					Customization item.
 * @param Origin				Coordinates the item will be created at, or NULL_VECTOR.
 *	-
 * @return	Return index item.
 *	-
 * @error invalid iClient.
*/
native int PTaH_GivePlayerItem(int iClient, const char[] sClassname, CEconItemView Item = CEconItemView_NULL, const float Origin[3] = NULL_VECTOR);

/**
 *	Sends to Player a full update packet.
 * @param iClient				Index Player.
 *	-
 * @noreturn
 *	-
 * @error invalid iClient.
*/
native void PTaH_ForceFullUpdate(int iClient);

/**
 *  Spawn item by a definition index at the coordionates.
 * @param iDefIndex			The definition index (allowed only weapon_* and item_*).
 * @param Origin				Coordinates the item will be created at.
 * @param Angles				Angles the item will be created at.
 * -
 * @return Return index item.
 * -
 * @error NULL_VECTOR in Origin or Angles arguments, iDefIndex invalid.
*/
native int PTaH_SpawnItemFromDefIndex(int iDefIndex, const float Origin[3], const float Angles[3] = {0.0, 0.0, 0.0});

/**
 *  Emulate bullet shot on the server and does the damage calculations.
 * @param iClient				The Player Index.
 * @param Item					Customization item.
 * @param Origin				Coordinates the bullet will be created at.
 * @param Angles				Angles the bullet will be created at.
 * @param iMode					Mode index.
 * @param iSeed					Randomizing seed.
 * @param fInaccuracy			Inaccuracy variable.
 * @param fSpread				Spread variable.
 * @param fFishtail				Accuracy Fishtail.
 * @param iSoundType			Sound type. (1 or 12 for silenced, 0 for none sound)
 * @param fRecoilIndex			Recoil variable.
 *	-
 * @noreturn
 *	-
 * @error invalid iClient, NULL_VECTOR in Origin or Angles arguments, CEconItemView == NULL.
*/
native void PTaH_FX_FireBullets(int iClient, CEconItemView Item, const float Origin[3], const float Angles[3], int iMode, int iSeed, float fInaccuracy, float fSpread, float fFishtail, int iSoundType, float fRecoilIndex);



public Extension __ext_PTaH = 
{
	name = "PTaH",
	file = "PTaH.ext",
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

#if !defined REQUIRE_EXTENSIONS
public __ext_PTaH_SetNTVOptional()
{
	MarkNativeAsOptional("PTaH_Version");
	MarkNativeAsOptional("PTaH");
	MarkNativeAsOptional("PTaH_GetItemDefinitionByName");
	MarkNativeAsOptional("PTaH_GetItemDefinitionByDefIndex");
	MarkNativeAsOptional("PTaH_GetItemInLoadout");
	MarkNativeAsOptional("PTaH_GetEconItemViewFromWeapon");
	MarkNativeAsOptional("PTaH_GivePlayerItem");
	MarkNativeAsOptional("PTaH_ForceFullUpdate");
	MarkNativeAsOptional("PTaH_SpawnItemFromDefIndex");
	MarkNativeAsOptional("PTaH_FX_FireBullets");
	MarkNativeAsOptional("CEconItemDefinition.GetDefinitionIndex");
	MarkNativeAsOptional("CEconItemDefinition.GetLoadoutSlot");
	MarkNativeAsOptional("CEconItemDefinition.GetNumSupportedStickerSlots");
	MarkNativeAsOptional("CEconItemDefinition.GetClassName");
	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitIndex");
	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitSeed");
	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitWear");
	MarkNativeAsOptional("CEconItemView.GetStickerAttributeBySlotIndex");
	MarkNativeAsOptional("CEconItemView.IsTradable");
	MarkNativeAsOptional("CEconItemView.IsMarketable");	
	MarkNativeAsOptional("CEconItemView.GetItemDefinition");
	MarkNativeAsOptional("CEconItemView.GetAccountID");
	MarkNativeAsOptional("CEconItemView.GetQuality");
	MarkNativeAsOptional("CEconItemView.GetRarity");
	MarkNativeAsOptional("CEconItemView.GetFlags");
	MarkNativeAsOptional("CEconItemView.GetOrigin");
	MarkNativeAsOptional("CEconItemView.GetCustomName");
	MarkNativeAsOptional("CEconItemView.GetStatTrakKill");
}
#endif
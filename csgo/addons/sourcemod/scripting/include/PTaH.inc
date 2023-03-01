#if defined _PTaH_included
  #endinput
#endif
#define _PTaH_included



#define PTaH_AVATAR_SIZE 64 * 64 * 3		// Height * Width * Pixel cell

enum PTaH_HookType
{
	UnHook = 0,
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
	PTaH_InventoryUpdatePost = 25
};

enum PTaH_ModelType
{
	ViewModel = 0,
	WorldModel,
	DroppedModel
};

enum EStickerAttributeType 
{
	EStickerAttribute_ID = 0,   // int
	EStickerAttribute_Wear,     // float
	EStickerAttribute_Scale,    // float
	EStickerAttribute_Rotation  // float
};

enum ESchemaAttributeType
{
	ESchemaAttribute_Unknown = -1,
	ESchemaAttribute_Uint32,
	ESchemaAttribute_Float,
	ESchemaAttribute_String,
	ESchemaAttribute_Vector
};

enum EEconItemQuality
{
	AE_UNDEFINED = -1,

	AE_NORMAL = 0,
	AE_GENUINE = 1,
	AE_VINTAGE,
	AE_UNUSUAL,
	AE_UNIQUE,
	AE_COMMUNITY,
	AE_DEVELOPER,
	AE_SELFMADE,
	AE_CUSTOMIZED,
	AE_STRANGE,
	AE_COMPLETED,
	AE_HAUNTED,
	AE_TOURNAMENT,
	AE_FAVORED,

	AE_MAX_TYPES,
};

enum eEconItemFlags
{
	kEconItemFlag_CannotTrade                       = 1 << 0,
	kEconItemFlag_CannotBeUsedInCrafting            = 1 << 1,
	kEconItemFlag_CanBeTradedByFreeAccounts         = 1 << 2,
	kEconItemFlag_NonEconomy                        = 1 << 3,	// Used for items that are meant to not interact in the economy -- these can't be traded, gift-wrapped, crafted, etc.

	// Combination of the above flags used in code.
	kEconItemFlags_CheckFlags_CannotTrade           = kEconItemFlag_CannotTrade,
	kEconItemFlags_CheckFlags_NotUsableInCrafting   = kEconItemFlag_CannotBeUsedInCrafting,

	kEconItemFlags_CheckFlags_AllGCFlags            = kEconItemFlags_CheckFlags_CannotTrade | kEconItemFlags_CheckFlags_NotUsableInCrafting,
};

enum eEconItemRarity
{
	kEconItemRarity_Default = 0,
	kEconItemRarity_Common,
	kEconItemRarity_Uncommon,
	kEconItemRarity_Rare,
	kEconItemRarity_Mythical,
	kEconItemRarity_Legendary,
	kEconItemRarity_Ancient,
	kEconItemRarity_Immortal
};

enum eEconItemOrigin
{
	kEconItemOrigin_Invalid = -1,

	kEconItemOrigin_Drop = 0,
	kEconItemOrigin_Achievement,
	kEconItemOrigin_Purchased,
	kEconItemOrigin_Traded,
	kEconItemOrigin_Crafted,
	kEconItemOrigin_StorePromotion,
	kEconItemOrigin_Gifted,
	kEconItemOrigin_SupportGranted,
	kEconItemOrigin_FoundInCrate,
	kEconItemOrigin_Earned,
	kEconItemOrigin_ThirdPartyPromotion,
	kEconItemOrigin_GiftWrapped,
	kEconItemOrigin_HalloweenDrop,
	kEconItemOrigin_PackageItem,
	kEconItemOrigin_Foreign,
	kEconItemOrigin_CDKey,
	kEconItemOrigin_CollectionReward,
	kEconItemOrigin_PreviewItem,
	kEconItemOrigin_SteamWorkshopContribution,
	kEconItemOrigin_PeriodicScoreReward,
	kEconItemOrigin_Recycling,
	kEconItemOrigin_TournamentDrop,
	kEconItemOrigin_StockItem,
	kEconItemOrigin_QuestReward,
	kEconItemOrigin_LevelUpReward,

	kEconItemOrigin_Max,
};

enum CEconItemDefinition
{
	CEconItemDefinition_NULL = 0
};

enum CEconItemAttributeDefinition
{
	CEconItemAttributeDefinition_NULL = 0
};

enum CEconItemAttribute
{
	CEconItemAttribute_NULL = 0
};

enum CAttributeList
{
	CAttributeList_NULL = 0
};

enum CEconItemView
{
	CEconItemView_NULL = 0
};

enum CCSPlayerInventory
{
	CCSPlayerInventory_NULL = 0
};



methodmap CEconItemDefinition	// < Address
{
	// CEconItemDefinition is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CEconItemDefinition - NULL ( if(pItemDefinition) ) !!!!!!!!!!!!!!!!!!!!!

	/**
	 * Gets the definition index.
	 *
	 * @return             Returns definition index.
	 *
	 * @error              CEconItemDefinition == NULL.
	 */
	public native int GetDefinitionIndex();

	/**
	 * Gets the item definition name.
	 *
	 * @param sBuffer      Destination string buffer.
	 * @param iLen         Maximum length of output string buffer.
	 *
	 * @return             Returns length or 0 if failed.
	 *
	 * @error              CEconItemDefinition == NULL.
	 */
	public native int GetDefinitionName(char[] sBuffer, int iLen);

	/**
	 * Gets LoadoutSlot.
	 *
	 * @param iTeam        Team index or 0 if independently.
	 *
	 * @return             Returns loadout slot index.
	 *
	 * @error              CEconItemDefinition == NULL.
	 */
	public native int GetLoadoutSlot(int iTeam = 0);

	/**
	 * Gets the used by team.
	 *
	 * @return             Returns team index or 0 if both team.
	 */
	public native int GetUsedByTeam();

	/**
	 * Gets the amount slot for stickers.
	 * @note On agents, places are counted according
	 *       to patch locations on the model.
	 *
	 * @return             Returns sticker slot count.
	 *
	 * @error              CEconItemDefinition == NULL.
	 */
	public native int GetNumSupportedStickerSlots();

	/**
	 * Gets the item econ image path in resource/flash/.
	 * Example: "econ/weapons/base_weapons/weapon_knife"
	 *
	 * @note Add ".png" in the end of string for full formatting.
	 *
	 * @param sBuffer      Destination string buffer.
	 * @param iLen         Maximum length of output string buffer.
	 *
	 * @return             Returns length or 0 if failed.
	 *
	 * @error              CEconItemDefinition == NULL.
	 */
	public native int GetEconImage(char[] sBuffer, int iLen);

	/**
	 * Gets the item model path.
	 *
	 * @param iModelType   Model type.
	 * @param sBuffer      Destination string buffer.
	 * @param iLen         Maximum length of output string buffer.
	 *                     Max size PLATFORM_MAX_PATH.
	 *
	 * @return             Returns length or 0 if failed.
	 *
	 * @error              CEconItemDefinition == NULL or model type invalid.
	 */
	public native int GetModel(PTaH_ModelType iModelType, char[] sBuffer, int iLen);

	/**
	 * @deprecated Use CEconItemDefinition::GetDefinitionName() for get the definition name. Will be removed.
	 */
	#pragma deprecated Use CEconItemDefinition::GetDefinitionName() instead
	public native int GetClassName(char[] sBuffer, int iLen);
};

methodmap CEconItemAttributeDefinition
{
	// CEconItemAttributeDefinition is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CEconItemAttributeDefinition - NULL ( if(pItemAttributeDefinition) ) !!!!!!!!!!!!!!!!!!!!!

	/**
	 * Gets the definition index.
	 *
	 * @return             Returns definition index.
	 *
	 * @error              CEconItemAttributeDefinition == NULL.
	 */
	public native int GetDefinitionIndex();

	/**
	 * Gets the definition attribute name.
	 *
	 * @param sBuffer      Destination string buffer.
	 * @param iLen         Maximum length of output string buffer.
	 *
	 * @return             Returns definition index.
	 *
	 * @error              CEconItemAttributeDefinition == NULL.
	 */
	public native int GetDefinitionName(char[] sBuffer, int iLen);

	/**
	 * Gets the attribute type.
	 *
	 * @return             Returns attribute type index.
	 *
	 * @error              CEconItemAttributeDefinition == NULL.
	 */
	public native ESchemaAttributeType GetAttributeType();
};

methodmap CEconItemAttribute
{
	// CEconItemAttribute is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CEconItemAttribute - NULL ( if(pItemAttribute) ) !!!!!!!!!!!!!!!!!!!!!

	// Returns the definition index.
	property int DefinitionIndex
	{
		public native get();
	}

	// Returns or sets attribute current value.
	property any Value
	{
		public native set(any Value);
		public native get();
	}

	// Returns the attribute initial value.
	property any InitialValue
	{
		public native get();
	}

	// None.
	property int RefundableCurrency
	{
		public native set(int RefundableCurrency);
		public native get();
	}

	// Returns or sets the setbonus flag.
	property bool SetBonus
	{
		public native set(bool SetBonus);
		public native get();
	}
};

methodmap CAttributeList	// < Address
{
	// CAttributeList is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CAttributeList - NULL ( if(pAttributeList) ) !!!!!!!!!!!!!!!!!!!!!

	/**
	 * Removes all attributes from the list.
	 *
	 * @noreturn
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native void DestroyAllAttributes();

	/**
	 * Gets the attributes count in the list.
	 *
	 * @return             Returns the attributes count.
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native int GetAttributesCount();

	/**
	 * Gets the attribute by index.
	 *
	 * @return             Returns the pointer in CEconItemAttribute.
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native CEconItemAttribute GetAttribute(int iIndex);

	/**
	 * Gets the attribute by definition index.
	 *
	 * @param iDefIndex    Attribute definition index.
	 *
	 * @return             Returns the pointer in CEconItemAttribute.
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native CEconItemAttribute GetAttributeByDefIndex(int iDefIndex);

	/**
	 * Removes the attribute by index.
	 *
	 * @param              Attribute index in list.
	 *
	 * @noreturn
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native void RemoveAttribute(int iIndex);

	/**
	 * Removes the attribute by definition index.
	 *
	 * @param iDefIndex    Attribute definition index.
	 *
	 * @noreturn
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native void RemoveAttributeByDefIndex(int iDefIndex);

	/**
	 * Sets ot adds the attribute value by definition index.
	 *
	 * @param iDefIndex    Attribute definition index.
	 * @param Value        Attribute value.
	 *
	 * @noreturn
	 *
	 * @error              CAttributeList == NULL.
	 */
	public native void SetOrAddAttributeValue(int iDefIndex, any Value);
};


methodmap CEconItemView	// < Address
{
	// CEconItemView is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CEconItemView - NULL ( if(pItemView) ) !!!!!!!!!!!!!!!!!!!!!
	// If a player will left from a server after function call to obtain CEconItemView (PTaH_GetEconItemViewFromEconEntity this applies if iEntity will be destroyed). You get crash server!!!!!!!!!!!!!!!!!!!!!
	
	/**
	 * Gets the index of skin.
	 *
	 * @return             Returns PaintKit index.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native int GetCustomPaintKitIndex();

	/**
	 * Gets the displacement of skin.
	 *
	 * @return             Returns PaintKit seed.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native int GetCustomPaintKitSeed();

	/**
	 * Gets the quality of skins.
	 *
	 * @param fDef         Default value if PaintKit is not found.
	 *
	 * @return             Returns PaintKit wear.
	 *
	 * @error CEconItemView == NULL.
	 */
	public native float GetCustomPaintKitWear(float flDef = -1.0);

	/**
	 * Gets the sticker index by slot.
	 *
	 * @param iSlot	       Sticker slot index.
	 * @param ESAT         Sticker attribute type.
	 * @param Def          Default value if sticker is not found.
	 *
	 * @return             Returns the attribute value.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native any GetStickerAttributeBySlotIndex(int iSlot, EStickerAttributeType ESAT, any Def = 0);

	/**
	 * Gets is it possible to exchange weapons.
	 *
	 * @return             Returns is tradable.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native bool IsTradable();

	/**
	 * Gets is it possible to sell weapons on http://steamcommunity.com/market/.
	 *
	 * @return             Returns Marketable.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native bool IsMarketable();

	/**
	 * Gets CEconItemDefinition.
	 *
	 * @return             Returns the pointer in CEconItemDefinition.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native CEconItemDefinition GetItemDefinition();

	/**
	 * Gets AccountID owner of ItemView.
	 *
	 * @return             Returns AccountID.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native int GetAccountID();

	/**
	 * Gets ItemID of ItemView.
	 *
	 * @param iItemID      Where will it be recorded ItemID.
	 *
	 * @noreturn
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native void GetItemID(int iItemID[2]);

	/**
	 * Gets the owner of ItemView.
	 *
	 * @return             Returns the client index or -1 is not found.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public int GetClientIndex()
	{ 
		int iAccountID = this.GetAccountID();
		
		for(int i = MaxClients + 1; --i;)
		{
			if(IsClientAuthorized(i) && iAccountID == GetSteamAccountID(i))
			{
				return i;
			}
		}

		return -1;
	}

	/**
	 * Gets is custom of ItemView.
	 *
	 * @return             Returns is custom.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public bool IsCustomItemView()
	{
		int iAccountID = this.GetAccountID();

		return iAccountID != 0 && iAccountID != -1;
	}

	/**
	 * Gets EconItem quality.
	 *
	 * @return             Returns the quality.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native EEconItemQuality GetQuality();

	/**
	 * Gets EconItem rarity.
	 *
	 * @return             Returns the rarity.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native eEconItemRarity GetRarity();

	/**
	 *	Gets EconItem flags.
	 *
	 * @return             Returns the flags.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native eEconItemFlags GetFlags();

	/**
	 * Gets EconItem origin.
	 *
	 * @return             Returns the origin.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native eEconItemOrigin GetOrigin();

	/**
	 * Gets the nametag on skin.
	 *
	 * @param sBuffer      Destination string buffer.
	 * @param iLen         Maximum length of output string buffer.
	 *
	 * @return             Returns the nametag length.
	 *
	 * @error              CEconItemView == NULL.
	 */
	public native int GetCustomName(char[] sBuffer, int iLen);

	/**
	 * Gets the amount StatTrak.
	 *
	 * @return             Returns the amount StatTrak.
	 *                     If -1, StatTrak attribute is not found.
	 *
	 * @error              CEconItemView == NULL.
	*/
	public native int GetStatTrakKill();

	/**
	 * Gets the attribute value by index.
	 *
	 * @param iAttribIndex  Attribute definition index.
	 * @param Value         Variable to store value.
	 *
	 * @return              Returns is attribute exist.
	 *
	 * @error               CEconItemView == NULL or iAttribIndex invalid.
	 */
	public native bool GetAttributeValueByIndex(int iAttribIndex, any &Value);

	// Returns the attribute list with static attributes.
	property CAttributeList AttributeList
	{
		public native get();
	}

	// Returns the attribute list with dynamic attributes.
	property CAttributeList NetworkedDynamicAttributesForDemos
	{
		public native get();
	}
};

methodmap CCSPlayerInventory	// < Address
{
	// CCSPlayerInventory is not Handle, CloseHandle() - NOT NEEDED !!!!!!!!!!!!!!!!!!!!!
	// Always check, if not wounded CCSPlayerInventory - NULL ( if(pPlayerInventory) ) !!!!!!!!!!!!!!!!!!!!!

	/**
	 * Gets CEconItemView in LoadoutSlot.
	 *
	 * @param iTeamIndex    Team index.
	 * @param iLoadoutSlot  Loadout slot index.
	 *
	 * @return              Returns the pointer in CEconItemView.
	 *
	 * @error               CCSPlayerInventory == NULL or team index is invalid.
	 */
	public native CEconItemView GetItemInLoadout(int iTeam, int iLoadoutSlot);

	/**
	 * Gets the custom items count in inventory.
	 *
	 * @return              Returns the items count.
	 *
	 * @error               CCSPlayerInventory == NULL.
	 */
	public native int GetItemsCount();

	/**
	 * Gets CEconItemView in inventory by index.
	 *
	 * @param iPos          Item position in inventory.
	 *
	 * @return              Returns the pointer in CEconItemView.
	 *
	 * @error               CCSPlayerInventory == NULL.
	 */
	public native CEconItemView GetItem(int iPos);
};



typeset PTaHCB
{
	/** GiveNamedItemPre
	 *
	 * Called before the issuance of the item.
	 *
	 * @param iClient       Client index.
	 * @param sClassname    Weapon classname.
	 * @param pItemView     Customization item.
	 * @param bIgnoredView  Is ignores CEconItemView the item.
	 * @param bOriginNULL   Origin is unspecified.
	 * @param vecOrigin     Coordinates where the item was created.
	 *                      You cannot compare vecOrigin == NULL_VECTOR, use bOriginNULL param for it.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled for stop granting item.
	 *                      Return Plugin_Continue for allow issuance item without changes.
	 *                      Return Plugin_Changed for allow issuance item with changes.
	 */
	function Action (int iClient, char sClassname[64], CEconItemView &pItemView, bool &bIgnoredView, bool &bOriginNULL, float vecOrigin[3]);

	/** GiveNamedItemPost
	 *
	 * It called when a player receives a item.
	 *
	 * @param iClient       Client index.
	 * @param sClassname    Weapon classname.
	 * @param pItemView     Customization item.
	 * @param iEntity       Entity index. -1 if invalid item.
	 * @param bOriginNULL   Origin is unspecified.
	 * @param vecOrigin     Coordinates where the item was created.
	 *
	 * @noreturn
	 */
	function void (int iClient, const char[] sClassname, const CEconItemView pItemView, int iEntity, bool bOriginNULL, const float vecOrigin[3]);

	/** WeaponCanUsePre
	 *
	 * Called when a player is trying to pickup the item.
	 *
	 * @param iClient       Client index.
	 * @param iEntity       Entity index.
	 * @param bCanUs        Is can be picked up.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled to forbid lifting.
	 *                      Return Plugin_Continue to leave unchanged.
	 *                      Return Plugin_Changed to apply the changes specified in bCanUse.
	 */
	function Action (int iClient, int iEntity, bool &bCanUse);

	/** WeaponCanUsePost
	 *
	 *	Called when a player attempted to pick up an item.
	 *
	 * @param iClient       Client index.
	 * @param iEntity       Entity index.
	 * @param bCanUs        Is can be picked up.
	 *
	 * @noreturn
	 */
	function void (int iClient, int iEntity, bool bCanUse);

	/** SetPlayerModelPre
	 *
	 * Called before changing the player model.
	 *
	 * @param iClient       Client index.
	 * @param sModel        Path to the player model.
	 * @param sNewModel     Path to a new model for change.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled stop changing models.
	 *                      Return Plugin_Continue for allow change model without changes.
	 *                      Return Plugin_Changed for allow the change to the modified model.
	 */
	function Action (int iClient, const char[] sModel, char sNewModel[256]);

	/** SetPlayerModelPost
	 *
	 * Called after the change of the player model.
	 *
	 * @param iClient       Client index.
	 * @param sModel        Path to the player model.
	 *
	 * @noreturn
	 */
	function void (int iClient, const char[] sModel);

	/** ClientVoiceToPre
	 *
	 * Called when a player tries to speak.
	 *
	 * @param iClient       Client index.
	 * @param iTarget       Player target Index.
	 * @param bListen       Can iTarget hear iClient.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled so that iTarget does not hear iClient.
	 *                      Return Plugin_Continue to leave unchanged. Return Plugin_Changed to apply the changes specified in bListen.
	 */
	function Action (int iClient, int iTarget, bool &bListen);

	/** ClientVoiceToPost
	 *
	 * Called after the player tried to speak.
	 *
	 * @param iClient       Client index.
	 * @param iTarget       Player target Index.
	 * @param bListen       Can iTarget hear iClient.
	 *
	 * @noreturn
	 */
	function void (int iClient, int iTarget, bool bListen);

	/** ConsolePrintPre
	 *
	 * Called before displaying messages to the player console.
	 *
	 * @param iClient       Client index.
	 * @param sMessage      Text message.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled for restrict display message.
	 *                      Return Plugin_Continue for allow the display message without changes.
	 *                      Return Plugin_Changed for allow display changed message.
	 *
	 */
	function Action (int iClient, char sMessage[1024]);

	/** ConsolePrintPost
	 *
	 * Called after displaying messages to the player console.
	 *
	 * @param iClient       Client index.
	 * @param sMessage      Message text.
	 *
	 * @noreturn
	 */
	function void (int iClient, const char[] sMessage);

	/** ExecuteStringCommandPre
	 *
	 * Called before executing the player command of the team on the server.
	 *
	 * @param iClient       Client index.
	 * @param sCommand      Execute command.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled for restrict execution.
	 *                      Return Plugin_Continue for allow execution without changes.
	 *                      Return Plugin_Changed for allow execution with changes.
	 */
	function Action (int iClient, char sCommand[512]);

	/** ExecuteStringCommandPost
	 *
	 * Called after executing the player command of the server.
	 *
	 * @param iClient       Client index.
	 * @param sCommand      Execute command.
	 *
	 * @noreturn
	 */
	function void (int iClient, const char[] sCommand);

	/** ClientConnectPre
	 *
	 * Called before the authorization of the client to the server.
	 *
	 * @param iAccountID    Client Steam account ID.
	 * @param sIP           Client IP address.
	 * @param sName         Client nickname.
	 * @param sPassword     Password witch he introduced.
	 * @param sRejectReason The reason is not authorized.
	 *
	 * @return              Return Plugin_Stop or Plugin_Handled for restrict autherization client.
	 *                      Return Plugin_Continue for allow autherization without changes.
	 *                      Return Plugin_Changed for allow autherization with changes.
	 */
	function Action (int iAccountID, const char[] sIP, const char[] sName, char sPassword[128], char sRejectReason[255]);

	/** ClientConnectPost
	 *
	 * Called after the authorization of the client to the server.
	 *
	 * @param iClient       Client index.
	 * @param iAccountID    Client Steam account ID.
	 * @param sIP           Client IP address.
	 * @param sName         Client nickname.
	 *
	 * @noreturn
	 */
	function void (int iClient, int iAccountID, const char[] sIP, const char[] sName);

	/** InventoryUpdatePost
	 *
	 * Called after action in the player inventory.
	 *
	 * @param iClient       Client index.
	 * @param pInventory    Pointer in CCSPlayerInventory.
	 *
	 * @noreturn
	 */
	function void (int iClient, CCSPlayerInventory pInventory);
};



/**
 * Gets PTaH Version.
 *
 * @param sBuffer       Destination string buffer.
 * @param iLen          Maximum length of output string buffer..
 *
 * @return              Return PTaH int Version. Example: 108 if sBuffer = "1.0.8".
 */
native int PTaH_Version(char[] sBuffer = NULL_STRING, int iLen = 0);

/**
 * Enables Hook.
 *
 * @param EventType     Event type.
 * @param HookType      Hook/Unhook.
 * @param Callback      Callback.
 *
 * @return              Is hook successful.
 *
 * @error               Invalid PTaH_HookEvent type.
 */
native bool PTaH(PTaH_HookEvent EventType, PTaH_HookType HookType, PTaHCB Callback);

/**
 * Gets CEconItemDefinition by definition name.
 *
 * @param sDefName      Item definition name.
 *
 * @return              Returns pointer in CEconItemDefinition.
 */
native CEconItemDefinition PTaH_GetItemDefinitionByName(const char[] sDefName);

/**
 * Gets CEconItemDefinition by definition index.
 *
 * @param iDefIndex     Definition index.
 *
 * @return              Returns CEconItemDefinition.
 */
native CEconItemDefinition PTaH_GetItemDefinitionByDefIndex(int iDefIndex);

/**
 * Gets CEconItemAttributeDefinition by definition name.
 *
 * @param sDefName      Attribute definition name.
 *
 * @return              Returns CEconItemAttributeDefinition.
 */
native CEconItemAttributeDefinition PTaH_GetAttributeDefinitionByName(const char[] sDefName);

/**
 * Gets CEconItemAttributeDefinition by definition index.
 *
 * @param iDefIndex     Attribute definition index.
 *
 * @return              Returns CEconItemAttributeDefinition.
 */
native CEconItemAttributeDefinition PTaH_GetAttributeDefinitionByDefIndex(int iDefIndex);

/**
 * Gets CEconItemView from entity with type DT_EconEntity.
 *
 * @param iEntity       Entity index.
 *
 * @return              Returns pointer in CEconItemView.
 *
 * @error               Invalid entity or entity type DT_EconEntity is not found.
 */
native CEconItemView PTaH_GetEconItemViewFromEconEntity(int iEntity);

/**
 * Gets CCSPlayerInventory of Player.
 *
 * @note Use event hook "player_spawn" for get an early
 * stage of loading Shared Data in the inventory
 *
 * @param iClient       Client index.
 *
 * @return              Returns pointer in CCSPlayerInventory.
 *
 * @error               Invalid client index.
 */
native CCSPlayerInventory PTaH_GetPlayerInventory(int iClient);

/**
 * It gives the player item with the specified CEconItemView.
 *
 * @param iClient       Client index.
 * @param sClassname    Item classname.
 * @param pItemView     Customization item.
 * @param vecOrigin     Coordinates the item will be created at, or NULL_VECTOR.
 *
 * @return              Return entity index.
 *
 * @error               Invalid client index.
 */
native int PTaH_GivePlayerItem(int iClient, const char[] sClassname, CEconItemView pItemView = CEconItemView_NULL, const float vecOrigin[3] = NULL_VECTOR);

/**
 * Sends to player a full update packet.
 *
 * @param iClient       Client index.
 *
 * @noreturn
 *
 * @error               Invalid client index, or client is fake.
 */
native void PTaH_ForceFullUpdate(int iClient);

/**
 * Spawn item by a definition index at the coordionates.
 *
 * @param iDefIndex     Definition index.
 * @param vecOrigin     Coordinates the item will be created at.
 * @param flAngles      Angles the item will be created at.
 *
 * @return              Return index item.
 *
 * @error               vecOrigin == NULL_VECTOR or invalid definition index.
 */
native int PTaH_SpawnItemFromDefIndex(int iDefIndex, const float vecOrigin[3], const float flAngles[3] = {0.0, 0.0, 0.0});

/**
 * Emulate bullet shot on the server and does the damage calculations.
 *
 * @param iClient       Client index.
 * @param pItemView     Customization item.
 * @param vecOrigin     Coordinates the bullet will be created at.
 * @param flAngles      Angles the bullet will be created at.
 * @param iMode         Mode index.
 * @param iSeed         Randomizing seed.
 * @param flInaccuracy  Inaccuracy variable.
 * @param flSpread      Spread variable.
 * @param flFishtail    Accuracy Fishtail.
 * @param iSoundType    Sound type. (1 or 12 for silenced, 0 for none sound)
 * @param flRecoilIndex Recoil variable.
 *
 * @noreturn
 *
 * @error               Invalid client index or CEconItemView == NULL or vecOrigin == NULL_VECTOR.
 */
native void PTaH_FX_FireBullets(int iClient, CEconItemView pItemView, const float vecOrigin[3], const float flAngles[3], int iMode, int iSeed, float flInaccuracy, float flSpread, float flFishtail, int iSoundType, float flRecoilIndex);

/**
 * Sets the player avatar for targets.
 * @note As a converter, use image with size 64x64
 *       cl_avatar_convert_rgb - for convert avatars/image.png files to avatars/image.rgb .
 *
 * @param iClient       Client index.
 * @param iTargets      Array containing player indexes to avatar broadcast.
 *                      Target must be connected and not fake client.
 * @param iTargetCount  Count of targets in the array.
 * @param Avatar        Contents of .rgb file.
 *
 * @return              Is avatar sets.
 *
 * @error               Invalid client or target (in array) index, or not connected, or is fake.
 */
native bool PTaH_SetPlayerAvatar(int iClient, const int[] iTargets, int iTargetCount, const char Avatar[PTaH_AVATAR_SIZE]);

/**
 * @deprecated Use CCSPlayerInventory::GetItemInLoadout() for get LoadoutSlot. Will be removed.
 */
#pragma deprecated Use CCSPlayerInventory::GetItemInLoadout() instead
native CEconItemView PTaH_GetItemInLoadout(int iClient, int iTeam, int iLoadoutSlot);

/**
 * @deprecated Use PTaH_GetEconItemViewFromEconEntity() for get CEconItemView from entity. Will be removed.
 */
#pragma deprecated Use PTaH_GetEconItemViewFromEconEntity() instead
native CEconItemView PTaH_GetEconItemViewFromWeapon(int iEntity);



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
	MarkNativeAsOptional("PTaH_GetAttributeDefinitionByName");
	MarkNativeAsOptional("PTaH_GetAttributeDefinitionByDefIndex");
	MarkNativeAsOptional("PTaH_GetEconItemViewFromEconEntity");
	MarkNativeAsOptional("PTaH_GetPlayerInventory");
	MarkNativeAsOptional("PTaH_GivePlayerItem");
	MarkNativeAsOptional("PTaH_ForceFullUpdate");
	MarkNativeAsOptional("PTaH_SpawnItemFromDefIndex");
	MarkNativeAsOptional("PTaH_FX_FireBullets");
	MarkNativeAsOptional("PTaH_SetPlayerAvatar");

	MarkNativeAsOptional("CEconItemDefinition.GetDefinitionIndex");
	MarkNativeAsOptional("CEconItemDefinition.GetDefinitionName");
	MarkNativeAsOptional("CEconItemDefinition.GetLoadoutSlot");
	MarkNativeAsOptional("CEconItemDefinition.GetUsedByTeam");
	MarkNativeAsOptional("CEconItemDefinition.GetNumSupportedStickerSlots");
	MarkNativeAsOptional("CEconItemDefinition.GetEconImage");
	MarkNativeAsOptional("CEconItemDefinition.GetModel");

	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitIndex");
	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitSeed");
	MarkNativeAsOptional("CEconItemView.GetCustomPaintKitWear");
	MarkNativeAsOptional("CEconItemView.GetStickerAttributeBySlotIndex");
	MarkNativeAsOptional("CEconItemView.IsTradable");
	MarkNativeAsOptional("CEconItemView.IsMarketable");
	MarkNativeAsOptional("CEconItemView.GetItemDefinition");
	MarkNativeAsOptional("CEconItemView.GetAccountID");
	MarkNativeAsOptional("CEconItemView.GetItemID");
	MarkNativeAsOptional("CEconItemView.GetQuality");
	MarkNativeAsOptional("CEconItemView.GetRarity");
	MarkNativeAsOptional("CEconItemView.GetFlags");
	MarkNativeAsOptional("CEconItemView.GetOrigin");
	MarkNativeAsOptional("CEconItemView.GetCustomName");
	MarkNativeAsOptional("CEconItemView.GetStatTrakKill");
	MarkNativeAsOptional("CEconItemView.GetAttributeValueByIndex");
	MarkNativeAsOptional("CEconItemView.AttributeList.get");
	MarkNativeAsOptional("CEconItemView.NetworkedDynamicAttributesForDemos.get");

	MarkNativeAsOptional("CCSPlayerInventory.GetItemInLoadout");
	MarkNativeAsOptional("CCSPlayerInventory.GetItemsCount");
	MarkNativeAsOptional("CCSPlayerInventory.GetItem");

	MarkNativeAsOptional("CAttributeList.DestroyAllAttributes");
	MarkNativeAsOptional("CAttributeList.GetAttributesCount");
	MarkNativeAsOptional("CAttributeList.GetAttribute");
	MarkNativeAsOptional("CAttributeList.GetAttributeByDefIndex");
	MarkNativeAsOptional("CAttributeList.RemoveAttribute");
	MarkNativeAsOptional("CAttributeList.RemoveAttributeByDefIndex");
	MarkNativeAsOptional("CAttributeList.SetOrAddAttributeValue");

	MarkNativeAsOptional("CEconItemAttribute.DefinitionIndex.get");
	MarkNativeAsOptional("CEconItemAttribute.Value.set");
	MarkNativeAsOptional("CEconItemAttribute.Value.get");
	MarkNativeAsOptional("CEconItemAttribute.InitialValue.get");
	MarkNativeAsOptional("CEconItemAttribute.RefundableCurrency.set");
	MarkNativeAsOptional("CEconItemAttribute.RefundableCurrency.get");
	MarkNativeAsOptional("CEconItemAttribute.SetBonus.set");
	MarkNativeAsOptional("CEconItemAttribute.SetBonus.get");

	MarkNativeAsOptional("CEconItemAttributeDefinition.GetDefinitionIndex");
	MarkNativeAsOptional("CEconItemAttributeDefinition.GetDefinitionName");
	MarkNativeAsOptional("CEconItemAttributeDefinition.GetAttributeType");

	// Deprecated
	MarkNativeAsOptional("PTaH_GetItemInLoadout");
	MarkNativeAsOptional("PTaH_GetEconItemViewFromWeapon");
	MarkNativeAsOptional("CEconItemDefinition.GetClassName");
}
#endif

#if defined _store_included
	#endinput
#endif
#define _store_included

int g_cvarChatTag = -1;
#define CHAT_TAG g_eCvars[g_cvarChatTag].sCache

#define LOG_ERROR 0
#define LOG_CREDITS 1
#define LOG_ADMIN 2
#define LOG_EVENT 3

#define ITEM_NAME_LENGTH 64
#define STORE_MAX_ITEMS 2048
#define STORE_MAX_HANDLERS 64
#define STORE_MAX_PLANS 8
#define STORE_MAX_SLOTS 12

enum struct Item_Plan
{
	char szName_Plan[ITEM_NAME_LENGTH];
	int iPrice_Plan;
	int iTime_Plan;
}

enum struct Store_Item
{
	char szName[ITEM_NAME_LENGTH];
	char szUniqueId[PLATFORM_MAX_PATH];
	char szShortcut[64];
	char szSteam[256];
	char szDescription[256];
	int iId;
	int iPrice;
	int iParent;
	int iHandler;
	int iFlagBits;
	int iData;
	int iPlans;
	bool bBuyable;
	bool bIgnoreFree;
	bool bIgnoreVIP;
	bool bPreview;
	Handle hAttributes;
}

enum struct Type_Handler
{
	char szType[64];
	char szUniqueKey[32];
	bool bEquipable;
	bool bRaw;
	Handle hPlugin;
	Function fnMapStart;
	Function fnReset;
	Function fnConfig;
	Function fnUse;
	Function fnRemove;
}

enum struct Client_Item
{
	int iId_Client_Item;
	int iUniqueId;
	bool bSynced;
	bool bDeleted;
	int iDateOfPurchase;
	int iDateOfExpiration;
	int iPriceOfPurchase;
}

native int Store_RegisterHandler(char[] type, char[] uniquekey, Function mapstart = INVALID_FUNCTION, Function reset = INVALID_FUNCTION, Function config = INVALID_FUNCTION, Function use = INVALID_FUNCTION, Function remove = INVALID_FUNCTION, bool equipable = true, bool raw = false);
native int Store_RegisterMenuHandler(char[] identifier, Function menu, Function handler);
native void Store_SetDataIndex(int itemid, int index);
native int Store_GetDataIndex(int itemid);
native int Store_GetEquippedItem(int client, char[] type, int slot=0);
native bool Store_IsClientLoaded(int client);
native void Store_DisplayPreviousMenu(int client);
native void Store_SetClientMenu(int client, int num);
native int Store_GetClientCredits(int client);
native void Store_SetClientCredits(int client, int credits);
native bool Store_IsClientVIP(int client);
native bool Store_IsItemInBoughtPackage(int client, int itemid, int uid=-1);
native bool Store_ShouldConfirm();
native void Store_DisplayConfirmMenu(int client, char[] title, Function callback,int data);
native int Store_GetItem(int itemid, any output[sizeof(Store_Item)]);
native void Store_GetHandler(int index, any output[sizeof(Type_Handler)]);
native void Store_GiveItem(int client, int itemid, int purchase=0, int expiration=0, int price=0);
native void Store_RemoveItem(int client, int itemid);
native bool Store_GetClientItem(int client, int itemid, any output[sizeof(Client_Item)]);
native int Store_GetClientTarget(int client);
native int Store_GiveClientItem(int client, int recipient, int itemid);
native bool Store_HasClientItem(int client, int itemid);
native int Store_IterateEquippedItems(int client,int &start, bool attributes=false);
native int Store_GetItemIdbyUniqueId(char[] unique_id);

native int Store_SQLEscape(char[] escapeString);
native int Store_SQLQuery(char[] query, SQLQueryCallback callback, any data);
native int Store_SQLTransaction(Transaction tnx, SQLTxnSuccess callback, any data);

/**
 * Set an mystore Log Message
 *
 * @param client		Client triggered logging event
 * @param callback		Message to log
 * @param data			Log Level
 * 						LOG_ERROR
 * 						LOG_CREDITS
 * 						LOG_ADMIN
 * 						LOG_EVENT
 *
 * @noreturn
 */
native void Store_SQLLogMessage(int client = 0, int level, char[] message, any ...);

forward void Store_OnClientModelChanged(int client, char[] model);


forward void Store_OnPreviewItem(int client, char[] type, int index);
forward void Store_OnConfigExecuted(char[] prefix);

native bool Store_IsInRecurringMenu(int client);
native void Store_SetClientRecurringMenu(int client, bool active);

/*
public Extension:__ext_store_sm =
{
	name = "Store - The Resurrection",
	file = "store_sm.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
	required = 0,
};*/
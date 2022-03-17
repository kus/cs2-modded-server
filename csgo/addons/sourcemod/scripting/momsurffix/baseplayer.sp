#define	MAX_EDICT_BITS			11
#define NUM_ENT_ENTRY_BITS		(MAX_EDICT_BITS + 1)
#define NUM_ENT_ENTRIES			(1 << NUM_ENT_ENTRY_BITS)
#define ENT_ENTRY_MASK			(NUM_ENT_ENTRIES - 1)
#define INVALID_EHANDLE_INDEX	0xFFFFFFFF

enum struct CBasePlayerOffsets
{
	//...
	int m_surfaceFriction;
	//...
	int m_hGroundEntity;
	//...
	int m_MoveType;
	//...
}

enum struct CBaseHandleOffsets
{
	int m_Index;
}

enum struct CEntInfoOffsets
{
	int m_pEntity;
	int m_SerialNumber;
	//...
	int size;
}

enum struct CBaseEntityListOffsets
{
	int m_EntPtrArray;
}

enum struct BasePlayerOffsets
{
	CBasePlayerOffsets cbpoffsets;
	CBaseHandleOffsets cbhoffsets;
	CEntInfoOffsets ceioffsets;
	CBaseEntityListOffsets cbeloffsets;
}
static BasePlayerOffsets offsets;

methodmap CBasePlayer < AddressBase
{
	property float m_surfaceFriction
	{
		public get() { return view_as<float>(LoadFromAddress(this.Address + offsets.cbpoffsets.m_surfaceFriction, NumberType_Int32)); }
	}
	
	//...
	
	property Address m_hGroundEntity
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.cbpoffsets.m_hGroundEntity, NumberType_Int32)); }
	}
	
	//...
	
	property MoveType m_MoveType
	{
		public get() { return view_as<MoveType>(LoadFromAddress(this.Address + offsets.cbpoffsets.m_MoveType, NumberType_Int8)); }
	}
}

methodmap CBaseEntityList < AddressBase
{
	property PseudoStackArray m_EntPtrArray
	{
		public get() { return view_as<PseudoStackArray>(LoadFromAddress(this.Address + offsets.cbeloffsets.m_EntPtrArray, NumberType_Int32)); }
	}
}

static CBaseEntityList g_pEntityList;

methodmap CBaseHandle < AddressBase
{
	property int m_Index
	{
		public get() { return LoadFromAddress(this.Address + offsets.cbhoffsets.m_Index, NumberType_Int32); }
	}
	
	public CBaseHandle Get()
	{
		return LookupEntity(this);
	}
	
	public int GetEntryIndex()
	{
		return
	}
}

methodmap CEntInfo < AddressBase
{
	public static int Size()
	{
		return offsets.ceioffsets.size;
	}
	
	property CBaseHandle m_pEntity
	{
		public get() { return view_as<CBaseHandle>(LoadFromAddress(this.Address + offsets.ceioffsets.m_pEntity, NumberType_Int32)); }
	}
	
	property int m_SerialNumber
	{
		public get() { return LoadFromAddress(this.Address + offsets.ceioffsets.m_SerialNumber, NumberType_Int32); }
	}
}

stock bool InitBasePlayer(GameData gd)
{
	char buff[128];
	bool early = false;
	
	if(gEngineVersion == Engine_CSS)
	{
		//g_pEntityList
		g_pEntityList = view_as<CBaseEntityList>(gd.GetAddress("g_pEntityList"));
		ASSERT_MSG(g_pEntityList.Address != Address_Null, "Can't get \"g_pEntityList\" address from gamedata.");
		
		//CBaseEntityList
		ASSERT_FMT(gd.GetKeyValue("CBaseEntityList::m_EntPtrArray", buff, sizeof(buff)), "Can't get \"CBaseEntityList::m_EntPtrArray\" offset from gamedata.");
		offsets.cbeloffsets.m_EntPtrArray = StringToInt(buff);
		
		//CEntInfo
		ASSERT_FMT(gd.GetKeyValue("CEntInfo::m_pEntity", buff, sizeof(buff)), "Can't get \"CEntInfo::m_pEntity\" offset from gamedata.");
		offsets.ceioffsets.m_pEntity = StringToInt(buff);
		ASSERT_FMT(gd.GetKeyValue("CEntInfo::m_SerialNumber", buff, sizeof(buff)), "Can't get \"CEntInfo::m_SerialNumber\" offset from gamedata.");
		offsets.ceioffsets.m_SerialNumber = StringToInt(buff);
		ASSERT_FMT(gd.GetKeyValue("CEntInfo::size", buff, sizeof(buff)), "Can't get \"CEntInfo::size\" offset from gamedata.");
		offsets.ceioffsets.size = StringToInt(buff);
		
		//CBaseHandle
		ASSERT_FMT(gd.GetKeyValue("CBaseHandle::m_Index", buff, sizeof(buff)), "Can't get \"CBaseHandle::m_Index\" offset from gamedata.");
		offsets.cbhoffsets.m_Index = StringToInt(buff);
		
		//CBasePlayer
		ASSERT_FMT(gd.GetKeyValue("CBasePlayer::m_surfaceFriction", buff, sizeof(buff)), "Can't get \"CBasePlayer::m_surfaceFriction\" offset from gamedata.");
		int offs = StringToInt(buff);
		int prop_offs = FindSendPropInfo("CBasePlayer", "m_szLastPlaceName");
		ASSERT_FMT(prop_offs > 0, "Can't get \"CBasePlayer::m_szLastPlaceName\" offset from FindSendPropInfo().");
		offsets.cbpoffsets.m_surfaceFriction = prop_offs + offs;
	}
	else if(gEngineVersion == Engine_CSGO)
	{
		//CBasePlayer
		ASSERT_FMT(gd.GetKeyValue("CBasePlayer::m_surfaceFriction", buff, sizeof(buff)), "Can't get \"CBasePlayer::m_surfaceFriction\" offset from gamedata.");
		int offs = StringToInt(buff);
		int prop_offs = FindSendPropInfo("CBasePlayer", "m_ubEFNoInterpParity");
		ASSERT_FMT(prop_offs > 0, "Can't get \"CBasePlayer::m_ubEFNoInterpParity\" offset from FindSendPropInfo().");
		offsets.cbpoffsets.m_surfaceFriction = prop_offs - offs;
	}
	
	offsets.cbpoffsets.m_hGroundEntity = FindSendPropInfo("CBasePlayer", "m_hGroundEntity");
	ASSERT_FMT(offsets.cbpoffsets.m_hGroundEntity > 0, "Can't get \"CBasePlayer::m_hGroundEntity\" offset from FindSendPropInfo().");
	
	if(IsValidEntity(0))
	{
		offsets.cbpoffsets.m_MoveType = FindDataMapInfo(0, "m_MoveType");
		ASSERT_FMT(offsets.cbpoffsets.m_MoveType != -1, "Can't get \"CBasePlayer::m_MoveType\" offset from FindDataMapInfo().");
	}
	else
		early = true;
	
	return early;
}

stock void LateInitBasePlayer(GameData gd)
{
	ASSERT(IsValidEntity(0));
	offsets.cbpoffsets.m_MoveType = FindDataMapInfo(0, "m_MoveType");
	ASSERT_FMT(offsets.cbpoffsets.m_MoveType != -1, "Can't get \"CBasePlayer::m_MoveType\" offset from FindDataMapInfo().");
}

stock CBaseHandle LookupEntity(CBaseHandle handle)
{
	if(handle.m_Index == INVALID_EHANDLE_INDEX)
		return view_as<CBaseHandle>(0);
	
	CEntInfo pInfo = view_as<CEntInfo>(g_pEntityList.m_EntPtrArray.Get32(handle.m_Index & ENT_ENTRY_MASK, CEntInfo.Size()));
	
	if(pInfo.m_SerialNumber == (handle.m_Index >> NUM_ENT_ENTRY_BITS))
		return pInfo.m_pEntity;
	else
		return view_as<CBaseHandle>(0);
}
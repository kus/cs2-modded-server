enum struct cplane_tOffsets
{
	int normal;
	int dist;
	int type;
	int signbits;
}

enum struct csurface_tOffsets
{
	int name;
	int surfaceProps;
	int flags;
}

enum struct CGameTraceOffsets
{
	//CBaseTrace
	int startpos;
	int endpos;
	int plane;
	int fraction;
	int contents;
	int dispFlags;
	int allsolid;
	int startsolid;
	//CGameTrace
	int fractionleftsolid;
	int surface;
	int hitgroup;
	int physicsbone;
	int m_pEnt;
	int hitbox;
	int size;
}

enum struct Ray_tOffsets
{
	int m_Start;
	int m_Delta;
	int m_StartOffset;
	int m_Extents;
	int m_pWorldAxisTransform;
	int m_IsRay;
	int m_IsSwept;
	int size;
}

enum struct CTraceFilterSimpleOffsets
{
	int vptr;
	int m_pPassEnt;
	int m_collisionGroup;
	int m_pExtraShouldHitCheckFunction;
	int size;
	Address vtable;
}

enum struct GameTraceOffsets
{
	cplane_tOffsets cptoffsets;
	csurface_tOffsets cstoffsets;
	CGameTraceOffsets cgtoffsets;
	Ray_tOffsets rtoffsets;
	CTraceFilterSimpleOffsets ctfsoffsets;
}
static GameTraceOffsets offsets;

methodmap Cplane_t < AddressBase
{
	property Vector normal
	{
		public get() { return view_as<Vector>(this.Address + offsets.cptoffsets.normal); }
	}
	
	property float dist
	{
		public get() { return view_as<float>(LoadFromAddress(this.Address + offsets.cptoffsets.normal, NumberType_Int32)); }
	}
	
	property char type
	{
		public get() { return view_as<char>(LoadFromAddress(this.Address + offsets.cptoffsets.type, NumberType_Int8)); }
	}
	
	property char signbits
	{
		public get() { return view_as<char>(LoadFromAddress(this.Address + offsets.cptoffsets.signbits, NumberType_Int8)); }
	}
}

methodmap Csurface_t < AddressBase
{
	property Address name
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.cstoffsets.name, NumberType_Int32)); }
	}
	
	property int surfaceProps
	{
		public get() { return LoadFromAddress(this.Address + offsets.cstoffsets.surfaceProps, NumberType_Int16); }
	}
	
	property int flags
	{
		public get() { return LoadFromAddress(this.Address + offsets.cstoffsets.flags, NumberType_Int16); }
	}
}

methodmap CGameTrace < AllocatableBase
{
	public static int Size()
	{
		return offsets.cgtoffsets.size;
	}
	
	property Vector startpos
	{
		public get() { return view_as<Vector>(this.Address + offsets.cgtoffsets.startpos); }
	}
	
	property Vector endpos
	{
		public get() { return view_as<Vector>(this.Address + offsets.cgtoffsets.endpos); }
	}
	
	property Cplane_t plane
	{
		public get() { return view_as<Cplane_t>(this.Address + offsets.cgtoffsets.plane); }
	}
	
	property float fraction
	{
		public get() { return view_as<float>(LoadFromAddress(this.Address + offsets.cgtoffsets.fraction, NumberType_Int32)); }
	}
	
	property int contents
	{
		public get() { return LoadFromAddress(this.Address + offsets.cgtoffsets.contents, NumberType_Int32); }
	}
	
	property int dispFlags
	{
		public get() { return LoadFromAddress(this.Address + offsets.cgtoffsets.dispFlags, NumberType_Int16); }
	}
	
	property bool allsolid
	{
		public get() { return view_as<bool>(LoadFromAddress(this.Address + offsets.cgtoffsets.allsolid, NumberType_Int8)); }
	}
	
	property bool startsolid
	{
		public get() { return view_as<bool>(LoadFromAddress(this.Address + offsets.cgtoffsets.startsolid, NumberType_Int8)); }
	}
	
	property float fractionleftsolid
	{
		public get() { return view_as<float>(LoadFromAddress(this.Address + offsets.cgtoffsets.fractionleftsolid, NumberType_Int32)); }
	}
	
	property Csurface_t surface
	{
		public get() { return view_as<Csurface_t>(this.Address + offsets.cgtoffsets.surface); }
	}
	
	property int hitgroup
	{
		public get() { return LoadFromAddress(this.Address + offsets.cgtoffsets.hitgroup, NumberType_Int32); }
	}
	
	property int physicsbone
	{
		public get() { return LoadFromAddress(this.Address + offsets.cgtoffsets.physicsbone, NumberType_Int16); }
	}
	
	property Address m_pEnt
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.cgtoffsets.m_pEnt, NumberType_Int32)); }
	}
	
	property int hitbox
	{
		public get() { return LoadFromAddress(this.Address + offsets.cgtoffsets.hitbox, NumberType_Int32); }
	}
	
	public CGameTrace()
	{
		return MALLOC(CGameTrace);
	}
}

methodmap Ray_t < AllocatableBase
{
	public static int Size()
	{
		return offsets.rtoffsets.size;
	}
	
	property Vector m_Start
	{
		public get() { return view_as<Vector>(this.Address + offsets.rtoffsets.m_Start); }
	}
	
	property Vector m_Delta
	{
		public get() { return view_as<Vector>(this.Address + offsets.rtoffsets.m_Delta); }
	}
	
	property Vector m_StartOffset
	{
		public get() { return view_as<Vector>(this.Address + offsets.rtoffsets.m_StartOffset); }
	}
	
	property Vector m_Extents
	{
		public get() { return view_as<Vector>(this.Address + offsets.rtoffsets.m_Extents); }
	}
	
	property Address m_pWorldAxisTransform
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.rtoffsets.m_pWorldAxisTransform, NumberType_Int32)); }
		public set(Address _worldaxistransform) { StoreToAddressCustom(this.Address + offsets.rtoffsets.m_pWorldAxisTransform, view_as<int>(_worldaxistransform), NumberType_Int32); }
	}
	
	property bool m_IsRay
	{
		public get() { return view_as<bool>(LoadFromAddress(this.Address + offsets.rtoffsets.m_IsRay, NumberType_Int8)); }
		public set(bool _isray) { StoreToAddressCustom(this.Address + offsets.rtoffsets.m_IsRay, _isray, NumberType_Int8); }
	}
	
	property bool m_IsSwept
	{
		public get() { return view_as<bool>(LoadFromAddress(this.Address + offsets.rtoffsets.m_IsSwept, NumberType_Int8)); }
		public set(bool _isswept) { StoreToAddressCustom(this.Address + offsets.rtoffsets.m_IsSwept, _isswept, NumberType_Int8); }
	}
	
	public Ray_t()
	{
		return MALLOC(Ray_t);
	}
	
	//That function is quite heavy, linux builds have it inlined, so can't use it!
	//Replacing this function with lighter alternative may increase speed by ~4 times!
	//From my testings the main performance killer here is StoreToAddress()....
	public void Init(float start[3], float end[3], float mins[3], float maxs[3])
	{
		float buff[3], buff2[3];
		
		SubtractVectors(end, start, buff);
		this.m_Delta.FromArray(buff);
		
		if(gEngineVersion == Engine_CSGO)
			this.m_pWorldAxisTransform = Address_Null;
		this.m_IsSwept = (this.m_Delta.LengthSqr() != 0.0);
		
		SubtractVectors(maxs, mins, buff);
		ScaleVector(buff, 0.5);
		this.m_Extents.FromArray(buff);
		
		this.m_IsRay = (this.m_Extents.LengthSqr() < 1.0e-6);
		
		AddVectors(mins, maxs, buff);
		ScaleVector(buff, 0.5);
		AddVectors(start, buff, buff2);
		this.m_Start.FromArray(buff2);
		NegateVector(buff);
		this.m_StartOffset.FromArray(buff);
	}
}

methodmap CTraceFilterSimple < AllocatableBase
{
	public static int Size()
	{
		return offsets.ctfsoffsets.size;
	}
	
	property Address vptr
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.ctfsoffsets.vptr, NumberType_Int32)); }
		public set(Address _vtbladdr) { StoreToAddressCustom(this.Address + offsets.ctfsoffsets.vptr, view_as<int>(_vtbladdr), NumberType_Int32); }
	}
	
	property CBaseHandle m_pPassEnt
	{
		public get() { return view_as<CBaseHandle>(LoadFromAddress(this.Address + offsets.ctfsoffsets.m_pPassEnt, NumberType_Int32)); }
		public set(CBaseHandle _passent) { StoreToAddressCustom(this.Address + offsets.ctfsoffsets.m_pPassEnt, view_as<int>(_passent), NumberType_Int32); }
	}
	
	property int m_collisionGroup
	{
		public get() { return LoadFromAddress(this.Address + offsets.ctfsoffsets.m_collisionGroup, NumberType_Int32); }
		public set(int _collisiongroup) { StoreToAddressCustom(this.Address + offsets.ctfsoffsets.m_collisionGroup, _collisiongroup, NumberType_Int32); }
	}
	
	property Address m_pExtraShouldHitCheckFunction
	{
		public get() { return view_as<Address>(LoadFromAddress(this.Address + offsets.ctfsoffsets.m_pExtraShouldHitCheckFunction, NumberType_Int32)); }
		public set(Address _checkfnc) { StoreToAddressCustom(this.Address + offsets.ctfsoffsets.m_pExtraShouldHitCheckFunction, view_as<int>(_checkfnc), NumberType_Int32); }
	}
	
	public CTraceFilterSimple()
	{
		CTraceFilterSimple addr = MALLOC(CTraceFilterSimple);
		addr.vptr = offsets.ctfsoffsets.vtable;
		return addr;
	}
	
	public void Init(CBaseHandle passentity, int collisionGroup, Address pExtraShouldHitCheckFn = Address_Null)
	{
		this.m_pPassEnt = passentity;
		this.m_collisionGroup = collisionGroup;
		this.m_pExtraShouldHitCheckFunction = pExtraShouldHitCheckFn;
	}
}

static Handle gCanTraceRay;

methodmap ITraceListData < AddressBase
{
	public bool CanTraceRay(Ray_t ray)
	{
		return SDKCall(gCanTraceRay, this.Address, ray.Address);
	}
}

static Handle gTraceRay, gTraceRayAgainstLeafAndEntityList;
static Address gEngineTrace;

stock void InitGameTrace(GameData gd)
{
	char buff[128];
	
	//cplane_t
	ASSERT_FMT(gd.GetKeyValue("cplane_t::normal", buff, sizeof(buff)), "Can't get \"cplane_t::normal\" offset from gamedata.");
	offsets.cptoffsets.normal = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("cplane_t::dist", buff, sizeof(buff)), "Can't get \"cplane_t::dist\" offset from gamedata.");
	offsets.cptoffsets.dist = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("cplane_t::type", buff, sizeof(buff)), "Can't get \"cplane_t::type\" offset from gamedata.");
	offsets.cptoffsets.type = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("cplane_t::signbits", buff, sizeof(buff)), "Can't get \"cplane_t::signbits\" offset from gamedata.");
	offsets.cptoffsets.signbits = StringToInt(buff);
	
	//csurface_t
	ASSERT_FMT(gd.GetKeyValue("csurface_t::name", buff, sizeof(buff)), "Can't get \"csurface_t::name\" offset from gamedata.");
	offsets.cstoffsets.name = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("csurface_t::surfaceProps", buff, sizeof(buff)), "Can't get \"csurface_t::surfaceProps\" offset from gamedata.");
	offsets.cstoffsets.surfaceProps = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("csurface_t::flags", buff, sizeof(buff)), "Can't get \"csurface_t::flags\" offset from gamedata.");
	offsets.cstoffsets.flags = StringToInt(buff);
	
	//CGameTrace
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::startpos", buff, sizeof(buff)), "Can't get \"CGameTrace::startpos\" offset from gamedata.");
	offsets.cgtoffsets.startpos = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::endpos", buff, sizeof(buff)), "Can't get \"CGameTrace::endpos\" offset from gamedata.");
	offsets.cgtoffsets.endpos = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::plane", buff, sizeof(buff)), "Can't get \"CGameTrace::plane\" offset from gamedata.");
	offsets.cgtoffsets.plane = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::fraction", buff, sizeof(buff)), "Can't get \"CGameTrace::fraction\" offset from gamedata.");
	offsets.cgtoffsets.fraction = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::contents", buff, sizeof(buff)), "Can't get \"CGameTrace::contents\" offset from gamedata.");
	offsets.cgtoffsets.contents = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::dispFlags", buff, sizeof(buff)), "Can't get \"CGameTrace::dispFlags\" offset from gamedata.");
	offsets.cgtoffsets.dispFlags = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::allsolid", buff, sizeof(buff)), "Can't get \"CGameTrace::allsolid\" offset from gamedata.");
	offsets.cgtoffsets.allsolid = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::startsolid", buff, sizeof(buff)), "Can't get \"CGameTrace::startsolid\" offset from gamedata.");
	offsets.cgtoffsets.startsolid = StringToInt(buff);
	
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::fractionleftsolid", buff, sizeof(buff)), "Can't get \"CGameTrace::fractionleftsolid\" offset from gamedata.");
	offsets.cgtoffsets.fractionleftsolid = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::surface", buff, sizeof(buff)), "Can't get \"CGameTrace::surface\" offset from gamedata.");
	offsets.cgtoffsets.surface = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::hitgroup", buff, sizeof(buff)), "Can't get \"CGameTrace::hitgroup\" offset from gamedata.");
	offsets.cgtoffsets.hitgroup = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::physicsbone", buff, sizeof(buff)), "Can't get \"CGameTrace::physicsbone\" offset from gamedata.");
	offsets.cgtoffsets.physicsbone = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::m_pEnt", buff, sizeof(buff)), "Can't get \"CGameTrace::m_pEnt\" offset from gamedata.");
	offsets.cgtoffsets.m_pEnt = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::hitbox", buff, sizeof(buff)), "Can't get \"CGameTrace::hitbox\" offset from gamedata.");
	offsets.cgtoffsets.hitbox = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CGameTrace::size", buff, sizeof(buff)), "Can't get \"CGameTrace::size\" offset from gamedata.");
	offsets.cgtoffsets.size = StringToInt(buff);
	
	//Ray_t
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_Start", buff, sizeof(buff)), "Can't get \"Ray_t::m_Start\" offset from gamedata.");
	offsets.rtoffsets.m_Start = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_Delta", buff, sizeof(buff)), "Can't get \"Ray_t::m_Delta\" offset from gamedata.");
	offsets.rtoffsets.m_Delta = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_StartOffset", buff, sizeof(buff)), "Can't get \"Ray_t::m_StartOffset\" offset from gamedata.");
	offsets.rtoffsets.m_StartOffset = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_Extents", buff, sizeof(buff)), "Can't get \"Ray_t::m_Extents\" offset from gamedata.");
	offsets.rtoffsets.m_Extents = StringToInt(buff);
	
	if(gEngineVersion == Engine_CSGO)
	{
		ASSERT_FMT(gd.GetKeyValue("Ray_t::m_pWorldAxisTransform", buff, sizeof(buff)), "Can't get \"Ray_t::m_pWorldAxisTransform\" offset from gamedata.");
		offsets.rtoffsets.m_pWorldAxisTransform = StringToInt(buff);
	}
	
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_IsRay", buff, sizeof(buff)), "Can't get \"Ray_t::m_IsRay\" offset from gamedata.");
	offsets.rtoffsets.m_IsRay = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("Ray_t::m_IsSwept", buff, sizeof(buff)), "Can't get \"Ray_t::m_IsSwept\" offset from gamedata.");
	offsets.rtoffsets.m_IsSwept = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("Ray_t::size", buff, sizeof(buff)), "Can't get \"Ray_t::size\" offset from gamedata.");
	offsets.rtoffsets.size = StringToInt(buff);
	
	//CTraceFilterSimple
	ASSERT_FMT(gd.GetKeyValue("CTraceFilterSimple::vptr", buff, sizeof(buff)), "Can't get \"CTraceFilterSimple::vptr\" offset from gamedata.");
	offsets.ctfsoffsets.vptr = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CTraceFilterSimple::m_pPassEnt", buff, sizeof(buff)), "Can't get \"CTraceFilterSimple::m_pPassEnt\" offset from gamedata.");
	offsets.ctfsoffsets.m_pPassEnt = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CTraceFilterSimple::m_collisionGroup", buff, sizeof(buff)), "Can't get \"CTraceFilterSimple::m_collisionGroup\" offset from gamedata.");
	offsets.ctfsoffsets.m_collisionGroup = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CTraceFilterSimple::m_pExtraShouldHitCheckFunction", buff, sizeof(buff)), "Can't get \"CTraceFilterSimple::m_pExtraShouldHitCheckFunction\" offset from gamedata.");
	offsets.ctfsoffsets.m_pExtraShouldHitCheckFunction = StringToInt(buff);
	ASSERT_FMT(gd.GetKeyValue("CTraceFilterSimple::size", buff, sizeof(buff)), "Can't get \"CTraceFilterSimple::size\" offset from gamedata.");
	offsets.ctfsoffsets.size = StringToInt(buff);
	
	if(gEngineVersion == Engine_CSS)
	{
		offsets.ctfsoffsets.vtable = gd.GetAddress("CTraceFilterSimple::vtable");
		ASSERT_MSG(offsets.ctfsoffsets.vtable != Address_Null, "Can't get \"CTraceFilterSimple::vtable\" address from gamedata.");
	}
	
	//enginetrace
	gd.GetKeyValue("CEngineTrace", buff, sizeof(buff));
	gEngineTrace = CreateInterface(buff);
	ASSERT_MSG(gEngineTrace != Address_Null, "Can't create \"enginetrace\" from CreateInterface().");
	
	//RayTrace
	StartPrepSDKCall(SDKCall_Raw);
	
	PrepSDKCall_SetVirtual(gd.GetOffset("TraceRay"));
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	
	gTraceRay = EndPrepSDKCall();
	ASSERT(gTraceRay);
	
	if(gEngineVersion == Engine_CSGO)
	{
		//TraceRayAgainstLeafAndEntityList
		StartPrepSDKCall(SDKCall_Raw);
		
		PrepSDKCall_SetVirtual(gd.GetOffset("TraceRayAgainstLeafAndEntityList"));
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		
		gTraceRayAgainstLeafAndEntityList = EndPrepSDKCall();
		ASSERT(gTraceRayAgainstLeafAndEntityList);
		
		//CanTraceRay
		StartPrepSDKCall(SDKCall_Raw);
		
		PrepSDKCall_SetVirtual(gd.GetOffset("CanTraceRay"));
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		
		gCanTraceRay = EndPrepSDKCall();
		ASSERT(gCanTraceRay);
	}
}

stock void TraceRayAgainstLeafAndEntityList(Ray_t ray, ITraceListData traceData, int mask, CTraceFilterSimple filter, CGameTrace trace)
{
	SDKCall(gTraceRayAgainstLeafAndEntityList, gEngineTrace, ray.Address, traceData.Address, mask, filter.Address, trace.Address);
}

stock void TraceRay(Ray_t ray, int mask, CTraceFilterSimple filter, CGameTrace trace)
{
	SDKCall(gTraceRay, gEngineTrace, ray.Address, mask, filter.Address, trace.Address);
}
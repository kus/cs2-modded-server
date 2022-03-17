#define MALLOC(%1) view_as<%1>(AllocatableBase._malloc(%1.Size(), #%1))
#define MEMORYPOOL_NAME_MAX 128

enum struct MemoryPoolEntry
{
	Address addr;
	char name[MEMORYPOOL_NAME_MAX];
}

methodmap AddressBase
{
	property Address Address
	{
		public get() { return view_as<Address>(this); }
	}
}

methodmap AllocatableBase < AddressBase
{
	public static Address _malloc(int size, const char[] name)
	{
		Address addr = Malloc(size, name);
		
		return addr;
	}
	
	public void Free()
	{
		Free(this.Address);
	}
}

methodmap PseudoStackArray < AddressBase
{
	public Address Get8(int idx, int size = 4)
	{
		ASSERT(idx >= 0);
		ASSERT(size > 0);
		
		return view_as<Address>(LoadFromAddress(this.Address + (idx * size), NumberType_Int8));
	}
	
	public Address Get16(int idx, int size = 4)
	{
		ASSERT(idx >= 0);
		ASSERT(size > 0);
		
		return view_as<Address>(LoadFromAddress(this.Address + (idx * size), NumberType_Int16));
	}
	
	public Address Get32(int idx, int size = 4)
	{
		ASSERT(idx >= 0);
		ASSERT(size > 0);
		
		return this.Address + (idx * size);
	}
}

methodmap Vector < AllocatableBase
{
	public static int Size()
	{
		return 12;
	}
	
	public Vector()
	{
		return MALLOC(Vector);
	}
	
	property float x
	{
		public set(float _x) { StoreToAddressCustom(this.Address, view_as<int>(_x), NumberType_Int32); }
		public get() { return view_as<float>(LoadFromAddress(this.Address, NumberType_Int32)); }
	}
	
	property float y
	{
		public set(float _y) { StoreToAddressCustom(this.Address + 4, view_as<int>(_y), NumberType_Int32); }
		public get() { return view_as<float>(LoadFromAddress(this.Address + 4, NumberType_Int32)); }
	}
	
	property float z
	{
		public set(float _z) { StoreToAddressCustom(this.Address + 8, view_as<int>(_z), NumberType_Int32); }
		public get() { return view_as<float>(LoadFromAddress(this.Address + 8, NumberType_Int32)); }
	}
	
	public void ToArray(float buff[3])
	{
		buff[0] = this.x;
		buff[1] = this.y;
		buff[2] = this.z;
	}
	
	public void FromArray(float buff[3])
	{
		this.x = buff[0];
		this.y = buff[1];
		this.z = buff[2];
	}
	
	public void CopyTo(Vector dst)
	{
		dst.x = this.x;
		dst.y = this.y;
		dst.z = this.z;
	}
	
	public float LengthSqr()
	{
		return this.x*this.x + this.y*this.y + this.z*this.z;
	}
	
	public float Length()
	{
		return SquareRoot(this.LengthSqr());
	}
	
	public float Dot(float vec[3])
	{
		return this.x*vec[0] + this.y*vec[1] + this.z*vec[2];
	}
}

static Address g_pMemAlloc;
static Handle gMalloc, gFree, gCreateInterface;
static ArrayList gMemoryPool;

stock void InitUtils(GameData gd)
{
	gMemoryPool = new ArrayList(sizeof(MemoryPoolEntry));
	
	//CreateInterface
	StartPrepSDKCall(SDKCall_Static);
	
	ASSERT_MSG(PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CreateInterface"), "Failed to get \"CreateInterface\" signature.");
	
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	
	gCreateInterface = EndPrepSDKCall();
	ASSERT(gCreateInterface);
	
	if(gEngineVersion == Engine_CSGO || gOSType == OSWindows)
	{
		//g_pMemAlloc
		g_pMemAlloc = gd.GetAddress("g_pMemAlloc");
		ASSERT_MSG(g_pMemAlloc != Address_Null, "Can't get \"g_pMemAlloc\" address from gamedata.");
		
		//Malloc
		StartPrepSDKCall(SDKCall_Raw);
		
		PrepSDKCall_SetVirtual(gd.GetOffset("Malloc"));
		
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		
		gMalloc = EndPrepSDKCall();
		ASSERT(gMalloc);
		
		//Free
		StartPrepSDKCall(SDKCall_Raw);
		
		PrepSDKCall_SetVirtual(gd.GetOffset("Free"));
		
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		
		gFree = EndPrepSDKCall();
		ASSERT(gFree);
	}
	else
	{
		//Malloc
		StartPrepSDKCall(SDKCall_Static);
		ASSERT_MSG(PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "malloc"), "Failed to get \"malloc\" signature.");
		
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		
		gMalloc = EndPrepSDKCall();
		ASSERT(gMalloc);
		
		//Free
		StartPrepSDKCall(SDKCall_Static);
		ASSERT_MSG(PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "free"), "Failed to get \"free\" signature.");
		
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		
		gFree = EndPrepSDKCall();
		ASSERT(gFree);
	}
}

stock Address CreateInterface(const char[] name)
{
	return SDKCall(gCreateInterface, name, 0);
}

stock Address Malloc(int size, const char[] name)
{
	ASSERT(gMemoryPool);
	ASSERT(size > 0);
	
	MemoryPoolEntry entry;
	strcopy(entry.name, sizeof(MemoryPoolEntry::name), name);
	
	if(gEngineVersion == Engine_CSS && gOSType == OSLinux)
		entry.addr = SDKCall(gMalloc, 0, size);
	else
		entry.addr = SDKCall(gMalloc, g_pMemAlloc, size);
	
	ASSERT_FMT(entry.addr != Address_Null, "Failed to allocate memory (size: %i)!", size);
	gMemoryPool.PushArray(entry);
	
	return entry.addr;
}

stock void Free(Address addr)
{
	ASSERT(addr != Address_Null);
	ASSERT(gMemoryPool);
	int idx = gMemoryPool.FindValue(addr, MemoryPoolEntry::addr);
	
	//Memory wasn't allocated by this plugin, return.
	if(idx == -1)
		return;
	
	gMemoryPool.Erase(idx);
	
	if(gEngineVersion == Engine_CSS && gOSType == OSLinux)
		SDKCall(gFree, 0, addr);
	else
		SDKCall(gFree, g_pMemAlloc, addr);
}

stock void AddToMemoryPool(Address addr, const char[] name)
{
	ASSERT(addr != Address_Null);
	ASSERT(gMemoryPool);
	
	MemoryPoolEntry entry;
	strcopy(entry.name, sizeof(MemoryPoolEntry::name), name);
	entry.addr = addr;
	
	gMemoryPool.PushArray(entry);
}

stock void CleanUpUtils()
{
	if(!gMemoryPool)
		return;
	
	MemoryPoolEntry entry;
	
	for(int i = 0; i < gMemoryPool.Length; i++)
	{
		gMemoryPool.GetArray(i, entry, sizeof(MemoryPoolEntry));
		view_as<AllocatableBase>(entry.addr).Free();
	}
	
	delete gMemoryPool;
}

stock void DumpMemoryUsage()
{
	if(!gMemoryPool || (gMemoryPool && gMemoryPool.Length == 0))
	{
		PrintToServer(SNAME..."Theres's currently no active pool or it's empty!");
		return;
	}
	
	MemoryPoolEntry entry;
	
	PrintToServer(SNAME..."Active memory pool (%i):", gMemoryPool.Length);
	for(int i = 0; i < gMemoryPool.Length; i++)
	{
		gMemoryPool.GetArray(i, entry, sizeof(MemoryPoolEntry));
		PrintToServer(SNAME..."[%i]: 0x%08X \"%s\"", i, entry.addr, entry.name);
	}
}
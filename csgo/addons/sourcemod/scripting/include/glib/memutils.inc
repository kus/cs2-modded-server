#if defined _memutils_included
#endinput
#endif
#define _memutils_included

#if !defined SNAME
#define __SNAME ""
#else
#define __SNAME SNAME
#endif

#define MEM_LEN_SAFE_THRESHOLD 2000

//-==ASSERTS
#define ASSERT_FMT_STRING_LEN 512

#if defined DISABLE_ASSERTION
#define ASSERT(%1)%2;
#define ASSERT_MSG(%1,%2)%3;
#define ASSERT_FINAL(%1)%2;
#define ASSERT_FINAL_MSG(%1,%2)%3;
#elseif defined CUSTOM_ASSERTION_FAILSTATE && defined FAILSTATE_FUNC
#define ASSERT(%1) if(!(%1)) FAILSTATE_FUNC(__SNAME..."Assertion failed: \""...#%1..."\"")
#define ASSERT_MSG(%1,%2) if(!(%1)) FAILSTATE_FUNC(__SNAME...%2)
#define ASSERT_FINAL(%1) if(!(%1)) SetFailState(__SNAME..."Assertion failed: \""...#%1..."\"")
#define ASSERT_FINAL_MSG(%1,%2) if(!(%1)) SetFailState(__SNAME...%2)
#else
#define ASSERT(%1) if(!(%1)) SetFailState(__SNAME..."Assertion failed: \""...#%1..."\"")
#define ASSERT_MSG(%1,%2) if(!(%1)) SetFailState(__SNAME...%2)
#define ASSERT_FINAL(%1) ASSERT(%1)
#define ASSERT_FINAL_MSG(%1,%2) ASSERT_MSG(%1,%2)
#endif

stock void ASSERT_FMT(bool result, char[] fmt, any ...)
{
#if !defined DISABLE_ASSERTION
	if(!result)
	{
		char buff[ASSERT_FMT_STRING_LEN];
		VFormat(buff, sizeof(buff), fmt, 3);
		
		SetFailState(__SNAME..."%s", buff);
	}
#endif
}
//ASSERS END==-

//-==Operator overloadings
stock Address operator+(Address l, int r)
{
	return l + view_as<Address>(r);
}

stock Address operator+(int l, Address r)
{
	return view_as<Address>(l) + r;
}

stock Address operator-(Address l, int r)
{
	return l - view_as<Address>(r);
}

stock Address operator-(int l, Address r)
{
	return view_as<Address>(l) - r;
}

stock Address operator*(Address l, int r)
{
	return l * view_as<Address>(r);
}

stock Address operator*(int l, Address r)
{
	return view_as<Address>(l) * r;
}

stock Address operator/(Address l, int r)
{
	return l / view_as<Address>(r);
}

stock Address operator/(int l, Address r)
{
	return view_as<Address>(l) / r;
}
//Operator overloadings==-

//-==PatchHandling methodmap
static StringMap gPatchStack;

methodmap PatchHandler
{
	public PatchHandler(Address addr)
	{
		ASSERT(addr != Address_Null);
		
		if(!gPatchStack)
			gPatchStack = new StringMap();
		
		return view_as<PatchHandler>(addr);
	}
	
	property Address Address
	{
		public get() { return view_as<Address>(this); }
	}
	
	property any Any
	{
		public get() { return view_as<any>(this); }
	}
	
	public void Save(int len)
	{
		ASSERT(gPatchStack);
		ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
		
		len++;
		
		int[] arr = new int[len];
		arr[0] = len;
		
		for(int i = 0; i < len - 1; i++)
			arr[i + 1] = LoadFromAddress(this.Address + i, NumberType_Int8);
		
		char buff[32];
		IntToString(this.Any, buff, sizeof(buff));
		gPatchStack.SetArray(buff, arr, len);
	}
	
	public void PatchNSave(int len, char byte = 0x90)
	{
		ASSERT(gPatchStack);
		ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
		
		len++;
		
		int[] arr = new int[len];
		arr[0] = len;
		
		for(int i = 0; i < len - 1; i++)
		{
			arr[i + 1] = LoadFromAddress(this.Address + i, NumberType_Int8);
			StoreToAddress(this.Address + i, byte, NumberType_Int8);
		}
		
		char buff[32];
		IntToString(this.Any, buff, sizeof(buff));
		gPatchStack.SetArray(buff, arr, len);
	}
	
	public void Restore()
	{
		if(!gPatchStack)
			return;
		
		char buff[32];
		IntToString(this.Any, buff, sizeof(buff));
		
		int arrSize[1];
		if(!gPatchStack.GetArray(buff, arrSize, sizeof(arrSize)))
			return;
		
		int[] arr = new int[arrSize[0]];
		gPatchStack.GetArray(buff, arr, arrSize[0]);
		gPatchStack.Remove(buff);
		
		for(int i = 0; i < arrSize[0] - 1; i++)
			StoreToAddress(this.Address + i, arr[i + 1], NumberType_Int8);
		
		if(gPatchStack.Size == 0)
			delete gPatchStack;
	}
}

public void OnPluginEnd()
{
	if(gPatchStack)
	{
		StringMapSnapshot sms = gPatchStack.Snapshot();
		char buff[32];
		Address addr;
		
		for(int i = 0; i < sms.Length; i++)
		{
			sms.GetKey(i, buff, sizeof(buff));
			addr = view_as<Address>(StringToInt(buff));
			view_as<PatchHandler>(addr).Restore();
		}
	}
	
#if !defined MEMUTILS_NOPLENDCALL
	OnPluginEnd_MemUtilsRedefined();
#endif
}
#undef OnPluginEnd
#define OnPluginEnd OnPluginEnd_MemUtilsRedefined
//PatchHandling methodmap==-

//-==Other util functions
stock void DumpOnAddress(Address addr, int len, int columns = 10)
{
	char buff[128], buff2[128];
	
	ASSERT(addr != Address_Null);
	ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
	
	Format(buff, sizeof(buff), "[0x%08X]", addr);
	char chr;
	for(int i = 0; i < len; i++)
	{
		chr = LoadFromAddress(addr + i, NumberType_Int8);
		Format(buff, sizeof(buff), "%s %02X", buff, chr);
		Format(buff2, sizeof(buff2), "%s%c", buff2, (chr > ' ' && chr != 0x7F && chr != 0xFF ? chr : '.'));
		if(i % columns == columns - 1)
		{
			PrintToServer(__SNAME..."%s %s", buff, buff2);
			Format(buff, sizeof(buff), "[0x%08X]", addr + i);
			buff2[0] = '\0';
		}
	}
	
	if((len - 1) % columns != columns - 1)
		PrintToServer(__SNAME..."%s %s", buff, buff2);
}

//NO OVERLAPPING!!
stock void MoveBytes(Address from, Address to, int len, char replace_with = 0x90)
{
	ASSERT(from != Address_Null);
	ASSERT(to != Address_Null);
	ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
	ASSERT(to < from || to > from + len);
	
	if(from == to)
		return;
	
	for(int i = 0; i < len; i++)
	{
		StoreToAddress(to + i, LoadFromAddress(from + i, NumberType_Int8), NumberType_Int8);
		StoreToAddress(from + i, replace_with, NumberType_Int8);
	}
}

stock void CutNCopyBytes(Address from, Address to, int len, char replace_with = 0x90)
{
	ASSERT(from != Address_Null);
	ASSERT(to != Address_Null);
	ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
	
	if(from == to)
		return;
	
	int[] arr = new int[len];
	
	for(int i = 0; i < len; i++)
	{
		arr[i] = LoadFromAddress(from + i, NumberType_Int8);
		StoreToAddress(from + i, replace_with, NumberType_Int8);
	}
	
	for(int i = 0; i < len; i++)
		StoreToAddress(to + i, arr[i], NumberType_Int8);
}

stock void PatchArea(Address addr, int len, char byte = 0x90)
{
	ASSERT(addr != Address_Null);
	ASSERT(len > 0 && len < MEM_LEN_SAFE_THRESHOLD);
	
	for(int i = 0; i < len; i++)
		StoreToAddress(addr + i, byte, NumberType_Int8);
}
//Other util functions==-

#undef MEM_LEN_SAFE_THRESHOLD
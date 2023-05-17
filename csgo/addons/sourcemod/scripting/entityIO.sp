#pragma semicolon 1
#pragma dynamic 1048576
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

public Plugin myinfo =
{
	name = "Entity Inputs & Outputs",
	author = "Ilusion",
	description = "Forwards and Natives for entity inputs and outputs.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

#define FIELDTYPE_VOID                   0
#define FIELDTYPE_FLOAT                  1
#define FIELDTYPE_STRING                 2
#define FIELDTYPE_VECTOR                 3
#define FIELDTYPE_INTEGER                5
#define FIELDTYPE_BOOLEAN                6
#define FIELDTYPE_SHORT                  7
#define FIELDTYPE_CHARACTER              8
#define FIELDTYPE_COLOR32                9
#define FIELDTYPE_CLASSPTR               12
#define FIELDTYPE_EHANDLE                13
#define FIELDTYPE_POSITION_VECTOR        15

#define FIELDTYPE_DESC_INPUT         8
#define FIELDTYPE_DESC_OUTPUT        16

enum EntityIO_VariantType
{
	EntityIO_VariantType_None,
	EntityIO_VariantType_Float,
	EntityIO_VariantType_String,
	EntityIO_VariantType_Vector,
	EntityIO_VariantType_Integer,
	EntityIO_VariantType_Boolean,
	EntityIO_VariantType_Character,
	EntityIO_VariantType_Color,
	EntityIO_VariantType_Entity,
	EntityIO_VariantType_PosVector
}

enum struct EntityIO_VariantInfo
{
	bool bValue;
	int iValue;
	float flValue;
	char sValue[256];
	int clrValue[4];
	float vecValue[3];
	EntityIO_VariantType variantType;
}

enum struct OutputInfo
{
	int offset;
	char output[256];
}

bool g_IsBaseEntityMapDataRetrieved;

int g_Offset_InputVariantType;
int g_Offset_InputVariantSize;
int g_Offset_ActionList;
int g_Offset_ActionTarget;
int g_Offset_ActionInput;
int g_Offset_ActionParam;
int g_Offset_ActionDelay;
int g_Offset_ActionTimesToFire;
int g_Offset_ActionIDStamp;
int g_Offset_ActionNext;
int g_Offset_DataDescMap;
int g_Offset_DataNumFields;
int g_Offset_DataClassName;
int g_Offset_DataBaseMap;
int g_Offset_DataFieldOffset;
int g_Offset_DataFieldFlags;
int g_Offset_DataFieldName;
int g_Offset_DataFieldSize;

ArrayList g_List_BaseEntityInputs;
ArrayList g_List_BaseEntityOutputs;

GlobalForward g_Forward_OnEntityInput;
GlobalForward g_Forward_OnEntityInput_Post;

Handle g_DHook_AcceptInput;
Handle g_SDKCall_GetDataDescMap;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("EntityIO_HasEntityInput", Native_HasEntityInput);
	CreateNative("EntityIO_FindEntityFirstInput", Native_FindEntityFirstInput);
	CreateNative("EntityIO_FindEntityNextInput", Native_FindEntityNextInput);
	CreateNative("EntityIO_GetEntityInputName", Native_GetEntityInputName);
	
	CreateNative("EntityIO_HasEntityOutput", Native_HasEntityOutput);
	CreateNative("EntityIO_FindEntityOutputOffset", Native_FindEntityOutputOffset);
	CreateNative("EntityIO_FindEntityFirstOutput", Native_FindEntityFirstOutput);
	CreateNative("EntityIO_FindEntityNextOutput", Native_FindEntityNextOutput);
	CreateNative("EntityIO_GetEntityOutputName", Native_GetEntityOutputName);
	CreateNative("EntityIO_GetEntityOutputOffset", Native_GetEntityOutputOffset);
	
	CreateNative("EntityIO_AddEntityOutputAction", Native_AddEntityOutputAction);
	CreateNative("EntityIO_FindEntityFirstOutputAction", Native_FindEntityFirstOutputAction);
	CreateNative("EntityIO_FindEntityNextOutputAction", Native_FindEntityNextOutputAction);
	CreateNative("EntityIO_GetEntityOutputActionTarget", Native_GetEntityOutputActionTarget);
	CreateNative("EntityIO_GetEntityOutputActionInput", Native_GetEntityOutputActionInput);
	CreateNative("EntityIO_GetEntityOutputActionParam", Native_GetEntityOutputActionParam);
	CreateNative("EntityIO_GetEntityOutputActionDelay", Native_GetEntityOutputActionDelay);
	CreateNative("EntityIO_GetEntityOutputActionTimesToFire", Native_GetEntityOutputActionTimesToFire);
	CreateNative("EntityIO_GetEntityOutputActionID", Native_GetEntityOutputActionID);
	
	RegPluginLibrary("entityIO");
}

public void OnPluginStart()
{	
	Handle configFile = LoadGameConfigFile("entityIO.games");
	if (!configFile)
	{
		SetFailState("Failed to load \"entityIO.games\" gamedata.");
	}
	
	int acceptInputOffset = GameConfGetOffset(configFile, "CBaseEntity::AcceptInput");
	if (acceptInputOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntity::AcceptInput\" offset.");
	}
	
	g_Offset_InputVariantType = GameConfGetOffset(configFile, "variant_t::fieldType");
	if (g_Offset_InputVariantType == -1)
	{
		SetFailState("Failed to load \"variant_t::fieldType\" offset.");
	}
	
	g_Offset_InputVariantSize = GameConfGetOffset(configFile, "sizeof::variant_t");
	if (g_Offset_InputVariantSize == -1)
	{
		SetFailState("Failed to load \"sizeof::variant_t\" offset.");
	}
	
	g_Offset_ActionList = GameConfGetOffset(configFile, "CBaseEntityOutput::m_ActionList");
	if (g_Offset_ActionList == -1)
	{
		SetFailState("Failed to load \"CBaseEntityOutput::m_ActionList\" offset.");
	}
	
	g_Offset_ActionTarget = GameConfGetOffset(configFile, "CEventAction::m_iTarget");
	if (g_Offset_ActionTarget == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTarget\" offset.");
	}
	
	g_Offset_ActionInput = GameConfGetOffset(configFile, "CEventAction::m_iTargetInput");
	if (g_Offset_ActionInput == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTargetInput\" offset.");
	}
	
	g_Offset_ActionParam = GameConfGetOffset(configFile, "CEventAction::m_iParameter");
	if (g_Offset_ActionParam == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iParameter\" offset.");
	}
	
	g_Offset_ActionDelay = GameConfGetOffset(configFile, "CEventAction::m_flDelay");
	if (g_Offset_ActionDelay == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_flDelay\" offset.");
	}
	
	g_Offset_ActionTimesToFire = GameConfGetOffset(configFile, "CEventAction::m_nTimesToFire");
	if (g_Offset_ActionTimesToFire == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_nTimesToFire\" offset.");
	}
	
	g_Offset_ActionIDStamp = GameConfGetOffset(configFile, "CEventAction::m_iIDStamp");
	if (g_Offset_ActionIDStamp == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iIDStamp\" offset.");
	}
	
	g_Offset_ActionNext = GameConfGetOffset(configFile, "CEventAction::s_iNextIDStamp");
	if (g_Offset_ActionNext == -1)
	{
		SetFailState("Failed to load \"CEventAction::s_iNextIDStamp\" offset.");
	}
	
	int getDataDescMapOffset = GameConfGetOffset(configFile, "CBaseEntity::GetDataDescMap");
	if (getDataDescMapOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntity::GetDataDescMap\" offset.");
	}
	
	g_Offset_DataDescMap = GameConfGetOffset(configFile, "datamap_t::dataDesc");
	if (g_Offset_DataDescMap == -1)
	{
		SetFailState("Failed to load \"datamap_t::dataDesc\" offset.");
	}
	
	g_Offset_DataNumFields = GameConfGetOffset(configFile, "datamap_t::dataNumFields");
	if (g_Offset_DataNumFields == -1)
	{
		SetFailState("Failed to load \"datamap_t::dataNumFields\" offset.");
	}
	
	g_Offset_DataClassName = GameConfGetOffset(configFile, "datamap_t::dataClassName");
	if (g_Offset_DataClassName == -1)
	{
		SetFailState("Failed to load \"datamap_t::dataClassName\" offset.");
	}
	
	g_Offset_DataBaseMap = GameConfGetOffset(configFile, "datamap_t::baseMap");
	if (g_Offset_DataBaseMap == -1)
	{
		SetFailState("Failed to load \"datamap_t::baseMap\" offset.");
	}
	
	g_Offset_DataFieldOffset = GameConfGetOffset(configFile, "typedescription_t::fieldOffset");
	if (g_Offset_DataFieldOffset == -1)
	{
		SetFailState("Failed to load \"typedescription_t::fieldOffset\" offset.");
	}
	
	g_Offset_DataFieldFlags = GameConfGetOffset(configFile, "typedescription_t::flags");
	if (g_Offset_DataFieldFlags == -1)
	{
		SetFailState("Failed to load \"typedescription_t::flags\" offset.");
	}
	
	g_Offset_DataFieldName = GameConfGetOffset(configFile, "typedescription_t::externalName");
	if (g_Offset_DataFieldName == -1)
	{
		SetFailState("Failed to load \"typedescription_t::externalName\" offset.");
	}
	
	g_Offset_DataFieldSize = GameConfGetOffset(configFile, "sizeof::typedescription_t");
	if (g_Offset_DataFieldSize == -1)
	{
		SetFailState("Failed to load \"sizeof::typedescription_t\" offset.");
	}
	
	delete configFile;
	
	g_DHook_AcceptInput = DHookCreate(acceptInputOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Object, g_Offset_InputVariantSize, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Int);
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(getDataDescMapOffset);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_SDKCall_GetDataDescMap = EndPrepSDKCall();
	
	if (!g_SDKCall_GetDataDescMap)
	{
		SetFailState("Failed to set up \"GetDataDescMap\" call.");
	}
	
	g_List_BaseEntityInputs = new ArrayList(ByteCountToCells(256));
	g_List_BaseEntityOutputs = new ArrayList(sizeof(OutputInfo));
	
	g_Forward_OnEntityInput = new GlobalForward("EntityIO_OnEntityInput", ET_Hook, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef, Param_Array, Param_Cell);
	g_Forward_OnEntityInput_Post = new GlobalForward("EntityIO_OnEntityInput_Post", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Array, Param_Cell);
	
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "*")) != -1)
	{
		DHookEntity(g_DHook_AcceptInput, false, entity, INVALID_FUNCTION, DHook_AcceptInput);
		DHookEntity(g_DHook_AcceptInput, true, entity, INVALID_FUNCTION, DHook_AcceptInput_Post);
	}
}

public void OnMapStart()
{
	g_IsBaseEntityMapDataRetrieved = false;
}

public void OnMapEnd()
{
	g_List_BaseEntityInputs.Clear();
	g_List_BaseEntityOutputs.Clear();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	DHookEntity(g_DHook_AcceptInput, false, entity, INVALID_FUNCTION, DHook_AcceptInput);
	DHookEntity(g_DHook_AcceptInput, true, entity, INVALID_FUNCTION, DHook_AcceptInput_Post);
}

public MRESReturn DHook_AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	char input[256];
	DHookGetParamString(hParams, 1, input, sizeof(input));
	
	int activator = -1;
	if (!DHookIsNullParam(hParams, 2))
	{
		activator = DHookGetParam(hParams, 2);
	}
	
	int caller = -1;
	if (!DHookIsNullParam(hParams, 3))
	{
		caller = DHookGetParam(hParams, 3);
	}
	
	EntityIO_VariantInfo variantInfo;
	int variantType = DHookGetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int);
	
	switch (variantType)
	{
		case FIELDTYPE_FLOAT:
		{
			variantInfo.flValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Float);
			variantInfo.variantType = EntityIO_VariantType_Float;
		}
		
		case FIELDTYPE_STRING:
		{
			DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, variantInfo.sValue, sizeof(EntityIO_VariantInfo::sValue));
			variantInfo.variantType = EntityIO_VariantType_String;
		}
		
		case FIELDTYPE_VECTOR:
		{
			DHookGetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			variantInfo.variantType = EntityIO_VariantType_Vector;
		}
		
		case FIELDTYPE_INTEGER, FIELDTYPE_SHORT:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.variantType = EntityIO_VariantType_Integer;
		}
		
		case FIELDTYPE_BOOLEAN:
		{
			variantInfo.bValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Bool);
			variantInfo.variantType = EntityIO_VariantType_Boolean;
		}
		
		case FIELDTYPE_CHARACTER:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.variantType = EntityIO_VariantType_Character;
		}
		
		case FIELDTYPE_COLOR32:
		{
			int color = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.clrValue[0] = color & 0xFF;
			variantInfo.clrValue[1] = (color >> 8) & 0xFF;
			variantInfo.clrValue[2] = (color >> 16) & 0xFF;
			variantInfo.clrValue[3] = (color >> 24) & 0xFF;
			variantInfo.variantType = EntityIO_VariantType_Color;
		}
		
		case FIELDTYPE_CLASSPTR:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_CBaseEntityPtr);
			variantInfo.variantType = EntityIO_VariantType_Entity;
		}
		
		case FIELDTYPE_EHANDLE:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Ehandle);
			variantInfo.variantType = EntityIO_VariantType_Entity;
		}
		
		case FIELDTYPE_POSITION_VECTOR:
		{
			DHookGetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			variantInfo.variantType = EntityIO_VariantType_PosVector;
		}
		
		default:
		{
			variantInfo.variantType = EntityIO_VariantType_None;
		}
	}
	
	int outputId = DHookGetParam(hParams, 5);	
	
	Action result = Plugin_Continue;
	Call_StartForward(g_Forward_OnEntityInput);
	Call_PushCell(pThis);
	Call_PushStringEx(input, sizeof(input), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCellRef(activator);
	Call_PushCellRef(caller);
	Call_PushArrayEx(variantInfo, sizeof(EntityIO_VariantInfo), SM_PARAM_COPYBACK);
	Call_PushCell(outputId);
	Call_Finish(result);
	
	if (result == Plugin_Handled || result == Plugin_Stop)
	{
		DHookSetReturn(hReturn, false);
		return MRES_Supercede;
	}
	
	if (result == Plugin_Changed)
	{
		DHookSetParamString(hParams, 1, input);
		
		if (activator == -1 || IsValidEntity(activator))
		{
			DHookSetParam(hParams, 2, activator);
		}
		
		if (caller == -1 || IsValidEntity(caller))
		{
			DHookSetParam(hParams, 3, caller);
		}
		
		switch (variantInfo.variantType)
		{
			case EntityIO_VariantType_None:
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_VOID);
			}
			
			case EntityIO_VariantType_Float: 
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_FLOAT);
				DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Float, variantInfo.flValue);
			}
			
			case EntityIO_VariantType_String:
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_STRING);
				DHookSetParamString(hParams, 4, variantInfo.sValue);
			}
			
			case EntityIO_VariantType_Vector:
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_VECTOR);
				DHookSetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			}
			
			case EntityIO_VariantType_Integer: 
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_INTEGER);
				DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int, variantInfo.iValue);
			}
			
			case EntityIO_VariantType_Boolean: 
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_BOOLEAN);
				DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Bool, variantInfo.bValue);
			}
			
			case EntityIO_VariantType_Character: 
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_CHARACTER);
				DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int, variantInfo.iValue);
			}
			
			case EntityIO_VariantType_Color:
			{
				int color = ((variantInfo.clrValue[0] & 0xFF) << 16) | ((variantInfo.clrValue[1] & 0xFF) << 8) | (variantInfo.clrValue[2] & 0xFF);
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_COLOR32);
				DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int, color);
			}
			
			case EntityIO_VariantType_Entity: 
			{
				if (variantInfo.iValue != -1 && IsValidEntity(variantInfo.iValue))
				{
					DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_CLASSPTR);
					DHookSetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_CBaseEntityPtr, variantInfo.iValue);
				}
				else
				{
					DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_VOID);
				}
			}
			
			case EntityIO_VariantType_PosVector:
			{
				DHookSetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int, FIELDTYPE_POSITION_VECTOR);
				DHookSetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			}
		}
		
		return MRES_ChangedHandled;
	}
	
	return MRES_Ignored;
}

public MRESReturn DHook_AcceptInput_Post(int pThis, Handle hReturn, Handle hParams)
{
	char input[256];
	DHookGetParamString(hParams, 1, input, sizeof(input));
	
	int activator = -1;
	if (!DHookIsNullParam(hParams, 2))
	{
		activator = DHookGetParam(hParams, 2);
	}
	
	int caller = -1;
	if (!DHookIsNullParam(hParams, 3))
	{
		caller = DHookGetParam(hParams, 3);
	}
	
	EntityIO_VariantInfo variantInfo;
	int fieldType = DHookGetParamObjectPtrVar(hParams, 4, g_Offset_InputVariantType, ObjectValueType_Int);
	
	switch (fieldType)
	{
		case FIELDTYPE_FLOAT:
		{
			variantInfo.flValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Float);
			variantInfo.variantType = EntityIO_VariantType_Float;
		}
		
		case FIELDTYPE_STRING:
		{
			DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, variantInfo.sValue, sizeof(EntityIO_VariantInfo::sValue));
			variantInfo.variantType = EntityIO_VariantType_String;
		}
		
		case FIELDTYPE_VECTOR:
		{
			DHookGetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			variantInfo.variantType = EntityIO_VariantType_Vector;
		}
		
		case FIELDTYPE_INTEGER, FIELDTYPE_SHORT:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.variantType = EntityIO_VariantType_Integer;
		}
		
		case FIELDTYPE_BOOLEAN:
		{
			variantInfo.bValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Bool);
			variantInfo.variantType = EntityIO_VariantType_Boolean;
		}
		
		case FIELDTYPE_CHARACTER:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.variantType = EntityIO_VariantType_Character;
		}
		
		case FIELDTYPE_COLOR32:
		{
			int color = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			variantInfo.clrValue[0] = color & 0xFF;
			variantInfo.clrValue[1] = (color >> 8) & 0xFF;
			variantInfo.clrValue[2] = (color >> 16) & 0xFF;
			variantInfo.clrValue[3] = (color >> 24) & 0xFF;
			variantInfo.variantType = EntityIO_VariantType_Color;
		}
		
		case FIELDTYPE_CLASSPTR:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_CBaseEntityPtr);
			variantInfo.variantType = EntityIO_VariantType_Entity;
		}
		
		case FIELDTYPE_EHANDLE:
		{
			variantInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Ehandle);
			variantInfo.variantType = EntityIO_VariantType_Entity;
		}
		
		case FIELDTYPE_POSITION_VECTOR:
		{
			DHookGetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, variantInfo.vecValue);
			variantInfo.variantType = EntityIO_VariantType_PosVector;
		}
		
		default:
		{
			variantInfo.variantType = EntityIO_VariantType_None;
		}
	}
	
	int outputId = DHookGetParam(hParams, 5);	
	
	Call_StartForward(g_Forward_OnEntityInput_Post);
	Call_PushCell(pThis);
	Call_PushString(input);
	Call_PushCell(activator);
	Call_PushCell(caller);
	Call_PushArray(variantInfo, sizeof(EntityIO_VariantInfo));
	Call_PushCell(outputId);
	Call_Finish();
	
	return MRES_Ignored;
}

void GetBaseEntityMapData(Address dataMap)
{
	Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
	if (dataDesc)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			Address address = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldName), NumberType_Int32));
			if (address == Address_Null)
			{
				continue;
			}
			
			char externalName[256];
			GetStringFromAddress(address, externalName, sizeof(externalName));
			
			int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
			if (view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
			{
				g_List_BaseEntityInputs.PushString(externalName);
			}
			
			if (view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
			{
				OutputInfo outputInfo;
				outputInfo.offset = view_as<int>(LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldOffset), NumberType_Int32));
				strcopy(outputInfo.output, sizeof(OutputInfo::output), externalName);
				
				g_List_BaseEntityOutputs.PushArray(outputInfo);
			}
		}
		
		g_IsBaseEntityMapDataRetrieved = true;
	}
}

int GetStringFromAddress(Address address, char[] buffer, int maxLen)
{
	int i;
	while (i < maxLen)
	{
		buffer[i] = view_as<char>(LoadFromAddress(address + view_as<Address>(i), NumberType_Int8));
		if (!buffer[i])
		{
			break;
		}
		
		i++;
	}
	
	return i;
}

public int Native_HasEntityInput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char input[256];
	GetNativeString(2, input, sizeof(input));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
				{
					continue;
				}
				
				Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldName), NumberType_Int32));
				if (addressName == Address_Null)
				{
					continue;
				}
				
				char externalName[256];
				GetStringFromAddress(addressName, externalName, sizeof(externalName));
				
				if (!StrEqual(input, externalName, false))
				{
					continue;
				}
				
				return true;
			}
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity inputs
	char baseInput[256];
	for (int i = 0; g_List_BaseEntityInputs.Length; i++)
	{
		g_List_BaseEntityInputs.GetString(i, baseInput, sizeof(baseInput));
		if (!StrEqual(input, baseInput, false))
		{
			continue;
		}
		
		return true;
	}
	
	return false;
}

public int Native_FindEntityFirstInput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
				{
					continue;
				}
				
				StringMap iterator = new StringMap();
				iterator.SetValue("dataIndex", i);
				iterator.SetValue("dataMap", dataMap);
				iterator.SetValue("dataDesc", dataDesc);
				
				return view_as<int>(iterator);
			}
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity inputs
	if (g_List_BaseEntityInputs.Length)
	{
		StringMap iterator = new StringMap();
		iterator.SetValue("dataMap", Address_Null);
		
		return view_as<int>(iterator);
	}
	
	return view_as<int>(INVALID_HANDLE);
}

public int Native_FindEntityNextInput(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	int dataIndex;
	int baseIndex;
	Address dataMap;
	
	iterator.GetValue("dataIndex", dataIndex);
	iterator.GetValue("baseIndex", baseIndex);
	iterator.GetValue("dataMap", dataMap);
	
	if (dataMap != Address_Null)
	{
		dataIndex += g_Offset_DataFieldSize;
	}
	else
	{
		baseIndex++;
	}
	
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = dataIndex; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
				{
					continue;
				}
				
				iterator.SetValue("dataIndex", i);
				iterator.SetValue("dataMap", dataMap);
				iterator.SetValue("dataDesc", dataDesc);
				
				return true;
			}
		}
		
		dataIndex = 0;
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity inputs
	for (int i = baseIndex; i < g_List_BaseEntityInputs.Length; i++)
	{
		iterator.SetValue("baseIndex", i);
		iterator.SetValue("dataMap", Address_Null);
		
		return true;
	}
	
	return false;
}

public int Native_GetEntityInputName(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	int dataIndex;
	int baseIndex;
	Address dataMap;
	Address dataDesc;
	
	iterator.GetValue("dataIndex", dataIndex);
	iterator.GetValue("baseIndex", baseIndex);
	iterator.GetValue("dataMap", dataMap);
	iterator.GetValue("dataDesc", dataDesc);
	
	int length;
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	if (dataMap != Address_Null)
	{
		Address address = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(dataIndex + g_Offset_DataFieldName), NumberType_Int32));
		if (address != Address_Null)
		{
			length = GetStringFromAddress(address, buffer, maxLen);
		}
	}
	else
	{
		length = g_List_BaseEntityInputs.GetString(baseIndex, buffer, maxLen);
	}
	
	SetNativeString(2, buffer, maxLen);
	return length;
}

public int Native_HasEntityOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
				{
					continue;
				}
				
				Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldName), NumberType_Int32));
				if (addressName == Address_Null)
				{
					continue;
				}
				
				char externalName[256];
				GetStringFromAddress(addressName, externalName, sizeof(externalName));
				
				if (!StrEqual(output, externalName, false))
				{
					continue;
				}
				
				return true;
			}
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity outputs
	OutputInfo outputInfo;
	for (int i = 0; i < g_List_BaseEntityOutputs.Length; i++)
	{
		g_List_BaseEntityOutputs.GetArray(i, outputInfo);
		if (!StrEqual(output, outputInfo.output, false))
		{
			continue;
		}
		
		return true;
	}
	
	return false;
}

public int Native_FindEntityOutputOffset(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
				{
					continue;
				}
				
				Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldName + i), NumberType_Int32));
				if (addressName == Address_Null)
				{
					continue;
				}
				
				char externalName[256];
				GetStringFromAddress(addressName, externalName, sizeof(externalName));
				
				if (!StrEqual(output, externalName, false))
				{
					continue;
				}
				
				return view_as<int>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldOffset + i), NumberType_Int16));
			}
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity outputs
	OutputInfo outputInfo;
	for (int i = 0; i < g_List_BaseEntityOutputs.Length; i++)
	{
		g_List_BaseEntityOutputs.GetArray(i, outputInfo);
		if (!StrEqual(output, outputInfo.output, false))
		{
			continue;
		}
		
		return outputInfo.offset;
	}
	
	return -1;
}

public int Native_FindEntityFirstOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
				{
					continue;
				}
				
				StringMap iterator = new StringMap();
				iterator.SetValue("dataIndex", i);
				iterator.SetValue("dataMap", dataMap);
				iterator.SetValue("dataDesc", dataDesc);
				
				return view_as<int>(iterator);
			}
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity outputs
	if (g_List_BaseEntityOutputs.Length)
	{
		StringMap iterator = new StringMap();
		iterator.SetValue("dataMap", Address_Null);
		
		return view_as<int>(iterator);
	}
	
	return view_as<int>(INVALID_HANDLE);
}

public int Native_FindEntityNextOutput(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	int dataIndex;
	int baseIndex;
	Address dataMap;
	
	iterator.GetValue("baseIndex", baseIndex);
	iterator.GetValue("dataIndex", dataIndex);
	iterator.GetValue("dataMap", dataMap);
	
	if (dataMap != Address_Null)
	{
		dataIndex += g_Offset_DataFieldSize;
	}
	else
	{
		baseIndex++;
	}
	
	while (dataMap != Address_Null)
	{
		Address addressClass = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataClassName), NumberType_Int32));
		if (addressClass)
		{
			char className[256];
			GetStringFromAddress(addressClass, className, sizeof(className));
			
			// do not search in BaseEntity map
			if (StrEqual(className, "CBaseEntity", true))
			{
				if (!g_IsBaseEntityMapDataRetrieved)
				{
					GetBaseEntityMapData(dataMap);
				}
				
				break;
			}
		}
		
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		if (dataDesc)
		{
			int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
			for (int i = dataIndex; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
			{
				int flags = LoadFromAddress(dataDesc + view_as<Address>(i + g_Offset_DataFieldFlags), NumberType_Int16);
				if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
				{
					continue;
				}
				
				iterator.SetValue("dataIndex", i);
				iterator.SetValue("dataMap", dataMap);
				iterator.SetValue("dataDesc", dataDesc);
				
				return true;
			}
		}
		
		dataIndex = 0;
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	// search in BaseEntity outputs
	for (int i = baseIndex; i < g_List_BaseEntityOutputs.Length; i++)
	{
		iterator.SetValue("baseIndex", i);
		iterator.SetValue("dataMap", Address_Null);
		
		return true;
	}
	
	return false;
}

public int Native_GetEntityOutputName(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	int dataIndex;
	int baseIndex;
	Address dataMap;
	Address dataDesc;
	
	iterator.GetValue("dataIndex", dataIndex);
	iterator.GetValue("baseIndex", baseIndex);
	iterator.GetValue("dataMap", dataMap);
	iterator.GetValue("dataDesc", dataDesc);
	
	int length;
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	if (dataMap != Address_Null)
	{
		Address address = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(dataIndex + g_Offset_DataFieldName), NumberType_Int32));
		if (address != Address_Null)
		{
			length = GetStringFromAddress(address, buffer, maxLen);
		}
	}
	else
	{
		OutputInfo outputInfo;
		g_List_BaseEntityOutputs.GetArray(baseIndex, outputInfo);
		
		length = strcopy(buffer, maxLen, outputInfo.output);
	}
	
	SetNativeString(2, buffer, maxLen);
	return length;
}

public int Native_GetEntityOutputOffset(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	int dataIndex;
	int baseIndex;
	Address dataMap;
	Address dataDesc;
	
	iterator.GetValue("dataIndex", dataIndex);
	iterator.GetValue("baseIndex", baseIndex);
	iterator.GetValue("dataMap", dataMap);
	iterator.GetValue("dataDesc", dataDesc);
	
	if (dataMap != Address_Null)
	{
		return view_as<int>(LoadFromAddress(dataDesc + view_as<Address>(dataIndex + g_Offset_DataFieldOffset), NumberType_Int32));
	}
	
	OutputInfo outputInfo;
	g_List_BaseEntityOutputs.GetArray(baseIndex, outputInfo);
	
	return outputInfo.offset;
}

public int Native_AddEntityOutputAction(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	int maxLen = 256;
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	maxLen += strlen(output);
	
	char target[256];
	GetNativeString(3, target, sizeof(target));
	maxLen += strlen(target);
	
	char input[256];
	GetNativeString(4, input, sizeof(input));
	maxLen += strlen(input);
	
	char param[256];
	GetNativeString(5, param, sizeof(param));
	maxLen += strlen(param);
	
	char[] buffer = new char[maxLen];
	FormatEx(buffer, maxLen, "%s %s:%s:%s:%f:%d", output, target, input, param, GetNativeCell(6), GetNativeCell(7));
	SetVariantString(buffer);
	
	return AcceptEntityInput(entity, "AddOutput");
}

public int Native_FindEntityFirstOutputAction(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	int offset = GetNativeCell(2);
	if (offset == -1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output offset %d", offset);
	}
	
	Address address = GetEntityAddress(entity);
	if (address != Address_Null)
	{
		address = view_as<Address>(LoadFromAddress(address + view_as<Address>(offset) + view_as<Address>(g_Offset_ActionList), NumberType_Int32));
		if (address != Address_Null)
		{
			StringMap iterator = new StringMap();
			iterator.SetValue("actionAddress", address);
			
			return view_as<int>(iterator);
		}
	}
	
	return view_as<int>(INVALID_HANDLE);
}

public int Native_FindEntityNextOutputAction(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionNext), NumberType_Int32));
	if (address != Address_Null)
	{
		iterator.SetValue("actionAddress", address);
		return true;
	}
	
	return false;
}

public int Native_GetEntityOutputActionTarget(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	int length;
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionTarget), NumberType_Int32));
	if (address != Address_Null)
	{
		length = GetStringFromAddress(address, buffer, maxLen);
	}
	
	SetNativeString(2, buffer, maxLen);
	return length;
}

public int Native_GetEntityOutputActionInput(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	int length;
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionInput), NumberType_Int32));
	if (address != Address_Null)
	{
		length = GetStringFromAddress(address, buffer, maxLen);
	}
	
	SetNativeString(2, buffer, maxLen);
	return length;
}

public int Native_GetEntityOutputActionParam(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	int length;
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionParam), NumberType_Int32));
	if (address != Address_Null)
	{
		length = GetStringFromAddress(address, buffer, maxLen);
	}
	
	SetNativeString(2, buffer, maxLen);
	return length;
}

public int Native_GetEntityOutputActionDelay(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionDelay), NumberType_Int32));
}

public int Native_GetEntityOutputActionTimesToFire(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionTimesToFire), NumberType_Int32));
}

public int Native_GetEntityOutputActionID(Handle plugin, int numParams)
{
	StringMap iterator = view_as<StringMap>(GetNativeCell(1));
	if (!iterator)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid handle %d", view_as<int>(iterator));
	}
	
	Address address;
	iterator.GetValue("actionAddress", address);
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionIDStamp), NumberType_Int32));
}
#if defined _SWGM_included
 #endinput
#endif
#define _SWGM_included

enum Status
{
	UNASSIGNED = 0,
	NO_GROUP,
	LEAVER,
	MEMBER,
	OFFICER
};

/**
 *	Вызывается когда клиент был проверен на группу. 
 *
 *	@param iClient			Индекс клиента.
 *	@param IsMember			Клиент в группе
 *	@param IsOfficer		Клиент Админ/Офицер в группе
 *	@noreturn
*/
forward void SWGM_OnJoinGroup(int iClient, bool IsMember, bool IsOfficer);

/**
 *	Вызывается когда клиент повторно проверяется и он вышел из группы. 
 *
 *	@param iClient			Индекс клиента.
 *	@noreturn
*/
forward void SWGM_OnLeaveGroup(int iClient);


/**
 *  Проверяет клиента на наличие в группе.
 *
 *  @param iClient          Индекс клиента.
 *  @return                 true, если в группе, иначе false.
 *  @error                  Клиент не на сервере, является ботом или его индекс превышает допустимую границу.
 */
native bool SWGM_InGroup(int iClient);

/**
 *  Проверяет на Администратора или Офицера группы.
 *
 *  @param iClient          Индекс клиента.
 *  @return                 true, если в группе, иначе false.
 *  @error                  Клиент не на сервере, является ботом или его индекс превышает допустимую границу.
 */
native bool SWGM_InGroupOfficer(int iClient);

/**
 *  Возвращает статус клиента.
 *
 *  @param iClient          Индекс клиента.
 *  @return                 Статус.
 *  @error                  Клиент не на сервере, является ботом или его индекс превышает допустимую границу.
 */
native Status SWGM_GetPlayerStatus(int iClient);

/**
 *  Запускает проверку клиента на состояние в группе.
 *
 *  @param iClient			Индекс клиента.
 *  @error                  Клиент не на сервере, является ботом или его индекс превышает допустимую границу.
 *  @noreturn
 */
native void SWGM_CheckPlayer(int iClient);

/**
 *  Проверяет загружен ли клиент.
 *
 *  @param iClient          Индекс клиента.
 *  @return                 true, если загружен, иначе fasle;
 *  @error                 	Индекс превышает допустимую границу.
 */
native bool SWGM_IsPlayerValidated(int iClient);

public SharedPlugin __pl_SWGM= 
{
	name = "SWGM",
	file = "SWGM.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_SWGM_SetNTVOptional()
{
	MarkNativeAsOptional("SWGM_InGroup");
	MarkNativeAsOptional("SWGM_InGroupOfficer");
	MarkNativeAsOptional("SWGM_GetPlayerStatus");
	MarkNativeAsOptional("SWGM_CheckPlayer");
	MarkNativeAsOptional("SWGM_IsPlayerValidated");
}
#endif
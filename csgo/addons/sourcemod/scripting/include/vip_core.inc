#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

/* Типы данных VIP-функций */
enum VIP_ValueType
{
	VIP_NULL	= 0,	// Нет данных
	INT,				// Целочисленный тип
	FLOAT,				// Числа с плавающей точкой (Дробные)
	BOOL,				// Логический тип (1/0)
	STRING				// Строчный тип
}

/* Статусы VIP-функций */
enum VIP_ToggleState
{
	DISABLED = 0,		// Выключено
	ENABLED,			// Включено
	NO_ACCESS			// Нет доступа
}

/* Типы VIP-функций */
enum VIP_FeatureType
{
	TOGGLABLE = 0,		// Вкл/Выкл в меню
	SELECTABLE,			// Только нажатие
	HIDE				// Скрытый
}

typeset ItemSelectCallback
{
	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа TOGGLABLE).
	 *	-
	 * @param iClient			Индекс игрока.
	 * @param szFeature			Уникальное имя ф-и.
	 * @param eOldStatus		Старое значение статуса.
	 * @param eNewStatus		Новое значение статуса.
	 *	-
	 * @return					Plugin_Stop или Plugin_Handled - остановит переключение статуса;
	 *							Plugin_Continue - разрешит переключение статуса без изменений;
	 *							Plugin_Changed - разрешит переключение статуса на eNewStatus.
	*/
	function Action (int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа SELECTABLE).
	 *	-
	 * @param iClient			Индекс игрока.
	 * @param szFeature			Уникальное имя ф-и.
	 *	-
	 * @return					true - снова откроет игроку VIP-меню;
	 * 							false.
	*/
	function bool (int iClient, const char[] szFeature);
};

/**
 *	Вызывается когда VIP-игроку отображается пункт в меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szDisplay			Буфер.
 * @param iMaxLength		Размер буфера.
 *	-
 * @return					true - Отображение содержимого szDisplay.
 * 							false - Отображение без изменений.
*/
typedef ItemDisplayCallback = function bool (int iClient, const char[] szFeature, char[] szDisplay, int iMaxLength);

/**
 *	Вызывается когда VIP-игроку отображается стиль пункта в меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param iStyle			Стиль.
 *	-
 * @return					Необходимый стиль (ITEMDRAW_*).
*/
typedef ItemDrawCallback = function int (int iClient, const char[] szFeature, int iStyle);

/**
 *	Вызывается когда игрок возрождается.
 *	-
 * @param iClient			Индекс игрока.
 * @param iTeam				Команда игрока (2 - Т, 3- КТ).
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP);

/**
 *	Вызывается когда игру отображается информация.
 *	-
 * @param iClient			Индекс игрока.
 * @param szEvent			Имя события:
 * 								"connect_info_time"	- VIP-игрок вошел на сервер (VIP-статус на время);
 * 								"connect_info_perm"	- VIP-игрок вошел на сервер (VIP-статус навсегда);
 * 								"no_access_info" 	- Игрок попытался открыть VIP-меню;
 * 								"connect_info_time"	- VIP-статус игрока истек.
 * @param szType			Тип сообщения:
 * 								"chat"	- В чат;
 * 								"menu"	- В меню;
 * 								"url"	- В MOTD окно.
 * @param hKeyValues		KeyValues ключа события.
 *	-
 * @return					Plugin_Stop или Plugin_Handled  - запретит показ уведомления;
 * 							Plugin_Changed - разрешит с изменениями;
 * 							Plugin_Continue - разрешит без изменений.
*/
forward Action VIP_OnShowClientInfo(int iClient, const char[] szEvent, const char[] szType, KeyValues hKeyValues);

/**
 *	Вызывается когда у VIP-игрока изменяется статус функции.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param eOldStatus		Старое значение статуса.
 * @param eNewStatus		Новое значение статуса.
 *	-
 * @return					Plugin_Stop или Plugin_Handled  - остановит переключение статуса;
 * 							Plugin_Continue  - разрешит переключение статуса без изменений;
 * 							Plugin_Changed - разрешит переключение статуса на eNewStatus.
*/
forward Action VIP_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

/**
 *	Вызывается когда VIP-плагин загрузился.
 *	-
 * @noparams
 *	-
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

/**
 *	Вызывается когда VIP-функция была зарегистрирована.
 *	-
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @noreturn
*/
forward void VIP_OnFeatureRegistered(const char[] szFeature);

/**
 *	Вызывается когда VIP-функция была удалена.
 *	-
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @noreturn
*/
forward void VIP_OnFeatureUnregistered(const char[] szFeature);

/**
 *	Вызывается перед проверкой игрока на наличие VIP-статуса.
 *	-
 * @param iClient			Индекс игрока.
 *	-

 * @return					true - продолжить.
 * 							false - не выполнять проверку.
*/
forward bool VIP_OnClientPreLoad(int iClient);

/**
 *	Вызывается когда игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward void VIP_OnClientLoaded(int iClient, bool bIsVIP);

/**
 *	Вызывается когда VIP-игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientLoaded(int iClient);

/**
 *	Вызывается когда игрок получает VIP-статус.
 *	-
 * @param iClient			Индекс игрока.
 * @param iAdmin			Индекс админа (0 - сервер).
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientAdded(int iClient, int iAdmin);

/**
 *	Вызывается когда игрок лишается VIP-статуса.
 *	-
 * @param iClient			Индекс игрока.
 * @param szReason			Причина:
 * 								"Expired" - Истек;
 * 								"Removed by Admin" - Удален админом;
 * 								"Removed by native" - Удален нативом.
 * @param iAdmin			Индекс админа (0 - сервер).
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientRemoved(int iClient, const char[] szReason, int iAdmin);

/**
 *	Запускает проверку игрока на наличие VIP прав.
 *	-
 * @param iClient			Индекс игрока.
 * @param bNotify			Известить ли игрока о результате проверки.
 * @param bForward			Вызывать ли форврад VIP_OnClientPreLoad перед проверкой.
 *	-
 * @noreturn
*/
native void VIP_CheckClient(int iClient, bool bNotify = false, bool bForward = true);

/**
 *	Получает наличие VIP прав у игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return					true - У игрока имеются VIP-статус.
 * 							false - У игрока нет VIP-статуса.
*/
native bool VIP_IsClientVIP(int iClient);

/**
 *	Получает уникальный ID VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return					Уникальный ID или -1 если временный.
*/
native int VIP_GetClientID(int iClient);

/**
 *	Получает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return					Дата в unix формате (0 - навсегда, -1 если не удалось получить).
*/
native int VIP_GetClientAccessTime(int iClient);

/**
 *	Устанавливает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 * @param iTime				Дата в unix формате, 0 если права навсегда, -1 если временный.
 * @param bInDB				Изменять ли в базе данных.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_SetClientAccessTime(int iClient, int iTime, bool bInDB = true);

/**
 *	Получает VIP-группу игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szGroup			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GetClientVIPGroup(int iClient, char[] szGroup, int iMaxLength);

/**
 *	Устанавливает игроку VIP-группу.
 *	-
 * @param iClient			Индекс игрока.
 * @param szGroup			VIP-группа.
 * @param bInDBB			Изменять ли в базе данных.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_SetClientVIPGroup(int iClient, const char[] szGroup, bool bInDB = true);

/**
 *	Получает Handle adt trie настроек VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return					StringMap (Handle) adt trie настроек VIP-игрока.
*/
native StringMap VIP_GetVIPClientTrie(int iClient);

/**
 *	Проверяет наличие VIP-группы.
 *	-
 * @param szGroup			Имя VIP-группы.
 *	-
 * @return					true - VIP-группа существует.
 * 							false -  VIP-группа не существует.
*/	
native bool VIP_IsValidVIPGroup(const char[] szGroup);

/**
 *	Выводит игроку сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param iClient			Индекс игрока.
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_PrintToChatClient(int iClient, const char[] szMessage, any ...);

/**
 *	Выводит всем игрокам сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_PrintToChatAll(const char[] szMessage, any ...);

/**
 *	Записывает сообщение в лог.
 *	-
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_LogMessage(const char[] szMessage, any ...);

/**
 *	Отправляет игроку VIP-меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param bSelection		Режим открытия:
 * 							true - на первой странице;
 * 							false - на странице последнего выбранного пункта.
 *	-
 * @noreturn
*/
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);

/**
 *	Выдает игроку VIP-права.
 *	-
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param iTime				Время в секундах.
 * @param szGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных.
 *	-
 * @noreturn
*/
native void VIP_GiveClientVIP(int iAdmin = 0, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);

#pragma deprecated Use VIP_GiveClientVIP() instead
native bool VIP_SetClientVIP(int iClient, int iTime, any AuthType, const char[] szGroup, bool bAddToDB = true);

/**
 *	Отнимает у игрока VIP-права.
 *	-
 * @param iAdmin			Индекс админа (0 - сервер).
 * @param iClient			Индекс игрока.
 * @param bInDB				Удалять ли тз базы данных.
 * @param bNotify			Уведомление игрока (true - уведомить/false - не уведомлять).
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_RemoveClientVIP2(int iAdmin = 0, int iClient, bool bInDB, bool bNotify);

#pragma deprecated Use VIP_RemoveClientVIP2() instead
native bool VIP_RemoveClientVIP(int iClient, bool bInDB, bool bNotify);

/**
 *	Проверка что ядро загружено и готово к регистрации функций.
 *	-
 * @noparams
 *	-
 * @return					true - Ядро загружено.
 * 							false - Ядро не загружено.
*/
native bool VIP_IsVIPLoaded();

/**
 *	Добавляет новую VIP-функцию.
 *	-
 * @param szFeature				Уникальное имя ф-и.
 * @param ValType				Тип данных ф-и.
 * @param FeatureType			Тип ф-и.
 * @param Item_select_callback	Обратный вызов при смене статуса ф-и.
 * @param Item_display_callback	Обратный вызов при отображении пункта ф-и .
 * @param Item_draw_callback	Обратный вызов при отображении стиля пункта ф-и.
 * @param eDefStatus			Значение по-умолчанию:
 * 									ENABLED - Включена
 * 									DISABLED - Отключена
 * 									NO_ACCESS - Не использовать (будет зависеть от sm_vip_features_default_status)
 *	-
 * @noreturn
*/

native void VIP_RegisterFeature(const char[]			szFeature,
								VIP_ValueType			eValType				= VIP_NULL,
								VIP_FeatureType			eType					= TOGGLABLE,
								ItemSelectCallback		Item_select_callback	= INVALID_FUNCTION,
								ItemDisplayCallback		Item_display_callback	= INVALID_FUNCTION,
								ItemDrawCallback		Item_draw_callback		= INVALID_FUNCTION,
								VIP_ToggleState			eDefStatus				= NO_ACCESS);

/**
 *	Удаляет VIP-функцию.
 *	-
 * @param szFeature				Уникальное имя ф-и.
 *	-
 * @noreturn
*/
native void VIP_UnregisterFeature(const char[] szFeature);

/**
 *	Удаляет все VIP-функции зарегистрированные плагином (вызывать в OnPluginEnd()).
 *	-
 * @noparams
 *	-
 * @noreturn
*/
native void VIP_UnregisterMe();

/**
 *	Проверяет существование функции.
 *	-
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					true - VIP-функция существует.
 * 							false -  VIP-функция не существует.
*/
native bool VIP_IsValidFeature(const char[] szFeature);

/**
 *	Получает тип функции.
 *	-
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает элемент списка VIP_FeatureType.
*/
native VIP_FeatureType VIP_GetFeatureType(const char[] szFeature);

/**
 *	Получает тип значения функции.
 *	-
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает элемент списка VIP_ValueType.
*/
native VIP_ValueType VIP_GetFeatureValueType(const char[] szFeature);

/**
 *	Заполняет adt массив ф-ями.
 *	-
 * @param hArray			Массив типа ArrayList.
 *	-
 * @return					Количество добавленных элементов.
*/
native int VIP_FillArrayByFeatures(ArrayList hArray);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает элемент списка VIP_ToggleState.
*/
native VIP_ToggleState VIP_GetClientFeatureStatus(int iClient, const char[] szFeature);

/**
 *	Устанавливает статус VIP-функции игроку.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param eStatus			Статус VIP-функции.
 * @param bCallback			Вызывать ли toggle каллбэк.
 * @param bSave				Сохранить ли в куки.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_SetClientFeatureStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus, bool bCallback = true, bool bSave = false);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					true - VIP-функции включена.
 * 							false - VIP-функции выключена или нет доступа.
*/
native bool VIP_IsClientFeatureUse(int iClient, const char[] szFeature);

/**
 *	Получает целочисленное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает целочисленное значение параметра VIP-функции у игрока.
*/
native int VIP_GetClientFeatureInt(int iClient, const char[] szFeature);

/**
 *	Получает дробное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает дробное значение параметра VIP-функции у игрока.
*/
native float VIP_GetClientFeatureFloat(int iClient, const char[] szFeature);

/**
 *	Получает логическое значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					Возвращает логическое значение параметра VIP-функции у игрока (true/false).
*/
native bool VIP_GetClientFeatureBool(int iClient, const char[] szFeature);

/**
 *	Получает строчное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *	-
 * @noreturn
*/
native void VIP_GetClientFeatureString(int iClient, const char[] szFeature, char[] szBuffer, int iMaxLength);

/**
 *	Выдает игроку VIP-функцию и устанавливает её значение (на время сессии).
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szValue			Значение (автоматически будет приведено к типу ф-и).
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GiveClientFeature(int iClient, const char[] szFeature, const char[] szValue);

/**
 *	Отнимает у VIP-игрока VIP-функцию (на время сессии).
 *	-
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_RemoveClientFeature(int iClient, const char[] szFeature);

/**
 *	Получает Handle базы данных. После работы необходимо закрыть с помощью CloseHandle() или delete
 *	-
 *	@noparams
 *	-
 *	@return					Database (Handle) базы данных
*/
native Database VIP_GetDatabase();

/**
 *	Получает тип базы данных.
 *	-
 *	@noparams
 *	-
 * @return					true - MySQL.
 * 							false - SQLite.
*/
native bool VIP_GetDatabaseType();

/**
 *	Получает время в секундах в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Время.
 *	-
 * @return					Возвращает количество секунд в зависимости от sm_vip_time_mode.
*/
native int VIP_TimeToSeconds(int iTime);

/**
 *	Получает время в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Количество секунд.
 *	-
 * @return					Возвращает время в зависимости от sm_vip_time_mode.
*/
native int VIP_SecondsToTime(int iTime);

/**
 *	Переводит секунды в человекопонятный вид.
 *	-
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 * @param iTimeStamp		Кол-во секунд.
 * @param iClient			Индекс игрока или LANG_SERVER.
 *	-
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GetTimeFromStamp(char[] szBuffer, int iMaxLength, int iTimeStamp, int iClient = LANG_SERVER);

/**
 *	Добавляет к строке статус ф-и.
 *	-
 * @param szInput			Исходная строка.
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 * @param szFeature			Уникальное имя ф-и.
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
native void VIP_AddStringToggleStatus(const char[] szInput, char[] szBuffer, int iMaxLength, const char[] szFeature, int iClient);

public SharedPlugin __pl_vip_core= 
{
	name = "vip_core",
	file = "VIP_Core.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vip_core_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_GetDatabase");
	MarkNativeAsOptional("VIP_GetDatabaseType");
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_GetFeatureType");
	MarkNativeAsOptional("VIP_GetFeatureValueType");
	MarkNativeAsOptional("VIP_SetFeatureDefStatus");
	MarkNativeAsOptional("VIP_FillArrayByFeatures");
	MarkNativeAsOptional("VIP_SetClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP");
	MarkNativeAsOptional("VIP_CheckClient");
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_GetClientID");
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_SetClientVIPGroup");
	MarkNativeAsOptional("VIP_GetClientAccessTime");
	MarkNativeAsOptional("VIP_SetClientAccessTime");
	MarkNativeAsOptional("VIP_GetVIPClientTrie");
	MarkNativeAsOptional("VIP_SendClientVIPMenu");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");
	MarkNativeAsOptional("VIP_IsClientFeatureUse");
	MarkNativeAsOptional("VIP_GetClientFeatureInt");
	MarkNativeAsOptional("VIP_GetClientFeatureFloat");
	MarkNativeAsOptional("VIP_GetClientFeatureBool");
	MarkNativeAsOptional("VIP_GetClientFeatureString");
	MarkNativeAsOptional("VIP_PrintToChatClient");
	MarkNativeAsOptional("VIP_PrintToChatAll");
	MarkNativeAsOptional("VIP_LogMessage");
	MarkNativeAsOptional("VIP_TimeToSeconds");
	MarkNativeAsOptional("VIP_SecondsToTime");
	MarkNativeAsOptional("VIP_GetTimeFromStamp");
	MarkNativeAsOptional("VIP_AddStringToggleStatus");
}
#endif

	

#define MAX_URL_LEN 512
#define WORKSHOP_ID_LENGTH 64

/*
 * Sends an API call for steam to fetch the maps inside a collection.
 */
public void UpdateWorkshopCache(const char[] collectionId, ArrayList list) {
  char requestUrl[MAX_URL_LEN];
  Format(requestUrl, MAX_URL_LEN,
         "http://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/");

  if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") ==
      FeatureStatus_Available) {
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, requestUrl);
    if (request == INVALID_HANDLE) {
      LogError("Failed to create HTTP POST request using url: %s", requestUrl);
      return;
    }

    DataPack pack = new DataPack();
    pack.WriteString(collectionId);
    pack.WriteCell(list);

    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "collectioncount", "1");
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "publishedfileids[0]", collectionId);
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "format", "vdf");
    SteamWorks_SetHTTPCallbacks(request, OnWorkshopInfoReceived);
    SteamWorks_SetHTTPRequestContextValue(request, pack);
    SteamWorks_SendHTTPRequest(request);

  } else {
    LogError("You must have the SteamWorks extension installed to use workshop collections.");
  }
}

// SteamWorks HTTP callback for fetching a workshop collection
public int OnWorkshopInfoReceived(Handle request, bool failure, bool requestSuccessful,
                           EHTTPStatusCode statusCode, Handle data) {
  char collectionId[WORKSHOP_ID_LENGTH];

  DataPack pack = view_as<DataPack>(data);
  pack.Reset();
  pack.ReadString(collectionId, sizeof(collectionId));
  ArrayList list = view_as<ArrayList>(pack.ReadCell());

  if (failure || !requestSuccessful) {
    LogError("Steamworks collection request failed, HTTP status code = %d", statusCode);
    AddWorkshopMapsToList(collectionId, list);  // add backup maps that might already be cached
    delete pack;
    return;
  }

  int len = 0;
  SteamWorks_GetHTTPResponseBodySize(request, len);
  char[] response = new char[len];
  SteamWorks_GetHTTPResponseBodyData(request, response, len);

  KeyValues kv = new KeyValues("response");
  if (kv.ImportFromString(response)) {
    WriteCollectionInfo(kv, collectionId, list);
  } else {
    LogError("Couldn't import keyvalue response:\n%s", response);
  }

  AddWorkshopMapsToList(collectionId, list);
  delete pack;
  delete kv;
}

stock void WriteCollectionInfo(KeyValues kv, const char[] collectionId, ArrayList mapList) {
  if (kv.JumpToKey("collectiondetails") && kv.JumpToKey("0") && kv.JumpToKey("children")) {
    kv.GotoFirstSubKey();

    // delete current workshop stuff in this collection
    g_WorkshopCache.Rewind();
    g_WorkshopCache.JumpToKey("collections", true);
    g_WorkshopCache.DeleteKey(collectionId);
    g_WorkshopCache.Rewind();

    ArrayList mapIds = CreateArray(WORKSHOP_ID_LENGTH);

    // write out maps currently in the collection
    char buffer[64];
    do {
      kv.GetSectionName(buffer, sizeof(buffer));
      char mapId[WORKSHOP_ID_LENGTH];
      kv.GetString("publishedfileid", mapId, sizeof(mapId));

      if (!StrEqual(mapId, "")) {
        g_WorkshopCache.Rewind();
        g_WorkshopCache.JumpToKey("collections", true);
        g_WorkshopCache.JumpToKey(collectionId, true);
        g_WorkshopCache.SetString(mapId, "x");  // apparently empty string values don't work
        g_WorkshopCache.Rewind();
        mapIds.PushString(mapId);
      } else {
        LogError("Failed to add map %s to collection %s inside the workshop cache", mapId,
                 collectionId);
      }

    } while (kv.GotoNextKey());

    // Updates any cache info about the maps in the collection
    UpdateMapInfo(collectionId, mapList, mapIds);
    delete mapIds;

  } else {
    LogError("Recieved improperly formatted response in response kv");
  }
}

static void AddWorkshopMapsToList(const char[] collectionId, ArrayList mapList) {
  // first get all the map ids for this colelction into a list
  ArrayList mapIds = CreateArray(WORKSHOP_ID_LENGTH);

  g_WorkshopCache.Rewind();
  g_WorkshopCache.JumpToKey("collections", true);
  g_WorkshopCache.JumpToKey(collectionId, true);
  g_WorkshopCache.GotoFirstSubKey(false);

  char mapId[WORKSHOP_ID_LENGTH];
  do {
    g_WorkshopCache.GetSectionName(mapId, sizeof(mapId));
    mapIds.PushString(mapId);
  } while (g_WorkshopCache.GotoNextKey(false));

  g_WorkshopCache.Rewind();

  // next traverse the map list within the cache to get the actual map names
  char mapName[PLATFORM_MAX_PATH];
  char fullMapPath[PLATFORM_MAX_PATH];
  g_WorkshopCache.JumpToKey("maps", true);

  mapList.Clear();
  for (int i = 0; i < mapIds.Length; i++) {
    mapIds.GetString(i, mapId, sizeof(mapId));
    g_WorkshopCache.GetString(mapId, mapName, sizeof(mapName));

    if (IsStockMap(mapName)) {
      // This isn't needed for correctness, but makes it so a changelevel to inferno will do
      // "changelevel inferno" rather than "changelevel workshop/1234678/de_inferno",
      // which will show to clients that they are on "Inferno" rather than that nasty workshop path.
      Format(fullMapPath, sizeof(fullMapPath), "%s", mapName);
    } else {
      Format(fullMapPath, sizeof(fullMapPath), "workshop/%s/%s", mapId, mapName);
    }

    AddMap(fullMapPath, mapList);
  }

  g_WorkshopCache.Rewind();

  delete mapIds;
}

/*
 * Sends an API call for steam to fetch the maps inside a collection.
 */
// public void UpdateMapInfo(const char[] collectionId, const char[] mapId, ArrayList list) {
public void UpdateMapInfo(const char[] collectionId, ArrayList list, ArrayList mapIds) {
  char requestUrl[MAX_URL_LEN];
  Format(requestUrl, MAX_URL_LEN,
         "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/");

  Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, requestUrl);
  if (request == INVALID_HANDLE) {
    LogError("Failed to create HTTP POST request using url: %s", requestUrl);
    return;
  }

  DataPack pack = new DataPack();
  pack.WriteString(collectionId);
  pack.WriteCell(list);
  pack.WriteCell(mapIds.Length);

  char itemcount[32];
  IntToString(mapIds.Length, itemcount, sizeof(itemcount));
  SteamWorks_SetHTTPRequestGetOrPostParameter(request, "itemcount", itemcount);

  char mapId[WORKSHOP_ID_LENGTH];
  for (int i = 0; i < mapIds.Length; i++) {
    mapIds.GetString(i, mapId, sizeof(mapId));
    pack.WriteString(mapId);

    char param[64];
    Format(param, sizeof(param), "publishedfileids[%d]", i);
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, param, mapId);
  }

  SteamWorks_SetHTTPRequestGetOrPostParameter(request, "format", "vdf");
  SteamWorks_SetHTTPCallbacks(request, OnMapInfoReceived);
  SteamWorks_SetHTTPRequestContextValue(request, pack);
  SteamWorks_SendHTTPRequest(request);
}

// SteamWorks HTTP callback for fetching map information
public int OnMapInfoReceived(Handle request, bool failure, bool requestSuccessful,
                      EHTTPStatusCode statusCode, Handle data) {
  char collectionId[WORKSHOP_ID_LENGTH];
  ArrayList mapIds = CreateArray(WORKSHOP_ID_LENGTH);

  DataPack pack = view_as<DataPack>(data);
  pack.Reset();
  pack.ReadString(collectionId, sizeof(collectionId));
  ArrayList list = view_as<ArrayList>(pack.ReadCell());

  int numMaps = pack.ReadCell();
  for (int i = 0; i < numMaps; i++) {
    char mapId[WORKSHOP_ID_LENGTH];
    pack.ReadString(mapId, sizeof(mapId));
    mapIds.PushString(mapId);
  }

  if (failure || !requestSuccessful) {
    LogError("Steamworks collection request failed, HTTP status code = %d", statusCode);
    AddWorkshopMapsToList(collectionId, list);
    delete pack;
    delete mapIds;
    return;
  }

  int len = 0;
  SteamWorks_GetHTTPResponseBodySize(request, len);
  char[] response = new char[len];
  SteamWorks_GetHTTPResponseBodyData(request, response, len);

  KeyValues kv = new KeyValues("response");
  if (kv.ImportFromString(response)) {
    char mapId[WORKSHOP_ID_LENGTH];
    for (int i = 0; i < numMaps; i++) {
      mapIds.GetString(i, mapId, sizeof(mapId));
      WriteMapInfo(kv, i, mapId);
    }
  } else {
    LogError("Couldn't import keyvalue response:\n%s", response);
  }

  AddWorkshopMapsToList(collectionId, list);
  delete pack;
  delete mapIds;
  delete kv;
}

public void WriteMapInfo(KeyValues kv, int index, const char[] mapId) {
  g_WorkshopCache.JumpToKey("maps", true);

  char indexString[32];
  IntToString(index, indexString, sizeof(indexString));

  if (kv.JumpToKey("publishedfiledetails") && kv.JumpToKey(indexString)) {
    char mapName[PLATFORM_MAX_PATH];
    kv.GetString("filename", mapName, sizeof(mapName));

    // The filename field looks like: "filename"  "mymaps/de_fire.bsp"
    // so the mymaps/ and .bsp need to get removed.
    ReplaceString(mapName, sizeof(mapName), "mymaps/", "");
    ReplaceString(mapName, sizeof(mapName), ".bsp", "");

    g_WorkshopCache.SetString(mapId, mapName);

  } else {
    LogError("Recieved improperly formatted respone in response kv");
  }

  kv.Rewind();
  g_WorkshopCache.Rewind();
}

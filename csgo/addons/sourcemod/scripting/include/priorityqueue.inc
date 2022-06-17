#if defined _priorityqueue_included
#endinput
#endif
#define _priorityqueue_included

/**
 * Initializes the queue and returns a handle to it that must be closed.
 */
stock Handle PQ_Init() {
  Handle queueHandle = CreateArray(2);
  ClearArray(queueHandle);
  return queueHandle;
}

/**
 * Adds a player and a value to the queue.
 * If the player is already in the queue, their score is updated in place.
 */
stock void PQ_Enqueue(Handle queueHandle, int client, float value) {
  int index = PQ_FindClient(queueHandle, client);

  // if they're not already in, put them at the end
  if (index == -1) {
    index = GetArraySize(queueHandle);
    PushArrayCell(queueHandle, client);
    SetArrayCell(queueHandle, index, client, 0);
  }

  // set their value
  SetArrayCell(queueHandle, index, value, 1);
}

/**
 * Selects the player with the max value in the queue and removes them, returning their client
 * index.
 */
stock int PQ_Dequeue(Handle queueHandle) {
  int maxIndex = -1;
  int maxClient = -1;
  float maxScore;

  for (int i = 0; i < GetArraySize(queueHandle); i++) {
    int client = GetArrayCell(queueHandle, i, 0);
    float score = GetArrayCell(queueHandle, i, 1);
    if (maxIndex == -1 || score > maxScore) {
      maxIndex = i;
      maxClient = client;
      maxScore = score;
    }
  }
  if (maxIndex != -1) {
    RemoveFromArray(queueHandle, maxIndex);
  }
  return maxClient;
}

/**
 * Finds an index of the client in the queue. Returns -1 if the client isn't in it.
 */
stock int PQ_FindClient(Handle queueHandle, int client) {
  for (int i = 0; i < GetArraySize(queueHandle); i++) {
    int c = GetArrayCell(queueHandle, i, 0);
    if (client == c)
      return i;
  }
  return -1;
}

/**
 * Drops a client from the queue completely.
 */
stock void PQ_DropFromQueue(Handle queueHandle, int client) {
  int index = PQ_FindClient(queueHandle, client);
  if (index != -1)
    RemoveFromArray(queueHandle, index);
}

/**
 * Returns the current size of the queue.
 */
stock int PQ_GetSize(Handle queueHandle) {
  return GetArraySize(queueHandle);
}

/**
 * Returns is the queu is empty.
 */
stock bool PQ_IsEmpty(Handle queueHandle) {
  return PQ_GetSize(queueHandle) == 0;
}

/**
 * Clears the Handle for a queue.
 */
stock void PQ_Destroy(Handle queueHandle) {
  CloseHandle(queueHandle);
}

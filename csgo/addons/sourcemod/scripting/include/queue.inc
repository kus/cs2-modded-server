#if defined _queue_included
#endinput
#endif
#define _queue_included

/**
 * This is a generic client FIFO-queue implentation.
 * It is just a wrapper on adt-arrays, so things like
 * GetArrayCell(queue, index) can still be used.
 */

/**
 * Initializes the queue. The handle returned by this must be closed or destroyed later.
 */
stock Handle Queue_Init() {
  return CreateArray();
}

/**
 * Push a Client into the Queue (don't add a client if already in queue).
 */
stock void Queue_Enqueue(Handle queueHandle, int client) {
  if (Queue_Find(queueHandle, client) == -1)
    PushArrayCell(queueHandle, client);
}

/**
 * Finds a client in the Queue and returns their index, or -1 if not found.
 */
stock int Queue_Find(Handle queueHandle, int client) {
  return FindValueInArray(queueHandle, client);
}

/**
 * Returns if a player is inside the queue.
 */
stock bool Queue_Inside(Handle queueHandle, int client) {
  return Queue_Find(queueHandle, client) >= 0;
}

/**
 * Drops a client from the Queue.
 */
stock void Queue_Drop(Handle queueHandle, int client) {
  int index = Queue_Find(queueHandle, client);
  if (index != -1)
    RemoveFromArray(queueHandle, index);
}

/**
 * Get queue length, does not validate clients in queue.
 */
stock int Queue_Length(Handle queueHandle) {
  return GetArraySize(queueHandle);
}

/**
 * Test if queue is empty.
 */
stock bool Queue_IsEmpty(Handle queueHandle) {
  return Queue_Length(queueHandle) == 0;
}

/**
 * Peeks the head of the queue.
 */
stock int Queue_Peek(Handle queueHandle) {
  if (Queue_IsEmpty(queueHandle))
    return -1;
  return GetArrayCell(queueHandle, 0);
}

/**
 * Fetch next client from queue.
 */
stock int Queue_Dequeue(Handle queueHandle) {
  if (Queue_IsEmpty(queueHandle))
    return -1;
  int val = Queue_Peek(queueHandle);
  RemoveFromArray(queueHandle, 0);
  return val;
}

/**
 * Clears all entires in a queue.
 */
stock void Queue_Clear(Handle queueHandle) {
  ClearArray(queueHandle);
}

/**
 * Frees the handle used by the queue.
 */
stock void Queue_Destroy(Handle queueHandle) {
  CloseHandle(queueHandle);
}

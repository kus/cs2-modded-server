// socket extension include file

#if defined _socket_included
  #endinput
#endif
#define _socket_included
#include <core>

enum SocketType {
	SOCKET_TCP = 1,
	SOCKET_UDP,
	SOCKET_RAW
	}

#define EMPTY_HOST 1
#define NO_HOST 2
#define CONNECT_ERROR 3
#define SEND_ERROR 4
#define BIND_ERROR 5
#define RECV_ERROR 6
#define LISTEN_ERROR 7


/*************************************************************************************************/
/******************************************** options ********************************************/
/*************************************************************************************************/


/**
 * Options available for SocketSetOption()
 *
 * @note modifying these options is not required for normal operation, you can skip the whole
 *       section in most cases.
 */
enum SocketOption {
/**
 * If this option is set the socket extension will try to concatenate SocketReceive callbacks.
 *
 * This will possibly lower the amount of callbacks passed to SourceMod plugins and improve the
 * performance. The socket extension will preserve the packet order.
 *
 * @note this doesn't prevent multiple callbacks, it only reduces them for high load.
 * @note this will not truncate packets below 4096 bytes, setting it lower will be ignored
 * @note set this option if you expect lots of data in a short timeframe
 * @note don't forget to set your buffer sizes at least to the value passed to this function, but
 *       always at least to 4096
 *
 * @param cell_t	0(=default) to disable or max. chunk size including \0 terminator in bytes
 * @return bool true on success
 */
	ConcatenateCallbacks = 1,
/**
 * If this option is set the socket extension will enforce a mutex lock in the GameFrame() hook.
 *
 * This will ensure that callbacks will be processed every gameframe as fast as possible with the
 * drawback of potentially creating lag. It's not recommended to set this option for most cases.
 * If this option is not set the gameframe will be skipped if quietly obtaining a lock fails.
 *
 * @note combine this with CallbacksPerFrame for best performance
 * @note this option will affect all sockets from all plugins, use it with caution!
 *
 * @param bool	whether to force locking or not
 * @return bool true on success
 */
	ForceFrameLock,
/**
 * This will specify the maximum amount of callbacks processed in every gameframe.
 *
 * The default value for this option is 1, setting it higher will possibly increase networking
 * performance but may cause lag if it's set too high.
 * The amount of callbacks actually being processed is limited by not being able to quietly obtain
 * a lock (see ForceFrameLock) and the amount of callbacks in the queue.
 *
 * @note this option will affect all sockets from all plugins, use it with caution!
 *
 * @param cell_t	maximum amount of callbacks per gameframe
 * @return bool 	true on success
 */
	CallbacksPerFrame,
/**
 * If this option is set the socket will be allowed to send broadcast messages in case the protocol
 * supports it. This is a wrapper for setting SO_BROADCAST.
 *
 * @param bool	whether to allow broadcasting or not
 * @return bool true on success
 */
	SocketBroadcast,
/**
 * If this option is set SocketBind() will allow reusing local adresses in case the protocol
 * supports it. This is a wrapper for setting SO_REUSEADDR.
 *
 * @param bool	whether to allow broadcasting or not
 * @return bool true on success
 */
	SocketReuseAddr,
/**
 * If this option is set the socket will try to keep the connection alive by periodically sending
 * messages if the protocol supports it. This is a wrapper for setting SO_KEEPALIVE.
 *
 * @param bool	whether to allow broadcasting or not
 * @return bool true on success
 */
	SocketKeepAlive,
/**
 * This option specifies how long a socket will wait if it's being closed and its send buffer is
 * still filled. This is a wrapper for setting SO_LINGER.
 *
 * @param cell_t	0 (=default) to disable or time in s
 * @return bool		true on success
 */
	SocketLinger,
/**
 * If this option is set out-of-band data will be inlined into the normal receive stream. This is a
 * wrapper for setting SO_OOBINLINE.
 *
 * @param bool	whether to inline out-of-band data or not
 * @return bool true on success
 */
	SocketOOBInline,
/**
 * This option specifies how large the send buffer will be. This is a wrapper for setting
 * SO_SNDBUF.
 *
 * @param cell_t	size in bytes
 * @return bool		true on success
 */
	SocketSendBuffer,
/**
 * This option specifies how large the receive buffer will be. This is a wrapper for setting
 * SO_RCVBUF.
 *
 * @param cell_t	size in bytes
 * @return bool		true on success
 */
	SocketReceiveBuffer,
/**
 * If this option is set outgoing messages will ignore the default routing facilities if the
 * protocol implementation supports it. The remote site should be directly connected to the sender.
 * This is a wrapper for setting SO_DONTROUTE.
 *
 * @param bool	whether to skip default routing or not
 * @return bool true on success
 */
	SocketDontRoute,
/**
 * This option specifies the minimum amount of data to receive before processing it. This is a
 * wrapper for setting SO_RCVLOWAT.
 *
 * @note this can probably block the extension, use it with caution!
 *
 * @param cell_t	size in bytes
 * @return bool		true on success
 */
	SocketReceiveLowWatermark,
/**
 * This option specifies how long a socket will try to receive data before it times out and
 * processes the data. This is a wrapper for setting SO_RCVTIMEO.
 *
 * @param cell_t	0 (=default) to disable or time in ms
 * @return bool		true on success
 */
	SocketReceiveTimeout,
/**
 * This option specifies the minimum amount of data required in the send buffer before starting to
 * send it. This is a wrapper for setting SO_SNDLOWAT.
 *
 * @note this can probably block the extension, use it with caution!
 *
 * @param cell_t	size in bytes
 * @return bool		true on success
 */
	SocketSendLowWatermark,
/**
 * This option specifies how long a socket will try to send data before it times out and
 * retries it later. This is a wrapper for setting SO_SNDTIMEO.
 *
 * @param cell_t	0 (=default) to disable or time in ms
 * @return bool		true on success
 */
	SocketSendTimeout,
/**
 * If this option is set the socket extension will display debugging messages in the server console/logs.
 *
 * @param bool	whether to enable debugging or not
 * @return bool true on success
 */
 	DebugMode
}


/*************************************************************************************************/
/******************************************* callbacks *******************************************/
/*************************************************************************************************/


/**
 * triggered if a normal sockets finished connecting and is ready to be used
 *
 * @param socket	The socket handle pointing to the calling socket
 * @param arg		The argument set by SocketSetArg()
 * @noreturn
 */
funcenum SocketConnectCB
{
    public(Handle:socket, any:arg)
};

/**
 * triggered if a listening socket received an incoming connection and is ready to be used
 *
 * @note The child-socket won't work until receive-, disconnect-, and errorcallback for it are set.
 *
 * @param Handle	socket		The socket handle pointing to the calling listen-socket
 * @param Handle	newSocket	The socket handle to the newly spawned child socket
 * @param String	remoteIP	The remote IP
 * @param any		arg			The argument set by SocketSetArg() for the listen-socket
 * @noreturn
 */
funcenum SocketIncomingCB
{
    public(Handle:socket, Handle:newSocket, const String:remoteIP[], remotePort, any:arg)
};

/**
 * triggered if a socket receives data
 *
 * @note This is binary safe if you always use dataSize for operations on receiveData[]
 * @note packets may be split up into multiple chunks -> multiple calls to the receive callback
 * @note if not set otherwise by SocketSetOption(..., ConcatenateCallbacks, ...) receiveData will
 *       never be longer than 4096 characters including \0 terminator
 *
 * @param Handle	socket		The socket handle pointing to the calling socket
 * @param String	receiveData	The data which arrived, 0-terminated at receiveData[dataSize]
 * @param cell_t	dataSize	The length of the arrived data excluding the 0-termination
 * @param any		arg			The argument set by SocketSetArg() for the socket
 * @noreturn
 */
funcenum SocketReceiveCB
{
    public(Handle:socket, const String:receiveData[], const dataSize, any:arg)
};

/**
 * called after a socket sent all items in its send queue successfully
 *
 * @param Handle	socket		The socket handle pointing to the calling socket
 * @param any		arg			The argument set by SocketSetArg() for the socket
 * @noreturn
 */
funcenum SocketSendqueueEmptyCB
{
    public(Handle:socket, any:arg)
};

/**
 * called if a socket has been properly disconnected by the remote side
 *
 * @note You should call CloseHandle(socket) or reuse the socket before this function ends
 *
 * @param Handle	socket		The socket handle pointing to the calling socket
 * @param any		arg			The argument set by SocketSetArg() for the socket
 * @noreturn
 */
funcenum SocketDisconnectCB
{
    public(Handle:socket, any:arg)
};

/**
 * called if an unrecoverable error occured, close the socket without an additional call to a disconnect callback
 *
 * @note You should call CloseHandle(socket) or reuse the socket before this function ends
 *
 * @param Handle	socket		The socket handle pointing to the calling socket
 * @param cell_t	errorType	The error type, see defines above
 * @param cell_t	errorNum	The errno, see errno.h for details
 * @param any		arg			The argument set by SocketSetArg() for the socket
 * @noreturn
 */
funcenum SocketErrorCB
{
    public(Handle:socket, const errorType, const errorNum, any:arg)
};


/*************************************************************************************************/
/******************************************** natives ********************************************/
/*************************************************************************************************/


/**
 * Returns whether a socket is connected or not.
 *
 * @param	socket	Socket handle to check
 * @return	bool	The connection status
 */
native bool SocketIsConnected(Handle socket);


/**
 * Creates a new socket.
 *
 * @note this function may be relatively expensive, reuse sockets if possible
 *
 * @param SocketType	protocol	The protocol to use, SOCKET_TCP is default
 * @param SocketErrorCB efunc		The error callback
 * @return Handle					The socket handle. Returns INVALID_HANDLE on failure
 */
native Handle SocketCreate(SocketType protocol=SOCKET_TCP, SocketErrorCB efunc);

/**
 * Binds the socket to a local address
 *
 * @param Handle	socket		The handle of the socket to be used.
 * @param String	hostname	The hostname (or IP) to bind the socket to.
 * @param cell_t	port		The port to bind the socket to.
 * @return bool 				true on success
 */
native bool SocketBind(Handle socket, const char[] hostname, int port);

/**
 * Connects a socket
 *
 * @note this native is threaded, it may be still running after it executed, use the connect callback
 * @note invokes the SocketError callback with errorType = CONNECT_ERROR or EMPTY_HOST if it fails
 * @note invokes the SocketConnect callback if it succeeds
 *
 * @param Handle				socket		The handle of the socket to be used.
 * @param SocketConnectCB		cfunc		The connect callback
 * @param SocketReceiveCB		rfunc		The receive callback
 * @param SocketDisconnectCB	dfunc		The disconnect callback
 * @param String				hostname	The hostname (or IP) to connect to.
 * @param cell_t				port		The port to connect to.
 * @noreturn
 */
native void SocketConnect(Handle socket, SocketConnectCB cfunc, SocketReceiveCB rfunc, SocketDisconnectCB dfunc, const char[] hostname, int port);

/**
 * Disconnects a socket
 *
 * @note this will not close the handle, the socket will be reset to a state similar to after SocketCreate()
 * @note this won't trigger any disconnect/error callbacks
 *
 * @noreturn
 */
native bool SocketDisconnect(Handle socket);

/**
 * Makes a socket listen for incoming connections
 *
 * @param Handle			socket	The handle of the socket to be used.
 * @param SocketIncomingCB	ifunc	The callback for incoming connections
 * @return bool 					true on success
 */
native bool SocketListen(Handle socket, SocketIncomingCB ifunc);

/**
 * Sends data through the socket.
 *
 * @note specify size for binary safe operation
 * @note if size is not specified the \0 terminator will not be included
 * @note This native is threaded, it may be still running after it executed (not atomic).
 * @note Use the SendqueueEmpty callback to determine when all data has been successfully sent.
 * @note The socket extension will ensure that the data will be send in the correct order and split
 *			the data if required.
 *
 * @param Handle	socket	The handle of the socket to be used.
 * @param String	data	The data to send.
 * @noreturn
 */
native void SocketSend(Handle socket, const char[] data, int size=-1);

/**
 * Sends UDP data through the socket to a specific destination.
 *
 * @note specify size for binary safe operation
 * @note if size is not specified the \0 terminator will not be included
 * @note This native is threaded, it may be still running after it executed (not atomic).
 * @note Use the SendqueueEmpty callback to determine when all data has been successfully sent.
 * @note The socket extension will ensure that the data will be send in the correct order and split
 *			the data if required.
 *
 * @param Handle	socket	The handle of the socket to be used.
 * @param String	data	The data to send.
 * @param String	hostname	The hostname (or IP) to send to.
 * @param cell_t	port		The port to send to.
 * @noreturn
 */
native void SocketSendTo(Handle socket, const char[] data, int size=-1, const char[] hostname, int port);

/**
 * Set a socket option.
 *
 * @param Handle		socket	The handle of the socket to be used. May be INVALID_HANDLE if not essential.
 * @param SocketOption	option	The option to modify (see enum SocketOption for details).
 * @param cellt_		value	The value to set the option to.
 * @return cell_t			1 on success.
 */
native int SocketSetOption(Handle socket, SocketOption option, int value);


/**
 * Defines the callback function for when the socket receives data
 *
 * @note this is only useful and required for child-sockets spawned by listen-sockets
 *       (otherwise you already set it in SocketConnect())
 *
 * @param Handle			socket	The handle of the socket to be used.
 * @param SocketReceiveCB	rfunc	The receive callback
 * @noreturn
 */
native void SocketSetReceiveCallback(Handle socket, SocketReceiveCB rfunc);

/**
 * Defines the callback function for when the socket sent all items in its send queue
 *
 * @note this must be called AFTER sending (queueing) the data
 * @note if no send-data is queued this will fire the callback itself
 * @note the callback is guaranteed to fire
 *
 * @param Handle				socket	The handle of the socket to be used.
 * @param SocketDisconnectCB	dfunc	The disconnect callback
 * @noreturn
 */
native void SocketSetSendqueueEmptyCallback(Handle socket, SocketSendqueueEmptyCB sfunc);

/**
 * Defines the callback function for when the socket was properly disconnected by the remote side
 *
 * @note this is only useful and required for child-sockets spawned by listen-sockets
 *       (otherwise you already set it in SocketConnect())
 *
 * @param Handle				socket	The handle of the socket to be used.
 * @param SocketDisconnectCB	dfunc	The disconnect callback
 * @noreturn
 */
native void SocketSetDisconnectCallback(Handle socket, SocketDisconnectCB dfunc);

/**
 * Defines the callback function for when the socket triggered an error
 *
 * @note this is only useful and required for child-sockets spawned by listen-sockets
 *       (otherwise you already set it in SocketCreate())
 *
 * @param Handle		socket	The handle of the socket to be used.
 * @param SocketErrorCB efunc	The error callback
 * @noreturn
 */
native void SocketSetErrorCallback(Handle socket, SocketErrorCB efunc);


/**
 * Sets the argument being passed to callbacks
 *
 * @param Handle	socket	The handle of the socket to be used.
 * @param any		arg		The argument to set
 * @noreturn
 */
native void SocketSetArg(Handle socket, any arg);

/**
 * Retrieve the local system's hostname as the command "hostname" does.
 *
 * @param dest    Destination string buffer to copy to.
 * @param destLen Destination buffer length (includes null terminator).
 *
 * @return			1 on success
 */
native bool SocketGetHostName(char[] dest, int destLen);

/**
 * _________________Do not edit below this line!_______________________
 */
public Extension __ext_smsock = 
{
	name = "Socket",
	file = "socket.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#if defined _socket_methodmap_included
  #endinput
#endif
#define _socket_methodmap_included

#include <socket>

methodmap Socket < Handle {
	/**
	 * Creates a new socket.
	 *
	 * @note this function may be relatively expensive, reuse sockets if possible
	 *
	 * @param SocketType    protocol	The protocol to use, SOCKET_TCP is default
	 * @param SocketErrorCB efunc		The error callback
	 * @return Handle					The socket handle. Returns INVALID_HANDLE on failure
	 */
	public Socket(SocketType protocol=SOCKET_TCP, SocketErrorCB efunc) {
		view_as<Socket>(SocketCreate(protocol, efunc));
	}

	/**
	 * Binds the socket to a local address
	 *
	 * @param String    hostname	The hostname (or IP) to bind the socket to.
	 * @param int       port		The port to bind the socket to.
	 * @return bool 				true on success
	 */
	public bool Bind(const char[] hostname, int port) {
		return SocketBind(this, hostname, port);
	}

	/**
	 * Connects a socket
	 *
	 * @note this native is threaded, it may be still running after it executed, use the connect callback
	 * @note invokes the SocketError callback with errorType = CONNECT_ERROR or EMPTY_HOST if it fails
	 * @note invokes the SocketConnect callback if it succeeds
	 *
	 * @param SocketConnectCB       cfunc		The connect callback
	 * @param SocketReceiveCB       rfunc		The receive callback
	 * @param SocketDisconnectCB    dfunc		The disconnect callback
	 * @param String                hostname	The hostname (or IP) to connect to.
	 * @param int                   port		The port to connect to.
	 * @noreturn
	 */
	public void Connect(SocketConnectCB cfunc, SocketReceiveCB rfunc, SocketDisconnectCB dfunc, const char[] hostname, int port) {
		SocketConnect(this, cfunc, rfunc, dfunc, hostname, port);
	}

	/**
	 * Disconnects a socket
	 *
	 * @note this will not close the handle, the socket will be reset to a state similar to after SocketCreate()
	 * @note this won't trigger any disconnect/error callbacks
	 *
	 * @return bool         true on success
	 */
	public bool Disconnect() {
		return SocketDisconnect(this);
	}

	/**
	 * Makes a socket listen for incoming connections
	 *
	 * @param SocketIncomingCB  ifunc   The callback for incoming connections
	 * @return bool                     true on success
	 */
	public bool Listen(SocketIncomingCB ifunc) {
		return SocketListen(this, ifunc);
	}

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
	 * @param String    data    The data to send.
	 * @noreturn
	 */
	public void Send(const char[] data, int size = -1) {
		SocketSend(this, data, size);
	}

	/**
	 * Sends UDP data through the socket to a specific destination.
	 *
	 * @note specify size for binary safe operation
	 * @note if size is not specified the \0 terminator will not be included
	 * @note This native is threaded, it may be still running after it executed (not atomic).
	 * @note Use the SendqueueEmpty callback to determine when all data has been successfully sent.
	 * @note The socket extension will ensure that the data will be send in the correct order and split
	 *       the data if required.
	 *
	 * @param String    data        The data to send.
	 * @param String    hostname    The hostname (or IP) to send to.
	 * @param int       port        The port to send to.
	 * @noreturn
	 */
	public void SendTo(const char[] data, int size = -1, const char[] hostname, int port) {
		SocketSendTo(this, data, size, hostname, port);
	}

	/**
	 * Set a socket option.
	 *
	 * @param SocketOption  option  The option to modify (see enum SocketOption for details).
	 * @param int           value   The value to set the option to.
	 * @return int          1 on success.
	 */
	public int SetOption(SocketOption option, int value) {
		return SocketSetOption(this, option, value);
	}

	/**
	 * Defines the callback function for when the socket receives data
	 *
	 * @note this is only useful and required for child-sockets spawned by listen-sockets
	 *       (otherwise you already set it in SocketConnect())
	 *
	 * @param SocketReceiveCB   rfunc   The receive callback
	 * @noreturn
	 */
	public void SetReceiveCallback(SocketReceiveCB rfunc) {
		SocketSetReceiveCallback(this, rfunc);
	}

	/**
	 * Defines the callback function for when the socket sent all items in its send queue
	 *
	 * @note this must be called AFTER sending (queueing) the data
	 * @note if no send-data is queued this will fire the callback itself
	 * @note the callback is guaranteed to fire
	 *
	 * @param SocketDisconnectCB    dfunc   The disconnect callback
	 * @noreturn
	 */
	public void SetSendqueueEmptyCallback(SocketSendqueueEmptyCB sfunc) {
		SocketSetSendqueueEmptyCallback(this, sfunc);
	}

	/**
	 * Defines the callback function for when the socket was properly disconnected by the remote side
	 *
	 * @note this is only useful and required for child-sockets spawned by listen-sockets
	 *       (otherwise you already set it in SocketConnect())
	 *
	 * @param SocketDisconnectCB    dfunc   The disconnect callback
	 * @noreturn
	 */
	public void SetDisconnectCallback(SocketDisconnectCB dfunc) {
		SocketSetDisconnectCallback(this, dfunc);
	}

	/**
	 * Defines the callback function for when the socket triggered an error
	 *
	 * @note this is only useful and required for child-sockets spawned by listen-sockets
	 *       (otherwise you already set it in SocketCreate())
	 *
	 * @param SocketErrorCB efunc   The error callback
	 * @noreturn
	 */
	public void SetErrorCallback(SocketErrorCB efunc) {
		SocketSetErrorCallback(this, efunc);
	}

	/**
	 * Sets the argument being passed to callbacks
	 *
	 * @param any       arg     The argument to set
	 * @noreturn
	 */
	public void SetArg(any arg) {
		SocketSetArg(this, arg);
	}

	/**
	 * Retrieve the local system's hostname as the command "hostname" does.
	 *
	 * @param dest    Destination string buffer to copy to.
	 * @param destLen Destination buffer length (includes null terminator).
	 *
	 * @return        1 on success
	 */
	public static int GetHostName(char[] dest, int destLen) {
		return SocketGetHostName(dest, destLen);
	}

	/**
	 * Returns whether a socket is connected or not.
	 *
	 * @return	bool	The connection status
	 */
	property bool Connected {
		public get() { SocketIsConnected(this); }
	}
}
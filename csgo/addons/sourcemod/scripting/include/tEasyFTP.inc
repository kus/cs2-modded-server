#if defined _teftp_included_
	#endinput
#endif
#define _teftp_included_


typedef EasyFTP_FileUploaded = function void(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any data);
native void EasyFTP_UploadFile(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, EasyFTP_FileUploaded func, any data = 0);
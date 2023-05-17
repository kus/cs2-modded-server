/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		   debugtools.inc
 *  Type:		   Core 
 *  Description:	Place to put custom functions and test stuff.
 *
 *  Copyright (C) 2009-2013  Greyscale, Richard Helgeby
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

void DebugOnCommandsCreate()
{
	// Custom test commands:
	/*
	RegConsoleCmd("zr_getparametercount", Command_GetParameterCount, "Test GetParameterCount function in paramtools.inc. Usage: zr_getparametercount <paramstring>");
	RegConsoleCmd("zr_getparametervalue", Command_GetParameterValue, "Test GetParameterValue function in paramtools.inc. Usage: zr_getparametervalue <paramname> <paramstring>");
	*/
}

/*
public Action Command_GetParameterCount(int client, int argc)
{
	if (argc < 1)
	{
		ReplyToCommand(client, "No parameter string passed. Usage: zr_getparametercount <paramstring>");
		return Plugin_Handled;
	}
	
	char argbuffer[256];
	char paramstring[256];
	
	paramstring[0] = 0;
	
	// Join the last parameters in a string.
	for (int arg = 1; arg <= argc; arg++)
	{
		GetCmdArg(arg, argbuffer, sizeof(argbuffer));
		StrCat(paramstring, sizeof(paramstring), argbuffer);
		
		// Add space, except on the last parameter.
		if (arg < argc)
		{
			StrCat(paramstring, sizeof(paramstring), " ");
		}
	}
	
	ReplyToCommand(client, "Parameter string: \"%s\"", paramstring);
	new paramcount = GetParameterCount(paramstring);
	ReplyToCommand(client, "Parameter count: %d", paramcount);
	
	return Plugin_Handled;
}

public Action Command_GetParameterValue(int client, int argc)
{
	if (argc < 2)
	{
		ReplyToCommand(client, "Missing parameters. Usage: zr_getparametervalue <paramname> <paramstring>");
		return Plugin_Handled;
	}
	
	char paramname[256];
	char paramstring[256];
	
	char valuebuffer[64];
	char argbuffer[256];
	
	paramstring[0] = 0;
	valuebuffer[0] = 0;
	
	GetCmdArg(1, paramname, sizeof(paramname));
	
	// Join the last parameters in a string.
	for (int arg = 2; arg <= argc; arg++)
	{
		GetCmdArg(arg, argbuffer, sizeof(argbuffer));
		StrCat(paramstring, sizeof(paramstring), argbuffer);
		
		// Add space, except on the last parameter.
		if (arg < argc)
		{
			StrCat(paramstring, sizeof(paramstring), " ");
		}
	}
	
	int retval = GetParameterValue(valuebuffer, sizeof(valuebuffer), paramstring, paramname);
	
	ReplyToCommand(client, "Return value: %d\nParameter string: \"%s\"\nParameter value: \"%s\"", retval, paramstring, valuebuffer);
	
	return Plugin_Handled;
}
*/

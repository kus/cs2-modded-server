/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  version.inc
 *  Description:   Command for version information.
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

void VersionOnCommandsCreate()
{
	RegConsoleCmd("zr_version", Command_Version, "Prints version info about this plugin.");
}

public Action Command_Version(int client, int argc)
{
	char buffer[512];
	char linebuffer[128];
	buffer[0] = 0;
	linebuffer[0] = 0;
	
	#define FORMATSTRING "%24s: %s\n"
	
	Format(linebuffer, sizeof(linebuffer), "%s\n", ZR_VER_PRODUCT_NAME);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), "%s\n\n", ZR_VER_COPYRIGHT);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), FORMATSTRING, "Version", ZR_VER_VERSION);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), FORMATSTRING, "Compile date", ZR_VER_DATE);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), FORMATSTRING, "License", ZR_VER_LICENSE);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), FORMATSTRING, "Build", ZR_VER_REVISION);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	Format(linebuffer, sizeof(linebuffer), FORMATSTRING, "Development branch", ZR_VER_BRANCH);
	StrCat(buffer, sizeof(buffer), linebuffer);
	
	ReplyToCommand(client, buffer);
	return Plugin_Handled;
}

/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  sayhooks.inc
 *  Type:		  Core
 *  Description:   Hook plugin say commands and redirect to their handling module.
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

/**
 * @section SM core config info.
 */
#define SAYHOOKS_CHAT_PUBLIC_DEFAULT "!"
#define SAYHOOKS_CHAT_SILENT_DEFAULT "/"
/**
 * @endsection
 */

/**
 * Max number of characters in a chat text string.
 */
#define SAYHOOKS_MAX_CHAT_LENGTH 192

/**
 * @section Say command key words.
 */
#define SAYHOOKS_KEYWORD_ZMENU	  "zmenu"
#define SAYHOOKS_KEYWORD_ZADMIN	 "zadmin"
#define SAYHOOKS_KEYWORD_ZCLASS	 "zclass"
#define SAYHOOKS_KEYWORD_ZCOOKIES   "zcookies"
#define SAYHOOKS_KEYWORD_ZSPAWN	 "zspawn"
#define SAYHOOKS_KEYWORD_ZTELE	  "ztele"
#define SAYHOOKS_KEYWORD_ZHP		"zhp"
#define SAYHOOKS_KEYWORD_ZMARKET	"zmarket"
#define SAYHOOKS_KEYWORD_ZSHIELD	"zshield"
/**
 * @endsection
 */

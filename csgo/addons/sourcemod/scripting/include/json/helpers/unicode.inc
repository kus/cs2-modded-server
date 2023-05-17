/**
 * vim: set ts=4 :
 * =============================================================================
 * sm-json
 * A pure SourcePawn JSON encoder/decoder.
 * https://github.com/clugg/sm-json
 *
 * sm-json (C)2020 James Dickens. (clug)
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#if defined _json_helpers_unicode_included
 #endinput
#endif
#define _json_helpers_unicode_included

// most of the code here is adapted from https://dev.w3.org/XML/encoding.c

/**
 * Calculates how many bytes will be required to store the ASCII
 * representation of a UTF-8 character.
 *
 * @param c     The UTF-8 character.
 * @returns     The number of bytes required, or -1 if c is invalid.
 */
stock int json_utf8_to_ascii_size(int c)
{
    if (c < 0 || c > 0x10FFFF) {
        return -1;
    }

    if (c < 0x80) {
        return 1;
    } else if (c < 0x800) {
        return 2;
    } else if (c < 0x10000) {
        if (c >= 0xD800 && c <= 0xDFFF) {
            // high surrogate
            return -1;
        }

        return 3;
    }

    return 4;
}

/**
 * Converts a UTF-8 character to its ASCII representation.
 *
 * @param c         The UTF-8 character.
 * @param output    String buffer to store output.
 * @param max_size  Maximum size of string buffer.
 * @returns         The number of bytes written, or -1 if c is invalid.
 */
stock int json_utf8_to_ascii(int c, char[] output, int max_size)
{
    if (max_size < 1) {
        return 0;
    }

    if (c < 0 || c > 0x10FFFF) {
        return -1;
    }

    int size = 0;
    if (c < 0x80) {
        size = 1;
        output[0] = c;
    } else if (c < 0x800) {
        size = 2;
        output[0] = ((c >> 6) & 0x1F) | 0xC0;
    } else if (c < 0x10000) {
        if (c >= 0xD800 && c <= 0xDFFF) {
            // high surrogate
            return -1;
        }

        size = 3;
        output[0] = ((c >> 12) & 0x0F) | 0xE0;
    } else {
        size = 4;
        output[0] = ((c >> 18) & 0x07) | 0xF0;
    }

    if (size >= max_size) {
        return -1;
    }

    // first byte has already been calculated, calculate the rest
    int i;
    for (i = 1; i < size; i += 1) {
        output[i] = ((c >> ((size - i - 1) * 6)) & 0x3F) | 0x80;
    }

    return i;
}

stock int json_ascii_to_utf8(const char[] ascii, int max_size, int &size)
{
    size = 0;
    if (max_size < 1) {
        return -1;
    }

    int c = 0;
    if ((ascii[0] & 0x80) != 0) {
        if (max_size < 2) {
            return -1;
        }

        if ((ascii[1] & 0xC0) != 0x80) {
            return -1;
        }

        if ((ascii[0] & 0xE0) == 0xE0) {
            if (max_size < 3) {
                return -1;
            }

            if ((ascii[2] & 0xC0) != 0x80) {
                return -1;
            }

            if ((ascii[0] & 0xF0) == 0xF0) {
                if (max_size < 4) {
                    return -1;
                }

                if ((ascii[0] & 0xF8) != 0xF0 || (ascii[3] & 0xC0) != 0x80) {
                    return -1;
                }

                size = 4;
                c = (ascii[0] & 0x07) << 18;
            } else {
                size = 3;
                c = (ascii[0] & 0x0F) << 12;
            }
        } else {
            size = 2;
            c = (ascii[0] & 0x1F) << 6;
        }
    } else {
        size = 1;
        c = ascii[0];
    }

    // first byte has already been calculated, calculate the rest
    int i;
    for (i = 1; i < size; i += 1) {
        c |= (ascii[i] & 0x3F) << ((size - i - 1) * 6);
    }

    return c;
}

/*
 * HexTags Inc File.
 * by: Hexah
 * https://github.com/Hexer10/HexTags
 * 
 * Copyright (C) 2017 Mattia (Hexah|Hexer10|Papero)
 *
 * This file is part of the HexTags SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>. 
 */
#if defined _hextags_included
#endinput
#endif
#define _hextags_included

//Allow plugins to use chat-processor defines
#if !defined _chat_processor_included
#define MAXLENGTH_FLAG		32
#define MAXLENGTH_NAME		128
#define MAXLENGTH_MESSAGE	128
#define MAXLENGTH_BUFFER	255
#endif

public SharedPlugin __pl_hextags =
{
	name = "hextags",
	file = "hextags.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};


#if !defined REQUIRE_PLUGIN
public void __pl_hextags_SetNTVOptional()
{
	MarkNativeAsOptional("HexTags_GetClientTag");
	MarkNativeAsOptional("HexTags_SetClientTag");
	MarkNativeAsOptional("HexTags_ResetClientTags");
}
#endif

enum eTags
{
	ScoreTag,
	ChatTag,
	ChatColor,
	NameColor
}

/** 
 * Returns an HexTags client tag.
 *
 * @param        Client Index.
 * @TagType        Tag type.
 * @buffer        String to store the tag in.
 * @maxlength      Maximum size of string buffer.
 *
 * @error        Invalid client index, or not connected.
 */
native void HexTags_GetClientTag(int client, eTags TagType, char[] buffer, int maxlength);

/** 
 * Sets an HexTags client tag.
 * This is resetted everytime that "HexTags_OnTagsUpdated" is called.
 *
 * @param        Client Index.
 * @TagType        Tag type.
 * @Tag          New client tag.
 * 
 * @error        Invalid client index, or not connected.
 */
native void HexTags_SetClientTag(int client, eTags TagType, char[] Tag);

/** 
 * Update the client tags to its default (from config).
 *
 * @param        Client Index.
 *
 * @error        Invalid client index, or not connected.
 */
native void HexTags_ResetClientTags(int client);

/** 
 * Called when the client tags gets updated.
 *
 * @param client		Client Index.
 */
forward void HexTags_OnTagsUpdated(int client);

/**
 * Called when the message is processed.
 *
 * @param client		Client Index.
 * @param name			Player's name.
 * @param message		Player's message.
 *
 * @return		Plugin_Continue to pass or Plugin_Handled or higher to block the processing.
 */
forward Action HexTags_OnMessagePreProcess(int client, char name[MAXLENGTH_NAME], char message[MAXLENGTH_MESSAGE]);

/**
 * Called when the message is processed.
 *
 * @param client		Client Index.
 * @param name			Player's name.
 * @param message		Player's message.

 * @return		Plugin_Continue to pass the event without edits, Plugin_Changed
 *				To pass edits or Plugin_Handled or greter to stop the event.
 */
forward Action HexTags_OnMessageProcess(int client, char name[MAXLENGTH_NAME], char message[MAXLENGTH_MESSAGE]);

/**
 * Called after the message is processed.
 *
 * @param client		Client Index.
 * @param name			Player's name.
 * @param message		Player's message.
 *
 * @noreturn
 */
forward void HexTags_OnMessageProcessed(int client, const char[] name, const char[] message);
/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  shoppinglist.inc
 *  Type:		  Core
 *  Description:   Module to handle shopping list style lists.
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
 * This file is meant for formatting a given string into a list formatted around the style of a shopping
 * list.
 * Example:
 * String: "Bacon, Egg, Egg, Milk, Butter"
 * Shopping List: "Bacon, Eggx2, Milk, Butter"
 * Function parameters will include options to change the "," to any character.  As well as the "x2" format.
 * 
 * More complex examples:
 * String: "Red - Green - Blue-Red- Green -Green - Yellow -Grey"  Note: Horribly formatted, but we can handle it.
 * Shopping List: "Red(2)\nGreen(3)\nBlue\nYellow\nGrey" Note: We can change what to separate each item with, as well as how to display the quantity.
 * 
 * List Options:
 * 
 * Construct: Take a string and dump out a list.  Simple.
 * Remove: Removes an item from the list.  Must remove from the end to preserve list order.
 *  
 * Scenario:
 * String: "Apple, Orange, Mango, Orange"
 * Shopping List: "Apple, Orange x2, Mango"
 * Remove: "Orange"
 * Remove first orange: "Apple, Mango, Orange"  Different order.
 * Remove last orange: "Apple, Orange, Mango" Yay.
 * 
 */

/**
 * @section String length defines.
 */
#define SHOPPINGLIST_MAXITEMS 32
#define SHOPPINGLIST_MAXLEN   32
/**
 * @endsection
 */

/**
 * Takes a given string and outputs a re-formatted shopping list styled list.  See description above.
 * Note:  This is for display purposes only, meaning there will be no API made to format the output of this function.
 * If you plan on the list being dynamic, store the raw string and use the API to edit those.
 * 
 * @param list			  Raw string to be formatted.
 * @param shoppinglist	  Outputted shopping list.
 * @param slist_maxlen	  The maximum length of the shopping list.
 * @param in_token		  The token used to separate each item in the raw string. Ex: "Apple, Orange"  Token: ","
 * @param out_token		 What to separate each item with in the shopping list.  Ex: Token: "\n"  List: "Apple\nOrange"
 * @param quantityformat	How to show the quantity of an item for multi-listed items.  ## is the number.  Ex: "Apples x2" quantityformat: " x##"
 */
stock void ShoppingListConstruct(const char[] list, char[] shoppinglist, int slist_maxlen, const char[] in_token = ",", const char[] out_token = ",", const char[] quantityformat = " x##")
{
	// Put each item in a list.
	char items[SHOPPINGLIST_MAXITEMS][SHOPPINGLIST_MAXLEN];
	ExplodeString(list, in_token, items, SHOPPINGLIST_MAXITEMS, SHOPPINGLIST_MAXLEN);
	
	// Put each item in a trie where we count each item.
	Handle trieItems = CreateTrie();
	int item_count;
	int validstrings;
	
	// x = Array index.
	for (int x = 0; x < SHOPPINGLIST_MAXITEMS; x++)
	{
		// Trim off any whitespace.
		TrimString(items[x]);
		
		// If there are no more items left, exit the loop.
		if (!items[x][0])
			break;
		
		// Reset item_count to 0, retrieve value, if it already exists, and set value + 1.
		item_count = 0;
		GetTrieValue(trieItems, items[x], item_count);
		SetTrieValue(trieItems, items[x], ++item_count);
		
		validstrings++;
	}
	
	// Initialize 'shoppinglist'.
	strcopy(shoppinglist, slist_maxlen, "");
	
	char item_formatted[SHOPPINGLIST_MAXLEN];
	char strQuantity[8];
	
	// x = Array index.
	for (int x = 0; x < validstrings; x++)
	{
		// Get quantity count, in string and int.
		GetTrieValue(trieItems, items[x], item_count);
		
		// If the item_count is 0, this item is already in the shopping list.
		if (item_count == 0)
			continue;
		
		IntToString(item_count, strQuantity, sizeof(strQuantity));
		
		strcopy(item_formatted, sizeof(item_formatted), items[x]);
		
		// Format the quantity on if there was more than 1.
		if (item_count > 1)
		{
			Format(item_formatted, sizeof(item_formatted), "%s%s", item_formatted, quantityformat);
			ReplaceString(item_formatted, sizeof(item_formatted), "##", strQuantity);
		}
		
		// Format the item onto the list.
		if (!shoppinglist[0])
		{
			strcopy(shoppinglist, slist_maxlen, item_formatted);
		}
		else
		{
			Format(shoppinglist, slist_maxlen, "%s%s%s", shoppinglist, out_token, item_formatted);
		}
		
		SetTrieValue(trieItems, items[x], 0);
	}
	
	// Destroy the trie handle.
	CloseHandle(trieItems);
}

/**
 * Add an item to the list.
 * Notes:
 * For max number of items, and the max length of each item, see SHOPPINGLIST_* defines at the top.
 * 
 * @param list		  The list to remove item from.
 * @param maxlen		The maximum length of the finished list.
 * @param item		  The item to remove from the list.
 * @param token		 The token to remove with the item. 
 * @return			  True if the item was found and removed, false if not found. 
 */
public bool ShoppingListRemove(char[] list, int maxlen, const char[] item, const char[] token)
{
	// Explode the items into an array.
	char items[SHOPPINGLIST_MAXITEMS][SHOPPINGLIST_MAXLEN];
	ExplodeString(list, token, items, SHOPPINGLIST_MAXITEMS, SHOPPINGLIST_MAXLEN);
	
	int validstrings;
	
	// x = Array index.
	for (int x = SHOPPINGLIST_MAXITEMS - 1; x >= 0; x--)
	{
		// Trim off any whitespace.
		TrimString(items[x]);
		
		if (StrEqual(item, items[x], false))
		{
			// Nullify the matching string.
			items[x][0] = 0;
			
			// Re-copy each index after the matching string to overwrite it. 
			for (int y = x; y < SHOPPINGLIST_MAXITEMS - 1; y++)
				items[y] = items[y + 1];
			
			// Implode the array of strings back together into a full string.
			ImplodeStrings(items, validstrings + x, token, list, maxlen);
			
			return true;
		}
		
		// If this is a valid string, count it.
		if (items[x][0])
			validstrings++;
	}
	
	return false;
}


/**
 * 
 *
 * BROKEN STUFF
 * Attempted versions of the above code.
 * The working version is mostly (99%) Frus's code.
 * 
 *
 */

/**
 * Add an item to the list.
 * 
 * @param list		  The list to remove item from.
 * @param maxlen		The maximum length of the finished list.
 * @param item		  The item to remove from the list.
 * @param token		 The token to remove with the item. 
 * @return			  True if the item was found and removed, false if not found. 
 */
/*stock bool ShoppingListRemove(char[] list, int maxlen, const char[] item, const char[] token)
{
	int itemindex = -1;
	int itemindex2 = -1;
	int pos;
	while (itemindex == itemindex2)
	{
		itemindex2 = pos = StrContains(list[pos], item, false);
		
		if (itemindex2 != -1)
		{
			itemindex = itemindex2;
			pos += 1;
			
			PrintToServer("%d %d %d %s", itemindex, itemindex2, pos, list[pos]);
		}
		else
			break;
	}
	
	if (itemindex == -1)
		return false;
	
	PrintToServer("position %d", itemindex);
	
	return true;
}*/

/**
 * Add an item to the list.
 * 
 * @param list		  The list to remove item from.
 * @param maxlen		The maximum length of the finished list.
 * @param maxitems	  The maximum number of shopping items.
 * @param maxitemlen	The maximum length of EACH item in the string.
 * @param item		  The item to remove from the list.
 * @param token		 The token to remove with the item. 
 * @return			  True if the item was found and removed, false if not found. 
 */
/*stock bool ShoppingListRemove(char list[], int maxlen, int maxitems, int maxitemlen, const char[] item, const char[] token)
{
	// Default initialized value = false.
	bool success;
	
	// Put each item in a list.
	char items[maxitems][maxitemlen];
	ExplodeString(list, token, items, maxitems, maxitemlen);
	
	// x = List index.
	for (int x = maxitems - 1; x >= 0; x--)
	{
		PrintToServer("%d %s", x, items[x]);
		if (StrEqual(items[x], item, false))
		{
			strcopy(items[x], maxitemlen, "");
			success = true;
			break;
		}
	}
	
	char items_after[maxitems][maxitemlen];
	int count;
	
	// x = List index.
	for (int x = 0; x < maxitems; x++)
	{
		PrintToServer("%d \"%s\"", x, items[x]);
		
		if (!items[x][0])
			continue;
		
		// Move valid item to new array, and increment count after.
		strcopy(items_after[count++], maxitemlen, items[x]);
	}
	
	// Join the valid strings back together.
	ImplodeStrings(items_after, count, token, list, maxlen);
	
	return success;
}*/

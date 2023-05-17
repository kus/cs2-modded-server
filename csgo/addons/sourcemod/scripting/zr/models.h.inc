/*
 * ============================================================================
 *
 *  Zombie:Reloaded
 *
 *  File:		  models.h.inc
 *  Type:		  Core
 *  Description:   Model data structures and constants.
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
 * Maximum number of models.
 */
#define MODELS_MAX 48

/**
 * Maximum folder depth a model file can be located.
 */
#define MODELS_PATH_MAX_DEPTH 8

/**
 * Maximum string length of a folder a model file is located under.
 */
#define MODELS_PATH_DIR_MAX_LENGTH 32

/**
 * Model access settings.
 */
enum ModelAccess
{
	ModelAccess_Invalid = -1,   /* Invalid access type. */
	ModelAccess_Public = 0,	 /* Everyone can use the model. */
	ModelAccess_Admins,		 /* Model can only be used by admins. */
	ModelAccess_Hidden,		 /* Model is excluded from public random selections. */
	ModelAccess_MotherZombies,  /* Only mother zombies can use this model. */
	ModelAccess_Group		   /* Enables group authentication. */
}

/**
 * @section Model access flags.
 */
#define MODEL_ACCESS_PUBLIC			 (1<<0)
#define MODEL_ACCESS_ADMINS			 (1<<1)
#define MODEL_ACCESS_HIDDEN			 (1<<2)
#define MODEL_ACCESS_MOTHER_ZOMBIES	 (1<<3)
#define MODEL_ACCESS_GROUP			  (1<<4)
/**
 * @endsection
 */

/**
 * Avaliable teams for models.
 */
enum ModelTeam
{
	ModelTeam_Invalid = -1,
	ModelTeam_Zombies = 0,
	ModelTeam_Humans
}

/**
 * Model settings structure.
 */
enum ModelAttributes
{
	String:Model_Name[64],					  /* File name of model (no file extension). */
	String:Model_Path[PLATFORM_MAX_PATH],	   /* Path to model files. */
	ModelTeam:Model_Team,					   /* What team the model belongs to. */
	ModelAccess:Model_Access,				   /* Access settings. */
	String:Model_Group[64]					  /* Group authentication (if used). */
}

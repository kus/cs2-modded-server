#if defined _smlib_math_included
	#endinput
#endif
#define _smlib_math_included

#include <sourcemod>

#define SIZE_OF_INT         2147483647 // without 0
#define INT_MAX_DIGITS      10

#define GAMEUNITS_TO_METERS	0.01905
#define METERS_TO_GAMEUNITS	52.49343832020997
#define METERS_TO_FEET		3.2808399
#define FEET_TO_METERS		0.3048
#define KILOMETERS_TO_MILES	0.62137

enum VecAngle
{
	ANG_ALPHA,
	ANG_BETA,
	ANG_GAMMA
}

/**
 * Makes a negative integer number to a positive integer number.
 * This is faster than Sourcemod's native FloatAbs() for integers.
 * Use FloatAbs() for Float numbers.
 *
 * @param number		A number that can be positive or negative.
 * @return				Positive number.
 */
stock Math_Abs(value)
{	
	return (value ^ (value >> 31)) - (value >> 31);
}

/**
 * Checks if 2 vectors are equal.
 * You can specfiy a tolerance, which is the maximum distance at which vectors are considered equals
 *
 * @param vec1			First vector (3 dim array)
 * @param vec2			Second vector (3 dim array)
 * @param tolerance 	If you want to check that those vectors are somewhat even. 0.0 means they are 100% even if this function returns true.
 * @return				True if vectors are equal, false otherwise.
 */
stock bool:Math_VectorsEqual(Float:vec1[3], Float:vec2[3], Float:tolerance=0.0)
{	
	new Float:distance = GetVectorDistance(vec1, vec2, true);
	
	return distance <= (tolerance * tolerance);
}

/**
 * Sets the given value to min
 * if the value is smaller than the given.
 * 
 * @param value			Value
 * @param min			Min Value used as lower border
 * @return				Correct value not lower than min
 */
stock any:Math_Min(any:value, any:min)
{
	if (value < min) {
		value = min;
	}
	
	return value;
}

/**
 * Sets the given value to max
 * if the value is greater than the given.
 * 
 * @param value			Value
 * @param max			Max Value used as upper border
 * @return				Correct value not upper than max
 */
stock any:Math_Max(any:value, any:max)
{	
	if (value > max) {
		value = max;
	}
	
	return value;
}

/**
 * Makes sure a value is within a certain range and
 * returns the value.
 * If the value is outside the range it is set to either
 * min or max, if it is inside the range it will just return
 * the specified value.
 * 
 * @param value			Value
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Correct value not lower than min and not greater than max.
 */
stock any:Math_Clamp(any:value, any:min, any:max)
{
	value = Math_Min(value, min);
	value = Math_Max(value, max);

	return value;
}

/* 
 * Checks if the value is within the given bounds (min & max).
 * 
 * @param value		The value you want to check.
 * @param min		The lower border.
 * @param max		The upper border.
 * @return			True if the value is within bounds (bigger or equal min / smaller or equal max), false otherwise.
 */
stock bool:Math_IsInBounds(any:value, any:min, any:max)
{
	if (value < min || value > max) {
		return false;
	}
	
	return true;
}

/**
 * Let's the specified value "overflow" if it is outside the given limit.
 * This is like with integers when it reaches a value above the max possible
 * integer size.
 * 
 * @param value			Value
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Overflowed number
 */
stock any:Math_Overflow(any:value, any:min, any:max)
{
	return (value % max) + min;
}

/**
 * Returns a random, uniform Integer number in the specified (inclusive) range.
 * This is safe to use multiple times in a function.
 * The seed is set automatically for each plugin.
 * Rewritten by MatthiasVance, thanks.
 * 
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Random Integer number between min and max
 */
stock Math_GetRandomInt(min, max)
{
	new random = GetURandomInt();
	
	if (random == 0) {
		random++;
	}

	return RoundToCeil(float(random) / (float(SIZE_OF_INT) / float(max - min + 1))) + min - 1;
}

/**
 * Returns a random, uniform Float number in the specified (inclusive) range.
 * This is safe to use multiple times in a function.
 * The seed is set automatically for each plugin.
 * 
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Random Float number between min and max
 */
stock Float:Math_GetRandomFloat(Float:min, Float:max)
{
	return (GetURandomFloat() * (max  - min)) + min;
}

/**
 * Gets the percentage of amount in all as Integer where
 * amount and all are numbers and amount usually
 * is a subset of all.
 * 
 * @param value			Integer value
 * @param all			Integer value
 * @return				An Integer value between 0 and 100 (inclusive).
 */
stock Math_GetPercentage(value, all) {
	return RoundToNearest((float(value) / float(all)) * 100.0);
}

/**
 * Gets the percentage of amount in all as Float where
 * amount and all are numbers and amount usually
 * is a subset of all.
 * 
 * @param value			Float value
 * @param all			Float value
 * @return				A Float value between 0.0 and 100.0 (inclusive).
 */
stock Float:Math_GetPercentageFloat(Float:value, Float:all) {
	return (value / all) * 100.0;
}

/*
 * Moves the start vector on a direct line to the end vector by the given scale.
 * Note: If scale is 0.0 the output will be the same as the start vector and if scale is 1.0 the output vector will be the same as the end vector.
 * Exmaple usage: Move an entity to another entity but only 12 units: Vector_MoveVector(entity1Origin,entity2Origin,(12.0 / GetVectorDistance(entity1Origin,entity2Origin)),newEntity1Origin); now only teleport your entity to newEntity1Origin.
 *
 * @param start			The start vector where the imagined line starts.
 * @param end			The end vector where the imagined line ends.
 * @param scale			The position on the line 0.0 is the start 1.0 is the end.
 * @param output		Output vector
 * @noreturn
 */
stock Math_MoveVector(const Float:start[3], const Float:end[3], Float:scale, Float:output[3])
{
	SubtractVectors(end,start,output);
	ScaleVector(output,scale);
	AddVectors(start,output,output);
}

/**
 * Puts x, y and z into a vector.
 * 
 * @param x				Float value.
 * @param y				Float value.
 * @param z				Float value.
 * @param result		Output vector.
 * @noreturn
 */
stock Math_MakeVector(const Float:x, const Float:y, const Float:z, Float:result[3])
{
	result[0] = x;
	result[1] = y;
	result[2] = z;
}

/**
 * Rotates a vector around its zero-point.
 * Note: As example you can rotate mins and maxs of an entity and then add its origin to mins and maxs to get its bounding box in relation to the world and its rotation.
 * When used with players use the following angle input:
 *   angles[0] = 0.0;
 *   angles[1] = 0.0;
 *   angles[2] = playerEyeAngles[1];
 * 
 * @param vec 			Vector to rotate.
 * @param angles 		How to rotate the vector.
 * @param result		Output vector.
 * @noreturn
 */
stock Math_RotateVector(const Float:vec[3], const Float:angles[3], Float:result[3])
{
	// First the angle/radiant calculations
	decl Float:rad[3];
	// I don't really know why, but the alpha, beta, gamma order of the angles are messed up...
	// 2 = xAxis
	// 0 = yAxis
	// 1 = zAxis
	rad[0] = DegToRad(angles[2]);
	rad[1] = DegToRad(angles[0]);
	rad[2] = DegToRad(angles[1]);

	// Pre-calc function calls
	new Float:cosAlpha = Cosine(rad[0]);
	new Float:sinAlpha = Sine(rad[0]);
	new Float:cosBeta = Cosine(rad[1]);
	new Float:sinBeta = Sine(rad[1]);
	new Float:cosGamma = Cosine(rad[2]);
	new Float:sinGamma = Sine(rad[2]);

	// 3D rotation matrix for more information: http://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
	new Float:x = vec[0], Float:y = vec[1], Float:z = vec[2];
	new Float:newX, Float:newY, Float:newZ;
	newY = cosAlpha*y - sinAlpha*z;
	newZ = cosAlpha*z + sinAlpha*y;
	y = newY;
	z = newZ;

	newX = cosBeta*x + sinBeta*z;
	newZ = cosBeta*z - sinBeta*x;
	x = newX;
	z = newZ;

	newX = cosGamma*x - sinGamma*y;
	newY = cosGamma*y + sinGamma*x;
	x = newX;
	y = newY;
	
	// Store everything...
	result[0] = x;
	result[1] = y;
	result[2] = z;
}

/**
 * Converts Source Game Units to metric Meters
 * 
 * @param units			Float value
 * @return				Meters as Float value.
 */
stock Float:Math_UnitsToMeters(Float:units)
{
	return (units * GAMEUNITS_TO_METERS);
}

/**
 * Converts Source Game Units to Meters
 * 
 * @param units			Float value
 * @return				Feet as Float value.
 */
stock Float:Math_UnitsToFeet(Float:units)
{
	return (Math_UnitsToMeters(units) * METERS_TO_FEET);
}

/**
 * Converts Source Game Units to Centimeters
 * 
 * @param units			Float value
 * @return				Centimeters as Float value.
 */
stock Float:Math_UnitsToCentimeters(Float:units)
{
	return (Math_UnitsToMeters(units) * 100.0);
}

/**
 * Converts Source Game Units to Kilometers
 * 
 * @param units			Float value
 * @return				Kilometers as Float value.
 */
stock Float:Math_UnitsToKilometers(Float:units)
{
	return (Math_UnitsToMeters(units) / 1000.0);
}

/**
 * Converts Source Game Units to Miles
 * 
 * @param units			Float value
 * @return				Miles as Float value.
 */
stock Float:Math_UnitsToMiles(Float:units)
{
	return (Math_UnitsToKilometers(units) * KILOMETERS_TO_MILES);
}
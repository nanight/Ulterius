/*
 *  Common.c
 *  Ulterius
 *
 */

#include "Common.h"

const BASCommandSpec kUlteriusCommandSet[] = {
{	kUlteriusGetVersionCommand,               // commandName
NULL,                                   // rightName           -- never authorize
NULL,                                   // rightDefaultRule	   -- not applicable if rightName is NULL
NULL,									// rightDescriptionKey -- not applicable if rightName is NULL
NULL                                    // userData
},
{
		kUlteriusWritePlistCommand,				// commandName
		kUlteriusWritePlistCommandRightName,	// rightName
		"allow",						// rightDefaultRule -- allow anyone
		NULL,							// rightDescriptionKey -- no custom prompt
		NULL							// userData
},
{
		kUlteriusDeletePlistCommand,				// commandName
		kUlteriusDeletePlistCommandRightName,	// rightName
		"allow",						// rightDefaultRule -- allow anyone
		NULL,							// rightDescriptionKey -- no custom prompt
		NULL							// userData
},
{
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	}
};

// The kUlteriusCommandSet is used by both the app and the tool to communicate the set of 
// supported commands to the BetterAuthorizationSampleLib module.


/*
 *  Common.h
 *  Ulterius
 *
 */

#ifndef _ULTERIUSCOMMON_H
#define _ULTERIUSCOMMON_H

#include "BetterAuthorizationSampleLib.h"

/**********************************************************************
* BetterAuthorizationSampleLib
***********************************************************************/

#define kUlteriusGetVersionCommand        "GetVersion"

// authorization right name (none)

// request keys (none)

// response keys

#define kUlteriusGetVersionResponse			"Version"                   // CFNumber

#define kUlteriusDeletePlistCommand		"deletePlist"
#define kUlteriusDeletePlistCommandRightName	"com.adequateproductions.Ulterius.deletePlist"

#define kUlteriusWritePlistCommand "writePlist"
// inputs:
// kBASCommandKey (CFDictionaryRef)
// outputs:
// kBASErrorKey (CFNumber)
// authorization right
#define kUlteriusWritePlistCommandRightName "com.adequateproductions.Ulterius.writePlist"

#define kUlteriusWritePlistForceFailure	"ForceFailure"              // CFBoolean (optional, presence implies true)

extern const BASCommandSpec kUlteriusCommandSet[];


/**********************************************************************
* Ulterius
***********************************************************************/

// Plist
#define kProgramArguments			"ProgramArguments"
#define kStartCalendarInterval		"StartCalendarInterval"
#define kTitle						"title"
#define kLaunchAgents				"/Library/LaunchAgents"
#define kUserLaunchAgents			"~/Library/LaunchAgents"

#define kMonthly					"Monthly"
#define kWeekly						"Weekly"
#define kDaily						"Daily"
#define kHourly						"Hourly"
#define kMinutely					"Every Minute"
#define kNoRecurrence				"No Recurrence"

// Resources
#define kApplicationSupport			"/Library/Application Support/Ulterius/"
#define kMyReceiversFileName		"myReceivers.plist"
#define kReceiversFileName			"receivers.plist"
#define kTransceiversFileName		"transceivers.plist"
#define kEventsFileName				"events.plist"
#define kPlist						"plist"
#define kTsdaemon					"tsdaemon"

// Tool
#define kToolVersion				4

#endif
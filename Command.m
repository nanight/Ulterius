//
//  Command.m
//  Ulterius
//

#import "Command.h"
#import "Common.h"

@implementation Command


#pragma mark -
#pragma mark Startup and Shutdown

-(id)init{
	[self release];
	return [[NSMutableDictionary dictionaryWithObjectsAndKeys:@"New", @kTitle, @"0", @"command", nil] retain];
}

@end

//
//  Receiver.h
//  Ulterius
//

#import <Cocoa/Cocoa.h>
@class AppController;

@interface Receiver : NSObject{
	AppController *appController;
	NSMutableDictionary *properties;
	NSMutableArray *commands;	
	NSMutableArray *units;	
	NSMutableArray *houses;	
	NSString *type;
	
}

@property (retain)NSMutableDictionary *properties;
@property (retain)NSMutableArray *commands;
@property (retain)NSMutableArray *units;
@property (retain)NSMutableArray *houses;
@property (retain)NSString *type;
@property (retain)AppController *appController;


- (id)initWithDictionary:(NSDictionary *)savedDict;
- (void)startObservingCommand:(NSMutableDictionary *)command;
- (void)stopObservingCommand:(NSMutableDictionary *)command;

@end

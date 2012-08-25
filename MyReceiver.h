//
//  MyReceiver.h
//  Ulterius
//

#import <Cocoa/Cocoa.h>
@class Event;
@class Receiver;
@class AppController;

@interface MyReceiver : NSObject{
	AppController *appController;
	Receiver *configuredReceiver;
	NSMutableDictionary *properties;
	NSMutableArray *events;
	NSDictionary *configuredUnit;
	NSDictionary *configuredHouse;
	NSString *type;
}
@property (retain)NSString *type;

- (Receiver *)configuredReceiver;
- (void)setConfiguredReceiver:(Receiver *)newConfiguredReceiver;

- (void)insertObject:(Event *)myEvent inEventsAtIndex:(int)index;
- (void)removeObjectFromEventsAtIndex:(int)index;
- (void)startObservingEvent:(Event *)myEvent;
- (void)stopObservingEvent:(Event *)myEvent;

@property (retain)NSMutableDictionary *properties;
@property (retain)NSDictionary *configuredHouse;
@property (retain)NSDictionary *configuredUnit;
@property (retain)NSMutableArray *events;
@property (retain)AppController *appController;

- (id)initWithDictionary:(NSDictionary *)savedDict andReceivers:(NSArray *)configuredReceivers;
- (NSString *)renderCommand:(NSString *)command;
- (NSString *)renderCommandFromEvent:(Event *)event;

- (NSDictionary *)getAsXML;

@end

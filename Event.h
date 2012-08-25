//
//  Event.h
//  Ulterius
//

#import <Cocoa/Cocoa.h>
@class Transceiver;
@class MyReceiver;
@class AppController;

@interface Event : NSObject {
	MyReceiver *myReceiver;
	Transceiver *configuredTransceiver;
	NSDictionary *configuredCommand;
	NSString *title;
	NSDate *dateTime;
	NSString *year;
	NSString *month;
	NSString *day;
	NSString *hour;
	NSString *minute;	
	NSString *second;
	NSMutableDictionary *weekday;
	NSArray *weekdays;
	NSString *recurring;
	NSString *type;
	NSNumber *dateEnabled;
	NSNumber *recurringHidden;
	NSNumber *weekdayEnabled;
	NSNumber *yearButton;
	NSNumber *monthButton;
	NSNumber *dayButton;
	NSNumber *hourButton;
	NSNumber *minuteButton;
	NSNumber *secondButton;
	NSNumber *enabled;

}
- (id)initWithDictionary:(NSDictionary *)savedDict andAppController:(AppController *)appController;

@property (retain)NSString *title;
@property (retain)NSDate *dateTime;
@property (retain)NSString *year;
@property (retain)NSString *month;
@property (retain)NSString *day;
@property (retain)NSString *hour;
@property (retain)NSString *minute;
@property (retain)NSString *second;
@property (retain)NSArray *weekdays;
@property (retain)NSString *type;
@property (retain)NSNumber *dateEnabled;
@property (retain)NSNumber *weekdayEnabled;
@property (retain)NSNumber *recurringHidden;
@property (retain)NSNumber *yearButton;
@property (retain)NSNumber *monthButton;
@property (retain)NSNumber *dayButton;
@property (retain)NSNumber *hourButton;
@property (retain)NSNumber *minuteButton;
@property (retain)NSNumber *secondButton;
@property (retain)MyReceiver *myReceiver;
@property (retain)NSNumber *enabled;

- (void)createSetTitle;

- (Transceiver *)configuredTransceiver;
- (void)setConfiguredTransceiver:(Transceiver *)newConfiguredTransceiver;

- (NSDictionary *)configuredCommand;
- (void)setConfiguredCommand:(NSDictionary *)newConfiguredCommand;

- (NSDate *)dateTime;
- (void)setDateTime:(NSDate *)newDateTime;

- (NSString *)recurring;
- (void)setRecurring:(NSString *)newRecurring;

- (NSMutableDictionary *)weekday;
- (void)setWeekday:(NSMutableDictionary *)newWeekday;

- (NSDictionary *)getAsXML;

@end

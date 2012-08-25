//
//  Transceiver.h
//  Ulterius
//
//

#import <Cocoa/Cocoa.h>
@class AppController;


@interface Transceiver : NSObject {
	AppController *appController;
	NSMutableDictionary *properties;
	NSString *status;
	NSString *device;
	NSString *VID;
	NSString *PID;
	NSString *type;
}

//- (BOOL)sendMyCommand:(NSString *)command;
- (void)loadDeviceStatus;
- (void)loadDeviceFirmware;

@property (retain)NSString *type;
@property (retain)NSString *VID;
@property (retain)NSString *PID;
@property (retain)NSString *device;
@property (retain)NSString *status;
@property (retain)NSMutableDictionary *properties;
@property (retain)AppController *appController;

- (id)initWithDictionary:(NSDictionary *)savedDict;
- (NSDictionary *)getAsXML;
@end


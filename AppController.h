//
//  AppController.h
//  Ulterius
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <SecurityFoundation/SFAuthorization.h>
@class Transceiver;
@class Receiver;
@class Event;
@class MyReceiver;

@interface AppController : NSDocument {
	IBOutlet NSArrayController *transceiversController;
	IBOutlet NSArrayController *eventsController;
	IBOutlet NSArrayController *receiversController;
	IBOutlet NSArrayController *myReceiversController;
	NSWindow *mainWindow;
	IBOutlet NSButton *commandButton;
	IBOutlet NSTableView *myReceiversTable;
/*	IBOutlet NSTableView *receiversTable;
	IBOutlet NSTableView *transceiversTable;*/
	NSDatePicker *datePicker;
	NSDatePickerCell *datePickerCell;
	IBOutlet NSButton *yearCheckBox;
	IBOutlet NSButton *monthCheckBox;
	IBOutlet NSButton *dayCheckBox;
	IBOutlet NSButton *hourCheckBox;
	IBOutlet NSButton *minuteCheckBox;
	IBOutlet NSButton *secondCheckBox;
	BOOL documentEdited;
	NSMutableArray *transceivers;
	NSMutableArray *receivers;
	NSMutableArray *myReceivers;
	NSArray *recurrings;
	NSArray *weekdays;
	NSSpeechRecognizer *recog;
	NSArray *cmds;
	BOOL globalLaunchAgents;
	
	// Localized GUI Strings
	//Tabs
	const NSString *schedulingString;
	const NSString *advancedString;

	// Scheduling tab
	// Events
	const NSString *enabledString; 
	const NSString *commandString;
	const NSString *dateString;
	const NSString *recurringString;
	const NSString *weekdayString;
	const NSString *customRecurringString;
	const NSString *saveChangesString;

	// Columns
	const NSString *eventsString;
	const NSString *unitString;
	const NSString *houseString;
	const NSString *modelString;
	const NSString *myReceiversString;
	
	// Manual Control
	const NSString *onString;
	const NSString *offString;
	const NSString *allOnString;
	const NSString *allOffString;
	const NSString *testEventString;

	const NSString *startSpeechRecognitionString;
	
	// Advanced tab
	const NSString *receiverModelsString;
	const NSString *commandsString;
	const NSString *transceiversString;
	const NSString *reloadDeviceString;
	const NSString *unitsString;
	const NSString *housesString;

}
// Localized GUI Strings
// Tabs
@property (retain)NSString *schedulingString;
@property (retain)NSString *advancedString;

// Scheduling tab
// Events
@property (retain)NSString *enabledString;
@property (retain)NSString *commandsString;
@property (retain)NSString *dateString;
@property (retain)NSString *recurringString;
@property (retain)NSString *weekdayString;
@property (retain)NSString *customRecurringString;
@property (retain)NSString *saveChangesString;

// Columns
@property (retain)NSString *eventsString;
@property (retain)NSString *unitString;
@property (retain)NSString *houseString;
@property (retain)NSString *modelString;
@property (retain)NSString *myReceiversString;

// Manual Control
@property (retain)NSString *onString;
@property (retain)NSString *offString;
@property (retain)NSString *allOnString;
@property (retain)NSString *allOffString;
@property (retain)NSString *testEventString;

@property (retain)NSString *startSpeechRecognitionString;

// Advanced tab
@property (retain)NSString *receiverModelsString;
@property (retain)NSString *commandString;
@property (retain)NSString *transceiversString;
@property (retain)NSString *reloadDeviceString;
@property (retain)NSString *unitsString;
@property (retain)NSString *housesString;


// Non GUI
@property (retain)NSMutableArray *transceivers;
@property (retain)NSMutableArray *receivers;
@property (retain)NSMutableArray *myReceivers;
@property (retain)NSArray *recurrings;
@property (retain)NSArray *weekdays;
@property (retain)IBOutlet NSWindow *mainWindow;
@property (retain)IBOutlet NSDatePicker *datePicker;
@property BOOL documentEdited;
@property BOOL globalLaunchAgents;

- (void)insertObject:(Receiver *)receiver inReceiversAtIndex:(int)index;
- (void)removeObjectFromReceiversAtIndex:(int)index;
- (void)insertObject:(MyReceiver *)myReceiver inMyReceiversAtIndex:(int)index;
- (void)removeObjectFromMyReceiversAtIndex:(int)index;
- (void)insertObject:(Transceiver *)transceiver inTransceiversAtIndex:(int)index;
- (void)removeObjectFromTransceiversAtIndex:(int)index;
- (IBAction)insertMyReceiverAction:(id)sender;
//- (IBAction)insertEventAction:(id)sender;
//- (IBAction)insertReceiverAction:(id)sender;
- (IBAction)insertTransceiverAction:(id)sender;


- (void)startObservingReceiver:(Receiver *)receiver;
- (void)stopObservingReceiver:(Receiver *)receiver;
- (void)startObservingMyReceiver:(MyReceiver *)myReceiver;
- (void)stopObservingMyReceiver:(MyReceiver *)myReceiver;
- (void)startObservingTransceiver:(Transceiver *)transceiver;
- (void)stopObservingTransceiver:(Transceiver *)transceiver;

- (NSString *)createTitleForObject:(id)object inArray:(NSArray *)objArray;
- (NSString *)doGetVersion;
- (void)initEvents;
- (void)initTransceivers;
- (void)initReceivers;
- (void)initMyReceivers;
- (void)deleteEvents;
- (void)sendCommand:(NSString *)command;
- (void)sendCommandByName:(NSString *)commandName toMyReceiver:(MyReceiver *)myReceiver;

- (IBAction)saveChangesAction:(id)sender;
- (IBAction)sendCommandAction:(id)sender;
- (IBAction)myReceiverOn:(id)sender;
- (IBAction)myReceiverOff:(id)sender;
- (IBAction)allReceiversOn:(id)sender;
- (IBAction)allReceiversOff:(id)sender;
- (IBAction)destroyRights:(id)sender;
- (IBAction)reinstallTool:(id)sender;
- (IBAction)saveDefaults:(id)sender;
- (IBAction)reloadDeviceStatus:(id)sender;

- (void)saveChanges;
- (void)writeMyReceivers;
- (void)writeTransceivers;
- (void)writeEvents;
- (void)setEdited:(BOOL)edited;

- (void)reinstallToolWithComment:(NSString *)alertComment;
- (IBAction)listen:(id)sender;
- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd;

@end

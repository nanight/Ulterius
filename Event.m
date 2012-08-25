//
//  Event.m
//  Ulterius
//

#import "Common.h"
#import "Event.h"
#import "MyReceiver.h"
#import "AppController.h"


@implementation Event

@synthesize title;
@synthesize dateTime;
@synthesize year;
@synthesize month;
@synthesize day;
@synthesize hour;
@synthesize minute;
@synthesize second;
@synthesize weekdays;
@synthesize type;
@synthesize dateEnabled;
@synthesize weekdayEnabled;
@synthesize recurringHidden;
@synthesize yearButton;
@synthesize monthButton;
@synthesize dayButton;
@synthesize hourButton;
@synthesize minuteButton;
@synthesize secondButton;
@synthesize myReceiver;
@synthesize enabled;

#pragma mark -
#pragma mark Startup and Shutdown

- (id)initWithDictionary:(NSDictionary *)savedDict andAppController:(AppController *)appController{
	[self init];
	
	self.dateTime = [savedDict objectForKey:@"dateTime"];
	self.minute = [dateTime descriptionWithCalendarFormat:@"%M" timeZone:nil locale:nil];
	self.hour = [dateTime descriptionWithCalendarFormat:@"%H" timeZone:nil locale:nil];
	self.day = [dateTime descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil];
	self.month = [dateTime descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil];
	self.year = [dateTime descriptionWithCalendarFormat:@"%y" timeZone:nil locale:nil];
	if ([savedDict objectForKey:@"weekday"] != NULL) {
		self.weekday = [savedDict objectForKey:@"weekday"];
	}
/*	[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[dateTime descriptionWithCalendarFormat:@"%A" timeZone:nil locale:nil], 
					@kTitle,
					[dateTime descriptionWithCalendarFormat:@"%w" timeZone:nil locale:nil], 
					@"day",
					nil];
*/	
	
	
	for (int i = 0; i < [[appController myReceivers] count]; ++i){
		if ([[[[[appController myReceivers] objectAtIndex:i] properties] objectForKey:@kTitle] 
			 isEqualToString:[savedDict objectForKey:@"myReceiver"]]){
			self.myReceiver = [[appController myReceivers] objectAtIndex:i];
		}
	}

	[myReceiver startObservingEvent:self];
	
	for (int j = 0; j < [[myReceiver.configuredReceiver commands] count]; j++){
		if ([[[[myReceiver.configuredReceiver commands] objectAtIndex:j] objectForKey:@kTitle] 
			 isEqualToString:[savedDict objectForKey:@"configuredCommand"]])
			self.configuredCommand = [[myReceiver.configuredReceiver commands] objectAtIndex:j];
	}
	for (int i = 0; i < [[appController transceivers] count]; ++i){
		if ([[[[[appController transceivers] objectAtIndex:i] properties] objectForKey:@kTitle] 
			 isEqualToString:[savedDict objectForKey:@"configuredTransceiver"]])
			self.configuredTransceiver = [[appController transceivers] objectAtIndex:i];
	}
	
	self.yearButton = [savedDict objectForKey:@"yearButton"];
	self.monthButton = [savedDict objectForKey:@"monthButton"];
	self.dayButton = [savedDict objectForKey:@"dayButton"];
	self.hourButton = [savedDict objectForKey:@"hourButton"];
	self.minuteButton = [savedDict objectForKey:@"minuteButton"];
	self.secondButton = [savedDict objectForKey:@"secondButton"];	
	self.recurringHidden = [savedDict objectForKey:@"recurringHidden"];	
	self.recurring = [savedDict objectForKey:@"recurring"];
	if (![savedDict objectForKey:@"enabled"])
		self.enabled = [NSNumber numberWithInt:1];
	else
		self.enabled = [savedDict objectForKey:@"enabled"];

	return self;
}

- (id)init{
	if (self = [super init]){
		
		self.weekdays = [NSArray arrayWithObjects:
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Monday", NULL), @kTitle, @"1", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Tuesday", NULL), @kTitle, @"2", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Wednesday", NULL), @kTitle, @"3", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Thursday", NULL), @kTitle, @"4", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Friday", NULL), @kTitle, @"5", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Saturday", NULL), @kTitle, @"6", @"day", nil],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Sunday", NULL), @kTitle, @"0", @"day", nil],
						 nil];
		
		
		self.type = @"Event";
		self.dateTime = [NSDate dateWithTimeIntervalSinceNow:60];
		self.recurring = @kDaily;
		self.weekday = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						[[NSDate date] descriptionWithCalendarFormat:@"%A" timeZone:nil locale:nil], 
						@kTitle,
						[[NSDate date] descriptionWithCalendarFormat:@"%w" timeZone:nil locale:nil], 
						@"day",
						nil];

		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:0];
		self.hourButton = [NSNumber numberWithInt:0];
		self.minuteButton = [NSNumber numberWithInt:0];
		self.secondButton = [NSNumber numberWithInt:0];
		self.recurringHidden = [NSNumber numberWithInt:0];
		self.enabled = [NSNumber numberWithInt:1];
		
		
	}
	return self;
}

- (void)dealloc{
	[configuredTransceiver release];
	[configuredCommand release];
	[weekdays release];
	[weekday release];
	[recurring release];
	[dateTime release];
	[year release];
	[month release];
	[day release];
	[hour release];
	[minute release];
	[second release];
	[yearButton release];
	[monthButton release];
	[dayButton release];
	[hourButton release];
	[minuteButton release];
	[secondButton release];
	[type release];	
	[title release];
	[weekdayEnabled release];
	[dateEnabled release];
	[enabled release];
	[super dealloc];
}

- (void)createSetTitle {
/*	BOOL observe = false;
	if ([self observationInfo])
		observe = true;
	
	if (observe == true)*/
		[myReceiver stopObservingEvent:self];
	
	if ([self.recurring isEqualToString:@kNoRecurrence]) {
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:0];
		self.title = [NSString stringWithFormat:@"%@ - %@-%@-%@ at %@:%@",
					  [configuredCommand objectForKey:@kTitle], self.year, self.month, self.day, self.hour, self.minute];
		
		self.yearButton = [NSNumber numberWithInt:1];
		self.monthButton = [NSNumber numberWithInt:1];
		self.dayButton = [NSNumber numberWithInt:1];
		self.hourButton = [NSNumber numberWithInt:1];
		self.minuteButton = [NSNumber numberWithInt:1];
		self.secondButton = [NSNumber numberWithInt:1];
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag | NSYearMonthDayDatePickerElementFlag];
	}
	if ([self.recurring isEqualToString:@kMinutely]) {
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:0];
		self.title = [NSString stringWithFormat:@"%@ - %@ at HH:MM:%@",
					  [configuredCommand objectForKey:@kTitle], @kMinutely, self.second];

		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:0];
		self.hourButton = [NSNumber numberWithInt:0];
		self.minuteButton = [NSNumber numberWithInt:0];
		self.secondButton = [NSNumber numberWithInt:1];
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag];
	}
	if ([self.recurring isEqualToString:@kHourly]) {
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:0];
		self.title = [NSString stringWithFormat:@"%@ - %@ at HH:%@",
					  [configuredCommand objectForKey:@kTitle], @kHourly, self.minute];

		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:0];
		self.hourButton = [NSNumber numberWithInt:0];
		self.minuteButton = [NSNumber numberWithInt:1];
		self.secondButton = [NSNumber numberWithInt:1];
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag];
	}
	if ([self.recurring isEqualToString:@kDaily]) {
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:0];
		self.title = [NSString stringWithFormat:@"%@ - %@ at %@:%@",
					  [configuredCommand objectForKey:@kTitle], @kDaily, self.hour, self.minute];

		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:0];
		self.hourButton = [NSNumber numberWithInt:1];
		self.minuteButton = [NSNumber numberWithInt:1];
		self.secondButton = [NSNumber numberWithInt:1];
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag];
	}
	if ([self.recurring isEqualToString:@kMonthly]) {
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:0];
		self.title = [NSString stringWithFormat:@"%@ - %@ %@:th at %@:%@",
					  [configuredCommand objectForKey:@kTitle], @kMonthly, self.day, self.hour, self.minute];
		
		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:1];
		self.hourButton = [NSNumber numberWithInt:1];
		self.minuteButton = [NSNumber numberWithInt:1];
		self.secondButton = [NSNumber numberWithInt:1];		
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag | NSYearMonthDayDatePickerElementFlag];
	}
	if ([self.recurring isEqualToString:@kWeekly]){
		self.dateEnabled = [NSNumber numberWithInt:1];
		self.weekdayEnabled = [NSNumber numberWithInt:1];
		self.title = [NSString stringWithFormat:@"%@ - %@s at %@:%@",
					  [configuredCommand objectForKey:@kTitle], [self.weekday objectForKey:@kTitle], self.hour, self.minute];

		self.yearButton = [NSNumber numberWithInt:0];
		self.monthButton = [NSNumber numberWithInt:0];
		self.dayButton = [NSNumber numberWithInt:0];
		self.hourButton = [NSNumber numberWithInt:1];
		self.minuteButton = [NSNumber numberWithInt:1];
		self.secondButton = [NSNumber numberWithInt:1];
		[[[self.myReceiver appController] datePicker] setDatePickerElements:NSHourMinuteSecondDatePickerElementFlag];

		//		NSLog(@"%@", [self.weekday objectForKey:@kTitle]);
	}
//	if (observe == true)
		[myReceiver startObservingEvent:self];
}

#pragma mark -
#pragma mark Simple Accessors

// Transceiver
- (Transceiver *)configuredTransceiver{
	return configuredTransceiver;	
}	

- (void)setConfiguredTransceiver:(Transceiver *)newConfiguredTransceiver{
	if (configuredTransceiver != newConfiguredTransceiver){
		[configuredTransceiver autorelease];
		configuredTransceiver = [newConfiguredTransceiver retain];
		

	}
}

// Command
- (NSDictionary *)configuredCommand{
	return configuredCommand;	
}	

- (void)setConfiguredCommand:(NSDictionary *)newConfiguredCommand{
	if (configuredCommand != newConfiguredCommand){
		[configuredCommand autorelease];
		configuredCommand = [newConfiguredCommand retain];	

		[self createSetTitle];	
	}
}

// DateTime
- (NSDate *)dateTime{
	return dateTime;	
}	

- (void)setDateTime:(NSDate *)newDateTime{
	[newDateTime retain];
	[dateTime release];
	dateTime = newDateTime;
	

	////////////////// LEAK
	// And strings	
	self.year = [[dateTime descriptionWithCalendarFormat:@"%y" timeZone:nil locale:nil]
						description];
	self.month = [[dateTime descriptionWithCalendarFormat:@"%m" timeZone:nil locale:nil]
						description];
	self.day = [[dateTime descriptionWithCalendarFormat:@"%d" timeZone:nil locale:nil]
					  description];
	self.hour = [[dateTime descriptionWithCalendarFormat:@"%H" timeZone:nil locale:nil]
					   description];
	self.minute = [[dateTime descriptionWithCalendarFormat:@"%M" timeZone:nil locale:nil] 
						 description];
	self.second = [[dateTime descriptionWithCalendarFormat:@"%S" timeZone:nil locale:nil] 
						 description];
	/*	self.weekday = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	 [dateTime descriptionWithCalendarFormat:@"%A" timeZone:nil locale:nil], 
					@kTitle,
					[dateTime descriptionWithCalendarFormat:@"%w" timeZone:nil locale:nil], 
					@"day",
					nil];*/
	
	[self createSetTitle];	
}

- (NSString *)recurring {
	return recurring;
}

- (void)setRecurring:(NSString *)newRecurring {
	[newRecurring retain];
	[recurring release];
	recurring = newRecurring;
		
	[self createSetTitle];	
}

- (NSMutableDictionary *)weekday {
	return weekday;
}

- (void)setWeekday:(NSMutableDictionary *)newWeekday {
	[newWeekday retain];
	[weekday release];
	weekday = newWeekday;
	
	[self createSetTitle];	
}

#pragma mark -
#pragma mark Encoding


- (NSDictionary *)getAsXML{
	NSDictionary *eventAsXML = [NSDictionary dictionaryWithObjects:
								   [NSArray arrayWithObjects:
									[[myReceiver properties] objectForKey:@kTitle],
									[[configuredTransceiver properties] objectForKey:@kTitle],
									[configuredCommand objectForKey:@kTitle],
									dateTime,
									weekday,
									recurring,
									yearButton,
									monthButton,
									dayButton,
									hourButton,
									minuteButton,
									secondButton,
									recurringHidden,
									enabled,
									nil]
															  forKeys:
								   [NSArray arrayWithObjects:
									@"myReceiver",
									@"configuredTransceiver",
									@"configuredCommand", 
									@"dateTime",
									@"weekday",
									@"recurring",
									@"yearButton",
									@"monthButton",
									@"dayButton",
									@"hourButton",
									@"minuteButton",
									@"secondButton",
									@"recurringHidden",
									@"enabled",
									nil]];	
	return eventAsXML;
}

@end

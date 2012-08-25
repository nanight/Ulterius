//
//  MyReceiver.m
//  Ulterius
//

#import "Common.h"
#import "MyReceiver.h"
#import "Receiver.h"
#import "Event.h"
#import "AppController.h"


@implementation MyReceiver

@synthesize properties;
@synthesize configuredHouse;
@synthesize configuredUnit;
@synthesize events;
@synthesize type;
@synthesize appController;

#pragma mark -
#pragma mark Startup and Shutdown

- (id)init{
	if (self = [super init]){
		self.type = @"MyReceiver";
		self.events = [[NSMutableArray alloc] init];
		
		NSArray *keys      = [NSArray arrayWithObjects: 
							   @kTitle, nil];
		NSArray *values    = [NSArray arrayWithObjects: 
							   @"My Receiver", nil];
		self.properties = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
		
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)savedDict andReceivers:(NSArray *)configuredReceivers{
	if (self = [super init]){
		self.type = @"MyReceiver";		
		self.events = [[NSMutableArray alloc] init];
		for (int i = 0; i < [configuredReceivers count]; ++i){
			if ([[[[configuredReceivers objectAtIndex:i] properties] objectForKey:@kTitle] 
				 isEqualToString:[savedDict objectForKey:@"configuredReceiver"]])
				self.configuredReceiver = [configuredReceivers objectAtIndex:i];
		}
		
		self.properties = [savedDict objectForKey:@"properties"];		
		
		for (int i = 0; i < [configuredReceiver.units count]; ++i){			
			if ([[[configuredReceiver.units objectAtIndex:i] objectForKey:@kTitle] 
				 isEqualToString:[savedDict objectForKey:@"unit"]])
				self.configuredUnit = [configuredReceiver.units objectAtIndex:i];
		}

		for (int i = 0; i < [configuredReceiver.houses count]; ++i){
			if ([[[configuredReceiver.houses objectAtIndex:i] objectForKey:@kTitle] 
				 isEqualToString:[savedDict objectForKey:@"house"]])
				self.configuredHouse = [configuredReceiver.houses objectAtIndex:i];
		}		
		
		
	}
	return self;
	
}

- (void)dealloc{
	[properties release];
	[configuredReceiver release];
	[configuredUnit release];
	[configuredHouse release];
	[type release];
	[events release];
	[super dealloc];
}

#pragma mark -
#pragma mark Simple Accessors

- (Receiver *)configuredReceiver{
	return configuredReceiver;
}

- (void)setConfiguredReceiver:(Receiver *)newConfiguredReceiver{
	if (configuredReceiver != newConfiguredReceiver){
		[configuredReceiver autorelease];
		configuredReceiver = [newConfiguredReceiver retain];
		
		self.configuredUnit = [configuredReceiver.units objectAtIndex:0];
		self.configuredHouse = [configuredReceiver.houses objectAtIndex:0];
	}
}

#pragma mark -
#pragma mark Key Value Accessors

- (void)insertObject:(Event *)myEvent inEventsAtIndex:(int)index {
	// Undo
	NSUndoManager *undo = [appController undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromEventsAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Insert Event"];
		myEvent.configuredTransceiver = [[appController transceivers] objectAtIndex:0];
		
		// Create event with next command choosen
		if ([events count] > 0 
			&& [[[[events objectAtIndex:index-1] configuredCommand] objectForKey:@kTitle] 
				isEqualToString:[[[configuredReceiver commands] objectAtIndex:0] objectForKey:@kTitle]]
			&& [[configuredReceiver commands] count] > 1)					
			myEvent.configuredCommand = [[configuredReceiver commands] objectAtIndex:1];
		else
			myEvent.configuredCommand = [[configuredReceiver commands] objectAtIndex:0];
		
		// Init date
		if ([events count] > 0)		
			myEvent.dateTime = [myEvent.dateTime initWithTimeInterval:60 sinceDate:[[events objectAtIndex:index-1] dateTime]];	
		[myEvent setMyReceiver:self];
	}
	[self startObservingEvent:myEvent];
	[events insertObject:myEvent atIndex:index];
	NSLog(@"%@", [[events objectAtIndex:index] dateTime]);
	[appController setEdited:YES];
}

- (void)removeObjectFromEventsAtIndex:(int)index {

 // Undo
	Event *myEvent = [events objectAtIndex:index];
	NSUndoManager *undo = [appController undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:myEvent inEventsAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Delete Event"];
	}
	[self stopObservingEvent:myEvent];
	[events removeObjectAtIndex:index];	
	[appController setEdited:YES];
 
}

#pragma mark -
#pragma mark Key Value Observers

- (void)startObservingEvent:(Event *)myEvent {
	[myEvent addObserver:self
			  forKeyPath:@"configuredTransceiver" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];	
		
	[myEvent addObserver:self
			  forKeyPath:@"configuredCommand" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];	
	
	[myEvent addObserver:self
			  forKeyPath:@"dateTime" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		
	
	[myEvent addObserver:self
			  forKeyPath:@"recurring" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"weekday" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"yearButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"monthButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"dayButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"hourButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"minuteButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"secondButton" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		

	[myEvent addObserver:self
			  forKeyPath:@"enabled" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];		
}

- (void)stopObservingEvent:(Event *)myEvent {
	[myEvent removeObserver:self forKeyPath:@"configuredTransceiver"];	
	[myEvent removeObserver:self forKeyPath:@"configuredCommand"];	
	[myEvent removeObserver:self forKeyPath:@"dateTime"];	
	[myEvent removeObserver:self forKeyPath:@"recurring"];	
	[myEvent removeObserver:self forKeyPath:@"weekday"];	
	[myEvent removeObserver:self forKeyPath:@"yearButton"];	
	[myEvent removeObserver:self forKeyPath:@"monthButton"];	
	[myEvent removeObserver:self forKeyPath:@"dayButton"];	
	[myEvent removeObserver:self forKeyPath:@"hourButton"];	
	[myEvent removeObserver:self forKeyPath:@"minuteButton"];	
	[myEvent removeObserver:self forKeyPath:@"secondButton"];	
	[myEvent removeObserver:self forKeyPath:@"enabled"];	
}

- (void)changeKeyPath:(NSString *)keyPath
			 ofObject:(id)obj
			  toValue:(id)newValue {
	// setValue:forKeyPath: will cause the key-value observing method
	// to be called, which takes care of the undo stuff
	[obj setValue:newValue forKeyPath:keyPath];	
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	NSUndoManager *undo = [appController undoManager];
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	
	// NSNull objects are used to represent nil in a dictionary
	if (oldValue == [NSNull null]) {
		oldValue = nil;
	}
	if (newValue == [NSNull null]) {
		newValue = nil;
	}
	
	if ([keyPath isEqualToString:@"yearButton"] || [keyPath isEqualToString:@"monthButton"] || [keyPath isEqualToString:@"dayButton"]
		|| [keyPath isEqualToString:@"hourButton"] || [keyPath isEqualToString:@"minuteButton"] || [keyPath isEqualToString:@"secondButton"]){
		[object setRecurring:@"Custom"];
	}
	
	//NSLog(@"oldValue = %@", oldValue);
	[[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath 
												  ofObject:object 
												   toValue:oldValue];
	[undo setActionName:@"Edit"];
	[appController setEdited:YES];
	
}

#pragma mark -
#pragma mark Logic

- (NSString *)renderCommandFromEvent:(Event *)event{
	return [self renderCommand:[[event configuredCommand] objectForKey:@"command"]];
}

- (NSString *)renderCommand:(NSString *)command{
	// HOUSE - UNIT - UNKNOWN - ACTIVATION
	
	NSString *start = @"S";
	NSString *confHouse = [[self configuredHouse] objectForKey:@"command"]; 
	NSString *confUnit = [[self configuredUnit] objectForKey:@"command"];
	//	NSString *unknown = @"0XX";
	NSString *stop = @"$}+";
	
	NSString *one = [[[self configuredReceiver] properties] objectForKey:@"1"];
	NSString *zero = [[[self configuredReceiver] properties] objectForKey:@"0"];
	NSString *ex = [[[self configuredReceiver] properties] objectForKey:@"X"];
	
	
	NSString *fullCommand = [NSString stringWithFormat:@"%@%@%@", confHouse, confUnit, command];
	NSString *renderedCom = [[[fullCommand stringByReplacingOccurrencesOfString:@"1" withString:one]
							  stringByReplacingOccurrencesOfString:@"0" withString:zero]
							 stringByReplacingOccurrencesOfString:@"X" withString:ex];
	//	NSString *fullRenderedCommand = [NSString stringWithFormat:@"%@%@%@", start, renderedCom, stop];
	//	NSLog(@"Rendered Command: %@", fullRenderedCommand);	
	
	return [NSString stringWithFormat:@"%@%@%@", start, renderedCom, stop];	
}

#pragma mark -
#pragma mark Encoding

- (NSDictionary *)getAsXML{
	NSDictionary *receiverAsXML = [NSDictionary dictionaryWithObjects:
								   [NSArray arrayWithObjects:
									properties, 
									[[configuredReceiver properties] objectForKey:@kTitle],
									[configuredUnit objectForKey:@kTitle], 
									[configuredHouse objectForKey:@kTitle], 
									nil]
															  forKeys:
								   [NSArray arrayWithObjects:
									@"properties", 
									@"configuredReceiver",
									@"unit",
									@"house", 
									nil]];	
	return receiverAsXML;
}
@end

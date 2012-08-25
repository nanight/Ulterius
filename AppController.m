//
//  AppController.m
//  Ulterius
//

#import "AppController.h"
#import "Common.h"
#import "BetterAuthorizationSampleLib.h"
#import "Receiver.h"
#import "Transceiver.h"
#import "Event.h"
#import "MyReceiver.h"
#import "ftd2xx.h"

// Common

@implementation AppController

@synthesize transceivers;
@synthesize receivers;
@synthesize myReceivers;
@synthesize recurrings;
@synthesize mainWindow;
@synthesize weekdays;
@synthesize datePicker;
@synthesize documentEdited;
@synthesize globalLaunchAgents;

// Localized GUI strings
@synthesize schedulingString;
@synthesize advancedString;

// Scheduling tab
// Events
@synthesize enabledString;
@synthesize commandString;
@synthesize dateString;
@synthesize recurringString;
@synthesize weekdayString;
@synthesize customRecurringString;
@synthesize saveChangesString;

// Columns
@synthesize eventsString;
@synthesize unitString;
@synthesize houseString;
@synthesize modelString;
@synthesize myReceiversString;

// Manual Control
@synthesize onString;
@synthesize offString;
@synthesize allOnString;
@synthesize allOffString;
@synthesize testEventString;

@synthesize startSpeechRecognitionString;

// Advanced tab
@synthesize receiverModelsString;
@synthesize commandsString;
@synthesize transceiversString;
@synthesize reloadDeviceString;
@synthesize unitsString;
@synthesize housesString;

/* TODO
 Bugg byte av House/Unit
 Autoupdate
 WebInterface
 Hemsida
 Ta bort händelser efter körning
 Gruppera Vardagar/Helger
 Gruppera efter dag/vecka/osv
 Grupper 
 Namngivning - custom
 */

extern char **environ;
static AuthorizationRef gAuth;

#pragma mark -
#pragma mark Startup and Shutdown

- (id)init {
    if (self = [super init]){

		[[self undoManager] disableUndoRegistration];

		// Init reccurance
		self.recurrings = [NSMutableArray arrayWithObjects:@kNoRecurrence, @kMinutely, @kHourly, @kDaily, @kWeekly, @kMonthly, nil];
		self.weekdays = [NSArray arrayWithObjects:
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Monday", NULL), @kTitle, @"1", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Tuesday", NULL), @kTitle, @"2", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Wednesday", NULL), @kTitle, @"3", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Thursday", NULL), @kTitle, @"4", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Friday", NULL), @kTitle, @"5", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Saturday", NULL), @kTitle, @"6", @"day", nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Sunday", NULL), @kTitle, @"0", @"day", nil],
					nil];
		
		[self initTransceivers];
		[self initReceivers];
		[self initMyReceivers];
		[self initEvents];		
		
		// Authorization stuff
		//--------------------------------------------------------
		OSStatus    junk;
		
		// Create the AuthorizationRef that we'll use through this application.  We ignore 
		// any error from this.  A failure from AuthorizationCreate is very unusual, and if it 
		// happens there's no way to recover; Authorization Services just won't work.
		
		junk = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &gAuth);
		assert(junk == noErr);
		assert( (junk == noErr) == (gAuth != NULL) );
		
		// For each of our commands, check to see if a right specification exists and, if not,
		// create it.
		//
		// The last parameter is the name of a ".strings" file that contains the localised prompts 
		// for any custom rights that we use.
		
		BASSetDefaultRules(
						   gAuth, 
						   kUlteriusCommandSet, 
						   CFBundleGetIdentifier(CFBundleGetMainBundle()), 
						   CFSTR("UlteriusAuthorizationPrompts")
						   );		
		
		NSString *currentToolVersion = [self doGetVersion];
		NSString *thisToolVersion = [NSString stringWithFormat:@"%i", kToolVersion];
		
		NSLog(@"Tool version: %@", currentToolVersion);
		if (![currentToolVersion isEqual:thisToolVersion]){
			NSLog(@"New tool version: %@, tool needs reinstall.", thisToolVersion);
			
			NSString *alertComment = [NSString stringWithFormat:NSLocalizedString(@"alertCommentInit", NULL), currentToolVersion, thisToolVersion];
			[self reinstallToolWithComment:alertComment];
		}
		
		
		// Init speech
		cmds = [NSArray arrayWithObjects:@"On", @"Off", nil];
		recog = [[NSSpeechRecognizer alloc] init];
		[recog setCommands:cmds];
		[recog setDelegate:self];

		[[self undoManager] enableUndoRegistration];
		self.documentEdited = FALSE;
		
		
		// Init localized GUI strings
		
		// Localized GUI strings
		schedulingString = NSLocalizedString(@"Scheduling", NULL);
		advancedString = NSLocalizedString(@"Advanced", NULL);
		
		// Scheduling tab
		// Events
		enabledString = NSLocalizedString(@"Enabled", NULL);
		commandString = NSLocalizedString(@"Command", NULL);
		dateString = NSLocalizedString(@"Date", NULL);
		recurringString = NSLocalizedString(@"Recurring", NULL);
		weekdayString = NSLocalizedString(@"Weekday", NULL);
		customRecurringString = NSLocalizedString(@"Custom Recurring", NULL);
		saveChangesString = NSLocalizedString(@"Save Changes", NULL);
		
		// Columns
		eventsString = NSLocalizedString(@"Events", NULL);
		unitString = NSLocalizedString(@"Unit", NULL);
		houseString = NSLocalizedString(@"House", NULL);
		modelString = NSLocalizedString(@"Model", NULL);
		myReceiversString = NSLocalizedString(@"My Receivers", NULL);
		
		// Manual Control
		onString = NSLocalizedString(@"On", NULL);
		offString = NSLocalizedString(@"Off", NULL);
		allOnString = NSLocalizedString(@"All On", NULL);
		allOffString = NSLocalizedString(@"All Off", NULL);
		testEventString = NSLocalizedString(@"Test Event", NULL);
		
		startSpeechRecognitionString = NSLocalizedString(@"Start Speech Recognition", NULL);
		
		// Advanced tab
		receiverModelsString = NSLocalizedString(@"Receiver Models", NULL);
		commandsString = NSLocalizedString(@"Commands", NULL);		
		transceiversString = NSLocalizedString(@"Transceivers", NULL);
		reloadDeviceString = NSLocalizedString(@"Reload Device", NULL);
		unitsString = NSLocalizedString(@"Units", NULL);
		housesString = NSLocalizedString(@"Houses", NULL);
		
    }
    return self;
}

/*- (void)awakeFromNib {
 }*/


# pragma mark -
# pragma mark init

- (void)initTransceivers {
	NSString *path;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if user has saved new data
	path = [NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kTransceiversFileName];
	if ([fileManager fileExistsAtPath:path] == NO)
		// Else use default path
		path = [[NSBundle mainBundle] pathForResource:@kTransceiversFileName ofType:nil];
	
	
	NSArray *mySavedTransceivers = [NSArray arrayWithContentsOfFile:path];
	transceivers = [[NSMutableArray alloc] init];
	
	// Create all myReceivers from the saved plist
	for (int i = 0; i < [mySavedTransceivers count]; i++) {
		[transceivers addObject:[[Transceiver alloc] initWithDictionary:[mySavedTransceivers objectAtIndex:i]]];
		[[transceivers objectAtIndex:i] setAppController:self];
		[self startObservingTransceiver:[transceivers objectAtIndex:i]];
		
	}
	[[transceivers objectAtIndex:0] loadDeviceStatus];
}

- (void)initReceivers {

	NSString *path;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if user has saved new data
	path = [NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kReceiversFileName];
	if ([fileManager fileExistsAtPath:path] == NO)
		// Else use default path
		path = [[NSBundle mainBundle] pathForResource:@kReceiversFileName ofType:nil];
	
	
	NSArray *savedReceivers = [NSArray arrayWithContentsOfFile:path];
	receivers = [[NSMutableArray alloc] init];
	
	// Create all myReceivers from the saved plist
	for (int i = 0; i < [savedReceivers count]; i++) {
		[receivers addObject:[[Receiver alloc] initWithDictionary:[savedReceivers objectAtIndex:i]]];
		[[receivers objectAtIndex:i] setAppController:self];
		[self startObservingReceiver:[receivers objectAtIndex:i]];
	}
}

- (void)initMyReceivers {
	
	NSString *path;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if user has saved new data
	path = [NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kMyReceiversFileName];
	if ([fileManager fileExistsAtPath:path] == NO)
		// Else use default path
		path = [[NSBundle mainBundle] pathForResource:@kMyReceiversFileName ofType:nil];
		
	NSArray *mySavedReceivers = [NSArray arrayWithContentsOfFile:path];
	myReceivers = [[NSMutableArray alloc] init];
	
	// Create all myReceivers from the saved plist
	for (int i = 0; i < [mySavedReceivers count]; i++) {
		[myReceivers addObject:[[MyReceiver alloc] initWithDictionary:[mySavedReceivers objectAtIndex:i] andReceivers:receivers]];
		[[myReceivers objectAtIndex:i] setAppController:self];		
		[self startObservingMyReceiver:[myReceivers objectAtIndex:i]];
	}
}

- (void)initEvents {
	
	NSString *path;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if user has saved new data
	path = [NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kEventsFileName];
	if ([fileManager fileExistsAtPath:path] == NO)
		// Else use default path
		path = [[NSBundle mainBundle] pathForResource:@kEventsFileName ofType:nil];
	
	NSArray *savedEvents = [NSArray arrayWithContentsOfFile:path];
	MyReceiver *usedMyReceiver = NULL;
	
	// Create all events from the saved plist
	for (int i = 0; i < [savedEvents count]; i++) {
		// For each receiver
		for (int j = 0; j < [myReceivers count]; j++){
			usedMyReceiver = [myReceivers objectAtIndex:j];
			if ([[[usedMyReceiver properties] objectForKey:@kTitle] isEqualToString:[[savedEvents objectAtIndex:i] objectForKey:@"myReceiver"]]){
				[[usedMyReceiver events] addObject:[[Event alloc] initWithDictionary:[savedEvents objectAtIndex:i] 
																	andAppController:self]];
			}			
		}
	}
	
	NSSortDescriptor *weekdayDescriptor;
	NSSortDescriptor *dateDescriptor;
	
	// Sort Event-array for each receiver
	NSMutableArray *eventsArray = NULL;
	for (int m = 0; m < [myReceivers count]; m++){
		eventsArray = [[myReceivers objectAtIndex:m] events];
		
		weekdayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weekday.day" ascending:YES];
		dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:weekdayDescriptor, dateDescriptor, nil];
		
		[[myReceivers objectAtIndex:m] setEvents:[NSMutableArray arrayWithArray:[eventsArray sortedArrayUsingDescriptors:sortDescriptors]]];
		[weekdayDescriptor release];
		[dateDescriptor release];
		
	}
}	

- (void) dealloc {
	[transceivers release];
    [myReceivers release];    
    [receivers release];    
	[recurrings release];
	[weekdays release];
	[recog release];
    [super dealloc];
}

#pragma mark -
#pragma mark Override insert and remove

- (NSString *)createTitleForObject:(id)obj inArray:(NSArray *)objArray {
	int postfix = 1;
	BOOL nameExists = true;
	
	while (nameExists){
		nameExists = false;
		for (int i = 0; i < [objArray count]; i++) {
			if ([[NSString stringWithFormat:@"%@ %i",[[obj properties] objectForKey:@kTitle], postfix]
				 isEqualToString:[[[objArray objectAtIndex:i] properties] objectForKey:@kTitle]]){
				nameExists = true;
				postfix++;
			}
		}
	}
	return [NSString stringWithFormat:@"%@ %i",[[obj properties] objectForKey:@kTitle], postfix];
}

// Receiver
- (IBAction)insertReceiverAction:(id)sender {
	[self insertObject:[[Receiver alloc] init] inReceiversAtIndex:[receivers count]];
}

- (void)insertObject:(Receiver *)receiver inReceiversAtIndex:(int)index {
	// Undo
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromReceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Insert Receiver"];
		NSString *title = [self createTitleForObject:receiver inArray:receivers];
		[[receiver properties] setValue:title forKey:@kTitle];
		receiver.appController = self;
		//	receiver.undoManager = undo;
	}
	
	[self startObservingReceiver:receiver];
	[receivers insertObject:receiver atIndex:index];
	[self setEdited:YES];
}

- (void)removeObjectFromReceiversAtIndex:(int)index {
	// Undo
	Receiver *receiver = [receivers objectAtIndex:index];
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:receiver inReceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Delete Receiver"];
	}
	[self stopObservingReceiver:receiver];	
	[receivers removeObjectAtIndex:index];	
	[self setEdited:YES];
}

// MyReceiver
- (IBAction)insertMyReceiverAction:(id)sender {
	[self insertObject:[[MyReceiver alloc] init] inMyReceiversAtIndex:[myReceivers count]];
}

- (void)insertObject:(MyReceiver *)myReceiver inMyReceiversAtIndex:(int)index {
	// Undo
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromMyReceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Insert My Receiver"];
		myReceiver.appController = self;
		myReceiver.configuredReceiver = [receivers objectAtIndex:0];
		myReceiver.configuredUnit = [[myReceiver.configuredReceiver units] objectAtIndex:0];
		myReceiver.configuredHouse = [[myReceiver.configuredReceiver houses] objectAtIndex:0];
		
		NSString *title = [self createTitleForObject:myReceiver inArray:myReceivers];
		[[myReceiver properties] setValue:title forKey:@kTitle];
	}
	
	[self startObservingMyReceiver:myReceiver];
	[myReceivers insertObject:myReceiver atIndex:index];
	[self setEdited:YES];
//	[myReceiversTable editColumn:0 row:0 withEvent:nil select:YES];
}

- (void)removeObjectFromMyReceiversAtIndex:(int)index {
	// Undo
	MyReceiver *myReceiver = [myReceivers objectAtIndex:index];
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:myReceiver inMyReceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Delete My Receiver"];
	}
	[self stopObservingMyReceiver:myReceiver];
	[myReceivers removeObjectAtIndex:index];	
	[self setEdited:YES];
}

// Transceiver
- (IBAction)insertTransceiverAction:(id)sender {
	[self insertObject:[[Transceiver alloc] init] inTransceiversAtIndex:[transceivers count]];
}

- (void)insertObject:(Transceiver *)transceiver inTransceiversAtIndex:(int)index {
	// Undo
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromTransceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Insert Transceiver"];
		NSString *title = [self createTitleForObject:transceiver inArray:transceivers];
		[[transceiver properties] setValue:title forKey:@kTitle];
		transceiver.appController = self;
	}
	
	[self startObservingTransceiver:transceiver];
	[transceivers insertObject:transceiver atIndex:index];
	[self setEdited:YES];
}

- (void)removeObjectFromTransceiversAtIndex:(int)index {
	// Undo
	Transceiver *transceiver = [transceivers objectAtIndex:index];
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:transceiver inTransceiversAtIndex:index];
	if (![undo isUndoing]){
		[undo setActionName:@"Delete Transceiver"];
	}
	[self stopObservingTransceiver:transceiver];
	[transceivers removeObjectAtIndex:index];	
	[self setEdited:YES];
}

#pragma mark -
#pragma mark Save sheet

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender { 
	
	if([mainWindow isDocumentEdited]){
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Save"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Don't Save"];
		[alert setMessageText:NSLocalizedString(@"SaveWindowMessage", NULL)];
		[alert setInformativeText:NSLocalizedString(@"SaveWindowInformation", NULL)];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert beginSheetModalForWindow:mainWindow
						  modalDelegate:self 
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
							contextInfo:nil];	
		return NSTerminateLater;
	}
	else
		return NSTerminateNow;
} 


- (void)alertDidEnd:(NSAlert *)alert 
		 returnCode:(int)returnCode
		contextInfo:(void *)contextInfo{
	
	if (returnCode == NSAlertFirstButtonReturn) {
		[self saveChanges];
		[NSApp replyToApplicationShouldTerminate:YES]; 
    }
	if (returnCode == NSAlertSecondButtonReturn) {
		[NSApp replyToApplicationShouldTerminate:NO]; 
    }
	if (returnCode == NSAlertThirdButtonReturn) {
		[NSApp replyToApplicationShouldTerminate:YES]; 
    }
}

#pragma mark -
#pragma mark Undo

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender {
	return [self undoManager]; // We created this undo manager manually
}

- (void)startObservingReceiver:(Receiver *)receiver {
	[receiver addObserver:self
			   forKeyPath:@"properties.title" 
				  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				  context:NULL];	
	
	[receiver addObserver:self
			   forKeyPath:@"properties.0" 
				  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				  context:NULL];	
	
	[receiver addObserver:self
			   forKeyPath:@"properties.1" 
				  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				  context:NULL];	
	
	[receiver addObserver:self
			   forKeyPath:@"properties.X" 
				  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				  context:NULL];		
}

- (void)stopObservingReceiver:(Receiver *)receiver {
	[receiver removeObserver:self forKeyPath:@"properties.title"];	
	[receiver removeObserver:self forKeyPath:@"properties.0"];	
	[receiver removeObserver:self forKeyPath:@"properties.1"];	
	[receiver removeObserver:self forKeyPath:@"properties.X"];	
}

- (void)startObservingMyReceiver:(MyReceiver *)myReceiver {
	[myReceiver addObserver:self
				 forKeyPath:@"properties.title" 
					options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
					context:NULL];	

	[myReceiver addObserver:self
				 forKeyPath:@"configuredReceiver" 
					options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
					context:NULL];	

	[myReceiver addObserver:self
				 forKeyPath:@"configuredUnit" 
					options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
					context:NULL];	

	[myReceiver addObserver:self
				 forKeyPath:@"configuredHouse" 
					options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
					context:NULL];		
}

- (void)stopObservingMyReceiver:(MyReceiver *)myReceiver {
	[myReceiver removeObserver:self forKeyPath:@"properties.title"];	
	[myReceiver removeObserver:self forKeyPath:@"configuredReceiver"];	
	[myReceiver removeObserver:self forKeyPath:@"configuredUnit"];	
	[myReceiver removeObserver:self forKeyPath:@"configuredHouse"];	
}

- (void)startObservingTransceiver:(Transceiver *)transceiver {
	[transceiver addObserver:self
			  forKeyPath:@"properties.title" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];	
	
	[transceiver addObserver:self
			  forKeyPath:@"VID" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew 
				 context:NULL];	
	
	[transceiver addObserver:self
			  forKeyPath:@"PID" 
				 options:NSKeyValueObservingOptionOld  | NSKeyValueObservingOptionNew
				 context:NULL];	
	
}

- (void)stopObservingTransceiver:(Transceiver *)transceiver {
	[transceiver removeObserver:self forKeyPath:@"properties.title"];	
	[transceiver removeObserver:self forKeyPath:@"VID"];	
	[transceiver removeObserver:self forKeyPath:@"PID"];	
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
	NSUndoManager *undo = [self undoManager];
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	
	// NSNull objects are used to represent nil in a dictionary
	if (oldValue == [NSNull null]) {
		oldValue = nil;
	}
	if (newValue == [NSNull null]) {
		newValue = nil;
	}
	
	// Look for duplicate name
	if ([[object type] isEqualToString:@"Transceiver"]){
		for(int i = 0; i < [transceivers count]; i++) {
			if (object != [transceivers objectAtIndex:i] ){
				if([newValue isEqualToString:[[[transceivers objectAtIndex:i] properties] objectForKey:@kTitle]]){
					NSAlert *alert = [NSAlert alertWithMessageText:@""
													 defaultButton:nil 
												   alternateButton:nil 
													   otherButton:nil 
										 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
					
					// Change back to oldValue
					[self stopObservingTransceiver:object];
					[[object properties] setValue:oldValue forKey:@kTitle];
					[self startObservingTransceiver:object];
					
					[alert runModal];
					return;
				}
			}
		}
	}
	
	// Look for duplicate name
	if ([[object type] isEqualToString:@"Receiver"]){
		for(int i = 0; i < [receivers count]; i++) {
			if (object != [receivers objectAtIndex:i] ){
				if([newValue isEqualToString:[[[receivers objectAtIndex:i] properties] objectForKey:@kTitle]]){
					NSAlert *alert = [NSAlert alertWithMessageText:@""
													 defaultButton:nil 
												   alternateButton:nil 
													   otherButton:nil 
										 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
					
					// Change back to oldValue
					[self stopObservingReceiver:object];
					[[object properties] setValue:oldValue forKey:@kTitle];
					[self startObservingReceiver:object];
					
					[alert runModal];
					return;
				}
			}
		}
	}
	
	// Look for duplicate name
	if ([newValue isKindOfClass:[NSString class]] && [[object type] isEqualToString:@"MyReceiver"]){
		for(int i = 0; i < [myReceivers count]; i++) {
			if (object != [myReceivers objectAtIndex:i] ){
				if([[NSString stringWithString:newValue] isEqualToString:[[[myReceivers objectAtIndex:i] properties] objectForKey:@kTitle]]){
					NSAlert *alert = [NSAlert alertWithMessageText:@""
													 defaultButton:nil 
												   alternateButton:nil 
													   otherButton:nil 
										 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
					
					// Change back to oldValue
					[self stopObservingMyReceiver:object];
					[[object properties] setValue:oldValue forKey:@kTitle];
					[self startObservingMyReceiver:object];
					
					[alert runModal];
					return;
				}
			}
		}
	}

	//NSLog(@"oldValue = %@", oldValue);
	[[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath 
												  ofObject:object 
												   toValue:oldValue];
	[undo setActionName:@"Edit"];
	[self setEdited:YES];

}


#pragma mark -
#pragma mark Loading and unload of plist

static int RunLaunchCtl(bool junkStdIO, const char *command, const char *plistPath ) {	
	// Handles all the invocations of launchctl by doing the fork() + execve()
	// for proper clean-up. Only two commands are really supported by our
	// implementation; loading and unloading of a job via the plist pointed at 
	// (const char *) plistPath.

	int				err;
	const char *	args[5];
	pid_t			childPID;
	pid_t			waitResult;
	int				status;
	
	// Pre-conditions.
	assert(command != NULL);
	assert(plistPath != NULL);
	
    // Make sure we get sensible logging even if we never get to the waitpid.
    
    status = 0;
    
    // Set up the launchctl arguments.  We run launchctl using StartupItemContext 
	// because, in future system software, launchctl may decide on the launchd 
	// to talk to based on your Mach bootstrap namespace rather than your RUID.
    
	args[0] = "/bin/launchctl";
	args[1] = command;				// "load" or "unload"
	args[2] = "-w";
	args[3] = plistPath;			// path to plist
	args[4] = NULL;
	
    fprintf(stderr, "launchctl %s %s '%s'\n", args[1], args[2], args[3]);
	
    // Do the standard fork/exec dance.
    
	childPID = fork();
	switch (childPID) {
		case 0:
			// child
			err = 0;
            
            // If we've been told to junk the I/O for launchctl, open 
            // /dev/null and dup that down to stdin, stdout, and stderr.
            
			if (junkStdIO) {
				int		fd;
				int		err2;
				
				fd = open("/dev/null", O_RDWR);
				if (fd < 0) {
					err = errno;
				}
				if (err == 0) {
					if ( dup2(fd, STDIN_FILENO) < 0 ) {
						err = errno;
					}
				}
				if (err == 0) {
					if ( dup2(fd, STDOUT_FILENO) < 0 ) {
						err = errno;
					}
				}
				if (err == 0) {
					if ( dup2(fd, STDERR_FILENO) < 0 ) {
						err = errno;
					}
				}
				err2 = close(fd);
				if (err2 < 0) {
					err2 = 0;
				}
				if (err == 0) {
					err = err2;
				}
			}
			if (err == 0) {
				err = execve(args[0], (char **) args, environ);
			}
			if (err < 0) {
				err = errno;
			}
			_exit(EXIT_FAILURE);
			break;
		case -1:
			err = errno;
			break;
		default:
			err = 0;
			break;
	}
	
    // Only the parent gets here.  Wait for the child to complete and get its 
    // exit status.
	
	if (err == 0) {
		do {
			waitResult = waitpid(childPID, &status, 0);
		} while ( (waitResult == -1) && (errno == EINTR) );
		
		if (waitResult < 0) {
			err = errno;
		} else {
			assert(waitResult == childPID);
			
            if ( ! WIFEXITED(status) || (WEXITSTATUS(status) != 0) ) {
                err = EINVAL;
            }
		}
	}
	
    fprintf(stderr, "launchctl -> %d %ld 0x%x\n", err, (long) childPID, status);
	
	return err;
}

#pragma mark -
#pragma mark Handle event files

static OSStatus deletePlist(NSString *plistName) {

	OSStatus        err;
	//    Boolean         success;
    CFBundleRef     bundle;
    CFStringRef     bundleID;
    BASFailCode     failCode;
	CFDictionaryRef response;
    NSDictionary *request;
	
	
	// Get our bundle information.
    
    bundle = CFBundleGetMainBundle();
    assert(bundle != NULL);
    
    bundleID = CFBundleGetIdentifier(bundle);
    assert(bundleID != NULL);
	
	NSArray *keys = [NSArray arrayWithObjects:@kBASCommandKey, @"plistName", nil];
	NSArray *values = [NSArray arrayWithObjects:@kUlteriusDeletePlistCommand, (CFStringRef)plistName, nil];
	request = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
	
	assert(request != NULL);
	
	response = NULL;
	
	err = BASExecuteRequestInHelperTool(
										gAuth, 
										kUlteriusCommandSet, 
										bundleID, 
										(CFDictionaryRef)request, 
										&response
										);
	
	
	// If it failed, try to recover.	
	if ( (err != noErr) && (err != userCanceledErr) ) {
		int alertResult;
		NSLog(@"Error: %@", err);
		failCode = BASDiagnoseFailure(gAuth, bundleID);
		
		// At this point we tell the user that something has gone wrong and that we need 
		// to authorize in order to fix it.  Ideally we'd use failCode to describe the type of 
		// error to the user.
		
		alertResult = NSRunAlertPanel(@"Needs Install", @"BAS needs to install", @"Install", @"Cancel", NULL);
		
		if ( alertResult == NSAlertDefaultReturn ) {
			// Try to fix things.
			
			err = BASFixFailure(gAuth, (CFStringRef) bundleID, CFSTR("InstallTool"), CFSTR("HelperTool"), failCode);
			
			// If the fix went OK, retry the request.
			
			if (err == noErr) {
				err = BASExecuteRequestInHelperTool(
													gAuth, 
													kUlteriusCommandSet, 
													bundleID, 
													(CFDictionaryRef)request, 
													&response
													);
			}
		} else {
			err = userCanceledErr;
		}
	}
	
	// If all of the above went OK, it means that the IPC to the helper tool worked.  We 
	// now have to check the response dictionary to see if the command's execution within 
	// the helper tool was successful.
	
	if (err == noErr) {
		err = BASGetErrorFromResponse(response);
	}
	
	if (err != noErr)
		NSLog(@"Error");
	
	/*    // Extract the descriptors from the response and copy them out to our caller.
	 if (err == noErr) {
	 CFArrayRef      descArray;
	 CFIndex         arrayIndex;
	 CFIndex         arrayCount;
	 CFNumberRef     thisNum;
	 
	 descArray = (CFArrayRef) CFDictionaryGetValue(response, CFSTR(kBASDescriptorArrayKey));
	 assert( descArray != NULL );
	 assert( CFGetTypeID(descArray) == CFArrayGetTypeID() );
	 
	 arrayCount = CFArrayGetCount(descArray);
	 assert(arrayCount == 3);
	 
	 for (arrayIndex = 0; arrayIndex < 3; arrayIndex++) {
	 thisNum = CFArrayGetValueAtIndex(descArray, arrayIndex);
	 assert(thisNum != NULL);
	 assert( CFGetTypeID(thisNum) == CFNumberGetTypeID() );
	 
	 success = CFNumberGetValue(thisNum, kCFNumberIntType, &fdArray[arrayIndex]);
	 assert(success);
	 }
	 }
	 */
	if (response != NULL) {
		CFRelease(response);
	}
	
	/*    assert( (err == noErr) == (fdArray[0] >= 0) );
	 assert( (err == noErr) == (fdArray[1] >= 0) );
	 assert( (err == noErr) == (fdArray[2] >= 0) );
	 */  
	[request release];
	return err;
}

- (NSDictionary *)generatePlistsForWriteOut {
	NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
	MyReceiver *tempReceiver;
	Event *tempEvent;
	NSMutableArray *keys;
	NSMutableArray *values;
	NSDictionary *startCalendarInterval;
	NSMutableArray *startCalendarIntervalArray;
	NSMutableArray *programArguments;
	NSString *tempKey;
	NSMutableDictionary *tempPlistDict;
	
	// Dictionary of events and commands
	// For each Event in each MyReceiver, look in eventDict to see if an event with similar values already exists.
	for (int j = 0; j < [myReceivers count]; ++j) {
		tempReceiver = [myReceivers objectAtIndex:j];
		
		for (int i = 0; i < [tempReceiver.events count]; i++ ){
			tempEvent = [tempReceiver.events objectAtIndex:i];
			if ([tempEvent.enabled isEqualToNumber:[NSNumber numberWithInt:1]]) {
				
				// Program arguments
				programArguments = [NSMutableArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@kTsdaemon ofType:nil],
									[[tempEvent configuredTransceiver] VID], 
									[[tempEvent configuredTransceiver] PID], 
									[tempReceiver renderCommandFromEvent:tempEvent], 
									@"100",
									nil];
				
				// File Name
				tempKey = [NSString stringWithFormat:@"com.adequateproductions.Ulterius.%@.%@.%@", 
						   [[[tempEvent configuredTransceiver] properties] objectForKey:@kTitle],
						   [[tempReceiver properties] objectForKey:@kTitle], 
						   [[tempEvent configuredCommand] objectForKey:@kTitle]];	
				//		NSLog(@"tempKey: %@", tempKey);
				
				// Fetch dates from event and create startDateInterval
				// Init calendarArray
				keys		= [NSMutableArray arrayWithObjects:@"Second", nil];
				values		= [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:[tempEvent.second intValue]], nil];		
				if([tempEvent.recurring isEqualToString:@kNoRecurrence]){
					[keys addObject:@"Year"];
					[keys addObject:@"Month"];
					[keys addObject:@"Day"];
					[keys addObject:@"Minute"];
					[keys addObject:@"Hour"];
					[values addObject:[NSNumber numberWithInt:[tempEvent.year intValue]]];		
					[values addObject:[NSNumber numberWithInt:[tempEvent.month intValue]]];		
					[values addObject:[NSNumber numberWithInt:[tempEvent.day intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.minute intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.hour intValue]]];
				} else if([tempEvent.recurring isEqualToString:@kWeekly]){
					[keys addObject:@"Weekday"];
					[keys addObject:@"Minute"];
					[keys addObject:@"Hour"];
					[values addObject:[NSNumber numberWithInt:[[tempEvent.weekday objectForKey:@"day"] intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.minute intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.hour intValue]]];
				} else if([tempEvent.recurring isEqualToString:@kMonthly]){
					[keys addObject:@"Day"];
					[keys addObject:@"Minute"];
					[keys addObject:@"Hour"];
					[values addObject:[NSNumber numberWithInt:[tempEvent.day intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.minute intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.hour intValue]]];
				} else if([tempEvent.recurring isEqualToString:@kDaily]){
					[keys addObject:@"Minute"];
					[keys addObject:@"Hour"];
					[values addObject:[NSNumber numberWithInt:[tempEvent.minute intValue]]];
					[values addObject:[NSNumber numberWithInt:[tempEvent.hour intValue]]];
				} else if([tempEvent.recurring isEqualToString:@kHourly]){
					[keys addObject:@"Minute"];
					[values addObject:[NSNumber numberWithInt:[tempEvent.minute intValue]]];
				}
				startCalendarInterval = [NSDictionary dictionaryWithObjects:values forKeys: keys];
				
				// Fetch plist with custom name (if exists)
				tempPlistDict = [eventDict objectForKey:tempKey];
				if (tempPlistDict) {
					// Fetch startCalendarInterval from plist
					startCalendarIntervalArray = [tempPlistDict objectForKey:@kStartCalendarInterval];
					
					// Add new calendar date to calendarArray
					[startCalendarIntervalArray addObject:startCalendarInterval];
					
					// Replace calendarArray in plist
					[tempPlistDict removeObjectForKey:@kStartCalendarInterval];
					[tempPlistDict setObject:startCalendarIntervalArray forKey:@kStartCalendarInterval];
				} else {
					// No plist with this name was found, add it to the eventDict
					// Fetch calendar from event, put in array
					startCalendarIntervalArray = [NSMutableArray arrayWithObjects:startCalendarInterval,nil];
					
					// Init new plist
					tempPlistDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																				tempKey, 
																				programArguments, 
																				startCalendarInterval, 
																				nil] 
																	   forKeys:[NSArray arrayWithObjects: 
																				@"Label", 
																				@kProgramArguments, 
																				@kStartCalendarInterval, 
																				nil]];
					
					
					// Put calendarArray in plist from event
					[tempPlistDict setObject:startCalendarIntervalArray forKey:@kStartCalendarInterval];
				}
				// Replace (or add) plist in eventDict with new plist
				[eventDict removeObjectForKey:tempKey];
				[eventDict setObject:tempPlistDict forKey:tempKey];		
			}
		}
	}
	return eventDict;
}

// Write plist to Library/LaunchAgents folder
- (void)writePlist {

    OSStatus        err;
//    Boolean         success;
    CFBundleRef     bundle;
    CFStringRef     bundleID;
    BASFailCode     failCode;
	CFDictionaryRef response;
    NSDictionary *request;
	
	NSString *fullPath;
	
	// Get our bundle information.
    
    bundle = CFBundleGetMainBundle();
    assert(bundle != NULL);
    
    bundleID = CFBundleGetIdentifier(bundle);
    assert(bundleID != NULL);

	// Create the request.  The request always contains the kBASCommandKey that 
    // describes the command to do.  It also, optionally, contains the 
	// kSampleLowNumberedPortsForceFailure key that tells the tool to always return 
	// an error.  The purpose of this is to test our error handling path (do we leak 
	// descriptors, for example). 
    
	// Init	
	NSDictionary *eventDict = [self generatePlistsForWriteOut];
		
	if (eventDict == NULL)
		return;
	NSString *aKey;
	NSEnumerator *keyEnumerator = [eventDict keyEnumerator];
	// Iterate through plists
	while (aKey = [keyEnumerator nextObject]) {
		
		NSArray *keys = [NSArray arrayWithObjects:@kBASCommandKey, @"myPlist", @"fileName", nil];
		NSArray *values = [NSArray arrayWithObjects:@kUlteriusWritePlistCommand, (CFDictionaryRef)[eventDict objectForKey:aKey], aKey, nil];
		request = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		/*	CFIndex         keyCount;
		 CFStringRef     keys[2];
		 CFTypeRef       values[2];
		 CFDictionaryRef request;
		 keyCount = 0;
		 keys[keyCount]   = CFSTR(kBASCommandKey);
		 values[keyCount] = CFSTR(kWritePlistCommand);
		 keyCount += 1;
		 
		 /*    if (forceFailure) {
		 keys[keyCount]   = CFSTR(kWritePlistForceFailure);
		 values[keyCount] = kCFBooleanTrue;
		 keyCount += 1;
		 }*/
		/*
		 request = CFDictionaryCreate(
		 NULL, 
		 (const void **) keys, 
		 (const void **) values, 
		 keyCount, 
		 &kCFTypeDictionaryKeyCallBacks, 
		 &kCFTypeDictionaryValueCallBacks
		 );
		 */
		assert(request != NULL);
		
		response = NULL;
		
		err = BASExecuteRequestInHelperTool(
											gAuth, 
											kUlteriusCommandSet, 
											bundleID, 
											(CFDictionaryRef)request, 
											&response
											);
		
		
		// If it failed, try to recover.	
		if ( (err != noErr) && (err != userCanceledErr) ) {
			int alertResult;
			NSLog(@"Tool Error");
			failCode = BASDiagnoseFailure(gAuth, bundleID);
			
			// At this point we tell the user that something has gone wrong and that we need 
			// to authorize in order to fix it.  Ideally we'd use failCode to describe the type of 
			// error to the user.
			
			alertResult = NSRunAlertPanel(@"Needs Install", @"BAS needs to install", @"Install", @"Cancel", NULL);
			
			if ( alertResult == NSAlertDefaultReturn ) {
				// Try to fix things.
				
				err = BASFixFailure(gAuth, (CFStringRef) bundleID, CFSTR("InstallTool"), CFSTR("HelperTool"), failCode);
				
				// If the fix went OK, retry the request.
				
				if (err == noErr) {
					err = BASExecuteRequestInHelperTool(
														gAuth, 
														kUlteriusCommandSet, 
														bundleID, 
														(CFDictionaryRef)request, 
														&response
														);
				}
			} else {
				err = userCanceledErr;
			}
		}
		
		// If all of the above went OK, it means that the IPC to the helper tool worked.  We 
		// now have to check the response dictionary to see if the command's execution within 
		// the helper tool was successful.
		
		if (err == noErr) {
			err = BASGetErrorFromResponse(response);
		}
		
		if (err != noErr)
			NSLog(@"Error");
		
		/*    // Extract the descriptors from the response and copy them out to our caller.
		 if (err == noErr) {
		 CFArrayRef      descArray;
		 CFIndex         arrayIndex;
		 CFIndex         arrayCount;
		 CFNumberRef     thisNum;
		 
		 descArray = (CFArrayRef) CFDictionaryGetValue(response, CFSTR(kBASDescriptorArrayKey));
		 assert( descArray != NULL );
		 assert( CFGetTypeID(descArray) == CFArrayGetTypeID() );
		 
		 arrayCount = CFArrayGetCount(descArray);
		 assert(arrayCount == 3);
		 
		 for (arrayIndex = 0; arrayIndex < 3; arrayIndex++) {
		 thisNum = CFArrayGetValueAtIndex(descArray, arrayIndex);
		 assert(thisNum != NULL);
		 assert( CFGetTypeID(thisNum) == CFNumberGetTypeID() );
		 
		 success = CFNumberGetValue(thisNum, kCFNumberIntType, &fdArray[arrayIndex]);
		 assert(success);
		 }
		 }
		 */
		if (response != NULL) {
			CFRelease(response);
		}
		
		/*    assert( (err == noErr) == (fdArray[0] >= 0) );
		 assert( (err == noErr) == (fdArray[1] >= 0) );
		 assert( (err == noErr) == (fdArray[2] >= 0) );
		 */  
		
		// Contstruct file path
		fullPath = [NSString stringWithFormat:@"%@/%@.%@", @kLaunchAgents, aKey, @kPlist];
		
		// Create buffer for unloading and loading of plist
		char buffer[[fullPath length]*16];
		if (CFStringGetCString((CFStringRef)fullPath, buffer, [fullPath length]*16, kCFStringEncodingUTF8)){
			//		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Buffer: %s", buffer);
		}	
		
		// Load new plist
		int error = RunLaunchCtl(true ,"load", buffer);
		if (error != 0)
			NSLog(@"Error loading plist");
		else {
			//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Plist loaded");
		}		

	}

	// Clean up
	[eventDict release];
	
}

#pragma mark -
#pragma mark Handle save files

- (void)writeReceivers {
	NSMutableArray *receiversPlist = [NSMutableArray arrayWithCapacity:[receivers count]];
	
	// Copy xml-representation of myReceivers to an array
	for (int i = 0; i < [receivers count]; i++) {	
		[receiversPlist insertObject:[[receivers objectAtIndex:i] getAsXML] atIndex:i];		
	}
		
	// Write out myReceivers
	[receiversPlist writeToFile:[NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kReceiversFileName] atomically:YES];
}

- (void)writeMyReceivers {
	NSMutableArray *myReceiversPlist = [NSMutableArray arrayWithCapacity:[myReceivers count]];
	
	// Copy xml-representation of myReceivers to an array
	for (int i = 0; i < [myReceivers count]; i++) {	
		[myReceiversPlist insertObject:[[myReceivers objectAtIndex:i] getAsXML] atIndex:i];		
	}

	// Write out myReceivers
	[myReceiversPlist writeToFile:[NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kMyReceiversFileName] atomically:YES];
}

- (void)writeTransceivers {
	NSMutableArray *transceiversPlist = [NSMutableArray arrayWithCapacity:[transceivers count]];
	
	// Copy xml-representation of transceivers to an array
	for (int i = 0; i < [transceivers count]; i++) {	
		[transceiversPlist insertObject:[[transceivers objectAtIndex:i] getAsXML] atIndex:i];		
	}
	
	// Write out transceivers
	[transceiversPlist writeToFile:[NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kTransceiversFileName] atomically:YES];
}

- (void)writeEvents {
	
	// Only local launchAgents for now
	globalLaunchAgents = FALSE;
	
	/***********************************
	 * Save event xmls:
	 ***********************************/ 
	int eventCount = 0;
	for (int i = 0; i < [myReceivers count]; i++ )
		eventCount = eventCount + [[[myReceivers objectAtIndex:i] events] count];
	NSMutableArray *eventsPlist = [NSMutableArray arrayWithCapacity:eventCount];
	
	// Copy an xml-representation of events to the eventPlist array
	int k = 0;
	for (int i = 0; i < [myReceivers count]; i++ ) {
		for (int j = 0; j < [[[myReceivers objectAtIndex:i] events] count]; j++ ) {
			[eventsPlist insertObject:[[[[myReceivers objectAtIndex:i] events] objectAtIndex:j] getAsXML] atIndex:k++];		
		}
	}
	
	// Write out events into event-file in Ulterius-folder
	[eventsPlist writeToFile:[NSString stringWithFormat:@"%@%@", @kApplicationSupport, @kEventsFileName] atomically:YES];
	
	// Check whether tool is installed
	//	if (globalLaunchAgents) {
	NSString *toolVersion = [NSString stringWithFormat:@"%@", [self doGetVersion]];
	if ([toolVersion hasPrefix:@"Error"]) {		
		NSString *alertComment = NSLocalizedString(@"alertCommentInstall", NULL);
		[self reinstallToolWithComment:alertComment];
	}
	//}

	/***********************************
	 * Delete all plists
	 ***********************************/ 
	[self deleteEvents];	

	/***********************************
	 * Write out new plists
	 ***********************************/ 
	// Generate dictionary of event plists
	NSDictionary *eventDict = [self generatePlistsForWriteOut];	
	if (eventDict == NULL)
		return;
	
	if (globalLaunchAgents) {
		// Write new plists
		[self writePlist];
	} else {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *aKey;
		NSEnumerator *keyEnumerator = [eventDict keyEnumerator];
		// Iterate through plists
		NSString *fullPath;
		while (aKey = [keyEnumerator nextObject]) {
			// Construct full path
			fullPath = [NSString stringWithFormat:@"%@/%@.%@", [@kUserLaunchAgents stringByExpandingTildeInPath], aKey, @kPlist];
			
			// Write plist-file
			if(![[eventDict objectForKey:aKey] writeToFile:fullPath 
												atomically:YES])
				NSLog(@"Failed writing file %@ to disk.", fullPath);	
			
			// Get permissions
			// NSNumber *num = (NSNumber *)[[fileManager attributesOfItemAtPath:fullPath error:NULL] objectForKey:NSFilePosixPermissions];
			
			// Set right permissions
			if(![fileManager changeFileAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:420] 
																			  forKey:NSFilePosixPermissions] atPath:fullPath])
				NSLog(@"Error setting file permissions of %@", fullPath);
			
			
			// Load plist
			// Create buffer for unloading and loading of plist
			char buffer[[fullPath length]*16];
			if (CFStringGetCString((CFStringRef)fullPath, buffer, [fullPath length]*16, kCFStringEncodingUTF8)){
				//		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Buffer: %s", buffer);
			}	
			
			// Load new plist
			int error = RunLaunchCtl(true ,"load", buffer);
			if (error != 0)
				NSLog(@"Error loading plist");		
		}
	}
}
	
#pragma mark -
#pragma mark Handle secure tool

- (IBAction)destroyRights:(id)sender {

// Called when the user chooses the "Destroy Rights" menu item.  This is just a testing 
// convenience; it allows you to destroy the credentials that are stored in the cache 
// associated with gAuth, so you can force the system to ask you for a password again.  
// However, this isn't as convenient as you might think because the credentials might 
// be cached globally.  See DTS Q&A 1277 "Security Credentials" for the gory details.
//
// <http://developer.apple.com/qa/qa2001/qa1277.html>
    OSStatus    junk;
    
    // Free gAuth, destroying any credentials that it has acquired along the way. 
    
    junk = AuthorizationFree(gAuth, kAuthorizationFlagDestroyRights);
    assert(junk == noErr);
    gAuth = NULL;
	
    // Recreate it from scratch.
    
    junk = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &gAuth);
    assert(junk == noErr);
    assert( (junk == noErr) == (gAuth != NULL) );    
}

- (IBAction)reinstallTool:(id)sender {
	NSString *alertComment = NSLocalizedString(@"alertCommentReinstall", NULL);
	[self reinstallToolWithComment:alertComment];
}

- (void)reinstallToolWithComment:(NSString *)alertComment {
	
	int alertResult;
	OSStatus        err;
	CFBundleRef     bundle;
    CFStringRef     bundleID;
    BASFailCode     failCode;
	
	// Get our bundle information.
    
    bundle = CFBundleGetMainBundle();
    assert(bundle != NULL);
    
    bundleID = CFBundleGetIdentifier(bundle);
    assert(bundleID != NULL);
	
	
	alertResult = NSRunAlertPanel(@"Needs Install", alertComment, @"Install", @"Cancel", NULL);
	
	if ( alertResult == NSAlertDefaultReturn ) {
		// Try to fix things.
		
		err = BASFixFailure(gAuth, (CFStringRef) bundleID, CFSTR("InstallTool"), CFSTR("HelperTool"), failCode);
		
		// If the fix went OK, retry the request.
		
		if (err == noErr) {
			NSLog(@"Reinstalled tool successfully");
		}
	} else {
		err = userCanceledErr;
		NSLog(@"Reinstall tool failed");
	}
	NSLog(@"Tool Version %@", [self doGetVersion]);
}

- (NSString *)doGetVersion {
    OSStatus        err;
    NSString *      bundleID;
    NSDictionary *  request;
    CFDictionaryRef response;
	
    response = NULL;
    
    // Create our request.  Note that NSDictionary is toll-free bridged to CFDictionary, so 
    // we can use an NSDictionary as our request.  Also, if the "Force failure" checkbox is 
    // checked, we use the wrong command ID to deliberately cause an "unknown command" error 
    // so that we can test that code path.
    
	request = [NSDictionary dictionaryWithObjectsAndKeys:@kUlteriusGetVersionCommand, @kBASCommandKey, nil];
	/*    if ( [forceFailure state] == 0 ) {
	 } else {
	 request = [NSDictionary dictionaryWithObjectsAndKeys:@"Utter Gibberish", @kBASCommandKey, nil];
	 }*/
    assert(request != NULL);
    
    bundleID = [[NSBundle mainBundle] bundleIdentifier];
    assert(bundleID != NULL);
    
    // Execute it.
    
	err = BASExecuteRequestInHelperTool(
										gAuth, 
										kUlteriusCommandSet, 
										(CFStringRef) bundleID, 
										(CFDictionaryRef) request, 
										&response
										);
    
    // If the above went OK, it means that the IPC to the helper tool worked.  We 
    // now have to check the response dictionary to see if the command's execution 
    // within the helper tool was successful.  For the GetVersion command, this 
    // is unlikely to ever fail, but we should still check. 
    
    if (err == noErr) {
        err = BASGetErrorFromResponse(response);
    }
    
    // Log our results.
    
    if (err == noErr) {
		return [NSString stringWithFormat:@"%@", [(NSDictionary *)response objectForKey:@kUlteriusGetVersionResponse]];
    } else {
        return [NSString stringWithFormat:@"Error: %ld", (long)err];
    }
    
    if (response != NULL) {
        CFRelease(response);
    }
}

#pragma mark -
#pragma mark UI Action Methods

- (void)sendCommand:(NSString *)command {
	Transceiver *selTransceiver = [transceivers objectAtIndex:0];
	
	NSArray *arguments = [NSArray arrayWithObjects:selTransceiver.VID, selTransceiver.PID, command, @"100", nil];
	
	NSLog(@"Trying to send command: %@", [[arguments objectAtIndex:2] description]);
	
	NSTask *tsdaemonTask = [[NSTask alloc] init];
	[tsdaemonTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@kTsdaemon ofType:nil]];
	[tsdaemonTask setArguments:arguments];
	
	// Launch task and wait for finish
	[tsdaemonTask launch];
	//	[commandButton setEnabled:NO];
	//	[tsdaemonTask waitUntilExit];
	//	[commandButton setEnabled:YES];
	[tsdaemonTask release];	
}

- (void)sendCommandByName:(NSString *)commandName toMyReceiver:(MyReceiver *)myReceiver {
	NSMutableArray *commands = [[myReceiver configuredReceiver] commands];
	NSString *command;
	for (int i = 0; i < [commands count]; i++ ) {
		if ([[[commands objectAtIndex:i] objectForKey:@"title"] isEqualToString:commandName]) {
			command = [[commands objectAtIndex:i] objectForKey:@"command"];
			break;
		}
	}
	
	[self sendCommand:[myReceiver renderCommand:command]];				
}

- (IBAction)sendCommandAction:(id)sender{
	NSString *command = [[[myReceiversController selectedObjects] objectAtIndex:0] 
						 renderCommandFromEvent:[[eventsController selectedObjects] objectAtIndex:0]];

	[self sendCommand:command];		
}

- (IBAction)myReceiverOn:(id)sender {
	[self sendCommandByName:@"On" toMyReceiver:[[myReceiversController selectedObjects] objectAtIndex:0]];
}

- (IBAction)myReceiverOff:(id)sender {
	[self sendCommandByName:@"Off" toMyReceiver:[[myReceiversController selectedObjects] objectAtIndex:0]];
}

- (IBAction)allReceiversOn:(id)sender {
	for (int i = 0; i < [myReceivers count]; i++ ) {
		[self sendCommandByName:@"On" toMyReceiver:[myReceivers objectAtIndex:i]];
	}
}

- (IBAction)allReceiversOff:(id)sender {
	for (int i = 0; i < [myReceivers count]; i++ ) {
		[self sendCommandByName:@"Off" toMyReceiver:[myReceivers objectAtIndex:i]];
	}	
}

- (void)deleteEvents {
	
	NSDictionary *plist;	
	NSString *deletedEventName;
	NSString *fullPath;
	
	NSArray *paths = [NSArray arrayWithObjects:@kLaunchAgents, [@kUserLaunchAgents stringByExpandingTildeInPath], nil];	
	NSFileManager *fileManager;
	NSDirectoryEnumerator *dirEnum;
	NSString *fileName;
	
	// Loop over global and local path
	for ( int i = 0; i <  [paths count]; i++ ) {		
		fileManager = [NSFileManager defaultManager];
		dirEnum = [fileManager enumeratorAtPath:[paths objectAtIndex:i]];		
		
		// Loop over each file in the launchAgents folder
		while (fileName = [dirEnum nextObject]) {
			if ([fileName hasPrefix:@"com.adequateproductions.Ulterius"]) {
				fullPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:i], fileName];
				plist = [NSDictionary dictionaryWithContentsOfFile:fullPath];
				
				// Look trough each event if the file is not deleted
				deletedEventName = fileName;	
				// If there was a file to delete
				if (deletedEventName != NULL){
					// Create char buffer for the path of the plist to be unloaded
					char buffer[[fullPath length]*16];
					if (!CFStringGetCString((CFStringRef)fullPath, buffer, [fullPath length]*16, kCFStringEncodingUTF8))
						NSLog(@"Error creating path buffer: %@", deletedEventName);
					
					// Unload old plist
					if(!RunLaunchCtl(true ,"unload", buffer))
						NSLog(@"Error unloading plist or no unloading required");
					
					// Delete the plist
					if (i == 0) {
						// Global
						if(!deletePlist(deletedEventName))
							NSLog(@"Error deleting plist: %@", deletedEventName);
					} else {	
						// Local
						if (![fileManager removeItemAtPath:fullPath error:NULL])
							NSLog(@"Error deleting plist: %@", deletedEventName);
					}
					deletedEventName = NULL;
				}
			}
		}
	}
}	

- (IBAction)reloadDeviceStatus:(id)sender{	
	Transceiver *selTransceiver = [[transceiversController selectedObjects] objectAtIndex:0];	
	[selTransceiver loadDeviceStatus];	
	[selTransceiver loadDeviceFirmware];
}

// Save default files
- (IBAction)saveDefaults:(id)sender{

	NSLog(@"Saved default data");
}

- (void)saveChanges {
	// Check if folder exists
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@kApplicationSupport] == NO)
		[fileManager createDirectoryAtPath:@kApplicationSupport  attributes:nil];	

	if ([fileManager fileExistsAtPath:[@kUserLaunchAgents stringByExpandingTildeInPath]] == NO)
		[fileManager createDirectoryAtPath:[@kUserLaunchAgents stringByExpandingTildeInPath] attributes:nil];	
	
	// Save plists
	[self writeReceivers];
	[self writeMyReceivers];
	[self writeTransceivers];
	[self writeEvents];
	[self setEdited:NO];
}

- (void)setEdited:(BOOL)edited {
	self.documentEdited = edited;
	[mainWindow	setDocumentEdited:edited];
}

- (IBAction)saveChangesAction:(id)sender{	
	[self saveChanges];	
}

// Speech recognition
- (IBAction)listen:(id)sender {
    if ([sender state] == NSOnState) { // listen
		[recog startListening];
		NSLog(@"Start Listening");
    } else {
		[recog stopListening];
		NSLog(@"Stop Listening");
    }
}

- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
	
    if ([(NSString *)aCmd isEqualToString:[cmds objectAtIndex:0]]) {
		[self myReceiverOn:sender];
		NSLog(@"On");
    }
	
    if ([(NSString *)aCmd isEqualToString:[cmds objectAtIndex:1]]) {
		[self myReceiverOff:sender];
		NSLog(@"Off");
    }
}

@end
 
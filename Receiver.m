//
//  Receiver.m
//  Ulterius
//

#import "Common.h"
#import "Receiver.h"
#import "AppController.h"

@implementation Receiver
@synthesize properties;
@synthesize commands;
@synthesize units;
@synthesize houses;
@synthesize type;
@synthesize appController;

#pragma mark -
#pragma mark Startup and Shutdown

-(id)init{
	if (self = [super init]){
		self.type = @"Receiver";
		
		// Properties
        NSArray *propKeys      = [NSArray arrayWithObjects: 
								  @kTitle, @"0", @"1", @"X", nil];
        NSArray *propValues    = [NSArray arrayWithObjects: 
								  @"Receiver", @"$k$k", @"k$k$", @"$kk$", nil];
        self.properties = [NSMutableDictionary dictionaryWithObjects:propValues forKeys:propKeys];   		
		
		self.commands = [NSMutableArray arrayWithObjects:
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:@"On", @kTitle, @"0XXX", @"command"],
						 [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Off", @kTitle, @"0XX0", @"command"],
						 nil];
		
		self.units = [NSMutableArray arrayWithObjects:
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @kTitle, @"0000", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @kTitle, @"X000", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @kTitle, @"0X00", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"4", @kTitle, @"XX00", @"command"],
/*					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"5", @kTitle, @"00X0", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"6", @kTitle, @"X0X0", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"7", @kTitle, @"0XX0", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"8", @kTitle, @"XXX0", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"9", @kTitle, @"000X", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"10", @kTitle, @"X00X", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"11", @kTitle, @"0X0X", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"12", @kTitle, @"XX0X", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"13", @kTitle, @"00XX", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"14", @kTitle, @"X0XX", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"15", @kTitle, @"0XXX", @"command"],
					  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"16", @kTitle, @"XXXX", @"command"],					  
*/					  nil];
		
		self.houses = [NSMutableArray arrayWithObjects:
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"A", @kTitle, @"0000", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"B", @kTitle, @"X000", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"C", @kTitle, @"0X00", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"D", @kTitle, @"XX00", @"command"],
/*					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"E", @kTitle, @"00X0", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"F", @kTitle, @"X0X0", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"G", @kTitle, @"0XX0", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"H", @kTitle, @"XXX0", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I", @kTitle, @"000X", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"J", @kTitle, @"X00X", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"K", @kTitle, @"0X0X", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"L", @kTitle, @"XX0X", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"M", @kTitle, @"00XX", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"N", @kTitle, @"X0XX", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"O", @kTitle, @"0XXX", @"command"],
					   [NSMutableDictionary dictionaryWithObjectsAndKeys:@"P", @kTitle, @"XXXX", @"command"],					  
*/					   nil];
		
		for (int i = 0; i < [units count]; i++)
			[self startObservingCommand:[units objectAtIndex:i]];
		
		for (int i = 0; i < [houses count]; i++)
			[self startObservingCommand:[houses objectAtIndex:i]];
		
		for (int i = 0; i < [commands count]; i++)
			[self startObservingCommand:[commands objectAtIndex:i]];
		
		
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)savedDict {
	if (self = [super init]){	
		self.type = @"Receiver";
		self.properties = [savedDict objectForKey:@"properties"]; 
		
		self.units = [savedDict objectForKey:@"units"];
		for (int i = 0; i < [units count]; i++)
			[self startObservingCommand:[units objectAtIndex:i]];

		self.houses = [savedDict objectForKey:@"houses"];
		for (int i = 0; i < [houses count]; i++)
			[self startObservingCommand:[houses objectAtIndex:i]];

		self.commands = [savedDict objectForKey:@"commands"];
		for (int i = 0; i < [commands count]; i++)
			[self startObservingCommand:[commands objectAtIndex:i]];

	}
	return self;
}

- (void)dealloc{
	[properties release];
	[commands release];
	[type release];
	[super dealloc];
}

#pragma mark -
#pragma mark Key Value Observers

- (void)startObservingCommand:(NSMutableDictionary *)command {
	[command addObserver:self
			  forKeyPath:@"title" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];	
	
	[command addObserver:self
			  forKeyPath:@"command" 
				 options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
				 context:NULL];	
	
}

- (void)stopObservingCommand:(NSMutableDictionary *)command {
	[command removeObserver:self forKeyPath:@"title"];	
	[command removeObserver:self forKeyPath:@"command"];	
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
	
	// Look for duplicate name
	for(int i = 0; i < [commands count]; i++) {
		if (object != [commands objectAtIndex:i] ){
			if([[NSString stringWithString:newValue] 
				isEqualToString:[[commands objectAtIndex:i] objectForKey:@kTitle]]){
				NSAlert *alert = [NSAlert alertWithMessageText:@""
												 defaultButton:nil 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
				
				// Change back to oldValue
				[self stopObservingCommand:object];
				[object setValue:oldValue forKey:@kTitle];
				[self startObservingCommand:object];
				
				[alert runModal];
				return;
			}
		}
	}
	
	// Look for duplicate name
	for(int i = 0; i < [units count]; i++) {
		if (object != [units objectAtIndex:i] ){
			if([[NSString stringWithString:newValue] 
				isEqualToString:[[units objectAtIndex:i] objectForKey:@kTitle]]){
				NSAlert *alert = [NSAlert alertWithMessageText:@""
												 defaultButton:nil 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
				
				// Change back to oldValue
				[self stopObservingCommand:object];
				[object setValue:oldValue forKey:@kTitle];
				[self startObservingCommand:object];
				
				[alert runModal];
				return;
			}
		}
	}
	
	// Look for duplicate name
	for(int i = 0; i < [houses count]; i++) {
		if (object != [houses objectAtIndex:i] ){
			if([[NSString stringWithString:newValue] 
				isEqualToString:[[houses objectAtIndex:i] objectForKey:@kTitle]]){
				NSAlert *alert = [NSAlert alertWithMessageText:@""
												 defaultButton:nil 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"nameTaken", NULL), newValue]];
				
				// Change back to oldValue
				[self stopObservingCommand:object];
				[object setValue:oldValue forKey:@kTitle];
				[self startObservingCommand:object];
				
				[alert runModal];
				return;
			}
		}
	}	
	
	//NSLog(@"oldValue = %@", oldValue);
	[[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath 
												  ofObject:object 
												   toValue:oldValue];
	[undo setActionName:@"Edit"];
	[[appController mainWindow] setDocumentEdited:YES];
	
}

#pragma mark -
#pragma mark Encoding

- (NSDictionary *)getAsXML{
	NSDictionary *receiverAsXML = [NSDictionary dictionaryWithObjects:
								   [NSArray arrayWithObjects:
									properties, 
									units,
									houses,
									commands,
									nil]
															  forKeys:
								   [NSArray arrayWithObjects:
									@"properties", 
									@"units", 
									@"houses",
									@"commands", 
									nil]];	
	return receiverAsXML;
}

@end

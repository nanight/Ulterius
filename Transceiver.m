//
//  Transceiver.m
//  Ulterius
//

#import "Common.h"
#import "Transceiver.h"
#import "ftd2xx.h"

#define BUF_SIZE 0x1000
DWORD iVID, iPID;
#define MAX_DEVICES		5
FT_HANDLE	ftHandle[MAX_DEVICES];

@implementation Transceiver

@synthesize VID;
@synthesize PID;
@synthesize device;
@synthesize status;
@synthesize properties;
@synthesize type;
@synthesize appController;

#pragma mark -
#pragma mark Startup and Shutdown

-(id)init {
	if (self = [super init]){
		self.type = @"Transceiver";
		self.VID = @"1781";
		self.PID = @"0c30";

		// Set properties
        NSArray * keys      = [NSArray arrayWithObjects: @kTitle, nil];
        NSArray * values    = [NSArray arrayWithObjects: @"TellStick", nil];
        self.properties = [NSMutableDictionary dictionaryWithObjects:values forKeys: keys];
					
		[self loadDeviceStatus];		
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)savedDict {
	if (self = [super init]){	
		self.type = @"Transceiver";
		self.properties = [savedDict objectForKey:@"properties"]; 
		self.VID = [savedDict objectForKey:@"VID"];
		self.PID = [savedDict objectForKey:@"PID"];
	}
	return self;
}

- (void)dealloc {
	[VID release];
	[PID release];
	[status release];
	[device release];
	[properties release];
	[super dealloc];
}

#pragma mark -
#pragma mark TellStick USB interface methods

- (void)loadDeviceStatus {
	// Init PID & VID
	const char *cVID[5];
	const char *cPID[5];
	*cVID = (const char*)[self.VID cString];
	*cPID = (const char*)[self.PID cString];
	sscanf(*cVID, "%X\n", &iVID);
	sscanf(*cPID, "%X\n", &iPID);
	
	int intReturn = -1;
	FT_HANDLE fthHandle = 0;
	FT_STATUS ftStatus = FT_OK;
	
	DWORD dwNumberOfDevices = 0;
	
	FT_SetVIDPID(iVID, iPID);
	
	ftStatus = FT_CreateDeviceInfoList(&dwNumberOfDevices);
	if (ftStatus == FT_OK) { 
		for (int i = 0; i < (int)dwNumberOfDevices; i++) {  
			
			FT_PROGRAM_DATA pData;
			char ManufacturerBuf[32]; 
			char ManufacturerIdBuf[16]; 
			char DescriptionBuf[64]; 
			char SerialNumberBuf[16]; 
			
			pData.Signature1 = 0x00000000; 
			pData.Signature2 = 0xffffffff; 
			pData.Version = 0x00000002;      // EEPROM structure with FT232R extensions 
			pData.Manufacturer = ManufacturerBuf; 
			pData.ManufacturerId = ManufacturerIdBuf; 
			pData.Description = DescriptionBuf; 
			pData.SerialNumber = SerialNumberBuf; 
			
			ftStatus = FT_Open(i, &fthHandle);
			ftStatus = FT_EE_Read(fthHandle, &pData);
			if(ftStatus == FT_OK){
				if(pData.VendorId == 6017 && pData.ProductId == 3120){
					
					NSLog(@"Device %d, %s, Serial Number - %s", i, pData.Description, pData.SerialNumber);
					self.device = [NSString stringWithFormat:@"Device %d - %s", i, pData.Description];

					intReturn = i;
					ftStatus = FT_Close(fthHandle);
					break;
				}
			}
			ftStatus = FT_Close(fthHandle);
		}
	}

//	return intReturn;
	
	
	/*
	 // Set PID and VID		
 FT_SetVIDPID(iVID,iPID);
	
	// List devices
	char * 	pcBufLD[4 + 1];
	char 	cBufLD[4][64];
	int	i, iNumDevs;
	for(i = 0; i < 4; i++) {
		pcBufLD[i] = cBufLD[i];
		ftHandle[i] = NULL;
	}	
	pcBufLD[4] = NULL;
	
	FT_STATUS ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_DESCRIPTION);		// Call FTDI function
	if(ftStatus != FT_OK) {
		[self setStatus:[NSString stringWithFormat:@"Error: FT_ListDevices(%d)\n", ftStatus]];
		printf("Error: FT_ListDevices(%d)\n", ftStatus);
	}
	
	// Set device name 
	for(i = 0; ( (i <4) && (i < iNumDevs) ); i++) {
		if (strcmp("Homeautomation USB-Dongle", cBufLD[i]) == 0) {
			NSLog(@"Device %d Serial Number - %s", i, cBufLD[i]);
			self.device = [NSString stringWithFormat:@"Device %d - %s", i, cBufLD[i]];
			break;
		} 
		else {
			NSLog(@"Device %d Serial Number - %s", i, cBufLD[i]);
			self.device = [NSString stringWithFormat:@"%s", cBufLD[i]];	
		}
	}
	if(!(iNumDevs > 0))
		self.device = @"No Transceiver found";	
	*/
}

- (void)loadDeviceFirmware {
	
	NSArray *arguments = [NSArray arrayWithObjects:VID, PID, @"V+", nil];
	
	// Create the tsdaemonTask with path and arguments
	NSTask *tsdaemonTask = [[NSTask alloc] init];
	[tsdaemonTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@kTsdaemon ofType:nil]];
	[tsdaemonTask setArguments:arguments];

	// Create a pipe for output
	NSPipe *pipe = [NSPipe pipe];
	[tsdaemonTask setStandardOutput:pipe];
	NSFileHandle *fileHandle = [pipe fileHandleForReading];
	
	// Launch task and wait for finish
	[tsdaemonTask launch];
		
	NSString *reply = [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] 
											encoding:NSASCIIStringEncoding];
	
	self.device = [NSString stringWithFormat:@"%@%@", self.device, reply];	
	
	[reply release];
	[tsdaemonTask release];
}

#pragma mark -
#pragma mark Encoding

- (NSDictionary *)getAsXML{
	NSDictionary *transceiverAsXML = [NSDictionary dictionaryWithObjects:
									 [NSArray arrayWithObjects:
									  properties, 
									  VID,
									  PID, 
									  nil]
																forKeys:
									 [NSArray arrayWithObjects:
									  @"properties", 
									  @"VID",
									  @"PID", 
									  nil]];	
	return transceiverAsXML;
}	

@end

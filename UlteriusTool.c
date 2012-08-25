/*
 *  UlteriusTool.c
 *  Ulterius
 *
 */


#include <CoreServices/CoreServices.h>
#include "BetterAuthorizationSampleLib.h"
#include "Common.h"
#include <unistd.h>

extern char **environ;

/////////////////////////////////////////////////////////////////
#pragma mark ***** Get Version Command

static OSStatus DoGetVersion(
							 AuthorizationRef			 auth,
							 const void *                userData,
							 CFDictionaryRef			 request,
							 CFMutableDictionaryRef      response,
							 aslclient                   asl,
							 aslmsg                      aslMsg
)
// Implements the kUlteriusGetVersionCommand.  Returns the version number of 
// the helper tool.
{	
	OSStatus					retval = noErr;
	CFNumberRef					value;
    static const int kCurrentVersion = kToolVersion;          // something very easy to spot
	
	// Pre-conditions
	
	assert(auth != NULL);
    // userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
    // asl may be NULL
    // aslMsg may be NULL
	
    // Add them to the response.
    
	value = CFNumberCreate(NULL, kCFNumberIntType, &kCurrentVersion);
	if (value == NULL) {
		retval = coreFoundationUnknownErr;
    } else {
        CFDictionaryAddValue(response, CFSTR(kUlteriusGetVersionResponse), value);
	}
	
	if (value != NULL) {
		CFRelease(value);
	}
	
	return retval;
}

static int RunLaunchCtl(
						bool						junkStdIO, 
						const char					*command, 
						const char					*plistPath
)
// Handles all the invocations of launchctl by doing the fork() + execve()
// for proper clean-up. Only two commands are really supported by our
// implementation; loading and unloading of a job via the plist pointed at 
// (const char *) plistPath.
{	
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


/////////////////////////////////////////////////////////////////
#pragma mark ***** Get Write Property List Command

SInt32 *WriteMyPropertyListToFile( CFPropertyListRef propertyList, CFURLRef fileURL ) {
	CFDataRef xmlData;
	Boolean status;
	SInt32 *errorCode;
	
	// Convert the property list into XML data.
	xmlData = CFPropertyListCreateXMLData( kCFAllocatorDefault, propertyList );
	
	// Write the XML data to the file.
	status = CFURLWriteDataAndPropertiesToResource (fileURL, xmlData, NULL, errorCode);
	CFRelease(xmlData);
	return errorCode;
}

static OSStatus DoWritePlist(
								 AuthorizationRef			auth,
								 const void*				userData,
								 CFDictionaryRef			request,
								 CFMutableDictionaryRef     response,
								 aslclient                  asl,
								 aslmsg                     aslMsg){

	OSStatus retval = noErr;
	int err;
	CFURLRef url;
	SInt32 *errCode;
	CFDictionaryRef myPlist;
	CFMutableStringRef fullPath = CFStringCreateMutable(NULL, 200);
	CFStringRef basePath;
	CFStringRef fileName;
	CFStringRef postFix;
	
	// Pre-conditions    
	assert(auth != NULL);
	assert(request != NULL);
	assert(response != NULL);


	//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "DoWritePlist is up");
	
	// Fetch stuff from dictionary
	myPlist = CFDictionaryGetValue(request, CFSTR("myPlist"));
	if(!myPlist)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Could not find the key myPlist in the request");	

	fileName = CFDictionaryGetValue(request, CFSTR("fileName"));
	if(!fileName)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Could not find the key fileName in the request");	
	
	// Contstruct file path
	basePath = CFSTR("/Library/LaunchAgents/");
	postFix = CFSTR(".plist");
	CFStringAppend(fullPath, basePath);
	CFStringAppend(fullPath, fileName);
	CFStringAppend(fullPath, postFix);
//	err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Plist path: %s", fullPath);	
	
/*	// Unload old plist
	char buffer[CFStringGetLength(fullPath)*16];
	if (CFStringGetCString(fullPath, buffer, CFStringGetLength(fullPath)*16, kCFStringEncodingUTF8)) {
		//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Buffer: %s", buffer);
	}
*/	
//	int error = RunLaunchCtl(true ,"unload", buffer);
//	if (error != 0)
//		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Error unloading plist");
//	else {
		//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Plist unloaded");
//	}
	
	// Create url
	//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Creating URL");	
	url = CFURLCreateWithFileSystemPath( kCFAllocatorDefault,
											fullPath,       // file path name
											kCFURLPOSIXPathStyle,    // interpret as POSIX path
											false );                 // is it a directory?

	// Write the file
	err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Writing File");	
	errCode = WriteMyPropertyListToFile(myPlist, url);
	if(*errCode != 0)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Failed creating file, error code: %d", (int)*errCode);
	else {
		//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Successfully created file");
	}

/*	// Load new plist
	int error = RunLaunchCtl(true ,"load", buffer);
	if (error != 0)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Error loading plist");
	else {
		//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Plist loaded");
	}
*/
	// Clean up
	if (fullPath != NULL)
		CFRelease(fullPath);	
	if (url != NULL)
		CFRelease(url);
	if (basePath != NULL)
		CFRelease(basePath);
	if (postFix != NULL)
		CFRelease(postFix);

	/*
	if (fileName != NULL)
		CFRelease(fileName);
*/	
	return retval;
}

// Delete plist
static OSStatus DoDeletePlist(
							 AuthorizationRef			auth,
							 const void*				userData,
							 CFDictionaryRef			request,
							 CFMutableDictionaryRef     response,
							 aslclient                  asl,
							 aslmsg                     aslMsg){
	
	OSStatus retval = noErr;
	int err;
	CFURLRef url;	
	SInt32 *errorCode;
	CFMutableStringRef fullPath = CFStringCreateMutable(NULL, 200);
	CFStringRef fileName;
	CFStringRef basePath;
	
	// Pre-conditions    
	assert(auth != NULL);
	assert(request != NULL);
	assert(response != NULL);
	
	
//	err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "DoDeletePlist is up");
	
	// Fetch stuff from the request
	fileName = CFDictionaryGetValue(request, CFSTR("plistName"));
	if(!fileName)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Could not find the key plistName in the request");	
	
	// Contstruct file path
	basePath = CFSTR("/Library/LaunchAgents/");
	CFStringAppend(fullPath, basePath);
	CFStringAppend(fullPath, fileName);

	// First unload plist
	char buffer[CFStringGetLength(fullPath)*16];
	if (CFStringGetCString(fullPath, buffer, CFStringGetLength(fullPath)*16, kCFStringEncodingUTF8)){
//		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Buffer: %s", buffer);
	}
	
	int error = RunLaunchCtl(true ,"unload", buffer);
	if (error != 0)
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Error unloading plist");
	else { 
//		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Plist unloaded");
}
	
	// Create url
//	err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Creating URL");	
	url = CFURLCreateWithFileSystemPath( kCFAllocatorDefault,
										fullPath,       // file path name
										kCFURLPOSIXPathStyle,    // interpret as POSIX path
										false );                 // is it a directory?
	
	// Delete the plist.
	err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Deleting File");	
	if(!CFURLDestroyResource(url, errorCode))
		err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Failed deleting file, error code: %d", (int)*errorCode);		
	else {
		//err = asl_log(asl, aslMsg, ASL_LEVEL_DEBUG, "Successfully deleted file");
	}
	
	// Clean up
	if (fullPath != NULL)
		CFRelease(fullPath);	
	if (url != NULL)
		CFRelease(url);
	if (basePath != NULL)
		CFRelease(basePath);
	
	/*
	 if (fileName != NULL)
	 CFRelease(fileName);
	 */	
	return retval;
}

/////////////////////////////////////////////////////////////////
#pragma mark ***** Tool Infrastructure

static const BASCommandProc kUlteriusCommandProcs[] = {
	DoGetVersion,
	DoWritePlist,
	DoDeletePlist,
	NULL
};

int main(int argc, char **argv)
{
    // Go directly into BetterAuthorizationSampleLib code.
	
    // IMPORTANT
    // BASHelperToolMain doesn't clean up after itself, so once it returns 
    // we must quit.
    
	return BASHelperToolMain(kUlteriusCommandSet, kUlteriusCommandProcs);
}

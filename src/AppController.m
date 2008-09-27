
// $Author: $
// $HeadURL: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Rev: $

#import "AppController.h"
#import "MBPreferenceController.h"
#import "SingleViewHostController.h"
#import "SwordManager.h"
#import "SwordInstallSourceController.h"
#import "SwordInstallSource.h"
#import "MBThreadedProgressSheetController.h"
#import "IndexingManager.h"
#import "globals.h"

NSString* pathForFolderType(OSType dir,short domain,BOOL createFolder) {
	OSStatus err = 0;
	FSRef folderRef;
	NSString *path = nil;
	NSURL *url = nil;
	
	err = FSFindFolder(domain,dir,createFolder,&folderRef);
	if(err == 0) {
		url = (NSURL *)CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &folderRef);
		if(url) {
			path = [NSString stringWithString:[url path]];
			[url release];
		}
	}
    
	return path;
}


@interface AppController (privateAPI)

- (void)registerDefaults;
- (BOOL)setupFolders;

@end

@implementation AppController (privateAPI)

+ (void)initialize {
	// get path to "Logs" folder of current user
	NSString *logPath = LOGFILE;
	
#ifdef DEBUG
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[MacSword2]" 
		  logFilterLevel:MBLOG_DEBUG 
			appendToFile:YES 
			logToConsole:YES];
#endif
#ifdef RELEASE
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[MacSword2]" 
		  logFilterLevel:MBLOG_WARN 
			appendToFile:YES 
			logToConsole:NO];	
#endif
	MBLOG(MBLOG_DEBUG,@"initLogging: logging initialized");    
}

- (void)registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// create a dictionary
	NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
    
    // defaults for BibleText display
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextShowBookNameKey];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextShowBookAbbrKey];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextVersesOnOneLineKey];
    [defaultsDict setObject:@"Lucida Grande" forKey:DefaultsBibleTextDisplayFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:12] forKey:DefaultsBibleTextDisplayFontSizeKey];
	[defaultsDict setObject:@"Lucida Grande" forKey:DefaultsHeaderViewFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:10] forKey:DefaultsHeaderViewFontSizeKey];
    
	// register the defaults
	[defaults registerDefaults:defaultsDict];
}

/**
sets up all needed folders so the application can work
 */
- (BOOL)setupFolders {
    BOOL ret = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // get app support path
	NSString *path = pathForFolderType(kApplicationSupportFolderType, kUserDomain, true);
	if(path == nil) {
		MBLOG(MBLOG_ERR, @"Cannot get path to Application Support!");
	} else {
        MBLOG(MBLOG_INFO, @"Have path to AppSupport, ok.");
        
        // add path for application path in Application Support
        path = [path stringByAppendingPathComponent:APPNAME];
        // check if dir for application exists
        NSFileManager *manager = [NSFileManager defaultManager];
        if([manager fileExistsAtPath:path] == NO) {
            MBLOG(MBLOG_INFO, @"path to Eloquent does not exist, creating it!");
            // create APP dir
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                MBLOG(MBLOG_ERR,@"Cannot create Eloquent folder in Application Support!");
                ret = NO;
            }
        }
        
        // on no error continue
        if(ret) {
            // create IndexFolder folder
            NSString *indexPath = [path stringByAppendingPathComponent:@"Index"];
            if([manager fileExistsAtPath:indexPath] == NO) {
                MBLOG(MBLOG_INFO, @"path to IndexFolder does not exist, creating it!");
                if([manager createDirectoryAtPath:indexPath attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR,@"Cannot create installmgr folder in Application Support!");
                }                
            }
            // put to defaults
            [defaults setObject:indexPath forKey:DEFAULTS_SWINDEX_PATH_KEY];
            [defaults synchronize];
        }

        // create default modules folder which is Sword
        path = DEFAULT_MODULE_PATH;
        if([manager fileExistsAtPath:path] == NO) {
            MBLOG(MBLOG_INFO, @"path to swmodules does not exist, creating it!");
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                MBLOG(MBLOG_ERR,@"Cannot create swmodules folder in Application Support!");
                ret = NO;
            }
            
            // check for "mods.d" folder
            NSString *modsFolder = [path stringByAppendingPathComponent:@"mods.d"];
            if([manager fileExistsAtPath:modsFolder] == NO) {
                // create it
                if([manager createDirectoryAtPath:modsFolder attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR, @"Could not create mods.d folder!");
                }
            }            
        }
        // put to defaults
        [defaults setObject:path forKey:DEFAULTS_SWMODULE_PATH_KEY];
        [defaults synchronize];                    
        
        // on no error continue
        if(ret) {
            // create InstallMgr folder
            NSString *installMgrPath = [path stringByAppendingPathComponent:SWINSTALLMGR_NAME];
            if([manager fileExistsAtPath:installMgrPath] == NO) {
                MBLOG(MBLOG_INFO, @"path to imstallmgr does not exist, creating it!");
                if([manager createDirectoryAtPath:installMgrPath attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR,@"Cannot create installmgr folder in Application Support!");
                    ret = NO;
                }                
            }
            // put to defaults
            [defaults setObject:installMgrPath forKey:DEFAULTS_SWINSTALLMGR_PATH_KEY];
            [defaults synchronize];
        }
	}
    
    return ret;
}

@end


@implementation AppController

/** the singleton */
static AppController *singleton;

+ (AppController *)defaultAppController {
    return singleton;
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc AppController!");		
    } else {
        // init window Hosts array
        windowHosts = [[NSMutableArray alloc] init];
        
		// register user defaults
		[self registerDefaults];
        
        // init AppSupportFolder
        BOOL success = [self setupFolders];
        if(!success) {
            MBLOG(MBLOG_ERR, @"[AppController -init] could not initialize AppSupport!");
        } else {
            // set singleton
            singleton = self;
            
            // initialize ThreadedProgressSheet
            [MBThreadedProgressSheetController standardProgressSheetController];
            
            // init install manager
            SwordInstallSourceController *sim = [SwordInstallSourceController defaultController];
            [sim setConfigPath:[userDefaults stringForKey:DEFAULTS_SWINSTALLMGR_PATH_KEY]];
            
            // init indexingmanager, set base index path
            IndexingManager *im = [IndexingManager sharedManager];
            [im setBaseIndexPath:[userDefaults stringForKey:DEFAULTS_SWINDEX_PATH_KEY]];
            
            // init SwordManager
            SwordManager *sm = [SwordManager defaultManager];
            // set SwordString Manager
            [SwordManager initStringManager];
            // init locale
            [SwordManager initLocale];
        }
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)finalize {
	// dealloc object
	[super finalize];
}

/** opens a new single host window for the given module */
- (void)openSingleHostWindowForModule:(SwordModule *)mod {
    // open a default view
    SingleViewHostController *svh = nil;
    if(([mod type] == bible) ||
       ([mod type] == commentary) ||
       ([mod type] == dictionary)) {
        svh = [[SingleViewHostController alloc] initWithModule:mod];
    }
    [windowHosts addObject:svh];
    svh.delegate = self;
    [svh showWindow:self];    
}

//-------------------------------------------------------------------
// NSApplication delegate method
//-------------------------------------------------------------------
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}


//-------------------------------------------------------------------
// show PreferencePanel (this method also is used for delegate methods from interface copntroller to open prefs panel)
//-------------------------------------------------------------------

- (IBAction)openNewSingleBibleHostWindow:(id)sender {
    // open a default view
    SingleViewHostController *svh = [[SingleViewHostController alloc] initForViewType:bible];
    [windowHosts addObject:svh];
    svh.delegate = self;
    [svh showWindow:self];
}

- (IBAction)openNewSingleCommentaryHostWindow:(id)sender {
    // open a default view
    SingleViewHostController *svh = [[SingleViewHostController alloc] initForViewType:commentary];
    [windowHosts addObject:svh];
    svh.delegate = self;
    [svh showWindow:self];    
}

- (IBAction)openNewSingleDictionaryHostWindow:(id)sender {
    // open a default view
    SingleViewHostController *svh = [[SingleViewHostController alloc] initForViewType:dictionary];
    [windowHosts addObject:svh];
    svh.delegate = self;
    [svh showWindow:self];    
}

- (IBAction)showPreferenceSheet:(id)sender {
	// check if preference controller already exists
	if(preferenceController == nil) {
		// create it
		preferenceController = [MBPreferenceController defaultPrefsController];
		// set delegate of preferenceController
		[preferenceController setDelegate:self];
		// load PreferenceSheet, so we have the views we need
		BOOL success = [NSBundle loadNibNamed:PREFERENCE_CONTROLLER_NIB_NAME owner:preferenceController];
		if(success == NO) {
			MBLOG(MBLOG_ERR,@"[AppController]: cannot load Preferences.nib!");
		}		
	}
	
	// show panel
	[preferenceController beginSheetForWindow:nil];
}

- (IBAction)showAboutWindow:(id)sender {
}

/**
 init module manager window controller
 */
- (IBAction)showModuleManager:(id)sender {
    if(moduleManager == nil) {
        moduleManager = [[ModuleManager alloc] init]; 
    }
    
    // show window
    [moduleManager showWindow:self];
}

#pragma mark - host window delegate methods

- (void)hostClosing:(NSWindowController *)aHost {
    // remove from array
    [windowHosts removeObject:aHost];
}

#pragma mark - app delegate methods

/**
 \brief gets called if the nib file has been loaded. all gfx objacts are available now.
*/
- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[AppController -awakeFromNib]");
    
    // load saved windows
    NSData *data = [NSData dataWithContentsOfFile:@"/tmp/MacSwordWindows.plist"];
    if(data == nil) {
        // open a default view
        SingleViewHostController *svh = [[SingleViewHostController alloc] initForViewType:bible];
        svh.delegate = self;
        [windowHosts addObject:svh];
    } else {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        windowHosts = [unarchiver decodeObjectForKey:@"WindowsEncoded"];
        for(NSWindowController *wc in windowHosts) {
            if([wc isKindOfClass:[SingleViewHostController class]]) {
                [(SingleViewHostController *)wc setDelegate:self];
            }
        }
    }
}

/**
 \brief is called when application loading is nearly finished
*/
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
}

/**
\brief is called when application loading is finished
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    MBLOG(MBLOG_DEBUG, @"[AppController -applicationDidFinishLaunching:]");
	if(self != nil) {
        // show svh
        for(id entry in windowHosts) {
            if([entry isKindOfClass:[SingleViewHostController class]]) {
                [(SingleViewHostController *)entry showWindow:self];
            }
        }
	}
    
    // start background indexer
    [[IndexingManager sharedManager] triggerBackgroundIndexCheck];
}

/**
\brief is called when application is terminated
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender {
    
    // encode all windows
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:windowHosts forKey:@"WindowsEncoded"];
    [archiver finishEncoding];
    // write data object
    [data writeToFile:@"/tmp/MacSwordWindows.plist" atomically:NO];
    
    // close logger
	[MBLogger closeLogger];
	
	// we want to terminate NOW
	return NSTerminateNow;
}

@end
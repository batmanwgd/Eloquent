/* MBPreferenceController */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <CocoLogger/CocoLogger.h>

#define PREFERENCE_CONTROLLER_NIB_NAME              @"Preferences"

// UserDefault defines

// text view margins
#define DefaultsTextContainerVerticalMargins        @"DefaultsTextContainerVerticalMargins"
#define DefaultsTextContainerHorizontalMargins      @"DefaultsTextContainerHorizontalMargins"

// bible display
#define DefaultsBibleTextShowBookNameKey            @"DefaultsBibleTextShowBookNameKey"
#define DefaultsBibleTextShowBookAbbrKey            @"DefaultsBibleTextShowBookAbbrKey"
#define DefaultsBibleTextVersesOnOneLineKey         @"DefaultsBibleTextVersesOnOneLineKey"
#define DefaultsBibleTextShowVerseNumberOnlyKey     @"DefaultsBibleTextShowVerseNumberOnlyKey"
#define DefaultsBibleTextHighlightBookmarksKey      @"DefaultsBibleTextHighlightBookmarksKey"

#define DefaultsBibleTextDisplayFontFamilyKey       @"DefaultsBibleTextDisplayFontFamilyKey"
#define DefaultsBibleTextDisplayBoldFontFamilyKey   @"DefaultsBibleTextDisplayBoldFontFamilyKey"
#define DefaultsBibleTextDisplayFontSizeKey         @"DefaultsBibleTextDisplayFontSizeKey"

#define DefaultsHeaderViewFontFamilyKey             @"DefaultsHeaderViewFontFamilyKey"
#define DefaultsHeaderViewFontSizeKey               @"DefaultsHeaderViewFontSizeKey"
#define DefaultsHeaderViewFontSizeBigKey            @"DefaultsHeaderViewFontSizeBigKey"

// module display settings
#define DefaultsModuleDisplaySettingsKey            @"DefaultsModuleDisplaySettingsKey"

// cipher keys
#define DefaultsModuleCipherKeysKey                 @"DefaultsModuleCipherKeysKey"

// define some userdefaults keys
#define DEFAULTS_SWMODULE_PATH_KEY                  @"SwordModulePath"
#define DEFAULTS_SWINSTALLMGR_PATH_KEY              @"SwordInstallMgrPath"
#define DEFAULTS_SWINDEX_PATH_KEY                   @"SwordIndexPath"
#define DEFAULTS_NOTES_PATH_KEY                     @"NotesTakingPath"
#define DefaultsSessionPath                         @"DefaultsSessionPath"

// default bible
#define DefaultsBibleModule                         @"DefaultsBibleModule"
#define DefaultsDictionaryModule                    @"DefaultsDictionaryModule"
#define DefaultsStrongsHebrewModule                 @"DefaultsStrongsHebrewModule"
#define DefaultsStrongsGreekModule                  @"DefaultsStrongsGreekModule"
#define DefaultsMorphHebrewModule                   @"DefaultsMorphHebrewModule"
#define DefaultsMorphGreekModule                    @"DefaultsMorphGreekModule"

// indexing defaults
#define DefaultsBackgroundIndexerEnabled            @"DefaultsBackgroundIndexerEnabled"
#define DefaultsRemoveIndexOnModuleRemoval          @"DefaultsRemoveIndexOnModuleRemoval"
#define DefaultsIndexedSearchBookSets               @"DefaultsIndexedSearchBookSets"

// UI defaults
#define DefaultsShowLSB                             @"DefaultsShowLSB"
#define DefaultsShowRSB                             @"DefaultsShowRSB"
#define DefaultsShowHUDPreview                      @"DefaultsShowHUDPreview"
#define DefaultsShowPreviewToolTip                  @"DefaultsShowPreviewToolTip"

// confirmations
#define DefaultsShowFullScreenConfirm               @"DefaultsShowFullScreenConfirm"

@class SwordManager;

@interface MBPreferenceController : NSWindowController {
	// global stuff
	IBOutlet NSButton *okButton;
	IBOutlet NSTabView *prefsTabView;
	
    IBOutlet NSFontManager *fontManager;
    IBOutlet NSTextField *bibleFontTextField;
    NSFont *bibleDisplayFont;
    
	// the views
	IBOutlet NSView *generalView;
    NSRect generalViewRect;
	IBOutlet NSView *bibleDisplayView;
    NSRect bibleDisplayViewRect;
    IBOutlet NSView *moduleFontsView;
    IBOutlet NSTableView *moduleFontsTableView;
    NSRect moduleFontsViewRect;
    NSString *currentModuleName;
	BOOL moduleFontAction;
    
	// the window the sheet shall come up
	NSWindow *sheetWindow;
    
	// set delegate
	id delegate;
	
	// return code of sheet
	int sheetReturnCode;
	
	// margins
	int northMargin;
	int southMargin;
	int sideMargin;
	int topTabViewMargin;
}

@property (readwrite) id delegate;
@property (readwrite) NSWindow *sheetWindow;

// the default prefs controller
+ (MBPreferenceController *)defaultPrefsController;

- (id)initWithDelegate:(id)aDelegate;

/** returns a copy of the default web preferences */
- (WebPreferences *)defaultWebPreferences;
- (WebPreferences *)defaultWebPreferencesForModuleName:(NSString *)aModName;

- (NSArray *)moduleNamesOfTypeBible;
- (NSArray *)moduleNamesOfTypeDictionary;
- (NSArray *)moduleNamesOfTypeStrongsGreek;
- (NSArray *)moduleNamesOfTypeStrongsHebrew;

// get font for module
- (NSFont *)normalDisplayFontForModuleName:(NSString *)aModName;
- (NSFont *)boldDisplayFontForModuleName:(NSString *)aModName;

// begin sheet
- (void)beginSheetForWindow:(NSWindow *)docWindow;
- (void)endSheet;
// sheet return code
- (int)sheetReturnCode;
// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// actions
- (IBAction)toggleBackgroundIndexer:(id)sender;
- (IBAction)openFontsPanel:(id)sender;
- (IBAction)resetModuleFont:(id)sender;

@end

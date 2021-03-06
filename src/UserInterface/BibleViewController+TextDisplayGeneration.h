//
//  BibleViewController+TextDisplayGeneration.h
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BibleViewController.h"

@class SwordBibleTextEntry;

@interface BibleViewController (TextDisplayGeneration)

- (void)handleTextEntry:(SwordBibleTextEntry *)entry duplicateDict:(NSMutableDictionary *)duplicateDict htmlString:htmlString;
- (NSString *)createHTMLStringWithMarkers;
- (SwordBibleTextEntry *)applyBookmarkHighlightingOnTextEntry:(SwordBibleTextEntry *)anEntry;
- (void)appendHTMLFromTextEntry:(SwordBibleTextEntry *)anEntry atHTMLString:(NSMutableString *)aString;
- (NSMutableAttributedString *)generateAttributedString:(NSString *)aString;
- (void)applyLinkCursorToLinks:(NSMutableAttributedString *)attrString;
- (void)replaceVerseMarkers:(NSMutableAttributedString *)attrString;
- (void)applyWritingDirection:(NSMutableAttributedString *)attrString;

@end

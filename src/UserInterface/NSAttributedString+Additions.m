//
//  NSAttributedString+Additions.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "NSAttributedString+Additions.h"
#import "ModuleViewController.h"

@implementation NSAttributedString (Additions)

- (NSArray *)findBibleVerses {
    NSMutableArray *verseList = [NSMutableArray array];
    for(NSInteger i = 0;i < [self length]; i++) {
        NSRange range;
        NSString *attrValue = [self attribute:TEXT_VERSE_MARKER atIndex:i effectiveRange:&range];
        if(attrValue) {
            i += (range.length - 1);
            [verseList addObject:attrValue];
        }
    }
    return verseList;
}

@end
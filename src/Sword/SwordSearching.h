//
//  SwordSearching.h
//  MacSword
//
// Copyright 2008 Manfred Bergmann
// Based on code by Will Thimbleby
//

#import <Foundation/Foundation.h>
#import <SwordModule.h>
#import <SwordBible.h>
#import <SwordDictionary.h>
#import <SwordBook.h>

#ifdef __cplusplus
#include <swtext.h>
#include <versekey.h>
#endif

@class Indexer;

@interface SwordModule(Searching)

- (BOOL)hasIndex;
- (void)createIndex;
- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordBible(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordDictionary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordBook(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;
#ifdef __cplusplus
- (id)indexContents:(sword::TreeKeyIdx *)treeKey 
          intoIndex:(Indexer *)indexer;
#endif    
@end
//
// Created by 张林 on 7/6/15.
// Copyright (c) 2015 张林. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSManagedObjectContext;
@class Meizhi;

@interface MeizhiStore : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
+ (instancetype)sharedStore;

- (NSArray *)loadAllMeizhi;

- (NSArray *)allMeizhi;

- (Meizhi *) newMeizhiFromHTML: (NSString *)html date: (NSString *)date;
- (Meizhi *) newMeizhiFromURL: (NSString *)url date: (NSString *)date thumbWidth:(int) width thumbHeight: (int) height;

- (BOOL) saveChanges;
@end
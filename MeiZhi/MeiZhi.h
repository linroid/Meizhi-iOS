//
//  Meizhi.h
//  Meizhi
//
//  Created by 张林 on 7/1/15.
//  Copyright (c) 2015 张林. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
@interface Meizhi : NSManagedObject

@property (nonatomic, retain) NSString * mid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic) float thumbHeight;
@property (nonatomic) float thumbWidth;

//-(instancetype) initWithURL: (NSString *)url date: (NSString *)date thumbWidth:(int) width thumbHeight: (int) height;
//-(instancetype) initWithHTML: (NSString *)html date: (NSString *)date;
//+(NSArray *) meizhiFromOldData;
-(NSString *) toGenerateString;
@end

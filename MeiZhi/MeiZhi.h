//
//  Meizhi.h
//  Meizhi
//
//  Created by 张林 on 7/1/15.
//  Copyright (c) 2015 张林. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meizhi : NSObject

@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) int thumbWidth;
@property (nonatomic) int thumbHeight;
-(instancetype) initWithURL: (NSString *)url date: (NSString *)date thumbWidth:(int) width thumbHeight: (int) height;
-(instancetype) initWithHTML: (NSString *)html date: (NSString *)date;
+(NSArray *) meizhiFromOldData;
-(NSString *) toGenerateString;
@end

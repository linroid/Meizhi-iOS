//
//  MeizhiCell.m
//  Meizhi
//
//  Created by 张林 on 7/1/15.
//  Copyright (c) 2015 张林. All rights reserved.
//

#import "MeizhiCell.h"
#include "Masonry.h"

@implementation MeizhiCell

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
		self.contentView.backgroundColor = [UIColor clearColor];

		UIView *container = [[UIView alloc] init];
		container.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];

		CALayer *layer = container.layer;
		layer.cornerRadius = 2;
		layer.masksToBounds = YES;
		layer.shadowColor = [UIColor blackColor].CGColor;
		layer.shadowOffset = CGSizeMake(4, 4);
		layer.shadowOpacity = 0.5;
		layer.shadowRadius = 10;

		[self.contentView addSubview:container];
		[container mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(8, 8, 0, 8));
		}];


		self.thumbnailView = [[UIImageView alloc] init];
		self.thumbnailView.layer.cornerRadius = 2;
//        self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
		[container addSubview:self.thumbnailView];
		[self.thumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(container);
			make.width.equalTo(container);
			make.centerX.equalTo(container);
		}];

		self.dateLabel  = [[UILabel alloc] init];
		self.dateLabel.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1];
		self.dateLabel.font = [UIFont systemFontOfSize:12];
        [container addSubview: self.dateLabel];
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.thumbnailView.mas_bottom).offset(4);
            make.bottom.equalTo(container).offset(-4);
            make.centerX.equalTo(container);
        }];

    }
    return self;
}

@end

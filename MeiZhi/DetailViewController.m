//
//  DetailViewController.m
//  Meizhi
//
//  Created by 张林 on 7/1/15.
//  Copyright (c) 2015 张林. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailViewController.h"
#import "Meizhi.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)loadView {
	[super loadView];
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.imageView = [[UIImageView alloc] init];
	[self.view addSubview:self.imageView];
	[self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
		CGRect frame = [UIScreen mainScreen].bounds;
		CGFloat width = frame.size.width;
		CGFloat height = self.meizhi.thumbHeight * width/self.meizhi.thumbWidth;
		if(height > frame.size.height) {
			height = frame.size.height;
			width = self.meizhi.thumbWidth * height/self.meizhi.thumbHeight;
		}
		make.width.mas_equalTo(width);
		make.height.mas_equalTo(height);
		make.center.equalTo(self.view);
	}];
	self.imageView.backgroundColor = [UIColor blackColor];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	[self.imageView sd_setImageWithURL:[[NSURL alloc] initWithString:self.meizhi.url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

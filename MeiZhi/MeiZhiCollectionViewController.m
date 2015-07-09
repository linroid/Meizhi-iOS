//
//  MeizhiCollectionViewController.m
//  Meizhi
//
//  Created by 张林 on 7/1/15.
//  Copyright (c) 2015 张林. All rights reserved.
//

#import "MeizhiCollectionViewController.h"
#import "AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MeizhiCell.h"
#import "Meizhi.h"
#import "DDCollectionViewFlowLayout.h"
#import "DetailViewController.h"
#import "MeizhiStore.h"

@interface MeizhiCollectionViewController () <DDCollectionViewDelegateFlowLayout>{
	MeizhiStore *store;
	NSMutableArray *meizhis;
	AFHTTPSessionManager *manager;
	NSDate *today;
	NSDateFormatter *formatter;
}
@end

static NSString *MeizhiEndpoint = @"http://gank.io/";


@implementation MeizhiCollectionViewController

static NSString *const reuseIdentifier = @"MeizhiCell";

- (instancetype)init {

	DDCollectionViewFlowLayout * layout = [[DDCollectionViewFlowLayout alloc] init];
	layout.delegate = self;
	self = [super initWithCollectionViewLayout:layout];
	if (self) {
		[self.collectionView setCollectionViewLayout:layout];
	}

	return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
	return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	Meizhi *meizhi = meizhis[indexPath.row];
	DetailViewController *detailViewController = [[DetailViewController alloc] init];
	detailViewController.meizhi = meizhi;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)viewDidLoad {

	[super viewDidLoad];
	self.navigationItem.title = @"妹纸.gank.io";
	self.collectionView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
	// Uncomment the following line to preserve selection between presentations
	// self.clearsSelectionOnViewWillAppear = NO;

	// Register cell classes
	[self.collectionView registerClass:[MeizhiCell class] forCellWithReuseIdentifier:reuseIdentifier];

	meizhis = [[NSMutableArray alloc] init];

	formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone localTimeZone]];
	[formatter setDateFormat:@"yyyy/MM/dd"];

	today = [[NSDate alloc] init];
	NSDate *lastDay;
	manager = [[AFHTTPSessionManager alloc] initWithBaseURL:
			[NSURL URLWithString:MeizhiEndpoint]];

	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	store = [MeizhiStore sharedStore];
	NSArray *savedMeizhis = [store allMeizhi];
	meizhis = [savedMeizhis mutableCopy];

	if ([meizhis count] == 0) {
		lastDay = [formatter dateFromString:@"2015/03/30"];
	} else {
		Meizhi *newestMeiZhi = [meizhis firstObject];
		lastDay = [formatter dateFromString:newestMeiZhi.mid];
	}
	[self loadData:lastDay];
}

- (void)loadData:(NSDate *) lastDay {
	NSDate *thatDay = [lastDay dateByAddingTimeInterval: 24*60*60];
	if ([thatDay compare:today] < 0) {
//		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		NSString *dateString = [formatter stringFromDate:thatDay];
//		NSString *url = [NSString stringWithFormat: @"http://gank.io/%@", dateString];
		NSURLSessionDataTask *task = [manager
				GET:dateString
		 parameters:nil
			success:^(NSURLSessionDataTask *__unused task, id data) {
				NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				Meizhi *meizhi = [[MeizhiStore sharedStore] newMeizhiFromHTML:html date:dateString];
				if(meizhi!=nil) {
					[meizhis insertObject:meizhi atIndex:0];
					NSIndexPath *newRow = [NSIndexPath indexPathForRow:0
															 inSection:0];
					[self.collectionView insertItemsAtIndexPaths:@[newRow]];
					NSLog(@"[%@]Fetch from Web success", thatDay);
					[store saveChanges];
				} else {
					NSLog(@"[%@]解析失败", thatDay);
				}
				[self loadData:thatDay];
			} failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
					NSLog(@"[%@]没有妹纸", thatDay);
					[self loadData:thatDay];
				}];

	} else {
		for (Meizhi * meizhi in meizhis) {
			NSLog(@"%@\n", [meizhi toGenerateString]);
		}
	}
}

//-(CGSize) collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    Meizhi *meizhi = self.meizhis[indexPath.row];
//    CGRect screenRect = [UIScreen mainScreen].bounds;
//    int width = screenRect.size.width / 2 - 10;
//    int height = meizhi.thumbHeight * (width/meizhi.thumbWidth);
//    return CGSizeMake(width, height);
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	Meizhi *meizhi = meizhis[indexPath.row];

	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGFloat width = screenRect.size.width / 2;
	double height;
	if(meizhi.thumbHeight) {
		height = meizhi.thumbHeight * (width * 1.0 / meizhi.thumbWidth) + 30;
	} else {
		height = width;
	}

	return CGSizeMake(width, height);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return meizhis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	MeizhiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	if (cell == nil) {
		cell = [[MeizhiCell alloc] init];
	}
	[self configureCell:cell atIndexPath:indexPath];

	return cell;
}

- (void)configureCell:(MeizhiCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Meizhi *meizhi = meizhis[indexPath.row];
	if(meizhi.thumbHeight&& meizhi.thumbWidth) {
		[cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:meizhi.url]];
	} else {
		[cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:meizhi.url]
							  placeholderImage:nil
									   options:nil
									 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
										 meizhi.thumbHeight = image.size.height;
										 meizhi.thumbWidth = image.size.width;
										 [[MeizhiStore sharedStore] saveChanges];
										 [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
									 }];
	}
	cell.dateLabel.text = meizhi.mid;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

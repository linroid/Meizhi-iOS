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


@interface MeizhiCollectionViewController () <DDCollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSMutableArray *meizhis;
@property(nonatomic, strong) AFHTTPSessionManager *manager;
@property(nonatomic, strong) NSDate *today;
@property(nonatomic, strong) NSDateFormatter *formatter;
@property(nonatomic, strong) NSMutableArray *heightArr;
@end

static NSString *MeiZhiEndpoint = @"http://gank.io/";


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
	Meizhi *meizhi = self.meizhis[indexPath.row];
	DetailViewController *detailViewController = [[DetailViewController alloc] init];
	detailViewController.meizhi = meizhi;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)viewDidLoad {

	[super viewDidLoad];
	self.navigationItem.title = @"妹纸.gank.io";
	self.heightArr = [[NSMutableArray alloc] init];
	self.collectionView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
	// Uncomment the following line to preserve selection between presentations
	// self.clearsSelectionOnViewWillAppear = NO;

	// Register cell classes
	[self.collectionView registerClass:[MeizhiCell class] forCellWithReuseIdentifier:reuseIdentifier];

	self.meizhis = [[NSMutableArray alloc] init];

	self.formatter = [[NSDateFormatter alloc] init];
	[self.formatter setTimeZone:[NSTimeZone localTimeZone]];
	[self.formatter setDateFormat:@"yyyy/MM/dd"];

	self.today = [[NSDate alloc] init];

	NSDate *lastDay;
	if ([self.meizhis count] == 0) {
		lastDay = [self.formatter dateFromString:@"2015/05/25"];
	} else {
		Meizhi *newestMeiZhi = [self.meizhis lastObject];
		lastDay = [self.formatter dateFromString:newestMeiZhi.mid];
	}

	self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:
			[NSURL URLWithString:MeiZhiEndpoint]];

	self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];

	[self loadData:lastDay];
}

- (void)loadData:(NSDate *)lastDay {
	NSDate *thatDay = [lastDay dateByAddingTimeInterval:24 * 60 * 60];
	if ([thatDay compare:self.today] < 0) {
//		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		NSString *dateString = [self.formatter stringFromDate:thatDay];
//		NSString *url = [NSString stringWithFormat: @"http://gank.io/%@", dateString];
		NSURLSessionDataTask *task = [self.manager
				GET:dateString
		 parameters:nil
			success:^(NSURLSessionDataTask *__unused task, id data) {
				NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				Meizhi *meizhi = [[Meizhi alloc] initWithHTML:html date:dateString];
				[self.meizhis insertObject:meizhi atIndex:0];
				NSIndexPath *newRow = [NSIndexPath indexPathForRow:0
														 inSection:0];
				[self.collectionView insertItemsAtIndexPaths:@[newRow]];
//				NSLog(@"[%@]Success: %@", thatDay, html);

				[self loadData:thatDay];

			} failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
					//NSLog(@"[%@]Error: %@", thatDay, dateString);
					[self loadData:thatDay];
				}];

//        [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
//        [self.refreshControl setRefreshingWithStateOfTask: task];
		NSLog(@"%@", thatDay);
	} else {
		for (Meizhi * meizhi in self.meizhis) {
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
	Meizhi *meizhi = self.meizhis[indexPath.row];

	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGFloat width = screenRect.size.width / 2;
	CGFloat height = meizhi.thumbHeight * (width * 1.0 / meizhi.thumbWidth) + 30;

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
	return self.meizhis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSLog(@"%@", NSStringFromSelector(_cmd));
	MeizhiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	if (cell == nil) {
		cell = [[MeizhiCell alloc] init];
	}
	[self configureCell:cell atIndexPath:indexPath];

	return cell;
}

- (void)configureCell:(MeizhiCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Meizhi *meiZhi = self.meizhis[indexPath.row];
	[cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:meiZhi.url]];
	cell.dateLabel.text = meiZhi.mid;
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

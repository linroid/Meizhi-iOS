//
// Created by 张林 on 7/6/15.
// Copyright (c) 2015 张林. All rights reserved.
//

#import "MeizhiStore.h"
#import "Meizhi.h"

#import <HTMLReader/HTMLDocument.h>
#import <HTMLReader/HTMLSelector.h>

@implementation MeizhiStore {
	NSArray *privateItems;
}
+ (instancetype)sharedStore {
	static MeizhiStore *store;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		store = [[MeizhiStore alloc] initPrivate];
	});
	return store;
}


- (instancetype)initPrivate {
	self = [super init];
	if (self) {

		NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
		NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model ];
		NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
				NSUserDomainMask,
				YES);
		NSString *path = [[directories firstObject] stringByAppendingPathComponent:@"store.data"];
		NSURL *storeURL = [NSURL fileURLWithPath:path];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:path]) {
			NSURL *defaultURL = [[NSBundle mainBundle] URLForResource:@"store" withExtension:@"data"];
			NSLog(@"CoreData default store location: %@", defaultURL);
			if([fileManager fileExistsAtPath:defaultURL]) {
				[fileManager copyItemAtURL:defaultURL toURL:storeURL error:nil];
			}
		}
		NSLog(@"CoreData store location: %@", storeURL);
		NSError *error = nil;
		if (![psc addPersistentStoreWithType:NSSQLiteStoreType
							   configuration:nil
										 URL:storeURL
									 options:nil
									   error:&error]) {
			@throw [NSException exceptionWithName:@"OpenFailure"
										   reason:@[[error localizedDescription]]
										 userInfo:nil];
		}
		self.context = [[NSManagedObjectContext alloc] init];
		self.context.persistentStoreCoordinator = psc;
	}
	[self loadAllMeizhi];
	return self;

}


- (NSArray *)loadAllMeizhi {
	NSError *error;
	NSArray *result;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mid" ascending:NO]];
	request.entity = [NSEntityDescription entityForName:@"Meizhi"
								 inManagedObjectContext:self.context];
	result = [self.context executeFetchRequest:request error:&error];
	if (!result) {
		[NSException raise:@"Fetch failed"
					format:@"Reason: %@", [error localizedDescription]
		];
	}
	privateItems = result;
	return result;
}

- (NSArray *)allMeizhi {
	return privateItems;
}

- (Meizhi *)newMeizhiFromHTML:(NSString *)html date:(NSString *)date {
	Meizhi *newMeizhi;

	HTMLDocument *document = [HTMLDocument documentWithString:html];
	NSArray *elements = [document nodesMatchingSelector:@"img"];

	int position = [self picturePosition:date];
	if(position<0 || [elements count]==0) {
		return nil;
	}
	NSLog(@"[%@]使用第%d张图片", date, position);

	HTMLElement *element = elements[position];
	if (!element) {
		return nil;
	}
	newMeizhi = [NSEntityDescription insertNewObjectForEntityForName:@"Meizhi"
											  inManagedObjectContext:self.context];
	NSString *url = element.attributes[@"src"];
	[newMeizhi setValue:date forKey:@"mid"];
	[newMeizhi setValue:url forKey:@"url"];

	//height:120px; width:120px
	NSString *style = element.attributes[@"style"];
	if (!style) {
		return newMeizhi;
	}
	NSRange heightRange = [style rangeOfString:@"height:"];
	NSRange heightPxRange = [style rangeOfString:@"px;"];

	if (heightRange.length <= 0 || heightPxRange.length <= 0) {
		return newMeizhi;
	}
	NSUInteger heightBegin = heightRange.location + heightRange.length;
	NSUInteger heightLength = heightPxRange.location - heightBegin;
	NSRange heightIntRange = NSMakeRange(heightBegin, heightLength);
	int thumbHeight = [[style substringWithRange:heightIntRange] intValue];

	NSRange widthRange = [style rangeOfString:@"width:"];
	NSRange widthIntRange = NSMakeRange(widthRange.location + widthRange.length, [style length] - 1 - (widthRange.location + widthRange.length + 1));
	int thumbWidth = [[style substringWithRange:widthIntRange] intValue];

	[newMeizhi setValue:@(thumbHeight) forKey:@"thumbHeight"];
	[newMeizhi setValue:@(thumbWidth) forKey:@"thumbWidth"];

	return newMeizhi;
}

- (Meizhi *)newMeizhiFromURL:(NSString *)url date:(NSString *)date thumbWidth:(int)width thumbHeight:(int)height {
	Meizhi *newMeizhi = [NSEntityDescription insertNewObjectForEntityForName:@"Meizhi"
													  inManagedObjectContext:self.context];
	if (newMeizhi) {
		[newMeizhi setValue:url forKey:@"url"];
		[newMeizhi setValue:@(height) forKey:@"thumbHeight"];
		[newMeizhi setValue:@(width) forKey:@"thumbWidth"];
	}
	return newMeizhi;
}

- (BOOL)saveChanges {
	NSError *error;
	BOOL successful = [self.context save:&error];
	if (!successful) {
		NSLog(@"Error saving:%@", [error localizedDescription]);
	}
	return successful;
}
- (int) picturePosition: (NSString *) date {
	const NSDictionary *dictionary = @{
			@"2015/07/08":@1,
			@"2015/06/12":@1,
			@"2015/06/01":@1,
			@"2015/05/28":@1,
			@"2015/05/27":@1,
			@"2015/05/19":@-1,
			@"2015/04/15":@-1,
			@"2015/04/10":@1,
			@"2015/04/03":@1,
			@"2015/04/01":@1,
			@"2015/03/26":@-1,
			@"2015/03/31":@2,
	};
	if(dictionary[date] == nil) {
		return 0;
	} else {
		return [dictionary[date] intValue];
	}
}

@end
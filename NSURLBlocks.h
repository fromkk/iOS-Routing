//          ______                                 ____     ____        ____     ____
//         /  _   /                               /   /   ／   ／       /   /   ／   ／
//        /  / /_/                               /   /  ／   ／        /   /  ／   ／
//  _____/  /_____                              /   /_／   ／         /   /_／   ／
// /____   ______/  _______    __     __       /        ／           /        ／
//     /  / ----  / ____  /   /   \  /  \     /       ＼            /       ＼
//    /  / /  ／ / /    / /  /     \/    \   /   ／＼   ＼          /   ／＼   ＼
//   /  / / /   / /    / /  /  /\   /\   / /   /    ＼   ＼       /   /    ＼   ＼
//  /  / / /   / /____/ /  /  / /__/ \  / /   /       ＼   ＼    /   /       ＼   ＼
// /__/ /_/   /________/  /__/      /__/ /___/          ＼___＼ /___/          ＼___＼
//
//  NSURLBlocks.h
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+query.h"

typedef void(^NSURLBLocks_)(BOOL result, NSData *data, NSError *error);
typedef void(^NSURLProgress)(CGFloat percent);

@interface NSURLBlocks : NSOperation <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableData *tmp;
    float totalBytes;
    float loadedBytes;
}

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, assign) NSMutableURLRequest *request;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, assign) NSError *error;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) NSURLBLocks_ block;
@property (nonatomic, assign) NSURLProgress progress;
@property (nonatomic, assign) BOOL isConnection;

+ (NSURLBlocks *)connectionWithURL:(NSURL *)URL result:(NSURLBLocks_)block progress:(NSURLProgress)progress;
+ (NSURLBlocks *)connectionWithURL:(NSURL *)URL result:(NSURLBLocks_)block method:(NSString *)method data:(NSData *)data progress:(NSURLProgress)progress;
- (void)cancel;

@end

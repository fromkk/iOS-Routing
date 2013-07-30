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
//  NSURLBlocks.m
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import "NSURLBlocks.h"

@interface NSURLBlocks()

- (id)initWithURL:(NSURL *)URL result:(NSURLBLocks_)block progress:(NSURLProgress)progress;

@end

@implementation NSURLBlocks

@synthesize URL = _URL;
@synthesize request = _request;
@synthesize connection = _connection;
@synthesize error = _error;
@synthesize block = _block;

static NSOperationQueue *sharedQueue = nil;

- (void)dealloc
{
    if ( nil != _block ) {
        Block_release(_block);
    }
    _block = nil;
    
    if ( nil != _progress ) {
        Block_release(_progress);
    }
    _progress = nil;
    
    [self.URL release];
    [tmp release];
    
    [super dealloc];
    
    self = nil;
}

- (id)initWithURL:(NSURL *)URL result:(NSURLBLocks_)block progress:(NSURLProgress)progress {
    self = [super init];
    
    if ( self ) {
        self.URL = URL;
        self.block = Block_copy(block);
        self.progress = Block_copy(progress);
        self.isConnection = NO;
    }
    
    return self;
}

- (void)main {
    self.request = [NSMutableURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120.0f];
    
    [self.request setHTTPMethod:self.method];
    if ( nil != self.data ) {
        [self.request setHTTPBody:self.data];
    }
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
    self.isConnection = YES;
}

- (void)cancel {
    [self.connection cancel];
    
    self.isConnection = NO;
}

+ (NSURLBlocks *)connectionWithURL:(NSURL *)URL result:(NSURLBLocks_)block progress:(NSURLProgress)progress {
    return [self connectionWithURL:URL result:block method:@"GET" data:nil progress:progress];
}

+ (NSURLBlocks *)connectionWithURL:(NSURL *)URL result:(NSURLBLocks_)block method:(NSString *)method data:(NSData *)data progress:(NSURLProgress)progress {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
    });
    
    NSURLBlocks *instance = [[[NSURLBlocks alloc] initWithURL:URL result:block progress:progress] autorelease];
    instance.method = method;
    instance.data   = data;
    
    [sharedQueue addOperation:instance];
    
    return instance;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    tmp = [[NSMutableData alloc] init];
    
    totalBytes = [response expectedContentLength];
    loadedBytes = 0.0f;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [tmp appendData:data];
    
    loadedBytes += data.length;
    
    if ( nil != _progress ) {
        _progress(loadedBytes / totalBytes);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.isConnection = NO;
    self.block(NO, nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSURLBLocks_ blocks = Block_copy(self.block);
    
    NSData *result = [[NSData alloc] initWithData:tmp];
    
    if ( blocks != nil ) {
        blocks(YES, result, nil);
        Block_release(blocks);
        
        [result release];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ( nil != _progress ) {
        _progress(totalBytesWritten / _data.length);
    }
}

@end

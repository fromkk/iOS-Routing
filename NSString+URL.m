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
//  NSString+URL.m
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (NSString *)encodeURL {
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

- (NSString *)decodeURL {
    return (NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
}

@end

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
//  NSDictionary+query.m
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import "NSDictionary+query.h"
#import "NSString+URL.h"

@implementation NSDictionary (query)

- (NSString *)query {
    return [self queryWithEscape:YES];
}

- (NSString *)queryWithEscape:(BOOL)escape {
    NSMutableArray *tmp = [NSMutableArray array];
    NSArray *allkeys = [self allKeys];
    for (NSString *key in allkeys) {
        [tmp addObject:[NSString stringWithFormat:@"%@=%@", key, escape ? [[self objectForKey:key] encodeURL] : [self objectForKey:key]]];
    }
    
    return [tmp componentsJoinedByString:@"&"];
}

@end

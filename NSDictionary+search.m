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
//  NSDictionary+search.m
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import "NSDictionary+search.h"

@implementation NSDictionary (search)

- (id)search:(NSString *)keypath {
    NSArray *keys = [keypath componentsSeparatedByString:@"."];
    
    id currentValue = self;
    for (NSString *key in keys) {
        if ( [currentValue isKindOfClass:[NSDictionary class]] ) {
            if ( nil != [currentValue objectForKey:key] ) {
                currentValue = [currentValue objectForKey:key];
            } else {
                return nil;
            }
        } else if ( [currentValue isKindOfClass:[NSArray class]] ) {
            int index = [key intValue];
            if ( [currentValue count] > index ) {
                currentValue = [currentValue objectAtIndex:index];
            } else {
                return nil;
            }
        }
    }
    
    return currentValue;
}

@end

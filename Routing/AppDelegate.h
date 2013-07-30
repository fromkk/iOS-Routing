//          ______                                 ____     ____          ____     ____
//         /  _   /                               /   /   ／   ／         /   /   ／   ／
//        /  / /_/                               /   /  ／   ／          /   /  ／   ／
//  _____/  /_____                              /   /_／   ／           /   /_／   ／
// /____   ______/   _______   ___    ____     /         ／            /        ／
//     /  / _____  / ____  /  /   \  /    \   /        ＼             /        ＼
//    /  / /  ／  / /   / /  /     \/      \ /    ／ ＼   ＼          /   ／ ＼   ＼
//   /  / / /   / /    / /  /  /\   /\    / /   ／    ＼   ＼       /   ／    ＼   ＼
//  /  / / /   / /____/ /  /  / /__/ \   / /   /       ＼   ＼     /   /       ＼   ＼
// /__/ /_/   /________/  /__/       /__/ /___/          ＼___＼  /___/          ＼___＼
//
//  AppDelegate.h
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign, readonly) UINavigationController *navigationController;
@property (nonatomic, assign, readonly) RootViewController *rootViewController;

@end

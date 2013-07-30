//          ______                                 ____     ____        ____     ____
//         /  _   /                               /   /   ／   ／       /   /   ／   ／
//        /  / /_/                               /   /  ／   ／        /   /  ／   ／
//  _____/  /_____                              /   /_／   ／         /   /_／   ／
// /____   ______/   _______    __    __       /        ／           /        ／
//     /  / ----  / ____  /   /   \  /  \     /       ＼            /       ＼
//    /  / /  ／ / /    / /  /     \/    \   /   ／＼   ＼          /   ／＼   ＼
//   /  / / /   / /    / /  /  /\   /\   / /   /    ＼   ＼       /   /    ＼   ＼
//  /  / / /   / /____/ /  /  / /__/ \  / /   /       ＼   ＼    /   /       ＼   ＼
// /__/ /_/   /________/  /__/      /__/ /___/          ＼___＼ /___/          ＼___＼
//
//  RootViewController.m
//  Routing
//
//  Created by Kazuya Ueoka on 2013/07/30.
//  Copyright (c) 2013年 Kazuya Ueoka. All rights reserved.
//

#import "RootViewController.h"
#import "NSURLBlocks.h"
#import "XMLReader.h"
#import "NSDictionary+search.h"
#import "NSArray+toArray.h"
#import "NSDictionary+toArray.h"

static NSString *googleDirectionAPI = @"https://maps.googleapis.com/maps/api/directions/xml";

@interface RootViewController ()

- (void)tappedSearchButton:(UIButton *)btn;
- (CLLocationCoordinate2D)northEast:(CLLocationCoordinate2D)p1 and:(CLLocationCoordinate2D)p2;
- (CLLocationCoordinate2D)southWest:(CLLocationCoordinate2D)p1 and:(CLLocationCoordinate2D)p2;

@end

@implementation RootViewController

- (void)dealloc
{
    [startField release];
    [endField release];
    [betweenLabel release];
    
    [searchButton removeFromSuperview];
    
    [_mapView release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"ルート検索";
        
        //MARK:from
        startField = [[UITextField alloc] init];
        startField.returnKeyType = UIReturnKeyDone;
        startField.placeholder = @"検索開始位置";
        startField.borderStyle = UITextBorderStyleRoundedRect;
        startField.delegate = self;
        startField.text = @"東京駅";
        [self.view addSubview:startField];
        
        betweenLabel = [[UILabel alloc] init];
        betweenLabel.text = @"〜";
        betweenLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:betweenLabel];
        
        //MARK:to
        endField = [[UITextField alloc] init];
        endField.returnKeyType = UIReturnKeyDone;
        endField.placeholder = @"検索終了位置";
        endField.borderStyle = UITextBorderStyleRoundedRect;
        endField.delegate = self;
        endField.text = @"東京タワー";
        [self.view addSubview:endField];
        
        //MARK:検索ボタン
        searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [searchButton setTitle:@"検索" forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(tappedSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:searchButton];
        
        //MARK:地図
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.userInteractionEnabled = YES;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        [self.view addSubview:_mapView];
        
        currentPolyline = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    bounds.origin.y = 60.0f;
    bounds.size.height -= 60.0f;
    
    CGFloat textFieldWidth = (bounds.size.width - 160.0f) / 2;
    
    startField.frame = CGRectMake(10.0f, 10.0f, textFieldWidth, 30.0f);
    betweenLabel.frame = CGRectMake(CGRectGetMaxX(startField.frame) + 10.0f, 10.0f, 20.0f, 20.0f);
    endField.frame = CGRectMake(CGRectGetMaxX(betweenLabel.frame) + 10.0f, 10.0f, textFieldWidth, 30.0f);
    searchButton.frame = CGRectMake(CGRectGetMaxX(endField.frame) + 10.0f, 5.0f, 80.0f, 40.0f);
    
    _mapView.frame = bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search button tapped

- (void)tappedSearchButton:(UIButton *)btn {
    [startField resignFirstResponder];
    [endField resignFirstResponder];
    
    if ( nil != startField.text && 0 != startField.text.length && nil != endField.text && 0 != endField.text.length ) {
        if ( nil != currentPolyline ) {
            [_mapView removeOverlay:currentPolyline];
            currentPolyline = nil;
        }
        
        //MARK:Google Direction APIのURLを生成
        NSDictionary *query = @{@"origin": startField.text,    //検索開始
                                @"destination": endField.text, //検索終了
                                @"sensor": @"false",           //センサーかどうか
                                @"mode": @"walking",           //交通手段 (driving（自動車）walking（歩行）bicycling（自転車）transit（公共交通機関）
                                @"alternatives": @"false",     //trueの場合複数経路
                                };
        
        //MARK:URLリクエスト
        [NSURLBlocks connectionWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", googleDirectionAPI, [query query]]] result:^(BOOL result, NSData *data, NSError *error) {
            if ( result ) {
                NSError *error = nil;
                
                //XMLパース
                NSDictionary *xml = [XMLReader dictionaryForXMLData:data error:&error];
                
                if ( nil != error ) {
                    NSLog(@"xml parse error:%@", error);
                } else {
                    if ( nil != [xml search:@"DirectionsResponse.status"] && [[xml search:@"DirectionsResponse.status"] isEqual:@"OK"]) {
                        CLLocationCoordinate2D start;
                        CLLocationCoordinate2D end;
                        
                        NSArray *steps = [[xml search:@"DirectionsResponse.route.leg.step"] toArray];
                        
                        CLLocationCoordinate2D coors[steps.count * 2];
                        
                        for (int i = 0; i < steps.count * 2; i++) {
                            NSInteger index;
                            if ( i % 2 == 0 ) {
                                index = i / 2;
                            } else if ( i == 1 ) {
                                index = 1;
                            } else {
                                index = i / 2 - 1;
                            }
                            
                            NSDictionary *step = [steps objectAtIndex:index];
                            
                            if ( i % 2 == 0 ) {
                                coors[i] = CLLocationCoordinate2DMake([[step search:@"start_location.lat"] floatValue], [[step search:@"start_location.lng"] floatValue]);
                            } else {
                                coors[i] = CLLocationCoordinate2DMake([[step search:@"end_location.lat"] floatValue], [[step search:@"end_location.lng"] floatValue]);
                            }
                            
                            if ( i == 0 ) {
                                start = CLLocationCoordinate2DMake([[step search:@"start_location.lat"] floatValue], [[step search:@"start_location.lng"] floatValue]);
                            } else if ( i == steps.count * 2 - 1 ) {
                                end = CLLocationCoordinate2DMake([[step search:@"end_location.lat"] floatValue], [[step search:@"end_location.lng"] floatValue]);
                            }
                        }
                        
                        currentPolyline = [MKPolyline polylineWithCoordinates:coors count:steps.count * 2];
                        [_mapView addOverlay:currentPolyline];
                        
                        CLLocationCoordinate2D northEast = [self northEast:start and:end];
                        CLLocationCoordinate2D southWest = [self southWest:start and:end];
                        
                        MKMapPoint northEastPoint = MKMapPointForCoordinate(northEast);
                        MKMapPoint southWestPoint = MKMapPointForCoordinate(southWest);
                        
                        double antimeridianOveflow = (northEast.longitude > southWest.longitude) ? 0 : MKMapSizeWorld.width;
                        
                        MKMapRect mapRect = MKMapRectMake(southWestPoint.x, northEastPoint.y, (northEastPoint.x - southWestPoint.x) + antimeridianOveflow,
                                                          (southWestPoint.y - northEastPoint.y));
                        [_mapView setVisibleMapRect:mapRect animated:YES];
                    } else {
                        NSLog(@"direction search error:%@", error);
                    }
                }
            } else {
                NSLog(@"network connection error:%@", error);
            }
        } progress:^(CGFloat percent) {
            
        }];
    }
}

#pragma mark - 地図に線を描画

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *view = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
    view.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
    view.lineWidth = 5.0f;
    view.lineCap = kCGLineCapRound;
    return view;
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - 開始・終了位置から北東・南西の位置を取得

- (CLLocationCoordinate2D)northEast:(CLLocationCoordinate2D)p1 and:(CLLocationCoordinate2D)p2 {
    CGFloat north = p1.latitude >= p2.latitude ? p1.latitude : p2.latitude;
    CGFloat east  = p1.longitude >= p2.longitude? p1.longitude : p2.longitude;
    
    CLLocationCoordinate2D result;
    result.latitude = north;
    result.longitude = east;
    
    return result;
}

- (CLLocationCoordinate2D)southWest:(CLLocationCoordinate2D)p1 and:(CLLocationCoordinate2D)p2 {
    CGFloat south = p1.latitude <= p2.latitude ? p1.latitude : p2.latitude;
    CGFloat west  = p1.longitude <= p2.longitude ? p1.longitude : p2.longitude;
    
    CLLocationCoordinate2D result;
    result.latitude = south;
    result.longitude = west;
    
    return result;
}

@end

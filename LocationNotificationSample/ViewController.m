//
//  ViewController.m
//  LocationNotificationSample
//
//  Created by koogawa on 2014/11/09.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 位置情報使用許可
    [self.locationManager requestAlwaysAuthorization];
    
//    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)setNotification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // 設定する前に、設定済みの通知をキャンセルする
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    // 目的地を設定
    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(35.665991, 139.732032);  // 六本木
    CLLocationDistance radius = 100.0;  // 半径何メートルに入ったら通知するか
    NSString *identifier = @"identifier"; // 通知のID
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:target
                                                                 radius:radius
                                                             identifier:identifier];

    // Notificationセット
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"目的地に着きました！";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertAction = @"OK";
    localNotification.regionTriggersOnce = YES;
    localNotification.region = region;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusDenied:
            [manager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            // 位置情報の使用が許可されていたらNotificationセット
            [self setNotification];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"olfLocation, newLocation = %@, %@", newLocation, oldLocation);
}

@end

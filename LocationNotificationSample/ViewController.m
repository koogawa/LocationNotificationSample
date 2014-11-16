//
//  ViewController.m
//  LocationNotificationSample
//
//  Created by koogawa on 2014/11/09.
//  Copyright (c) 2014年 Kosuke Ogawa. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL didInitializeUserLocation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

//    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)setNotificationWithTarget:(CLLocationCoordinate2D)target
{
    // 緯度経度の検証
    if (!CLLocationCoordinate2DIsValid(target)) {
        return;
    }

    // 設定する前に、設定済みの通知をキャンセルする
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    // 目的地の領域を設定
//    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(35.74054023732303,139.61697354912758);  // 六本木
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

- (void)userLocationDidInitialize:(MKUserLocation *)userLocation
{
    NSArray *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if ([scheduledLocalNotifications count] > 0)
    {
        // Notificationがスケジューリング済みならその領域を表示
        UILocalNotification *notification = scheduledLocalNotifications[0];
        CLLocationCoordinate2D center = [(CLCircularRegion *)notification.region center];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:100];
        [self.mapView addOverlay:circle];
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(center, 400, 400) animated:YES];
    }
    else {
        // スケジューリングされてないなら現在地を表示
        CLLocationCoordinate2D center = userLocation.location.coordinate;
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(center, 400, 400) animated:YES];
    }
}

- (IBAction)currentButtonDidTap:(id)sender
{
    CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(center, 400, 400) animated:YES];
}

- (IBAction)saveButtonDidTap:(id)sender
{
    if ([self.mapView.overlays count] == 0) {
        return;
    }

    MKCircle *circle = self.mapView.overlays[0];
    [self setNotificationWithTarget:circle.coordinate];

    self.saveButtonItem.enabled = NO;
}

// タップイベントを検出
- (IBAction)mapViewDidTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // いったんすべてのサークルを消す
        [self.mapView removeOverlays:self.mapView.overlays];

        // タップした位置を緯度経度に変換してサークルを表示
        CGPoint tapPoint = [sender locationInView:self.view];
        CLLocationCoordinate2D center = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:100];
        [self.mapView addOverlay:circle];

        self.saveButtonItem.enabled = YES;
    }
}


#pragma mark - MKMapView delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.didInitializeUserLocation)
    {
        self.didInitializeUserLocation = YES;
        [self userLocationDidInitialize:userLocation];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *renderer =
        [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        renderer.strokeColor = [UIColor redColor]; // 外側の線の色
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4]; // 内側を塗りつぶす色
        renderer.lineWidth = 1; // 外側の線の太さ

        return renderer;
    }

    return nil;
}


#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusDenied:
            [manager requestWhenInUseAuthorization];
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

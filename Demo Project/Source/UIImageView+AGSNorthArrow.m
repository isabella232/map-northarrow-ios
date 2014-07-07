//
//  UIImageView+AGSNorthArrow.m
//  AGSCommonPatternsSample
//
//  Created by Nicholas Furness on 2/14/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "UIImageView+AGSNorthArrow.h"
#import <objc/runtime.h>

#define kMapViewKey @"trackingMapView"
#define kAngleKey @"rotationAngle"
#define kTimerKey @"timer"
#define kAnimatingKey @"animating"

@interface UIImageView (AGSNorthArrowInternal)
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation UIImageView (AGSNorthArrow)
#pragma mark - MapView Property
-(void)setMapViewForNorthArrow:(AGSMapView *)mapView
{
    AGSMapView *oldMapView = self.mapViewForNorthArrow;
    if (oldMapView) {
        // We're watching a new map now. Let's forget the old one.
        [oldMapView removeObserver:self forKeyPath:kAngleKey];
        [oldMapView removeObserver:self forKeyPath:kAnimatingKey];
    }

    // Ensure we are configured properly
    self.userInteractionEnabled = NO;
    self.contentMode = UIViewContentModeScaleAspectFit;

    // Keep a weak reference to the AGSMapView (or nil)
    objc_setAssociatedObject(self, kMapViewKey, mapView, OBJC_ASSOCIATION_ASSIGN);
    
    if (mapView) {
        // Show North
        [self setNorthArrowAngle:mapView.rotationAngle];

        // Track rotation, either through interaction or animating with AGSMapView::setRotationAngle
        [mapView addObserver:self forKeyPath:kAngleKey options:NSKeyValueObservingOptionNew context:nil];
        [mapView addObserver:self forKeyPath:kAnimatingKey options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self setNorthArrowAngle:0];
    }
}

-(AGSMapView *)mapViewForNorthArrow
{
    return objc_getAssociatedObject(self, kMapViewKey);
}

#pragma mark - Timer Property for tracking rotation animation
-(void)setTimer:(NSTimer *)timer
{
    if (timer) {
        // Strong reference
        objc_setAssociatedObject(self, kTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        // Weak reference to nil
        objc_setAssociatedObject(self, kTimerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

-(NSTimer *)timer
{
    return objc_getAssociatedObject(self, kTimerKey);
}

#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAngleKey]) {
        // Simple. The map view's rotation was set directly.
        [self setNorthArrowAngle:(double)[object rotationAngle]];
    } else if ([keyPath isEqualToString:kAnimatingKey]) {
        // In this case, we're animating to a new rotation. Let's track it and update as we can.
        if (self.mapViewForNorthArrow.animating) {
            // We'll use a timer to update the north arrow as the map animates.
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                          target:self
                                                        selector:@selector(checkRotation:)
                                                        userInfo:nil repeats:YES];
        } else if (self.timer) {
            // Finished animating. Stop updating on a timer.
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

#pragma mark - Timer event for use during animation
-(void)checkRotation:(NSTimer*)timer
{
    [self setNorthArrowAngle:self.mapViewForNorthArrow.rotationAngle];
}

#pragma mark - Rotate ourselves to match the mapView
-(void)setNorthArrowAngle:(double)mapAngle
{
    self.transform = CGAffineTransformMakeRotation(-M_PI * mapAngle / 180);
}
@end

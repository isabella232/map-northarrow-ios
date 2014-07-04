//
//  AGSNorthArrowSampleViewController.m
//
//  Created by Nicholas Furness on 11/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSNorthArrowSampleViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "BasemapURLs.h"
#import "UIImageView+AGSNorthArrow.h"

@interface AGSNorthArrowSampleViewController ()
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *northArrow;
@property (weak, nonatomic) IBOutlet UIImageView *northFinger;
@end

@implementation AGSNorthArrowSampleViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up a map view as usual.
    NSURL *basemapURL = [NSURL URLWithString:kGreyURL];
    AGSTiledMapServiceLayer *basemapLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:basemapURL];
    [self.mapView addMapLayer:basemapLayer];

    [self.mapView enableWrapAround];
    self.mapView.allowRotationByPinching = YES;
    
    AGSEnvelope *initialEnvelope = [AGSEnvelope envelopeWithXmin:-13995275
                                                            ymin:-80703
                                                            xmax:-7733554
                                                            ymax:8920520
                                                spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    [self.mapView zoomToEnvelope:initialEnvelope animated:YES];

    // Set up the North Arrows. This is all you have to do.
    self.northArrow.mapViewForNorthArrow = self.mapView;
    self.northFinger.mapViewForNorthArrow = self.mapView;
}

- (IBAction)randomAngleTapped:(id)sender {
    double randomAngle = rand() % 360;
    [self.mapView setRotationAngle:randomAngle animated:YES];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

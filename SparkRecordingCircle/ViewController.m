//
//  ViewController.m
//  SparkRecordingCircle
//
//  Created by Sam Page on 1/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import "ViewController.h"
#import "RecordingCircleOverlayView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RecordingCircleOverlayView *recordingCircleOverlayView = [[RecordingCircleOverlayView alloc] initWithFrame:self.view.bounds strokeWidth:7.f insets:UIEdgeInsetsMake(10.f, 0.f, 10.f, 0.f)];
    recordingCircleOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    recordingCircleOverlayView.duration = 10.f;
    [self.view addSubview:recordingCircleOverlayView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

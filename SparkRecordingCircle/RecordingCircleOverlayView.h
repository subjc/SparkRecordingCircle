//
//  RecordingCircleOverlayView.h
//  SparkRecordingCircle
//
//  Created by Sam Page on 1/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingCircleOverlayView : UIView

- (id)initWithFrame:(CGRect)frame strokeWidth:(CGFloat)strokeWidth insets:(UIEdgeInsets)insets;

@property (nonatomic, assign) CGFloat duration;

@end

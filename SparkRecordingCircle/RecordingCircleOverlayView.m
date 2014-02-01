//
//  RecordingCircleOverlayView.m
//  SparkRecordingCircle
//
//  Created by Sam Page on 1/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import "RecordingCircleOverlayView.h"

@interface RecordingCircleOverlayView ()

@property (nonatomic, strong) NSMutableArray *progressLayers;
@property (nonatomic, strong) CAShapeLayer *currentProgressLayer;
@property (nonatomic, strong) UIBezierPath *circlePath;

@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign, getter = hasFinishedAnimating) BOOL finishedAnimating;

@end

@implementation RecordingCircleOverlayView

- (id)initWithFrame:(CGRect)frame strokeWidth:(CGFloat)strokeWidth insets:(UIEdgeInsets)insets
{
    if (self = [super initWithFrame:frame])
    {
        self.duration = 45.f;
        self.strokeWidth = strokeWidth;
        self.progressLayers = [NSMutableArray array];
        
        CGPoint arcCenter = CGPointMake(CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds));
        CGFloat radius = CGRectGetMidX(self.bounds) - insets.top - insets.bottom;
        
        self.circlePath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                         radius:radius
                                                     startAngle:M_PI
                                                       endAngle:-M_PI
                                                      clockwise:NO];
        [self addBackgroundLayer];
    }
    return self;
}

- (void)addBackgroundLayer
{
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = self.circlePath.CGPath;
    backgroundLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    backgroundLayer.fillColor = [[UIColor clearColor] CGColor];
    backgroundLayer.lineWidth = self.strokeWidth;
    
    [self.layer addSublayer:backgroundLayer];
}

- (void)addNewLayer
{
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.path = self.circlePath.CGPath;
    progressLayer.strokeColor = [[self randomColor] CGColor];
    progressLayer.fillColor = [[UIColor clearColor] CGColor];
    progressLayer.lineWidth = self.strokeWidth;
    progressLayer.strokeEnd = 0.f;
    
    [self.layer addSublayer:progressLayer];
    [self.progressLayers addObject:progressLayer];
    
    self.currentProgressLayer = progressLayer;
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.f];
}

- (void)updateAnimations
{    
    CGFloat duration = self.duration * (1.f - [[self.progressLayers firstObject] strokeEnd]);
    CGFloat strokeEndFinal = 1.f;
    
    for (CAShapeLayer *progressLayer in self.progressLayers)
    {
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.duration = duration;
        strokeEndAnimation.fromValue = @(progressLayer.strokeEnd);
        strokeEndAnimation.toValue = @(strokeEndFinal);
        strokeEndAnimation.autoreverses = NO;
        strokeEndAnimation.repeatCount = 0.f;
        strokeEndAnimation.fillMode = kCAFillModeForwards;
        strokeEndAnimation.removedOnCompletion = NO;
        strokeEndAnimation.delegate = self;
        [progressLayer addAnimation:strokeEndAnimation forKey:@"strokeEndAnimation"];
        
        strokeEndFinal -= (progressLayer.strokeEnd - progressLayer.strokeStart);
        
        if (progressLayer != self.currentProgressLayer)
        {
            CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            strokeStartAnimation.duration = duration;
            strokeStartAnimation.fromValue = @(progressLayer.strokeStart);
            strokeStartAnimation.toValue = @(strokeEndFinal);
            strokeStartAnimation.autoreverses = NO;
            strokeStartAnimation.repeatCount = 0.f;
            strokeStartAnimation.fillMode = kCAFillModeForwards;
            strokeStartAnimation.removedOnCompletion = NO;
            [progressLayer addAnimation:strokeStartAnimation forKey:@"strokeStartAnimation"];
        }
    }
}

- (void)removeAnimations
{
    for (CAShapeLayer *progressLayer in self.progressLayers)
    {
        progressLayer.strokeStart = [progressLayer.presentationLayer strokeStart];
        progressLayer.strokeEnd = [progressLayer.presentationLayer strokeEnd];
        [progressLayer removeAllAnimations];
    }
}

#pragma UIResponder overrides

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.hasFinishedAnimating == NO)
    {
        [self addNewLayer];
        [self updateAnimations];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.hasFinishedAnimating == NO)
    {
        [self removeAnimations];
    }
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.hasFinishedAnimating == NO && flag)
    {
        [self removeAnimations];
        self.finishedAnimating = flag;
    }
}

@end

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
@property (nonatomic, strong) UIBezierPath *circlePath;

@property (nonatomic, strong) CAShapeLayer *currentProgressLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign, getter = isCircleComplete) BOOL circleComplete;

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
    self.backgroundLayer = [CAShapeLayer layer];
    self.backgroundLayer.path = self.circlePath.CGPath;
    self.backgroundLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    self.backgroundLayer.fillColor = [[UIColor clearColor] CGColor];
    self.backgroundLayer.lineWidth = self.strokeWidth;
    
    [self.layer addSublayer:self.backgroundLayer];
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
        CABasicAnimation *strokeEndAnimation = nil;
        strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.duration = duration;
        strokeEndAnimation.fromValue = @(progressLayer.strokeEnd);
        strokeEndAnimation.toValue = @(strokeEndFinal);
        strokeEndAnimation.autoreverses = NO;
        strokeEndAnimation.repeatCount = 0.f;
        
        CGFloat previousStrokeEnd = progressLayer.strokeEnd;
        progressLayer.strokeEnd = strokeEndFinal;
        
        [progressLayer addAnimation:strokeEndAnimation forKey:@"strokeEndAnimation"];
        
        strokeEndFinal -= (previousStrokeEnd - progressLayer.strokeStart);
        
        if (progressLayer != self.currentProgressLayer)
        {
            CABasicAnimation *strokeStartAnimation = nil;
            strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            strokeStartAnimation.duration = duration;
            strokeStartAnimation.fromValue = @(progressLayer.strokeStart);
            strokeStartAnimation.toValue = @(strokeEndFinal);
            strokeStartAnimation.autoreverses = NO;
            strokeStartAnimation.repeatCount = 0.f;
            
            progressLayer.strokeStart = strokeEndFinal;
            
            [progressLayer addAnimation:strokeStartAnimation forKey:@"strokeStartAnimation"];
        }
    }
    
    CABasicAnimation *backgroundLayerAnimation = nil;
    backgroundLayerAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    backgroundLayerAnimation.duration = duration;
    backgroundLayerAnimation.fromValue = @(self.backgroundLayer.strokeStart);
    backgroundLayerAnimation.toValue = @(1.f);
    backgroundLayerAnimation.autoreverses = NO;
    backgroundLayerAnimation.repeatCount = 0.f;
    backgroundLayerAnimation.delegate = self;
    
    self.backgroundLayer.strokeStart = 1.0;
    
    [self.backgroundLayer addAnimation:backgroundLayerAnimation forKey:@"strokeStartAnimation"];
}

- (void)updateLayerModelsForPresentationState
{
    for (CAShapeLayer *progressLayer in self.progressLayers)
    {
        progressLayer.strokeStart = [progressLayer.presentationLayer strokeStart];
        progressLayer.strokeEnd = [progressLayer.presentationLayer strokeEnd];
        [progressLayer removeAllAnimations];
    }
    
    self.backgroundLayer.strokeStart = [self.backgroundLayer.presentationLayer strokeStart];
    [self.backgroundLayer removeAllAnimations];
}

#pragma UIResponder overrides

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isCircleComplete == NO)
    {
        [self addNewLayer];
        [self updateAnimations];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isCircleComplete == NO)
    {
        [self updateLayerModelsForPresentationState];
    }
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.isCircleComplete == NO && flag)
    {
        self.circleComplete = flag;
    }
}

@end

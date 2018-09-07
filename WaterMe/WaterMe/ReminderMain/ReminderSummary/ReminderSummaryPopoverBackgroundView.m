//
//  ReminderSummaryPopoverBackgroundView.m
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/6/18.
//  Copyright © 2018 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ReminderSummaryPopoverBackgroundView.h"

@interface ReminderSummaryPopoverBackgroundView ()
{
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@property (nonatomic, weak, nullable) UIView* myArrowView;
@property (nonatomic, weak, nullable) CALayer* myArrowViewMaskLayer;
@property (nonatomic, weak, nullable) NSLayoutConstraint* horizontalArrowConstraint;
@property (nonatomic, weak, nullable) NSLayoutConstraint* verticalArrowConstraint;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* upConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* downConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* leadingConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* trailingConstraints;

@end

@implementation ReminderSummaryPopoverBackgroundView

@dynamic arrowOffset, arrowDirection, wantsDefaultContentAppearance;

// MARK: Required of Implementers

+ (UIEdgeInsets)contentViewInsets;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
+ (CGFloat)arrowHeight;
{
    return 30;
}
+ (CGFloat)arrowBase;
{
    return 50;
}
+ (BOOL)wantsDefaultContentAppearance;
{
    return NO;
}
- (CGFloat)arrowOffset;
{
    return _arrowOffset;
}
- (void)setArrowOffset:(CGFloat)arrowOffset;
{
    _arrowOffset = arrowOffset;
    [self updateArrowConstraintsForOffset];
}
- (UIPopoverArrowDirection)arrowDirection;
{
    return _arrowDirection;
}
- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection;
{
    _arrowDirection = arrowDirection;
    [self enableDisableConstraintsForArrowDirection];
}

// MARK: Sneakiness to get desired look

- (CGFloat)_shadowOpacity;
{
    return 0.1;
}

- (void)didMoveToWindow;
{
    [super didMoveToWindow];
    if (![self myArrowView]) {
        [self configureArrowViewConstraints];
        [self updateArrowConstraintsForOffset];
        [self configureArrowMaskLayer];
        [self enableDisableConstraintsForArrowDirection];
    }
    [[self layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self layer] setBorderWidth:1];
}

- (void)configureArrowViewConstraints;
{
    // Create and Add the View
    UIVisualEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIView* view = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self setMyArrowView:view];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];

    // Configure height and width constraints
    // And add them. These never change
    NSLayoutConstraint* arrowWidthConstraint = [[view widthAnchor] constraintEqualToConstant:[self aB]];
    NSLayoutConstraint* arrowHeightConstraint = [[view heightAnchor] constraintEqualToConstant:[self aH]];
    [self addConstraints:@[arrowWidthConstraint, arrowHeightConstraint]];

    // Configure left/right/top/bottom attachments
    // But don't add them, these change
    NSLayoutConstraint* upDownSlide = [[view centerXAnchor] constraintEqualToAnchor:[self centerXAnchor] constant:0];
    NSLayoutConstraint* leftRightSlide = [[view centerYAnchor] constraintEqualToAnchor:[self centerYAnchor] constant:0];
    NSLayoutConstraint* upAttach = [[view topAnchor] constraintEqualToAnchor:[self topAnchor] constant:0];
    NSLayoutConstraint* downAttach = [[view bottomAnchor] constraintEqualToAnchor:[self bottomAnchor] constant:0];
    NSLayoutConstraint* leadAttach = [[view leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:0];
    NSLayoutConstraint* trailAttach = [[view trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:0];

    // Store them in the appropriate properties
    // These need to change dynamically
    [self setUpConstraints:@[upDownSlide, upAttach]];
    [self setDownConstraints:@[upDownSlide, downAttach]];
    [self setLeadingConstraints:@[leadAttach, leftRightSlide]];
    [self setTrailingConstraints:@[trailAttach, leftRightSlide]];
    [self setHorizontalArrowConstraint:leftRightSlide];
    [self setVerticalArrowConstraint:upDownSlide];
}

- (void)enableDisableConstraintsForArrowDirection;
{
    // if the arrow view has not been configured yet, bail
    if (![self myArrowView]) { return; }

    [self removeConstraints:[self upConstraints]];
    [self removeConstraints:[self downConstraints]];
    [self removeConstraints:[self leadingConstraints]];
    [self removeConstraints:[self trailingConstraints]];
    CGAffineTransform leftRightRotation;
    CGAffineTransform leftRightRotationAndTranslation;
    switch ([self arrowDirection]) {
        case UIPopoverArrowDirectionAny:
        case UIPopoverArrowDirectionUnknown:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unexpected Arrow Direction"
                                         userInfo:nil];
        case UIPopoverArrowDirectionUp:
            [[self myArrowView] setTransform:CGAffineTransformIdentity];
            [self addConstraints:[self upConstraints]];
            break;
        case UIPopoverArrowDirectionDown:
            [[self myArrowView] setTransform:CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0)];
            [self addConstraints:[self downConstraints]];
            break;
        case UIPopoverArrowDirectionLeft:
            leftRightRotation = CGAffineTransformMakeRotation((-90 * M_PI) / 180.0);
            leftRightRotationAndTranslation = CGAffineTransformTranslate(leftRightRotation, 0, ([self aH] - [self aB])/2);
            [[self myArrowView] setTransform:leftRightRotationAndTranslation];
            [self addConstraints:[self leadingConstraints]];
            break;
        case UIPopoverArrowDirectionRight:
            leftRightRotation = CGAffineTransformMakeRotation((90 * M_PI) / 180.0);
            leftRightRotationAndTranslation = CGAffineTransformTranslate(leftRightRotation, 0, ([self aH] - [self aB])/2);
            [[self myArrowView] setTransform:leftRightRotationAndTranslation];
            [self addConstraints:[self trailingConstraints]];
            break;
    }
}

- (void)updateArrowConstraintsForOffset;
{
    [[self horizontalArrowConstraint] setConstant:[self arrowOffset]];
    [[self verticalArrowConstraint] setConstant:[self arrowOffset]];
}

- (void)configureArrowMaskLayer;
{
    [[self myArrowViewMaskLayer] removeFromSuperlayer];
    [self setMyArrowViewMaskLayer:nil];
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake([self aG], [self aH])];
    [path addLineToPoint:CGPointMake([self aB] / 2, [self aG])];
    [path addLineToPoint:CGPointMake([self aB], [self aH])];
    [path closePath];
    CAShapeLayer* mask = [[CAShapeLayer alloc] init];
    [mask setPath:[path CGPath]];
    [mask setFillColor:[[UIColor blackColor] CGColor]];
    [mask setFillRule:kCAFillRuleNonZero];
    [[[self myArrowView] layer] setMask:mask];
    [self setMyArrowViewMaskLayer:mask];
    [mask setPosition: [[[self myArrowView] layer] position]];
}

- (CGFloat)aG;
{
    return 2;
}

- (CGFloat)aH;
{
    return [ReminderSummaryPopoverBackgroundView arrowHeight] - [self aG];
}

- (CGFloat)aB;
{
    return [ReminderSummaryPopoverBackgroundView arrowBase] - [self aG];
}

@end

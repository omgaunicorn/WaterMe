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

@property (nonatomic, weak) UIView*_Nullable myArrowView;
@property (nonatomic, weak) NSLayoutConstraint*_Nullable horizontalArrowConstraint;
@property (nonatomic, weak) NSLayoutConstraint*_Nullable verticalArrowConstraint;
@property (nonatomic, strong) NSArray<NSLayoutConstraint*>*_Nonnull upConstraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint*>*_Nonnull downConstraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint*>*_Nonnull leadingConstraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint*>*_Nonnull trailingConstraints;

@end

@implementation ReminderSummaryPopoverBackgroundView

@dynamic arrowOffset, arrowDirection, wantsDefaultContentAppearance;

// MARK: Required of Implementers

+ (CGFloat)arrowBase;
{
    return 40;
}
+ (UIEdgeInsets)contentViewInsets;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
+ (CGFloat)arrowHeight;
{
    return 40;
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
        [self configureMyArrowView];
        [self enableDisableConstraintsForArrowDirection];
        [self updateArrowConstraintsForOffset];
    }
    [[self layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self layer] setBorderWidth:1];
}

- (void)configureMyArrowView;
{
    UIVisualEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIView* view = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self setMyArrowView:view];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    [self addConstraints:@[
                           [[view widthAnchor] constraintEqualToConstant:40],
                           [[view heightAnchor] constraintEqualToConstant:40],
                           ]];
    NSLayoutConstraint* upDownSlide = [[view centerXAnchor] constraintEqualToAnchor:[self centerXAnchor]];
    NSLayoutConstraint* leftRightSlide = [[view centerYAnchor] constraintEqualToAnchor:[self centerYAnchor]];
    NSLayoutConstraint* upAttach = [[view topAnchor] constraintEqualToAnchor:[self topAnchor]];
    NSLayoutConstraint* downAttach = [[view bottomAnchor] constraintEqualToAnchor:[self bottomAnchor]];
    NSLayoutConstraint* leadAttach = [[view leadingAnchor] constraintEqualToAnchor:[self leadingAnchor]];
    NSLayoutConstraint* trailAttach = [[view trailingAnchor] constraintEqualToAnchor:[self trailingAnchor]];
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
    switch ([self arrowDirection]) {
        case UIPopoverArrowDirectionAny:
        case UIPopoverArrowDirectionUnknown:
            assert(NO);
            break;
        case UIPopoverArrowDirectionUp:
            [self addConstraints:[self upConstraints]];
            break;
        case UIPopoverArrowDirectionDown:
            [self addConstraints:[self downConstraints]];
            break;
        case UIPopoverArrowDirectionLeft:
            [self addConstraints:[self leadingConstraints]];
            break;
        case UIPopoverArrowDirectionRight:
            [self addConstraints:[self trailingConstraints]];
            break;
    }
}

- (void)updateArrowConstraintsForOffset;
{
    [[self horizontalArrowConstraint] setConstant:[self arrowOffset]];
    [[self verticalArrowConstraint] setConstant:[self arrowOffset]];
}

@end

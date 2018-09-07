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

@property (nonatomic, weak) UIView* myArrowView;
@property (nonatomic, weak) NSLayoutConstraint* myArrowHorizontalOffsetConstraint;

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
    [[self myArrowHorizontalOffsetConstraint] setConstant:arrowOffset];
    [self setNeedsLayout];
}
- (UIPopoverArrowDirection)arrowDirection;
{
    return _arrowDirection;
}
- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection;
{
    _arrowDirection = arrowDirection;
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
    NSLayoutConstraint* horizontalOffsetConstraint = [[view centerXAnchor] constraintEqualToAnchor:[self centerXAnchor] constant:[self arrowOffset]];
    [self setMyArrowHorizontalOffsetConstraint:horizontalOffsetConstraint];
    [self addConstraints:@[
                           [[view widthAnchor] constraintEqualToConstant:40],
                           [[view heightAnchor] constraintEqualToConstant:40],
                           horizontalOffsetConstraint,
                           [[view topAnchor] constraintEqualToAnchor:[self topAnchor] constant:0]
                           ]];
}

@end

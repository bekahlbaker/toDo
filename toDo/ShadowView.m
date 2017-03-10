//
//  ShadowView.m
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "ShadowView.h"

@implementation ShadowView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    UIColor *color = [UIColor darkGrayColor];
    CGColorRef gray = color.CGColor;
    self.layer.shadowColor = gray;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 1;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.masksToBounds = NO;
}

@end

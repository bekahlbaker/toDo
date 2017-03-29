//
//  RoundedLabel.m
//  toDo
//
//  Created by Rebekah Baker on 3/29/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "RoundedLabel.h"

@implementation RoundedLabel

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8;
}

@end

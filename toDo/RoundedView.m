//
//  RoundedView.m
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "RoundedView.h"

@implementation RoundedView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8;
}

@end

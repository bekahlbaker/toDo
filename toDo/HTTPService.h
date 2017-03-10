//
//  HTTPService.h
//  toDo
//
//  Created by Rebekah Baker on 3/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^onComplete)(NSArray * _Nullable dataArray, NSString * _Nullable errMessage);

@interface HTTPService : NSObject

+ (id) instance;
- (void) getToDoItems: (nullable onComplete)completionHandler;

@end

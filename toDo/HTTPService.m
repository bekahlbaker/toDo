//
//  HTTPService.m
//  toDo
//
//  Created by Rebekah Baker on 3/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "HTTPService.h"

#define URL_BASE "http://localhost:8000"
#define URL_ITEMS "/toDoItems"

@implementation HTTPService

+ (id) instance {
    static HTTPService *sharedInstance = nil;
    
    @synchronized (self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc]init];
    }
    return sharedInstance;
}

- (void) getToDoItems:(nullable onComplete)completionHandler {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s", URL_BASE, URL_ITEMS]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
        
    }] resume];
}
@end


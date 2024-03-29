//
//  AppDelegate.m
//  OCTest
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ACRequestParameters *params = [[ACRequestParameters alloc] init];
    [params addFormParamStringValue:@"dQAXWbcv" forKey:@"fling_hash"];
    
    ACRestfulAPI *caller = [ACRestfulAPI restfulAPICallerWithAPI:[ACAPI APIWithPath:@"fling" HTTPMethod:ACHTTPMethodGET] params:params];
    
    [caller addJSONResponseHandler:^(id _Nullable JSONObject, NSURLResponse * _Nullable response) {
        NSLog(@"JSONOBject:%@", JSONObject);
    }];
    
    [caller addTextResponseHandler:^(NSString * _Nonnull text, NSURLResponse * _Nullable response) {
        NSLog(@"text:%@",text);
    }];

    [caller setFailedResponseHandler:^(NSData * _Nullable failedData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"failed: %@, error:%@",failedData, error);
    }];
    
    [caller setRecevingProcessHandler:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
        NSLog(@"%ld, %ld, %ld", bytes, totalBytes, totalBytesExpected);
    }];
    
    [caller run:NSURLCacheStorageAllowed priority:ACQueuePriorityDefault];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@""];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://www.google.com.tw"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    
    
    [dataTask resume];
    [dataTask cancel];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

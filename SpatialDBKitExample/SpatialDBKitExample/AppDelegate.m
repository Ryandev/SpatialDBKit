//
//  AppDelegate.m
//  SpatialDBKitExample
//
//  Created by Andrea Cremaschi on 04/12/14.
//  Copyright (c) 2014 acremaschi. All rights reserved.
//

#import "AppDelegate.h"

#import <SpatialDBKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *sqliteVersion = [SpatialDatabase sqliteLibVersion];
    NSLog(@"sqlite version: %@", sqliteVersion);
    
    NSString *spatialiteVersion = [SpatialDatabase spatialiteLibVersion];
    NSLog(@"spatialite version: %@", spatialiteVersion);
    
    // test spatialite AsText function -> ShapeKit object import
    SpatialDatabase *db = [SpatialDatabase databaseWithPath: [[NSBundle mainBundle] pathForResource:@"Assets/test-2.3" ofType:@"sqlite"]] ;
    [db open];
    FMResultSet *rs = [db executeQuery:@"select AsText(geometry) AS text FROM Regions WHERE PK_UID = 106"];
    while ([rs next])
    {
        id object = [rs resultDictionary];
        
        NSLog(@"%@", object);
    }
    
    // test spatialite fetch function -> ShapeKit WKB object import
    SpatialDatabase *db3 = [SpatialDatabase databaseWithPath: [[NSBundle mainBundle] pathForResource:@"Assets/test-2.3" ofType:@"sqlite"]] ;
    [db3 open];
    FMResultSet *rs3 = [db executeQuery:@"select geometry FROM Regions WHERE PK_UID = 106"];
    ShapeKitGeometry* geom = nil;
    while ([rs3 next])
    {
        NSDictionary * object = [rs3 resultDictionary];
        if ((!geom) && ([object objectForKey:@"geometry"]))
            geom=[object objectForKey:@"geometry"]; // get the route geom for future use
        
        NSLog(@"%@", object);
    }
    
    // test ShapeKit topology functions
    NSLog(@"Route boundary: %@", geom.boundary);
    NSLog(@"Route cascaded union : %@", [(ShapeKitMultiPolygon *)geom cascadedUnion]);
    
    // test VirtualNetwork module for Dijkstra-based routing
    SpatialDatabase *db2 = [SpatialDatabase databaseWithPath: [[NSBundle mainBundle] pathForResource:@"Assets/test-network-2.3" ofType:@"sqlite"]] ;
    [db2 open];
    FMResultSet *rs2 = [db2 executeQuery:@"SELECT * AS WKT_geometry  \
                        FROM Roads_net \
                        WHERE NodeFrom = 1 AND NodeTo = 512;"];
    while ([rs2 next])
    {
        id object = [rs2 resultDictionary];
        
        NSLog(@"%@", object);
    }
    
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

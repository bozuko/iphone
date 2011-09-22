//
//  BozukoAppDelegate.m
//  Bozuko
//
//  Created by Tom Corwine on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoAppDelegate.h"
#import "RootViewController.h"

@implementation BozukoAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	_rootViewController = [[RootViewController alloc] init];
	[self.window addSubview:_rootViewController.view];
	
	[self.window makeKeyAndVisible];
	
	// Delete files in image cache if they haven't been used in 60 days. Files are touched every time they're read.
	NSString *tmpDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *tmpPath = [[NSString alloc] initWithFormat:@"%@/imageCache", tmpDocumentsDirectory];
	
	NSArray *tmpArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpPath error:nil];
	[tmpPath release];
	
	for (NSString *tmpFile in tmpArray)
	{
		NSString *tmpFilePath = [NSString stringWithFormat:@"%@/%@", tmpDocumentsDirectory, tmpFile];
		NSDictionary *tmpFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpFilePath error:nil];
		
		NSDate *tmpFileModifiedDate = [tmpFileAttributesDictionary fileModificationDate];
		NSTimeInterval tmpTimeInterval = [tmpFileModifiedDate timeIntervalSinceNow];
		
		if (tmpTimeInterval < -5184000) //5,184,000 seconds is 60 days
			[[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
	}

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

- (void)dealloc
{
	[_rootViewController release];
	[_window release];
    [super dealloc];
}

@end

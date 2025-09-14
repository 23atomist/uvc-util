//
//  AppDelegate.m
//  UVCCameraGUI
//
//  Created by UVC Camera GUI Tool
//
// Copyright (2025) Thomas Gallaway (github:atomist23)
// Portions copyright (c) Dr. Jeffrey Frey, IT-NSS, 2016, licensed under the MIT License.
//
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create the main window
    NSRect windowFrame = NSMakeRect(100, 100, 800, 600);
    self.window = [[NSWindow alloc] initWithContentRect:windowFrame
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setTitle:@"UVC Camera Control"];
    [self.window setMinSize:NSMakeSize(600, 400)];
    
    // Create and set the main view controller
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [self.window setContentViewController:mainViewController];
    [mainViewController release];
    
    // Activate the application and show the window
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    
    NSLog(@"UVC Camera GUI launched successfully");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

@end
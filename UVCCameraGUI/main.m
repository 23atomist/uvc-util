//
//  main.m
//  UVCCameraGUI
//
//  Created by UVC Camera GUI Tool
//
// Copyright (2025) Thomas Gallaway (github:atomist23)
// Portions copyright (c) Dr. Jeffrey Frey, IT-NSS, 2016, licensed under the MIT License.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        
        // Ensure this is a regular GUI application (not background)
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        
        NSLog(@"Starting UVC Camera GUI application...");
        
        [app run];
        
        [delegate release];
    }
    
    return 0;
}
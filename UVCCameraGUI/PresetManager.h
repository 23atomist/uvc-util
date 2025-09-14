//
//  PresetManager.h
//  UVCCameraGUI
//
//  Created by UVC Camera GUI Tool
//
// Copyright (2025) Thomas Gallaway (github:atomist23)
// Portions copyright (c) Dr. Jeffrey Frey, IT-NSS, 2016, licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface PresetManager : NSObject

- (BOOL)savePreset:(NSDictionary *)preset toFile:(NSString *)filePath;
- (NSDictionary *)loadPresetFromFile:(NSString *)filePath;

@end
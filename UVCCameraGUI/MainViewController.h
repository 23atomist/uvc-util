//
//  MainViewController.h
//  UVCCameraGUI
//
//  Created by UVC Camera GUI Tool
//
// Copyright (2025) Thomas Gallaway (github:atomist23)
// Portions copyright (c) Dr. Jeffrey Frey, IT-NSS, 2016, licensed under the MIT License.
//

#import <Cocoa/Cocoa.h>
#import "UVCController.h"
#import "PresetManager.h"

@interface MainViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSArray *_availableControls;
}

@property (nonatomic, strong) IBOutlet NSPopUpButton *cameraPopUp;
@property (nonatomic, strong) IBOutlet NSTableView *controlsTableView;
@property (nonatomic, strong) IBOutlet NSScrollView *controlsScrollView;
@property (nonatomic, strong) IBOutlet NSButton *refreshCamerasButton;
@property (nonatomic, strong) IBOutlet NSButton *loadPresetButton;
@property (nonatomic, strong) IBOutlet NSButton *savePresetButton;
@property (nonatomic, strong) IBOutlet NSTextField *statusLabel;

@property (nonatomic, strong) NSArray *cameras;
@property (nonatomic, strong) UVCController *selectedCamera;
@property (nonatomic, strong) NSArray *availableControls;
@property (nonatomic, strong) PresetManager *presetManager;
@property (nonatomic, strong) NSMutableDictionary *controlSliders;

- (IBAction)cameraSelectionChanged:(id)sender;
- (IBAction)refreshCameras:(id)sender;
- (IBAction)loadPreset:(id)sender;
- (IBAction)savePreset:(id)sender;
- (void)refreshCameraList;
- (void)refreshControlsList;
- (void)updateControlValue:(NSSlider *)slider;

@end
//
//  MainViewController.m
//  UVCCameraGUI
//
//  Created by UVC Camera GUI Tool
//
// Copyright (2025) Thomas Gallaway (github:atomist23)
// Portions copyright (c) Dr. Jeffrey Frey, IT-NSS, 2016, licensed under the MIT License.
//

#import "MainViewController.h"
#import <objc/runtime.h>

@interface MainViewController ()
@property (nonatomic, strong) NSView *controlsContainerView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize properties
    self.cameras = @[];
    self.availableControls = @[];
    self.controlSliders = [[NSMutableDictionary alloc] init];
    self.presetManager = [[PresetManager alloc] init];
    
    [self setupUI];
    [self refreshCameras:nil];
}

- (void)setupUI {
    // Create main container view
    NSView *mainView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
    [self setView:mainView];
    [mainView release];
    
    // Create camera selection section
    [self createCameraSelectionUI];
    
    // Create controls section
    [self createControlsUI];
    
    // Create preset buttons
    [self createPresetUI];
    
    // Create status label
    [self createStatusUI];
}

- (void)createCameraSelectionUI {
    NSView *mainView = [self view];
    
    // Camera label
    NSTextField *cameraLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 550, 100, 20)];
    [cameraLabel setStringValue:@"Camera:"];
    [cameraLabel setBezeled:NO];
    [cameraLabel setDrawsBackground:NO];
    [cameraLabel setEditable:NO];
    [cameraLabel setSelectable:NO];
    [mainView addSubview:cameraLabel];
    [cameraLabel release];
    
    // Camera popup button
    self.cameraPopUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(130, 545, 400, 30)];
    [self.cameraPopUp setTarget:self];
    [self.cameraPopUp setAction:@selector(cameraSelectionChanged:)];
    [mainView addSubview:self.cameraPopUp];
    
    // Refresh button
    self.refreshCamerasButton = [[NSButton alloc] initWithFrame:NSMakeRect(540, 545, 100, 30)];
    [self.refreshCamerasButton setTitle:@"Refresh"];
    [self.refreshCamerasButton setTarget:self];
    [self.refreshCamerasButton setAction:@selector(refreshCameras:)];
    [mainView addSubview:self.refreshCamerasButton];
}

- (void)createControlsUI {
    NSView *mainView = [self view];
    
    // Controls label
    NSTextField *controlsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 500, 150, 20)];
    [controlsLabel setStringValue:@"Camera Controls:"];
    [controlsLabel setBezeled:NO];
    [controlsLabel setDrawsBackground:NO];
    [controlsLabel setEditable:NO];
    [controlsLabel setSelectable:NO];
    [mainView addSubview:controlsLabel];
    [controlsLabel release];
    
    // Controls scroll view
    self.controlsScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 100, 760, 390)];
    [self.controlsScrollView setHasVerticalScroller:YES];
    [self.controlsScrollView setHasHorizontalScroller:NO];
    [self.controlsScrollView setBorderType:NSBezelBorder];
    [mainView addSubview:self.controlsScrollView];
    
    // Controls container view
    self.controlsContainerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 740, 390)];
    [self.controlsScrollView setDocumentView:self.controlsContainerView];
}

- (void)createPresetUI {
    NSView *mainView = [self view];
    
    // Load preset button
    self.loadPresetButton = [[NSButton alloc] initWithFrame:NSMakeRect(20, 60, 120, 30)];
    [self.loadPresetButton setTitle:@"Load Preset"];
    [self.loadPresetButton setTarget:self];
    [self.loadPresetButton setAction:@selector(loadPreset:)];
    [mainView addSubview:self.loadPresetButton];
    
    // Save preset button
    self.savePresetButton = [[NSButton alloc] initWithFrame:NSMakeRect(150, 60, 120, 30)];
    [self.savePresetButton setTitle:@"Save Preset"];
    [self.savePresetButton setTarget:self];
    [self.savePresetButton setAction:@selector(savePreset:)];
    [mainView addSubview:self.savePresetButton];
}

- (void)createStatusUI {
    NSView *mainView = [self view];
    
    // Status label
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 20, 760, 20)];
    [self.statusLabel setStringValue:@"Ready"];
    [self.statusLabel setBezeled:NO];
    [self.statusLabel setDrawsBackground:NO];
    [self.statusLabel setEditable:NO];
    [self.statusLabel setSelectable:NO];
    [self.statusLabel setTextColor:[NSColor secondaryLabelColor]];
    [mainView addSubview:self.statusLabel];
}

- (IBAction)refreshCameras:(id)sender {
    [self refreshCameraList];
}

- (void)refreshCameraList {
    [self.statusLabel setStringValue:@"Scanning for UVC cameras..."];
    
    // Get list of UVC controllers
    NSArray *controllers = [UVCController uvcControllers];
    
    if (controllers && [controllers count] > 0) {
        self.cameras = controllers;
        
        // Update popup button
        [self.cameraPopUp removeAllItems];
        for (UVCController *controller in self.cameras) {
            NSString *deviceName = [controller deviceName];
            if (!deviceName) {
                deviceName = [NSString stringWithFormat:@"Camera (VID:0x%04X PID:0x%04X)", 
                             [controller vendorId], [controller productId]];
            }
            [self.cameraPopUp addItemWithTitle:deviceName];
        }
        
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"Found %ld UVC camera(s)", [self.cameras count]]];
        
        // Select first camera by default
        if ([self.cameras count] > 0) {
            [self.cameraPopUp selectItemAtIndex:0];
            [self cameraSelectionChanged:nil];
        }
    } else {
        self.cameras = @[];
        [self.cameraPopUp removeAllItems];
        [self.statusLabel setStringValue:@"No UVC cameras found"];
        [self clearControls];
    }
}

- (IBAction)cameraSelectionChanged:(id)sender {
    NSInteger selectedIndex = [self.cameraPopUp indexOfSelectedItem];
    
    if (selectedIndex >= 0 && (NSUInteger)selectedIndex < [self.cameras count]) {
        self.selectedCamera = [self.cameras objectAtIndex:selectedIndex];
        [self refreshControlsList];
    } else {
        self.selectedCamera = nil;
        [self clearControls];
    }
}

- (void)refreshControlsList {
    if (!self.selectedCamera) {
        [self clearControls];
        return;
    }
    
    [self.statusLabel setStringValue:@"Loading camera controls..."];
    NSLog(@"DEBUG: Starting to load controls for camera: %@", [self.selectedCamera deviceName]);
    
    // Open interface if needed
    if (![self.selectedCamera isInterfaceOpen]) {
        NSLog(@"DEBUG: Opening camera interface...");
        [self.selectedCamera setIsInterfaceOpen:YES];
    }
    
    if (![self.selectedCamera isInterfaceOpen]) {
        [self.statusLabel setStringValue:@"Error: Cannot open camera interface"];
        NSLog(@"ERROR: Failed to open camera interface");
        return;
    }
    
    // Get available controls
    NSArray *controlNames = [self.selectedCamera controlStrings];
    NSLog(@"DEBUG: Found %ld control names: %@", [controlNames count], controlNames);
    
    if ([controlNames count] == 0) {
        [self.statusLabel setStringValue:@"No controls available for this camera"];
        NSLog(@"DEBUG: No control names found");
        return;
    }
    
    NSMutableArray *validControls = [[NSMutableArray alloc] init];
    
    for (NSString *controlName in controlNames) {
        NSLog(@"DEBUG: Checking control: %@", controlName);
        UVCControl *control = [self.selectedCamera controlWithName:controlName];
        if (control) {
            NSLog(@"DEBUG: Control %@ - supportsGet: %d, supportsSet: %d",
                  controlName, [control supportsGetValue], [control supportsSetValue]);
            if ([control supportsGetValue] && [control supportsSetValue]) {
                [validControls addObject:control];
                NSLog(@"DEBUG: Added valid control: %@", controlName);
            }
        } else {
            NSLog(@"DEBUG: Failed to get control object for: %@", controlName);
        }
    }
    
    self.availableControls = [NSArray arrayWithArray:validControls];
    [validControls release];
    
    NSLog(@"DEBUG: Found %ld valid controls", [self.availableControls count]);
    NSLog(@"DEBUG: availableControls array: %@", self.availableControls);
    
    [self createControlSliders];
    
    [self.statusLabel setStringValue:[NSString stringWithFormat:@"Loaded %ld controls for %@",
                                    [self.availableControls count], [self.selectedCamera deviceName]]];
}

- (void)clearControls {
    // Remove all control views
    NSArray *subviews = [[self.controlsContainerView subviews] copy];
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    [self.controlSliders removeAllObjects];
    // Don't clear availableControls here - only clear UI elements
}

- (void)createControlSliders {
    [self clearControls];
    
    NSLog(@"DEBUG: createControlSliders called with %ld controls", [self.availableControls count]);
    NSLog(@"DEBUG: availableControls in createControlSliders: %@", self.availableControls);
    
    if ([self.availableControls count] == 0) {
        NSLog(@"DEBUG: No controls to create sliders for");
        return;
    }
    
    CGFloat yPosition = 0;
    CGFloat rowHeight = 50;
    
    for (NSInteger i = [self.availableControls count] - 1; i >= 0; i--) {
        UVCControl *control = [self.availableControls objectAtIndex:i];
        
        NSLog(@"DEBUG: Creating slider for control: %@", [control controlName]);
        
        // Create control row
        [self createControlRow:control atY:yPosition];
        yPosition += rowHeight;
    }
    
    // Update container view height
    NSRect containerFrame = [self.controlsContainerView frame];
    containerFrame.size.height = MAX(yPosition, [self.controlsScrollView frame].size.height);
    [self.controlsContainerView setFrame:containerFrame];
    
    NSLog(@"DEBUG: Created UI with container height: %f", containerFrame.size.height);
}

- (void)createControlRow:(UVCControl *)control atY:(CGFloat)yPos {
    NSString *controlName = [control controlName];
    UVCValue *currentValue = [control currentValue];
    UVCValue *minimum = [control minimum];
    UVCValue *maximum = [control maximum];
    
    if (!currentValue || !minimum || !maximum) {
        return;
    }
    
    // Create label
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, yPos + 15, 200, 20)];
    [label setStringValue:controlName];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    [self.controlsContainerView addSubview:label];
    [label release];
    
    // Get numeric values for slider
    double minVal = [self getNumericValue:minimum];
    double maxVal = [self getNumericValue:maximum];
    double curVal = [self getNumericValue:currentValue];
    
    // Create slider
    NSSlider *slider = [[NSSlider alloc] initWithFrame:NSMakeRect(220, yPos + 15, 300, 20)];
    [slider setMinValue:minVal];
    [slider setMaxValue:maxVal];
    [slider setDoubleValue:curVal];
    [slider setTarget:self];
    [slider setAction:@selector(sliderChanged:)];
    [slider setContinuous:YES];
    [self.controlsContainerView addSubview:slider];
    
    // Store slider reference with control name
    [self.controlSliders setObject:slider forKey:controlName];
    
    // Create value label
    NSTextField *valueLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(530, yPos + 15, 80, 20)];
    [valueLabel setStringValue:[NSString stringWithFormat:@"%.0f", curVal]];
    [valueLabel setBezeled:NO];
    [valueLabel setDrawsBackground:NO];
    [valueLabel setEditable:NO];
    [valueLabel setSelectable:NO];
    [valueLabel setAlignment:NSTextAlignmentCenter];
    [self.controlsContainerView addSubview:valueLabel];
    [valueLabel release];
    
    // Create min/max labels
    NSTextField *minLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(620, yPos + 15, 50, 20)];
    [minLabel setStringValue:[NSString stringWithFormat:@"%.0f", minVal]];
    [minLabel setBezeled:NO];
    [minLabel setDrawsBackground:NO];
    [minLabel setEditable:NO];
    [minLabel setSelectable:NO];
    [minLabel setTextColor:[NSColor secondaryLabelColor]];
    [minLabel setAlignment:NSTextAlignmentCenter];
    [self.controlsContainerView addSubview:minLabel];
    [minLabel release];
    
    NSTextField *maxLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(680, yPos + 15, 50, 20)];
    [maxLabel setStringValue:[NSString stringWithFormat:@"%.0f", maxVal]];
    [maxLabel setBezeled:NO];
    [maxLabel setDrawsBackground:NO];
    [maxLabel setEditable:NO];
    [maxLabel setSelectable:NO];
    [maxLabel setTextColor:[NSColor secondaryLabelColor]];
    [maxLabel setAlignment:NSTextAlignmentCenter];
    [self.controlsContainerView addSubview:maxLabel];
    [maxLabel release];
    
    // Associate value label with slider for updates
    objc_setAssociatedObject(slider, "valueLabel", valueLabel, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(slider, "controlName", controlName, OBJC_ASSOCIATION_RETAIN);
    
    [slider release];
}

- (IBAction)sliderChanged:(NSSlider *)sender {
    [self updateControlValue:sender];
}

- (void)updateControlValue:(NSSlider *)slider {
    NSString *controlName = (NSString *)objc_getAssociatedObject(slider, "controlName");
    NSTextField *valueLabel = (NSTextField *)objc_getAssociatedObject(slider, "valueLabel");
    
    if (!controlName || !self.selectedCamera) {
        return;
    }
    
    UVCControl *control = [self.selectedCamera controlWithName:controlName];
    if (!control) {
        return;
    }
    
    // Update value label
    double newValue = [slider doubleValue];
    [valueLabel setStringValue:[NSString stringWithFormat:@"%.0f", newValue]];
    
    // Set control value
    UVCValue *currentValue = [control currentValue];
    if (currentValue) {
        [self setNumericValue:newValue forUVCValue:currentValue];
        [control writeFromCurrentValue];
    }
}

- (double)getNumericValue:(UVCValue *)value {
    if (!value) return 0.0;
    
    void *ptr = [value valuePtr];
    UVCType *type = [value valueType];
    
    // Handle different data types - simplified approach
    // This assumes single-component values
    NSUInteger componentCount = [type fieldCount];
    if (componentCount > 0) {
        UVCTypeComponentType componentType = [type fieldTypeAtIndex:0];
        
        switch (componentType) {
            case kUVCTypeComponentTypeSInt16:
                return (double)*(int16_t*)ptr;
            case kUVCTypeComponentTypeUInt16:
                return (double)*(uint16_t*)ptr;
            case kUVCTypeComponentTypeSInt8:
                return (double)*(int8_t*)ptr;
            case kUVCTypeComponentTypeUInt8:
                return (double)*(uint8_t*)ptr;
            case kUVCTypeComponentTypeBoolean:
                return (double)*(uint8_t*)ptr;
            case kUVCTypeComponentTypeSInt32:
                return (double)*(int32_t*)ptr;
            case kUVCTypeComponentTypeUInt32:
                return (double)*(uint32_t*)ptr;
            default:
                return 0.0;
        }
    }
    
    return 0.0;
}

- (void)setNumericValue:(double)numValue forUVCValue:(UVCValue *)value {
    if (!value) return;
    
    void *ptr = [value valuePtr];
    UVCType *type = [value valueType];
    
    NSUInteger componentCount = [type fieldCount];
    if (componentCount > 0) {
        UVCTypeComponentType componentType = [type fieldTypeAtIndex:0];
        
        switch (componentType) {
            case kUVCTypeComponentTypeSInt16:
                *(int16_t*)ptr = (int16_t)numValue;
                break;
            case kUVCTypeComponentTypeUInt16:
                *(uint16_t*)ptr = (uint16_t)numValue;
                break;
            case kUVCTypeComponentTypeSInt8:
                *(int8_t*)ptr = (int8_t)numValue;
                break;
            case kUVCTypeComponentTypeUInt8:
                *(uint8_t*)ptr = (uint8_t)numValue;
                break;
            case kUVCTypeComponentTypeBoolean:
                *(uint8_t*)ptr = (uint8_t)(numValue != 0);
                break;
            case kUVCTypeComponentTypeSInt32:
                *(int32_t*)ptr = (int32_t)numValue;
                break;
            case kUVCTypeComponentTypeUInt32:
                *(uint32_t*)ptr = (uint32_t)numValue;
                break;
            case kUVCTypeComponentTypeSInt64:
                *(int64_t*)ptr = (int64_t)numValue;
                break;
            case kUVCTypeComponentTypeUInt64:
                *(uint64_t*)ptr = (uint64_t)numValue;
                break;
            case kUVCTypeComponentTypeBitmap8:
                *(uint8_t*)ptr = (uint8_t)numValue;
                break;
            case kUVCTypeComponentTypeBitmap16:
                *(uint16_t*)ptr = (uint16_t)numValue;
                break;
            case kUVCTypeComponentTypeBitmap32:
                *(uint32_t*)ptr = (uint32_t)numValue;
                break;
            case kUVCTypeComponentTypeBitmap64:
                *(uint64_t*)ptr = (uint64_t)numValue;
                break;
            case kUVCTypeComponentTypeInvalid:
            case kUVCTypeComponentTypeMax:
            default:
                // Do nothing for invalid types
                break;
        }
    }
}

- (IBAction)loadPreset:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [panel setAllowedFileTypes:@[@"yaml", @"yml"]];
#pragma clang diagnostic pop
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [[panel URLs] firstObject];
        NSString *filePath = [url path];
        
        NSDictionary *preset = [self.presetManager loadPresetFromFile:filePath];
        if (preset && self.selectedCamera) {
            [self applyPreset:preset];
            [self.statusLabel setStringValue:[NSString stringWithFormat:@"Loaded preset from %@", [filePath lastPathComponent]]];
        } else {
            [self.statusLabel setStringValue:@"Failed to load preset"];
        }
    }
}

- (IBAction)savePreset:(id)sender {
    if (!self.selectedCamera) {
        [self.statusLabel setStringValue:@"No camera selected"];
        return;
    }
    
    NSSavePanel *panel = [NSSavePanel savePanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [panel setAllowedFileTypes:@[@"yaml"]];
#pragma clang diagnostic pop
    [panel setNameFieldStringValue:@"camera_preset.yaml"];
    
    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [panel URL];
        NSString *filePath = [url path];
        
        NSDictionary *preset = [self getCurrentPreset];
        BOOL success = [self.presetManager savePreset:preset toFile:filePath];
        
        if (success) {
            [self.statusLabel setStringValue:[NSString stringWithFormat:@"Saved preset to %@", [filePath lastPathComponent]]];
        } else {
            [self.statusLabel setStringValue:@"Failed to save preset"];
        }
    }
}

- (NSDictionary *)getCurrentPreset {
    NSMutableDictionary *preset = [[NSMutableDictionary alloc] init];
    
    for (UVCControl *control in self.availableControls) {
        NSString *controlName = [control controlName];
        UVCValue *currentValue = [control currentValue];
        
        if (currentValue) {
            double value = [self getNumericValue:currentValue];
            [preset setObject:@(value) forKey:controlName];
        }
    }
    
    return [preset autorelease];
}

- (void)applyPreset:(NSDictionary *)preset {
    for (NSString *controlName in preset) {
        NSNumber *value = [preset objectForKey:controlName];
        if (![value isKindOfClass:[NSNumber class]]) continue;
        
        UVCControl *control = [self.selectedCamera controlWithName:controlName];
        NSSlider *slider = [self.controlSliders objectForKey:controlName];
        
        if (control && slider) {
            double numValue = [value doubleValue];
            
            // Update slider
            [slider setDoubleValue:numValue];
            
            // Update control
            [self updateControlValue:slider];
        }
    }
}

- (void)dealloc {
    [_cameraPopUp release];
    [_controlsTableView release];
    [_controlsScrollView release];
    [_refreshCamerasButton release];
    [_loadPresetButton release];
    [_savePresetButton release];
    [_statusLabel release];
    [_cameras release];
    [_selectedCamera release];
    [_availableControls release];
    [_presetManager release];
    [_controlSliders release];
    [_controlsContainerView release];
    [super dealloc];
}

@end
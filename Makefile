# Makefile for UVC Camera GUI

# Compiler and flags
CC = clang
CFLAGS = -Wall -Wextra -std=c99 -fobjc-arc-exceptions
OBJCFLAGS = -Wall -Wextra -fobjc-exceptions -fno-objc-arc
FRAMEWORKS = -framework Cocoa -framework IOKit -framework CoreFoundation
INCLUDES = -I./src -I./UVCCameraGUI

# Project settings
PROJECT_NAME = UVCCameraGUI
BUILD_DIR = build
SRC_DIR = src
GUI_DIR = UVCCameraGUI

# Source files
UVC_SOURCES = $(SRC_DIR)/UVCController.m $(SRC_DIR)/UVCValue.m $(SRC_DIR)/UVCType.m
GUI_SOURCES = $(GUI_DIR)/AppDelegate.m $(GUI_DIR)/MainViewController.m $(GUI_DIR)/PresetManager.m $(GUI_DIR)/main.m
ALL_SOURCES = $(UVC_SOURCES) $(GUI_SOURCES)

# Object files
UVC_OBJECTS = $(UVC_SOURCES:$(SRC_DIR)/%.m=$(BUILD_DIR)/%.o)
GUI_OBJECTS = $(GUI_SOURCES:$(GUI_DIR)/%.m=$(BUILD_DIR)/gui_%.o)
ALL_OBJECTS = $(UVC_OBJECTS) $(GUI_OBJECTS)

# Target binary
TARGET = $(BUILD_DIR)/$(PROJECT_NAME)

.PHONY: all build clean test help info

all: build

info:
	@echo "=== UVC Camera GUI Build Info ==="
	@echo "UVC Sources: $(UVC_SOURCES)"
	@echo "GUI Sources: $(GUI_SOURCES)" 
	@echo "All Objects: $(ALL_OBJECTS)"
	@echo "Target: $(TARGET)"

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile UVC library objects
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.m | $(BUILD_DIR)
	@echo "Compiling UVC library file: $<"
	$(CC) $(OBJCFLAGS) $(INCLUDES) -c $< -o $@

# Compile GUI objects  
$(BUILD_DIR)/gui_%.o: $(GUI_DIR)/%.m | $(BUILD_DIR)
	@echo "Compiling GUI file: $<"
	$(CC) $(OBJCFLAGS) $(INCLUDES) -c $< -o $@

# Link final executable
$(TARGET): $(ALL_OBJECTS) | $(BUILD_DIR)
	@echo "Linking executable: $(TARGET)"
	$(CC) $(OBJCFLAGS) $(ALL_OBJECTS) $(FRAMEWORKS) -o $(TARGET)
	@echo "Build completed successfully!"
	@echo "Run with: $(TARGET)"

build: $(TARGET)

clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean completed."

test: build
	@echo "=== UVC Camera GUI Test ==="
	@echo "To test the application:"
	@echo "1. Connect a UVC-compatible camera"
	@echo "2. Run: $(TARGET)"
	@echo "3. Select camera from dropdown"
	@echo "4. Adjust controls with sliders"
	@echo "5. Save/load presets as YAML files"
	@echo ""
	@echo "Note: The application requires a connected UVC camera to function properly."

help:
	@echo "Available targets:"
	@echo "  build  - Build the GUI application using clang"
	@echo "  clean  - Remove build artifacts" 
	@echo "  test   - Show test instructions"
	@echo "  info   - Show build configuration info"
	@echo "  help   - Show this help message"
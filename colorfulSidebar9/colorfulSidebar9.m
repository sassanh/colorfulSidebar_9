//
//  colorfulSidebar9.m
//  colorfulSidebar9
//
//  Created by Wolfgang Baird
//  Copyright 2016 cvz.
//

@import AppKit;
#import "ZKSwizzle.h"
@import QuartzCore;

//Note that after cloning you may need to delete the xcuserdata folder inside the xcodeproj in order to get the scheme to appear

static const char * const activeKey = "wwb_isactive";

@interface colorfulSidebar9 : NSObject
@end

static NSDictionary *cfsbIconMappingDict = nil;

struct TFENode {
    struct OpaqueNodeRef *fNodeRef;
};

@interface wb_TImageView : NSImageView
@end

@interface wb_TSidebarItemCell : NSObject
- (id)getNodeAsResolvedNode:(BOOL)arg1;
+ (id)nodeFromNodeRef:(struct OpaqueNodeRef *)nodeRef;
- (struct OpaqueIconRef *)createAlternativeIconRepresentationWithOptions:(id)arg1;
@end

@implementation wb_TSidebarItemCell

- (void)wb_setImage:(id)i {
    SEL aSEL = @selector(accessibilityAttributeNames);
    if ([self respondsToSelector:aSEL] && [[self performSelector:aSEL] containsObject:NSAccessibilityURLAttribute]) {
        NSURL *aURL = [self accessibilityAttributeValue:NSAccessibilityURLAttribute];
        NSImage *image = nil;
        if ([aURL isFileURL]) {
            NSString *path = [aURL path];
            image = cfsbIconMappingDict[path];
        }
        if (image)
            [i setImage:image];
    }
}

// 10.9 & 10.10
- (void)drawWithFrame:(struct CGRect)arg1 inView:(id)arg2 {
    [self wb_setImage:self];
    ZKOrig(void, arg1, arg2);
}

// 10.11 +
- (_Bool)isHighlighted {
    SEL aSEL = @selector(subviews);
    if ([self respondsToSelector:aSEL])
        for (id i in [self performSelector:aSEL])
            if ([i class] == NSClassFromString(@"TImageView") || [i class] == NSClassFromString(@"FI_TImageView") )
                [self wb_setImage:i];
    return ZKOrig(_Bool);
}

@end

@implementation wb_TImageView

- (void)wb_bumping {
    NSNumber *hasBumped = objc_getAssociatedObject(self, activeKey);
    if (hasBumped == nil) {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            SEL se = @selector(isHighlighted);
            if ([[self superview] respondsToSelector:se])
                [[self superview] performSelector:se];
            [[self superview] updateLayer];
            NSNumber *hasBumped = [NSNumber numberWithBool:true];
            objc_setAssociatedObject(self, activeKey, hasBumped, OBJC_ASSOCIATION_RETAIN);
        });
    }
}

- (void)_updateImageView {
    ZKOrig(void);
    [self wb_bumping];
}

- (void)updateLayer {
    ZKOrig(void);
    [self wb_bumping];
}

- (void)layout {
    ZKOrig(void);
    [self wb_bumping];
}

@end

@implementation colorfulSidebar9

+ (void)load {
    if (NSAppKitVersionNumber < 1138)
        return;
    
    if (!cfsbIconMappingDict) {
        NSLog(@"Loading colorfulSidebar...");
        
        [self performSelector:@selector(setUpIconMappingDict)];
        
        if (NSClassFromString(@"TSidebarItemCell"))
            ZKSwizzle(wb_TSidebarItemCell, TSidebarItemCell);
        
        if (NSClassFromString(@"FI_TSidebarItemCell"))
            ZKSwizzle(wb_TSidebarItemCell, FI_TSidebarItemCell);
        
        if (NSClassFromString(@"TImageView"))
            ZKSwizzle(wb_TImageView, TImageView);
        
        if (NSClassFromString(@"FI_TImageView"))
            ZKSwizzle(wb_TImageView, FI_TImageView);
    
        #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
            NSLog(@"%@ loaded into %@ on macOS 10.%ld", [self class], [[NSBundle mainBundle] bundleIdentifier], [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion);
        #else
            NSLog(@"%@ loaded into %@ on OSX <= 10.9", [self class], [[NSBundle mainBundle] bundleIdentifier]);
        #endif
    }
    
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.finder"]) {
        NSMenu *go = [[[NSApp mainMenu] itemAtIndex:4] submenu];
        for (NSMenuItem *i in [go itemArray]) {
            NSImage *image = nil;
            NSString *action = NSStringFromSelector([i action]);
            if ([action isEqualToString:@"cmdGoToAllMyFiles:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AllMyFiles.icns"];
            
            if ([action isEqualToString:@"cmdGoToDocuments:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/Applications/iBooks.app/Contents/Resources/iBooksAppIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToDesktop:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/PreferencePanes/Displays.prefPane/Contents/Resources/Displays.icns"];
            
            if ([action isEqualToString:@"cmdGoToDownloads:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns"];
            
            if ([action isEqualToString:@"cmdGoHome:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/HomeFolderIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToUserLibrary:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/Siri.app/Contents/Resources/AppIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToComputer:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macpro.icns"];
            
            if ([action isEqualToString:@"cmdGoToMeetingRoom:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AirDrop.icns"];
            
            if ([action isEqualToString:@"cmdGoToNetwork:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericNetworkIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToICloud:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/iDiskGenericIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToApplications:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/Applications/App Store.app/Contents/Resources/AppIcon.icns"];
            
            if ([action isEqualToString:@"cmdGoToUtilities:"])
                image = [[NSImage alloc] initWithContentsOfFile:@"/Applications/Utilities/ColorSync Utility.app/Contents/Resources/ColorSyncUtility.icns"];

            if (image) {
                [image setSize:NSMakeSize(16, 16)];
            }
        }
    }
}

+ (void)setUpIconMappingDict {
    NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"icons" ofType:@"plist"];
    #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
        if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 10)
            path = [[NSBundle bundleForClass:self] pathForResource:@"icons10" ofType:@"plist"];
    #endif
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict) {
        cfsbIconMappingDict = [NSDictionary new];
    } else {
        NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
        for (NSString *key in dict) {
            NSImage *image;
            if ([key isAbsolutePath]) {
                image = [[[NSImage alloc] initWithContentsOfFile:key] autorelease];
                
                //If you are using colored icons instead of the usual black icon templates, comment out the rest
                NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
                CGImageRef cgImage = [image CGImageForProposedRect:&imageRect context:NULL hints:nil];
                CIImage *ciImage = [[CIImage alloc] initWithCGImage:cgImage];
                CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorControls"];
                [ciFilter setDefaults];
                [ciFilter setValue:ciImage forKey:@"inputImage"];
                
                //Below brightness level works for mavericks. You might need to adjust the value to match your OS.
                [ciFilter setValue:[NSNumber numberWithFloat:.04] forKey:@"inputBrightness"];
                CIImage *outputImage = [ciFilter valueForKey:@"outputImage"];
                NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
                image = [[NSImage alloc] initWithSize:rep.size];
                
                //No resizing is currently performed. Ensure your icon contains a 32x32 representation
                [image addRepresentation:rep];
                [image setTemplate:true];
            } else if ([key length] == 4) {
                OSType code = UTGetOSTypeFromString((CFStringRef)CFBridgingRetain(key));
                image = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(code)];
            } else {
                image = [NSImage imageNamed:key];
                if (image && [key rangeOfString:@"NSMediaBrowserMediaType"].length) {
                    image = [[image copy] autorelease];
                    NSSize size = NSMakeSize(32, 32);
                    [image setSize:size];
                    [[[image representations] lastObject] setSize:size];
                }
            }
            if (image) {
                NSArray *arr = dict[key];
                for (key in arr) {
                    if ([key hasPrefix:@"~"]) {
                        key = [key stringByExpandingTildeInPath];
                    }
                    mdict[key] = image;
                }
            }
        }
        cfsbIconMappingDict = [mdict copy];
    }
}

@end

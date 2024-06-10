//
//  TheLostFinderNewWindow.m
//  TheLostFinderNewWindow
//
//  Created by Sigurdur Helgason on 07/03/2014.
//  Copyright (c) 2014 Siggi.hk. All rights reserved.
//

#import "TheLostFinderNewWindow.h"

#import <objc/objc-class.h>

void TLFNWSwizzleInstanceMethod (Class cls, SEL old, SEL new) {
	Method mold = class_getInstanceMethod(cls, old);
	Method mnew = class_getInstanceMethod(cls, new);
	if (mold && mnew) {
		if (class_addMethod(cls, old, method_getImplementation(mold), method_getTypeEncoding(mold))) {
			mold = class_getInstanceMethod(cls, old);
		}
		if (class_addMethod(cls, new, method_getImplementation(mnew), method_getTypeEncoding(mnew))) {
			mnew = class_getInstanceMethod(cls, new);
		}
		method_exchangeImplementations(mold, mnew);
	}
}

void TLFNWSwizzleClassMethod (Class cls, SEL old, SEL new) {
	Method mold = class_getClassMethod(cls, old);
	Method mnew = class_getClassMethod(cls, new);
	if (mold && mnew) {
		Class metaCls = objc_getMetaClass(class_getName(cls));
		if (class_addMethod(metaCls, old, method_getImplementation(mold), method_getTypeEncoding(mold))) {
			mold = class_getClassMethod(cls, old);
		}
		if (class_addMethod(metaCls, new, method_getImplementation(mnew), method_getTypeEncoding(mnew))) {
			mnew = class_getClassMethod(cls, new);
		}
		method_exchangeImplementations(mold, mnew);
	}
}

@implementation NSObject (TheLostFinderNewWindow)
- (BOOL) isFullscreen {
    Class cls = nil;
    cls = NSClassFromString(@"TBaseBrowserViewController");
    if ([self isKindOfClass:cls]) {
        NSViewController *viewController = (NSViewController *)self;
        return ([[[viewController view] window] styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
    }
    cls = NSClassFromString(@"TSpringController");
    if ([self isKindOfClass:cls]) {
        NSViewController *viewController = (NSViewController*) [self performSelector:@selector(_delegate)];
        return ([[[viewController view] window] styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
    }
    return NO;
}
- (BOOL) isFullscreenController:(NSViewController *) viewController {
    return ([[[viewController view] window] styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
}
- (BOOL) isFullscreenWindow:(NSWindow *) window {
    return ([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
}
- (void) plugin_openSelectionWithModifiers:(unsigned long long)modifiers allowTabs:(_Bool)allowTabs {
    // TBaseBrowserViewController
    if ([self isFullscreen]) {
        [self plugin_openSelectionWithModifiers:modifiers allowTabs:allowTabs];
    } else {
        // the following code toggles the command key on/off so Finder sees the opposite of your input.
        if ((modifiers & 1048576) != 0) { // command key is pressed!
            modifiers -= 1048576;
        } else { // command key is NOT pressed!
            modifiers |= 1048576;
        }
        [self plugin_openSelectionWithModifiers:modifiers allowTabs:allowTabs];
    }
}

- (void) plugin_openSelection {
    // TBaseBrowserViewController
    if ([self isFullscreen]) {
        [self plugin_openSelection];
    } else {
        [self plugin_openSelectionWithModifiers:1048576 allowTabs:YES];
    }
}

- (void) plugin_cmdOpen:(id)arg1 {
    // TBaseBrowserViewController
    if ([self isFullscreen]) {
        [self plugin_cmdOpen:arg1];
    } else {
        [self plugin_openSelectionWithModifiers:1048576 allowTabs:YES];
    }
}

- (void) plugin_cmdOpenParent:(id)arg1 {
    // TBaseBrowserViewController
    if ([self isFullscreen]) {
        [self plugin_cmdOpenParent:arg1];
    } else {
        [self performSelector:@selector(cmdOpenParentAltBrowse:) withObject:arg1];
    }
}

+ (void) plugin_showGotoForContainerController:(id)arg1 window:(id)arg2 initialFilename:(id)arg3 completionHandler:(id)arg4 {
    // TGotoWindowController
    if ([self isFullscreenController:(NSViewController *)arg1]) {
        [self plugin_showGotoForContainerController:arg1 window:arg2 initialFilename:arg3 completionHandler:arg4];
    } else {
        [self plugin_showGotoForContainerController:nil window:arg2 initialFilename:arg3 completionHandler:arg4];
    }
}

+ (void) plugin_showGotoForContainerController:(id)arg1 {
    // TGotoWindowController
    if ([self isFullscreenController:(NSViewController *)arg1]) {
        [self plugin_showGotoForContainerController:arg1];
    } else {
        [self plugin_showGotoForContainerController:nil];
    }
}

- (BOOL) plugin_commandKeyDown {
    // TSpringController
    return ![self plugin_commandKeyDown];
}

- (void) plugin_goToCommon:(id) arg1 {
    // TGlobalWindowController
    Class globalWindowController = NSClassFromString(@"TGlobalWindowController");
    [[globalWindowController class] performSelector:@selector(createWindowWithTarget:) withObject:arg1];
}
@end

@implementation TheLostFinderNewWindow
+ (void)load {
    Class cls;
    SEL old, new;
    
    cls = NSClassFromString(@"TBaseBrowserViewController");
    if (cls) {
        old = @selector(openSelectionWithModifiers:allowTabs:);
        new = @selector(plugin_openSelectionWithModifiers:allowTabs:);
        TLFNWSwizzleInstanceMethod(cls, old, new);
        
        old = @selector(openSelection);
        new = @selector(plugin_openSelection);
        TLFNWSwizzleInstanceMethod(cls, old, new);
        
        old = @selector(cmdOpen:);
        new = @selector(plugin_cmdOpen:);
        TLFNWSwizzleInstanceMethod(cls, old, new);
        
        old = @selector(cmdOpenParent:);
        new = @selector(plugin_cmdOpenParent:);
        TLFNWSwizzleInstanceMethod(cls, old, new);
    }
    cls = NSClassFromString(@"TGlobalWindowController");
    if (cls) {
        old = @selector(goToCommon:);
        new = @selector(plugin_goToCommon:);
        TLFNWSwizzleInstanceMethod(cls, old, new);
    }
    cls = NSClassFromString(@"TGotoWindowController");
    if (cls) {
        old = @selector(showGotoForContainerController:window:initialFilename:completionHandler:);
        new = @selector(plugin_showGotoForContainerController:window:initialFilename:completionHandler:);
        TLFNWSwizzleClassMethod(cls, old, new);
        
        old = @selector(showGotoForContainerController:);
        new = @selector(plugin_showGotoForContainerController:);
        TLFNWSwizzleClassMethod(cls, old, new);
    }
    cls = NSClassFromString(@"TSpringController");
    if (cls) {
        old = @selector(commandKeyDown);
        new = @selector(plugin_commandKeyDown);
        TLFNWSwizzleInstanceMethod(cls, old, new);
    }
    
    NSLog(@"TheLostFinderNewWindow Loaded");
}
+ (TheLostFinderNewWindow*) sharedInstance {
    static TheLostFinderNewWindow* plugin = nil;
    
    if (plugin == nil) {
        plugin = [[TheLostFinderNewWindow alloc] init];
    }
    
    return plugin;
}
@end

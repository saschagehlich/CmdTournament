//
//  APAppDelegate.m
//  CmdTournament
//
//  Created by Sascha Gehlich on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APAppDelegate.h"
#import <Carbon/Carbon.h>

@implementation APAppDelegate

static id globalSelf;
static NSRect startRect;

@synthesize window = _window;
@synthesize imageView = _imageView;
@synthesize view = _view;
@synthesize statusMenu = _statusMenu;
@synthesize statusItem = _statusItem;
@synthesize quitItem = _quitItem;


- (id)init {
    self = [super init];
    if(self != nil) {
        globalSelf = self;
    }
    return self;
}
//OSStatus keyPressed(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
//	NSLog(@"Event received!\n");
//	return CallNextEventHandler(nextHandler, theEvent);
//}

- (void)awakeFromNib 
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"icon_black.tiff"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"icon_white.tiff"]];
}

-(IBAction)clickQuit:(id)sender {
    [NSApp terminate:nil];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.imageView = [[NSImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window center];
    
    startRect = self.window.frame;
    startRect.origin.y += 100;
    
    [self.window setFrame:startRect display:YES];
    
    [self bindHotkeys];
}

- (void)takeToFront {
    [[NSAnimationContext currentContext] setDuration:1.0f];
    
    [self.window setAlphaValue:1.0f];
    
    [self.window setLevel:NSFloatingWindowLevel];
    [self.window makeKeyAndOrderFront:globalSelf];
    [self.window setOrderedIndex:0];
    
    [self.window setFrame:startRect display:YES];
    
    [self.window.animator setAlphaValue:0.0];
}

- (void)displayImage:(NSString *)fileName {
    [[globalSelf imageView] setImage:[NSImage imageNamed:fileName]];
    [[globalSelf imageView] setFrame:self.view.bounds]; 

    [[[globalSelf imageView] animator] setFrame:NSMakeRect(0,0,self.view.bounds.size.width,50)];
}

- (void)playSound:(NSString *)fileName {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:resourcePath byReference:YES];
    [sound play];
}

# pragma mark - Keyboard handling

OSStatus HotkeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                       void *userData)
{
    EventHotKeyID hkCom;
    GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
                      sizeof(hkCom),NULL,&hkCom);
    int l = hkCom.id;
    
    OSErr err;
    ProcessSerialNumber psn;
    CGEventRef cKeyDown;
    CGEventRef cKeyUp;
    
    err = GetFrontProcess( &psn );
    
    if( err != noErr )
    {
        NSLog( @"Failed getting front PSN: %d", err );
        return;
    }        
    
    switch (l) {
        case 1: //do something
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)8, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)8, false );

            [globalSelf playSound:@"copy"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"copy-1.png"];
            break;
        case 2:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)9, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)9, false );
            
            [globalSelf playSound:@"paste"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"paste-1.png"];
            break;
        case 3:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)7, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)7, false );
            
            [globalSelf playSound:@"cut"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"cut-1.png"];
            break;
        case 4:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)1, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)1, false );
            
            [globalSelf playSound:@"save"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"save-1.png"];
            break;
        case 5:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)13, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)13, false );
            
            [globalSelf playSound:@"close"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"close-1.png"];
            break;
        case 6:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)12, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)12, false );
            
            [globalSelf playSound:@"quit"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"quit-1.png"];
            break;
        case 7:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)0, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)0, false );
            
            [globalSelf playSound:@"select_all"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"selectall-1.png"];
            break;
        case 8:
            cKeyDown = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)45, true );
            cKeyUp = CGEventCreateKeyboardEvent( NULL, (CGKeyCode)45, false );
            
            [globalSelf playSound:@"new"];
            
            [globalSelf takeToFront];
            [globalSelf displayImage:@"new-1.png"];
            break;
    }
    
    if (cKeyDown || cKeyUp) {
        CGEventSetFlags( cKeyDown, kCGEventFlagMaskCommand );
        CGEventPostToPSN(&psn, cKeyDown);
        CGEventPostToPSN(&psn, cKeyUp);
        CFRelease(cKeyDown);
        CFRelease(cKeyUp);
    }
    
    return eventNotHandledErr;
}

- (void)bindHotkeys
{
    //Register the Hotkeys
    EventHotKeyRef copyRef;
    EventHotKeyID copyId;
    
    EventHotKeyRef pasteRef;
    EventHotKeyID pasteId;
    
    EventHotKeyRef cutRef;
    EventHotKeyID cutId;
    
    EventHotKeyRef saveRef;
    EventHotKeyID saveId;
    
    EventHotKeyRef closeRef;
    EventHotKeyID closeId;
    
    EventHotKeyRef quitRef;
    EventHotKeyID quitId;
    
    EventHotKeyRef selectAllRef;
    EventHotKeyID selectAllId;
    
    EventHotKeyRef newRef;
    EventHotKeyID newId;
    
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&HotkeyHandler,1,&eventType,NULL,NULL);
    
    copyId.signature='hkCopy';
    copyId.id=1;
    
    pasteId.signature='hkPaste';
    pasteId.id=2;
    
    cutId.signature='hkCut';
    cutId.id=3;
    
    saveId.signature='hkSave';
    saveId.id=4;
    
    closeId.signature='hkClose';
    closeId.id=5;
    
    quitId.signature='hkQuit';
    quitId.id=6;
    
    selectAllId.signature='hkSelectAll';
    selectAllId.id=7;
    
    newId.signature='hkNew';
    newId.id=8;    
    
    RegisterEventHotKey(8, cmdKey, copyId, GetApplicationEventTarget(), 0, &copyRef);
    RegisterEventHotKey(9, cmdKey, pasteId, GetApplicationEventTarget(), 0, &pasteRef);
    RegisterEventHotKey(7, cmdKey, cutId, GetApplicationEventTarget(), 0, &cutRef);
    RegisterEventHotKey(13, cmdKey, closeId, GetApplicationEventTarget(), 0, &closeRef);
//    RegisterEventHotKey(12, cmdKey, quitId, GetApplicationEventTarget(), 0, &quitRef);
    RegisterEventHotKey(0, cmdKey, selectAllId, GetApplicationEventTarget(), 0, &selectAllRef);
    RegisterEventHotKey(45, cmdKey, newId, GetApplicationEventTarget(), 0, &newRef);
    RegisterEventHotKey(1, cmdKey, saveId, GetApplicationEventTarget(), 0, &saveRef);
}

@end

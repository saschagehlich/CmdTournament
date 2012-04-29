//
//  APAppDelegate.h
//  CmdTournament
//
//  Created by Sascha Gehlich on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSImageView *imageView;
@property (weak) IBOutlet NSView *view;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenuItem *quitItem;

-(IBAction)clickQuit:(id)sender;

@end

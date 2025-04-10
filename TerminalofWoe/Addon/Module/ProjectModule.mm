//
//  ProjectModule.m
//  CodeaProject
//
//  Created by Simeon Saint-Saens on 17/3/19.
//  Copyright © 2019 Two Lives Left. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProjectModule.h"
#import "ProjectAddon.h"
#import "ModuleIncludes.h"

using namespace LuaIntf;

@interface ProjectModule ()
@property (nonatomic, strong) UIDocumentInteractionController* docController;
@end

@implementation ProjectModule
    
- (void)registerForAddon:(ProjectAddon *)addon {
    LuaBinding(addon.L)
        .addFunction("shareTerminal", [self, addon](lua_State* L) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *url = [NSBundle.mainBundle URLForResource:@"TerminalofWoe.codea/Terminal of Woe" withExtension:@"zip"];
                
                self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
                
                CGPoint center = addon.controller.view.center;
                [self.docController presentOpenInMenuFromRect:CGRectMake(center.x - 50, center.y - 50, 100, 100) inView:addon.controller.view animated:true];
            });
        });
}

@end

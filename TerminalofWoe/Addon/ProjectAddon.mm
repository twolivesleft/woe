//
//  ProjectAddon.m
//  CodeaProject
//
//  Created by Simeon Saint-Saens on 17/3/19.
//  Copyright © 2019 Two Lives Left. All rights reserved.
//

#import "ProjectAddon.h"

#include "ModuleIncludes.h"

#import "ProjectModule.h"

@interface ProjectAddon ()

@property (nullable, nonatomic, assign) lua_State* L;

@end

@implementation ProjectAddon

+ (NSArray*) defaultModules
{
    return @[
             [ProjectModule new],
            ];
}
    
- (void)codea:(nonnull ThreadedRuntimeViewController *)controller didCreateLuaState:(nonnull struct lua_State *)L isValidating:(BOOL)validating {
    self.L = L;
    self.controller = controller;
    
    for(id<Module> mod in [ProjectAddon defaultModules]) {
        [mod registerForAddon:self];
    }
}
    
- (void)codeaWillDrawFrame:(ThreadedRuntimeViewController *)controller withDelta:(CGFloat)deltaTime {}
    
- (void)codeaDidFinishSetup:(CodeaViewController *)controller {
    if( self.ready ) {
        self.ready(self);
    }
}
    
@end

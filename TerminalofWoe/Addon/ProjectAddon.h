//
//  ProjectAddon.h
//  CodeaProject
//
//  Created by Simeon Saint-Saens on 17/3/19.
//  Copyright © 2019 Two Lives Left. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RuntimeKit/RuntimeKit.h>

@class ProjectAddon;
@class TerminalofWoeViewController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProjectReady)(ProjectAddon*);

@interface ProjectAddon : NSObject<CodeaAddon>

@property (nullable, nonatomic, readonly) lua_State* L;
@property (nullable, nonatomic, strong) ProjectReady ready;
@property (nullable, nonatomic, weak) ThreadedRuntimeViewController* controller;
    
@end

NS_ASSUME_NONNULL_END

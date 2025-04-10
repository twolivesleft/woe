//
//  Module.h
//  FPaint
//
//  Created by Simeon Saint-Saens on 23/9/18.
//  Copyright © 2018 Two Lives Left. All rights reserved.
//

@class ProjectAddon;

@protocol Module <NSObject>

- (void) registerForAddon:(ProjectAddon *_Nonnull)addon;

@end


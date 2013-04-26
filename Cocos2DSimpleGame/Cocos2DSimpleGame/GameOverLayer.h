//
//  GameOverLayer.h
//  Cocos2DSimpleGame
//
//  Created by Holyen Zou on 13-4-26.
//  Copyright 2013年 demo.HolyenZou.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor

+ (CCScene *)sceneWithWon:(BOOL)won;
-(id)initWithWon:(BOOL)won;

@end

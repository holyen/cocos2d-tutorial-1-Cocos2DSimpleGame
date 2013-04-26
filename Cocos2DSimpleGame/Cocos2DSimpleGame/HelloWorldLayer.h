//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by holyenzou on 13-4-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
    int _monstersDestroyed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

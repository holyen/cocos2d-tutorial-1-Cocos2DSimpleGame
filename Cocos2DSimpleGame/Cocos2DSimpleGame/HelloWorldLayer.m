//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by holyenzou on 13-4-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id)init
{
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width / 2, winSize.height / 2);
        [self addChild:player];
        [self setIsTouchEnabled:YES];
        
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        
        [self schedule:@selector(gameLogic:) interval:1.5];
        [self schedule:@selector(update:)];
    }
    return self;
}

- (void)gameLogic:(ccTime)dt
{
    [self addMonster];
}

- (void)addMonster
{
    CCSprite *monster = [CCSprite spriteWithFile:@"monster.png"];
    monster.tag = 1;
    [_monsters addObject:monster];
    
    //Determine where to spawn the monster along the Y axis.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height / 2;
    int maxY = winSize.height - monster.contentSize.height / 2;
    int rangeY = maxY - minY;
    
    /**   
     arc4random() 比较精确不需要生成随即种子
     
     使用方法 ：
     
     通过arc4random() 获取0到x-1之间的整数的代码如下：
     
     int value = arc4random() % x;
     
     
     获取1到x之间的整数的代码如下:
     
     int value = (arc4random() % x) + 1;  
     */
    int actualY = (arc4random() % rangeY) + minY; // 随机范围:minY - rangeY
    
    /** Create the monster slightly off-screen along the right edge, and along a random position along the Y axis as calculated above:actualY. */
    monster.position = ccp(winSize.width + monster.contentSize.width / 2, actualY);
    [self addChild:monster];
    
    //Determine speed of the monster.
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;// 2 - 4 ?
    
    //Create the actions.
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-monster.contentSize.width / 2, actualY)];;
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [_monsters removeObject:node];
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }];/** you’re going to set up this action to run after the monster goes offscreen to the left – and you’ll remove the monster from the layer when this occurs for not leak memory. */
    
    /** The CCSequence action allows us to chain together a sequence of actions that are performed in order, one at a time. This way, you can have the CCMoveTo action perform first, and once it is complete perform the CCCallBlockN action. */
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_monsters release];
    _monsters = nil;
    [_projectiles release];
    _projectiles = nil;
    
	[super dealloc];
}

- (void)update:(ccTime)dt
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite *projectile in _projectiles)
    {
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters)
        {
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox))
            {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete)
        {
            [_monsters removeObject:monster];
            _monstersDestroyed ++;
            if (_monstersDestroyed > 30) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
            [self removeChild:monster cleanup:YES];
        }
        
        if (monstersToDelete.count > 0)
        {
            [projectilesToDelete addObject:projectile];
        }
        
        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete)
    {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    
    [projectilesToDelete release];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

#pragma mark For Touch

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    //set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
    projectile.tag = 2;
    [_projectiles addObject:projectile];
    projectile.position = ccp(20, winSize.height / 2);
    
    //Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    if (offset.x <= 0) {
        return;
    }
    
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width / 2);
    float ratio = (float)offset.y / (float)offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    //Determine the length of how far you're shooting.
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX * offRealX) + (offRealY * offRealY));
    float velocity = 480 / 1; //480pixels/1sec
    float realMoveDuration = length / velocity;
    
    //Move projectile to actual endpoint.
    [projectile runAction:[CCSequence actions:[CCMoveTo actionWithDuration:realMoveDuration position:realDest], [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [_projectiles removeObject:node];
    }], nil]];
}

@end

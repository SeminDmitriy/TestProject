//
//  GameViewController.m
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import "GameViewController.h"
#import "TapElementView.h"
#import <QuartzCore/QuartzCore.h>
#import "TapElementModel.h"
#import "Common.h"

#define UP    0
#define DOWN  1
#define RIGHT 2
#define LEFT  3

@implementation GameViewController

@synthesize imageViewForGame        = imageViewForGameSynth;
@synthesize viewForElements         = viewForElementsSynth;
@synthesize startNewGameButton      = startNewGameButtonSynth;
@synthesize buttonShowOriginalImage = buttonShowOriginalImageSynth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    countElements = [[userDef objectForKey:@"countElements"] intValue];
    
    if (countElements == 0)
        countElements = 3;
    
    NSFileManager *fileManager = nil;
    NSString *nameFile         = nil;
    NSString *pathToFile       = nil;
    
    fileManager = [NSFileManager defaultManager];
    
    nameFile = [userDef objectForKey:@"pictureForGame"];
    
    pathToFile = [Common pathToDocumentsDirectory];
    pathToFile = [pathToFile stringByAppendingString:nameFile];
    
    if ([fileManager fileExistsAtPath:pathToFile])
        imageViewForGameSynth.image = [UIImage imageWithContentsOfFile:pathToFile];
    else
        imageViewForGameSynth.image = [UIImage imageNamed:nameFile];
    
    [buttonShowOriginalImageSynth setHidden:YES];
    
    newGameCreated = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Actions
- (IBAction)btnNewGamePress:(id)sender
{
    newGameCreated = !newGameCreated;
    
    if (newGameCreated == YES)
    {
        [self startNewGame];
        startNewGameButtonSynth.title = @"Stop";
    }
}
- (IBAction)btnShowOriginalPicturePress:(id)sender
{
    CGFloat alphaOriginalImage = imageViewForGameSynth.alpha;
    CGFloat alphaGameView = viewForElementsSynth.alpha;
    [UIView animateWithDuration:0.3 animations:^{
        viewForElementsSynth.alpha = alphaOriginalImage;
        imageViewForGameSynth.alpha = alphaGameView;
    }];
    if (alphaOriginalImage == 0.f)
        [buttonShowOriginalImageSynth setTitle:@"Return" forState:UIControlStateNormal];
    else
        [buttonShowOriginalImageSynth setTitle:@"Show Original Picture" forState:UIControlStateNormal];
}
#pragma mark - Create New Game
- (void)startNewGame
{
    [UIView animateWithDuration:.5f animations:^{
        [viewForElementsSynth setAlpha:1.f];
        [viewForElementsSynth.layer setBorderColor:[UIColor grayColor].CGColor];
        [viewForElementsSynth.layer setBorderWidth:2];
        [imageViewForGameSynth setAlpha:0.f];
    }];
    
    [self createGamePictureView];
    
    if (!arrayAnimationsNewGame)
        arrayAnimationsNewGame = [NSMutableArray new];
    else
        [arrayAnimationsNewGame removeAllObjects];
        
    newGameCreated = YES;
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    int countMoves = [[userDef objectForKey:@"countMoves"] intValue];
    
    if (countMoves == 0)
        countMoves = 100;
    
    
    for (int i = 0; i < countMoves; i++)
    {
        
        TapElementModel *hiddenElement = [self findHiddenElement];
        
        NSArray *arrayValidElements = [self getArrayValidElementWithHidden:hiddenElement];
        
        int randomIndex = rand() % [arrayValidElements count];
        
        NSDictionary *dictModel = [arrayValidElements objectAtIndex:randomIndex];
        
        //запоминаем ход, чтобы небыло два одинаковых подряд
        previousModelElement = [dictModel objectForKey:@"model"];
        
        [self changeCenterElement:[dictModel objectForKey:@"model"] withTypeTransform:[[dictModel objectForKey:@"typeMoved"] intValue]];
    }
    
    [self animationsQueueStart];
}
- (void)createGamePictureView
{
    int a = imageViewForGameSynth.frame.size.width/countElements;
    
    if (!arrayElementOriginal)
        arrayElementOriginal = [NSMutableArray new];
    else
        [arrayElementOriginal removeAllObjects];
    
    if (!arrayElementPuzzle)
        arrayElementPuzzle = [NSMutableArray new];
    else
    {
        for (UIView *view in viewForElementsSynth.subviews)
            [view removeFromSuperview];

        [arrayElementPuzzle removeAllObjects];
    }
    for (int i = 0; i < countElements; i++)
    {
        NSMutableArray *horizontalRows = [NSMutableArray new];
        
        for (int j = 0; j < countElements; j++)
        {
                TapElementModel *model = [TapElementModel new];
                model.verticalRow = i;
                model.horizontalRow = j;
                model.imageElement = [self getCropImageElement:j y:i];
                model.sizeElement = a;
                model.hiddenElement = NO;
                model.indexElement = [[NSString stringWithFormat:@"%d%d", i,j] intValue]+100;
                
                if (j == countElements - 1 && i == countElements - 1)
                    model.hiddenElement = YES;
                
                TapElementView *viewElement = [[[NSBundle mainBundle] loadNibNamed:@"TapElementView" owner:nil options:nil] objectAtIndex:0];
                [viewElement customizedViewWithModel:model];
                [viewElement setTag:model.indexElement];
                [viewElement setDelegate:self];
                [viewForElementsSynth addSubview:viewElement];
                
                model.centerElementView = viewElement.center;
                [horizontalRows insertObject:model atIndex:j];
                
                [self addGestureRecognizerInViewElemnt:viewElement];
        }
        [arrayElementOriginal insertObject:horizontalRows atIndex:i];
        [arrayElementPuzzle insertObject:horizontalRows atIndex:i];
    }
}
#pragma mark - button element protocol methods
- (void)buttonElementPressed:(TapElementModel *)model
{
    if (!newGameCreated) {
        TapElementModel *hiddenModelElement = [self findAndGetNearbyHiddenElement:model];
        [self changeCenterElement:model withTypeTransform:hiddenModelElement.pathToHiddenElement];
    }
}

#pragma mark Recognizer methods
- (void)addGestureRecognizerInViewElemnt:(id)currentElement
{
    UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [currentElement addGestureRecognizer:pgr];
}
- (void)handlePan:(UIPanGestureRecognizer*)pgr;
{
    CGPoint translation = [pgr translationInView:viewForElementsSynth];
    TapElementModel *swipeElementModel = ((TapElementView *) pgr.view).model;
    
    TapElementModel *hiddenModel = [self findAndGetNearbyHiddenElement:swipeElementModel];
   
    if (hiddenModel && !newGameCreated)
    {
        if (swipeElementModel.centerElementView.y == hiddenModel.centerElementView.y)
            translation.y = 0;
        
        else if (swipeElementModel.centerElementView.x == hiddenModel.centerElementView.x)
            translation.x = 0;
        
        pgr.view.center = CGPointMake(pgr.view.center.x + translation.x,
                                      pgr.view.center.y + translation.y);
        
        if (hiddenModel.pathToHiddenElement == UP)
        {
            if (pgr.view.center.y <= hiddenModel.centerElementView.y)
                pgr.view.center = hiddenModel.centerElementView;
            if (pgr.view.center.y >= swipeElementModel.centerElementView.y)
                pgr.view.center = swipeElementModel.centerElementView;
        }
        
        if (hiddenModel.pathToHiddenElement == DOWN)
        {
            if (pgr.view.center.y >= hiddenModel.centerElementView.y)
                pgr.view.center = hiddenModel.centerElementView;
            if (pgr.view.center.y <= swipeElementModel.centerElementView.y)
                pgr.view.center = swipeElementModel.centerElementView;
        }
        if (hiddenModel.pathToHiddenElement == RIGHT)
        {
            if (pgr.view.center.x >= hiddenModel.centerElementView.x)
                pgr.view.center = hiddenModel.centerElementView;
            if (pgr.view.center.x <= swipeElementModel.centerElementView.x)
                pgr.view.center = swipeElementModel.centerElementView;
        }
        if (hiddenModel.pathToHiddenElement == LEFT)
        {
            if (pgr.view.center.x <= hiddenModel.centerElementView.x)
                pgr.view.center = hiddenModel.centerElementView;
            if (pgr.view.center.x >= swipeElementModel.centerElementView.x)
                pgr.view.center = swipeElementModel.centerElementView;
        }
        
        [pgr setTranslation:CGPointMake(0, 0) inView:self.view];
    

        if (pgr.state == UIGestureRecognizerStateEnded)
        {
            
            CGPoint velocity = [pgr velocityInView:pgr.view];
            
            if (swipeElementModel.centerElementView.y == hiddenModel.centerElementView.y)
                velocity.y = 0;
            
            else if (swipeElementModel.centerElementView.x == hiddenModel.centerElementView.x)
                velocity.x = 0;

            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            CGFloat slideMult = magnitude / 180;
            
            float slideFactor = 0.1 * slideMult;
            BOOL customSwipeSimulate = NO;
            
            if (pgr.view.center.x + (velocity.x*slideFactor) >= hiddenModel.centerElementView.x && hiddenModel.pathToHiddenElement == RIGHT )
                customSwipeSimulate = YES;
            
            if (pgr.view.center.y + (velocity.y*slideFactor) >= hiddenModel.centerElementView.y && hiddenModel.pathToHiddenElement == DOWN)
                customSwipeSimulate = YES;
            
            if (pgr.view.center.y + (velocity.y*slideFactor) <= hiddenModel.centerElementView.y && hiddenModel.pathToHiddenElement == UP)
                customSwipeSimulate = YES;

            if (pgr.view.center.x + (velocity.x*slideFactor) <= hiddenModel.centerElementView.x && hiddenModel.pathToHiddenElement == LEFT)
                customSwipeSimulate = YES;
            
            if (customSwipeSimulate){
                [UIView animateWithDuration:0.2f animations:^{
                    pgr.view.center = hiddenModel.centerElementView;
                }];
            }
            BOOL newPosition = NO;
            
            switch (hiddenModel.pathToHiddenElement)
            {
                case UP:
                    if (abs(hiddenModel.centerElementView.y - pgr.view.center.y) < hiddenModel.sizeElement/2.f)
                        newPosition = YES;
                break;

                case DOWN:
                    if (abs(pgr.view.center.y - hiddenModel.centerElementView.y) < hiddenModel.sizeElement/2.f)
                        newPosition = YES;
                break;

                case RIGHT:
                    if (abs(pgr.view.center.x - hiddenModel.centerElementView.x) < hiddenModel.sizeElement/2.f)
                        newPosition = YES;
                break;

                case LEFT:
                    if (abs(pgr.view.center.x - hiddenModel.centerElementView.x) < hiddenModel.sizeElement/2.f)
                        newPosition = YES;
                break;

                default:
                    break;
            }

            if (newPosition)
                [self changeCenterElement:swipeElementModel withTypeTransform:hiddenModel.pathToHiddenElement];
            else
                [UIView animateWithDuration:0.2f animations:^{
                    pgr.view.center = swipeElementModel.centerElementView;
                }];
        }
    }
}
#pragma mark - Other methods
- (TapElementModel*)findHiddenElement
{
    TapElementModel *hiddenElementModel = nil;
    NSPredicate *predicateFindHiddenElement = [NSPredicate predicateWithFormat:@"hiddenElement == YES"];
    
    NSArray *array;
    
    array = [arrayElementPuzzle filteredArrayUsingPredicate:predicateFindHiddenElement];
    
    for (NSArray *arrayHorizontal in arrayElementPuzzle)
    {
        array = [arrayHorizontal filteredArrayUsingPredicate:predicateFindHiddenElement];
        if ([array count] > 0)
            hiddenElementModel = [array objectAtIndex:0];
        
        if (hiddenElementModel)
            break;
    }
    
    return hiddenElementModel;
}
- (NSArray*)getArrayValidElementWithHidden:(TapElementModel*)hiddenModel
{
    NSMutableArray *arrayAllValidElements = [NSMutableArray new];
    
    for (int typeMoved = 0; typeMoved < 4; typeMoved ++)
    {
        NSDictionary *dictModel = [self getElementWithParamatersPlace:hiddenModel.horizontalRow y:hiddenModel.verticalRow typeMoved:typeMoved];
        TapElementModel *variableModel = [dictModel objectForKey:@"model"];
        if (dictModel && ![variableModel isEqual:previousModelElement])
            [arrayAllValidElements addObject:dictModel];
    }
    
    return arrayAllValidElements;
}

- (NSDictionary *)getElementWithParamatersPlace:(int)x y:(int)y typeMoved:(int)typeMoved
{
    int horizontal = x;
    int vertical = y;
    int flagMovedType = 0;
    
    switch (typeMoved) {
        case UP:
            vertical -= 1;
            flagMovedType = DOWN;
            break;
            
        case DOWN:
            vertical += 1;
            flagMovedType = UP;
            break;
            
        case RIGHT:
            horizontal += 1;
            flagMovedType = LEFT;
            break;
            
        case LEFT:
            horizontal -= 1;
            flagMovedType = RIGHT;
            break;
            
        default:
            break;
            
    }
    
    TapElementModel *model = nil;
    NSDictionary *dictElement = nil;
    
    if ((vertical >= 0 && horizontal >= 0) && (vertical <=countElements - 1 && horizontal <= countElements - 1))
    {
        model = [[arrayElementPuzzle objectAtIndex:vertical] objectAtIndex:horizontal];
        dictElement = [NSDictionary dictionaryWithObjectsAndKeys:model, @"model", [NSNumber numberWithInt:flagMovedType],@"typeMoved", nil];
    }
    
    return dictElement;
}
- (TapElementModel *)findAndGetNearbyHiddenElement:(TapElementModel *)model
{
    
    TapElementModel *hiddenModel = nil;
    
    for (int typeMoved = 0; typeMoved < 4; typeMoved++)
    {
        int vertical = model.verticalRow;
        int horizontal = model.horizontalRow;
        
        switch (typeMoved) {
            case UP:
                vertical -= 1;
                break;
                
            case DOWN:
                vertical += 1;
                break;
                
            case RIGHT:
                horizontal += 1;
                break;
                
            case LEFT:
                horizontal -= 1;
                break;
                
            default:
                break;
        }
        if ((vertical >= 0 && vertical <= countElements - 1) && (horizontal >= 0 && horizontal <= countElements - 1))
        {
            TapElementModel *targetReabaseElement = [[arrayElementPuzzle objectAtIndex:vertical] objectAtIndex:horizontal];
            
            if (targetReabaseElement.hiddenElement)
            {
                targetReabaseElement.pathToHiddenElement = typeMoved;
                hiddenModel = targetReabaseElement;
                break;
            }
        }
    }
    
    return hiddenModel;
}
- (void)changeCenterElement:(TapElementModel*)model withTypeTransform:(int)typeMoved
{
    TapElementModel *currentModel = model;
    TapElementView  *view = (TapElementView *)[viewForElementsSynth viewWithTag:currentModel.indexElement];
    
    int horizontal = currentModel.horizontalRow;
    int vertical = currentModel.verticalRow;
    
    switch (typeMoved) {
        case UP:
            vertical -= 1;
            break;
            
        case DOWN:
            vertical += 1;
            break;
            
        case RIGHT:
            horizontal += 1;
            break;
            
        case LEFT:
            horizontal -= 1;
            break;
            
        default:
            break;
    }
    if ((vertical >= 0 && vertical <= countElements - 1) && (horizontal >= 0 && horizontal <= countElements - 1))
    {
        TapElementModel *targetRebaseElement = [[arrayElementPuzzle objectAtIndex:vertical] objectAtIndex:horizontal];
        
        if (targetRebaseElement.hiddenElement)
        {
            CGPoint centerTarget = targetRebaseElement.centerElementView;
            
            [self replaceModelInArray:currentModel targetModel:targetRebaseElement arrayForReplace:arrayElementPuzzle];
            
            if (newGameCreated)
            {
                NSDictionary *dictAnimationsOptions = [NSDictionary dictionaryWithObjectsAndKeys:view, @"view",
                                                            [NSNumber numberWithFloat:centerTarget.x], @"centerX",
                                                            [NSNumber numberWithFloat:centerTarget.y], @"centerY", nil];
                
                [arrayAnimationsNewGame addObject:dictAnimationsOptions];
            }
            else
                [UIView animateWithDuration:0.2 delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    view.center = centerTarget;
                } completion:^(BOOL finished)
                 {
                     if([self checkWin])
                     {
                         [UIView animateWithDuration:0.5 animations:^{
                             [viewForElementsSynth setAlpha:0.f];
                             [imageViewForGameSynth setAlpha:1.f];
                         }
                                          completion:^(BOOL finished)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"You Win!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                              [alert show];
                              [buttonShowOriginalImageSynth setHidden:YES];
                          }];
                     }
                 }];
        }
    }
}
- (void)replaceModelInArray:(TapElementModel *)currentModel targetModel:(TapElementModel *)targetModel arrayForReplace:(NSMutableArray *)array
{
    int horizontal = targetModel.horizontalRow;
    int vertical = targetModel.verticalRow;
    CGPoint centerTarget = targetModel.centerElementView;

    targetModel.horizontalRow = currentModel.horizontalRow;
    targetModel.verticalRow = currentModel.verticalRow;
    targetModel.centerElementView = currentModel.centerElementView;
    
    [[array objectAtIndex:currentModel.verticalRow] replaceObjectAtIndex:currentModel.horizontalRow withObject:targetModel];
    
    currentModel.verticalRow = vertical;
    currentModel.horizontalRow = horizontal;
    currentModel.centerElementView = centerTarget;
    
    [[array objectAtIndex:vertical] replaceObjectAtIndex:horizontal withObject:currentModel];
}
- (void)animationsQueueStart
{
    if ([arrayAnimationsNewGame count] == 0 || newGameCreated == NO)
    {
        [buttonShowOriginalImageSynth setHidden:NO];
        [self endProcessCreateNewGame];
    }
    else
    {
        NSDictionary *dictAnimationsOptions = [arrayAnimationsNewGame objectAtIndex:0];
        
        UIView *view = [dictAnimationsOptions objectForKey:@"view"];
        
        CGPoint centerTarget = CGPointMake([[dictAnimationsOptions objectForKey:@"centerX"] floatValue],
                                           [[dictAnimationsOptions objectForKey:@"centerY"] floatValue]);
        [UIView animateWithDuration:0.2 delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (newGameCreated)
                view.center = centerTarget;
        } completion:^(BOOL finished) {
            [arrayAnimationsNewGame removeObjectAtIndex:0];
            [self animationsQueueStart];
        }];
    }
}
- (void)endProcessCreateNewGame
{
    startNewGameButtonSynth.title = @"New Game";
    newGameCreated = NO;
    
    NSMutableArray *arrayElements = [NSMutableArray new];
    for (UIView *view in [viewForElementsSynth subviews])
        if ([view isKindOfClass:[TapElementView class]])
            [arrayElements addObject:((TapElementView *)view)];
    
    for (TapElementView *tapView in arrayElements)
        if (!CGPointEqualToPoint(tapView.center, tapView.model.centerElementView) && tapView.model.hiddenElement == NO)
        {
            int horizontalRow = (tapView.frame.origin.x + tapView.frame.size.width)/tapView.model.sizeElement - 1;
            int verticalRow   = (tapView.frame.origin.y + tapView.frame.size.height)/tapView.model.sizeElement - 1;
            
            TapElementModel *currentModel = tapView.model;
            
            TapElementModel *targetModel  = [[arrayElementPuzzle objectAtIndex:verticalRow] objectAtIndex:horizontalRow];
            
            [self replaceModelInArray:currentModel targetModel:targetModel arrayForReplace:arrayElementPuzzle];
            
        }
}
- (BOOL)checkWin
{
    BOOL win = YES;
    
    for (int y = 0; y < countElements; y++)
    {
        NSArray *arrayHorizontalForCheck = [arrayElementPuzzle objectAtIndex:y];

        for (int x = 0; x < countElements; x++)
        {
            TapElementModel *modelCheck    = [arrayHorizontalForCheck objectAtIndex:x];
            int index = [[NSString stringWithFormat:@"%d%d", y,x] intValue] + 100;
            int indexCheck = modelCheck.indexElement;
            
            if (index != indexCheck)
                win = NO;
        }
    }
    
    return win;
}
- (UIImage *)getCropImageElement:(int)x y:(int)y
{
    UIImage *image = imageViewForGameSynth.image;
    int lenghtElement = image.size.width/countElements;

    CGRect frameCrop;
    
    frameCrop = CGRectMake(x*lenghtElement, y*lenghtElement,
                           lenghtElement, lenghtElement);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frameCrop);
    
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIImage *imageResult = [[UIImage alloc] initWithCGImage: cropImage.CGImage
                                                      scale: 1.0
                                                orientation: UIImageOrientationUp];
    
    return imageResult;
}

@end

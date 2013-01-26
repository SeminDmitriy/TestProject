//
//  OptionsViewController.m
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import "OptionsViewController.h"
#import "Common.h"
@implementation OptionsViewController

@synthesize fieldCountElements       = fieldCountElementsSynth;
@synthesize stepperCountElements     = stepperCountElementsSynth;
@synthesize imageViewPictureForGame  = imageViewPictureForGameSynth;
@synthesize fieldCountMoves          = fieldCountMovesSynth;
@synthesize stepperCountMoves        = stepperCountMovesSynth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    fieldCountElementsSynth.text = [userDef objectForKey:@"countElements"];
    fieldCountMovesSynth.text = [userDef objectForKey:@"countMoves"];
    
    if ([fieldCountElementsSynth.text length] == 0)
        fieldCountElementsSynth.text = @"3";
    else
        [stepperCountElementsSynth setValue:[fieldCountElementsSynth.text doubleValue]];
    
    if ([fieldCountMovesSynth.text length] == 0)
        fieldCountMovesSynth.text = @"100";
    else
        [stepperCountMovesSynth setValue:[fieldCountMovesSynth.text doubleValue]];
    
    UIImage *imageForGame = [UIImage imageWithContentsOfFile:[userDef objectForKey:@"PathToPictureGame"]];
    if (!imageForGame)
        imageForGame = [UIImage imageNamed:@"standartPicture.jpg"];
    imageViewPictureForGameSynth.image = imageForGame;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)stepperElementsValueChanged:(id)sender
{
    fieldCountElementsSynth.text = [NSString stringWithFormat:@"%d", (int)stepperCountElementsSynth.value];
    
    [[NSUserDefaults standardUserDefaults] setValue:fieldCountElementsSynth.text forKey:@"countElements"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)stepperMovesValueChanged:(id)sender
{
    fieldCountMovesSynth.text = [NSString stringWithFormat:@"%d", (int)stepperCountMovesSynth.value];
    
    [[NSUserDefaults standardUserDefaults] setValue:fieldCountMovesSynth.text forKey:@"countMoves"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)btnStandartPicturePress:(id)sender
{
    [imageViewPictureForGameSynth setImage:[UIImage imageNamed:@"standartPicture.jpg"]];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:@"standartPicture.jpg" forKey:@"pictureForGame"];
    [userDef synchronize];
}
- (IBAction)btnPhotoPicturePress:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.showsCameraControls = YES;
        [picker setDelegate:self];
        [self presentModalViewController:picker animated:NO];
    }
}
- (IBAction)btnAlbumPicturePress:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setDelegate:self];
        [self presentModalViewController:picker animated:NO];
    }
}
#pragma mark - Picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:NO];
    
    UIImage * PortraitImage = [self fixOrientation:image];
    
    CGFloat height = PortraitImage.size.height;
    CGFloat width = PortraitImage.size.width;
    CGFloat sideOfTheSquare = 0.f;
    CGRect frameCrop;
    
    sideOfTheSquare = MIN(width, height);
    
    frameCrop = CGRectMake((image.size.width - sideOfTheSquare)/2.f, (image.size.height - sideOfTheSquare)/2.f, sideOfTheSquare, sideOfTheSquare);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([PortraitImage CGImage], frameCrop);
    
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIImage *imageResult = [[UIImage alloc] initWithCGImage: cropImage.CGImage
                                                      scale: 1.0
                                                orientation: UIImageOrientationUp];
    
    NSString      *path        = nil;
    NSFileManager *fileManager = nil;
    
    fileManager = [NSFileManager defaultManager];
    
    path = [Common pathToDocumentsDirectory];
    path = [path stringByAppendingString:@"TapTapPicture.jpg"];

//    if ([fileManager isWritableFileAtPath:path])
//    {
        NSData *dataImage = UIImageJPEGRepresentation(imageResult, 0.8f);
        [dataImage writeToFile:path atomically:YES];
//    }
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:@"TapTapPicture.jpg" forKey:@"pictureForGame"];
    [userDef synchronize];
    
    [imageViewPictureForGameSynth setImage:imageResult];
}
- (UIImage *)fixOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
        break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:

            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end

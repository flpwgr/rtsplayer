//
//  rtsplayerViewController.m
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import "rtsplayer.h"
#import "rtsplayerViewController.h"
#import "FFFrameExtractor.h"

@interface rtsplayerViewController (){
    BOOL isHidden;
    UIActivityIndicatorView *spinner;
    FFFrameExtractor *frameExtractor;
    NSOperationQueue *opQueue;
}

@property (nonatomic, retain) NSTimer *nextFrameTimer;

// TODO:
// COPIAR O FRAMEEXTRACTOR PARA O CORDOVA PLUGIN
// ADICIONAR OS FREEs DE MEMORIA, e so depois remover o BOOL abaixo
// REMOVER TODAS AS REFERENCIAS AO videoRtsplayer
// ACHO QUE SO
//
//////////////////////////////////////////////////////////////////////
//BOOL adhuasdhuasd = HUDAHSUdhasd
@end

@implementation rtsplayerViewController

// Load with xib :)
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    isHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.videoView setContentMode:UIViewContentModeScaleAspectFit];
    
    frameExtractor = [[FFFrameExtractor alloc] initWithInputPath:self.videoAddress];
    [self addTapGesture];
    
    opQueue = [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 1; // set to 1 to force everything to run on one thread;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showSpinner];
    [opQueue addOperationWithBlock:^{
        if( [frameExtractor start] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/15 target:self selector:@selector(displayNextFrame:) userInfo:nil repeats:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [frameExtractor stop];
                [self buttonDismissPressed:nil]; // deu erro volta
            });
        }
    }];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        //        video = [[ITBPlayer alloc] initWithVideo:@"rtsp://admin:admin@172.16.2.58:554/video"];
//        video = [[videoRTSPlayer alloc] initWithVideo:self.videoAddress];
//        
//        
//        if(video == nil) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                // hide loading spinner
//                [self buttonDismissPressed:nil];
//            });
//            
//            return;
//        }
//        
//        dispatch_async( dispatch_get_main_queue(), ^{
//            // Video started streaming, get frames
//            [self playButtonAction:nil];
//        });
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            // hide loading spinner
//            [self hideSpinner];
//        });
//    });
}
                           
#pragma mark - TESTE FFFrameExtractor

- (void)displayNextFrame:(NSTimer *)timer
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [opQueue addOperationWithBlock:^(void){
            if (frameExtractor.delegate == nil) {
                frameExtractor.delegate = self;
            }
            [frameExtractor processNextFrame];
        }];
    }
}

- (void)updateWithCurrentUIImage:(UIImage *)image
{
    if (image != nil) {
        [self hideSpinner];
        self.videoView.image = image;
    }
}

#pragma mark - FIM TESTE

-(void) showSpinner {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.bounds = self.view.frame;
    spinner.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

-(void) hideSpinner {
    [spinner stopAnimating];
}

-(IBAction)playButtonAction:(id)sender {
    lastFrameTime = -1;
    
    [video seekTime:0.0];
    
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/15
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}


//-(void)displayNextFrame:(NSTimer *)timer
//{
//    if (![video stepFrame]) {
//        return;
//    }
//    
//    self.videoView.image = video.currentImage;
//}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(void) addTapGesture {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    
    UIImageView *get = (UIImageView*)[self.view viewWithTag:100];
    
    [get setUserInteractionEnabled:YES];
    [get addGestureRecognizer:singleTap];
}

-(void) imageTap {
    
    isHidden = !isHidden;
    int direction;
    
    if(isHidden) {
        direction = -1;
    } else {
        direction = 1;
    }
    
    CGPoint navbarNewCenter = CGPointMake(self.navBar.center.x, self.navBar.center.y + self.navBar.frame.size.height * direction);
    CGPoint videoNewCenter  = CGPointMake(self.videoView.center.x, self.videoView.center.y + self.navBar.frame.size.height * direction);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    
    self.navBar.center = navbarNewCenter;
    self.videoView.center = videoNewCenter;
    
    CGRect videoFrame = self.videoView.frame;
    videoFrame.size = CGSizeMake(videoFrame.size.width, videoFrame.size.height + self.navBar.frame.size.height * direction * -1);
    self.videoView.frame = videoFrame;
    
    [UIView commitAnimations];
}

- (IBAction)buttonDismissPressed:(id)sender {
    // clean up timer
    NSLog(@"parando timer");
    [self.nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
    
    NSLog(@"fechando stream");
    
    // Close stream and free all contexts
    if(video != nil) {
        [video closeStream];
    }
    
    NSLog(@"Fechando viewcontroller");
    
    [self.origem finishOkAndDismiss];
}

@end

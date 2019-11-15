//
//  ViewController.m
//  ZegoExpressQuickStart-iOS-OC
//
//  Created by Patrick Fu on 2019/11/15.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ViewController.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

/// Apply AppID and AppSign from Zego
///
/// e.g.
/// static unsigned int appID = 1234567890;
/// static NSString *appSign = @"abcdefghijklmnopqrstuvwzyv123456789abcdefghijklmnopqrstuvwzyz123";
static unsigned int appID = <#Fill in your appID#>;
static NSString *appSign = <#Fill in your appSign#>;


@interface ViewController () <ZegoEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *engine;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// Preview and Play View
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

// CreateEngine
@property (nonatomic, assign) BOOL isTestEnv;
@property (weak, nonatomic) IBOutlet UILabel *appIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *appSignLabel;
@property (weak, nonatomic) IBOutlet UILabel *isTestEnvLabel;
@property (weak, nonatomic) IBOutlet UIButton *createEngineButton;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;

// PublishStream
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;


@end

@implementation ViewController

#pragma mark - Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isTestEnv = YES;
    self.roomID = @"QuickStartRoom-1";
    
    // Use a random number as the UserID
    srand((unsigned)time(0));
    self.userID = [NSString stringWithFormat:@"%u", (unsigned)rand()];
    
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"Quick Start";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    
    self.appIDLabel.text = [NSString stringWithFormat:@"AppID: %u", appID];
    self.appSignLabel.text = [NSString stringWithFormat:@"AppSign: %@", appSign];
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];
    self.isTestEnvLabel.text = [NSString stringWithFormat:@"isTestEnv: %@", self.isTestEnv ? @"YES" : @"NO"];
}

#pragma mark - Step 1: CreateEngine

- (IBAction)createEngineButtonClick:(UIButton *)sender {
    
    // Create an ZegoExpressEngine and add self as a delegate (ZegoEventHandler)
    self.engine = [ZegoExpressEngine createEngineWithAppID:appID appSign:appSign isTestEnv:self.isTestEnv scenario:ZegoScenarioGeneral eventHandler:self];
    
    // Print log
    [self appendLog:@" 🚀 Initialize the ZegoExpressEngine"];
    
    // Add a flag to the button for successful operation
    [self.createEngineButton setTitle:@"✅ CreateEngine" forState:UIControlStateNormal];
}

#pragma mark - Step 2: LoginRoom

- (IBAction)loginRoomButtonClick:(UIButton *)sender {
    if (self.engine) {
        // Instantiate a ZegoUser object
        ZegoUser *user = [ZegoUser userWithUserID:self.userID];
        
        // Instantiate a ZegoRoomConfig object with the default configuration
        ZegoRoomConfig *roomConfig = [ZegoRoomConfig defaultConfig];
        
        // Login room
        [self.engine loginRoom:self.roomID user:user config:roomConfig];
        
        // Print log
        [self appendLog:@" 🚪 Start login room"];
    } else {
        [self appendLog:@" ‼️ Please initialize the ZegoExpressEngine first"];
    }
}

#pragma mark - Step 3: StartPublishing

- (IBAction)startPublishingButtonClick:(UIButton *)sender {
    if (self.engine) {
        // Instantiate a ZegoCanvas for local preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView viewMode:ZegoViewModeAspectFill];
        
        // Start preview
        [self.engine startPreview:previewCanvas];
        
        NSString *publishStreamID = self.publishStreamIDTextField.text;
        
        // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
        [self.engine startPublishing:publishStreamID];
        
        // Print log
        [self appendLog:@" 📤 Start publishing stream"];
    } else {
        [self appendLog:@" ‼️ Please initialize the ZegoExpressEngine first"];
    }
}

#pragma mark - Step 4: StartPlaying

- (IBAction)startPlayingButtonClick:(UIButton *)sender {
    if (self.engine) {
        // Instantiate a ZegoCanvas for local preview
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView viewMode:ZegoViewModeAspectFill];
        
        NSString *playStreamID = self.playStreamIDTextField.text;
        
        // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
        [self.engine startPlayingStream:playStreamID canvas:playCanvas];
        
        // Print log
        [self appendLog:@" 📥 Strat playing stream"];
    } else {
        [self appendLog:@" ‼️ Please initialize the ZegoExpressEngine first"];
    }
}

#pragma mark - Exit

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        
        // Logout room before exiting
        [self.engine logoutRoom:self.roomID];
        
        // Can destroy the engine when you don't need audio and video calls
        [ZegoExpressEngine destroyEngine];
    }
    [super viewDidDisappear:animated];
}

- (void)exit {
    // Logout room before exiting
    [self.engine logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    [ZegoExpressEngine destroyEngine];
    
    [self.createEngineButton setTitle:@"CreateEngine" forState:UIControlStateNormal];
    [self.loginRoomButton setTitle:@"LoginRoom" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"StartPublishing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"StartPlaying" forState:UIControlStateNormal];
    
    self.logTextView.text = @"";
}

#pragma mark - ZegoEventHandler Delegate

/// Room status change notification
- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode room:(NSString *)roomID {
    if (state == ZegoRoomStateConnected && errorCode == 0) {
        [self appendLog:@" 🚩 🚪 Login room success"];
        
        // Add a flag to the button for successful operation
        [self.loginRoomButton setTitle:@"✅ LoginRoom" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@" 🚩 ❌ 🚪 Login room fail"];
        
        [self.loginRoomButton setTitle:@"❌ LoginRoom" forState:UIControlStateNormal];
    }
}

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode stream:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@" 🚩 📤 Publishing stream success"];
        
        // Add a flag to the button for successful operation
        [self.startPublishingButton setTitle:@"✅ StartPublishing" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@" 🚩 ❌ 📤 Publishing stream fail"];
        
        [self.startPublishingButton setTitle:@"❌ StartPublishing" forState:UIControlStateNormal];
    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode stream:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@" 🚩 📥 Playing stream success"];
        
        // Add a flag to the button for successful operation
        [self.startPlayingButton setTitle:@"✅ StartPlaying" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@" 🚩 ❌ 📥 Playing stream fail"];
        
        [self.startPlayingButton setTitle:@"❌ StartPlaying" forState:UIControlStateNormal];
    }
}



#pragma mark - Helper Methods

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@%@", oldText, newLine, tipText];
    
    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

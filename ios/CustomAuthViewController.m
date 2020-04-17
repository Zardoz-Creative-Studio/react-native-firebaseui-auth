//
//  CustomAuthViewController.m
//  Pods
//
//  Created by Robert Greene on 4/16/20.
//

#import "CustomAuthViewController.h"

@interface CustomAuthViewController ()

@end

@implementation CustomAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)cancelAuthorization {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult,
                                                     NSError * _Nullable error) {
      
        if(error){
            [super cancelAuthorization];
        } else {
            [self.authUI.delegate authUI:self.authUI didSignInWithUser:authResult.user error:error];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end

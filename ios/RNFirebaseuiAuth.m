
#import "RNFirebaseuiAuth.h"
#import "CustomAuthViewController.h"

@interface RNFirebaseuiAuth ()
@property (nonatomic, retain) FUIAuth *authUI;
@property (nonatomic) RCTPromiseResolveBlock _resolve;
@property (nonatomic) RCTPromiseRejectBlock _reject;
@end

@implementation RNFirebaseuiAuth

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.authUI = [FUIAuth defaultAuthUI];
        self.authUI.autoUpgradeAnonymousUsers = true;
        self.authUI.delegate = self;
    }
    return self;
}

- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
    return [[CustomAuthViewController alloc] initWithAuthUI:authUI];
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(signIn:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSMutableArray<id<FUIAuthProvider>> *providers = [[NSMutableArray alloc] init];
    NSArray<NSString *> *optProviders = [options objectForKey:@"providers"];

    for (int i = 0; i < [optProviders count]; i++)
    {
        if ([optProviders[i] isEqualToString:@"facebook"]) {
            [providers addObject:[[FUIFacebookAuth alloc] init]];
        }
        else if ([optProviders[i] isEqualToString:@"google"]) {
            [providers addObject:[[FUIGoogleAuth alloc] init]];
        }
        else if ([optProviders[i] isEqualToString:@"email"]) {
            [providers addObject:[[FUIEmailAuth alloc] init]];
        }
        else if ([optProviders[i] isEqualToString:@"phone"]) {
            [providers addObject:[[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]]];
        }
    }

    self.authUI.providers = providers;
    self.authUI.TOSURL = [NSURL URLWithString:options[@"tosUrl"]];
    self.authUI.privacyPolicyURL = [NSURL URLWithString:options[@"privacyPolicyUrl"]];

    UINavigationController *authViewController = [self.authUI authViewController];
    UIViewController *rootVC = UIApplication.sharedApplication.delegate.window.rootViewController;
    [rootVC presentViewController:authViewController animated:YES completion:nil];
    self._resolve = resolve;
    self._reject = reject;
}

RCT_EXPORT_METHOD(signOut:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error;
    [self.authUI signOutWithError:&error];
    if (error) {
        reject(@"102", @"Sign out error", error);
        return;
    }
    resolve(@{@"success": @(true)});
}

RCT_EXPORT_METHOD(getCurrentUser:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    FIRUser *user = self.authUI.auth.currentUser;
    if (user) {
        NSDictionary *authResultDict = [self mapUser:user];
        resolve(authResultDict);
        return;
    }
    resolve(user);
}

- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
    if (error) {
        self._reject(@"101", @"Sign in error", error);
        return;
    }
    if (user) {
        NSDictionary *authResultDict = [self mapUser:user];
        self._resolve(authResultDict);
        return;
    }
    self._resolve(@{@"success": @(false)});
}

- (NSDictionary*)mapUser:(nullable FIRUser*)user {
    return @{
        @"uid": user.uid ?: [NSNull null],
        @"displayName": user.displayName ?: [NSNull null],
        @"photoURL": user.photoURL ?: [NSNull null],
        @"email": user.email ?: [NSNull null],
        @"phoneNumber": user.phoneNumber ?: [NSNull null],
    };
}

@end



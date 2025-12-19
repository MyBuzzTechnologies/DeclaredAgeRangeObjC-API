//
//  ViewController.m
//  DeclaredAgeRangeObjCTestApp
//
//  Created by Chris Pimlott on 18/12/2025.
//

#import "ViewController.h"
#import "DeclaredAgeRangeObjC/DeclaredAgeRangeObjC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showAlertIn:(UIViewController *)viewController
              title:(NSString *)title
            message:(NSString *)message {
    
    // 1. Create the alert controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 2. Create the "OK" action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    // 3. Add the action and present
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)buttonPressed:(id)sender {
    [DeclaredAgeRangeObjCWrapper fetchAgeRangeWithMinimumAge:13 maximumAge:13 viewController:self completion:^(NSObject * _Nullable resp, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error fetching age range: %@", error.localizedDescription);
            [self showAlertIn:self title:@"Error" message:error.localizedDescription];
            return;
        }
        
        if ([resp isKindOfClass:[DeclaredAgeRangeResponse class]]) {
            DeclaredAgeRangeResponse *response = (DeclaredAgeRangeResponse *)resp;
                        
            NSLog(@"Age range received: %ld", (long)response.resultCode);
            NSString* msg = [NSString stringWithFormat:@"Return Code: %ld, Age: %ld", (long)response.resultCode, (long)response.upperBound];
            [self showAlertIn:self title:@"Ok" message:msg];
            
        } else {
            NSLog(@"Object was not of type DeclaredAgeRangeResponse");
            [self showAlertIn:self title:@"Error" message:@"Object was not of type DeclaredAgeRangeResponse"];
        }
    }];
}

@end

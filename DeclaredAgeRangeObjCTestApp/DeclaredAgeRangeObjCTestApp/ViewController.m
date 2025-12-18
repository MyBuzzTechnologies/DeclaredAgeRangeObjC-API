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

- (IBAction)buttonPressed:(id)sender {
    [DeclaredAgeRangeObjCWrapper fetchAgeRangeWithMinimumAge:13 maximumAge:13 viewController:self completion:^(NSObject * _Nullable resp, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error fetching age range: %@", error.localizedDescription);
            return;
        }
        
        if ([resp isKindOfClass:[DeclaredAgeRangeResponse class]]) {
            DeclaredAgeRangeResponse *response = (DeclaredAgeRangeResponse *)resp;
                        
            NSLog(@"Age range received: %ld", (long)response.resultCode);
            
        } else {
            NSLog(@"Object was not of type DeclaredAgeRangeResponse");
        }
    }];
}

@end

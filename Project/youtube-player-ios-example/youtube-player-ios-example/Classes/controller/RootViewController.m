//
//  RootViewController.m
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/25/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Instance Method
- (void)pushViewController:(UIViewController *)vc
                  animated:(BOOL)animated
{
//    if ([self.vcList count] > 0) {
//        [self.view_bg setBlurLevel:1.0];
//    }
//    
//    [self.vcList addObject:vc];
    [self addChildViewController:vc];
//    [self.view_subview addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
//    if (animated) {
//        vc.view.frame = CGRectMake( self.view_subview.frame.size.width,
//                                   0,
//                                   self.view_subview.bounds.size.width,
//                                   self.view_subview.bounds.size.height);
//        
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             vc.view.frame = self.view_subview.bounds;
//                             
//                             if (self.activeVC) {
//                                 CGRect frame = self.activeVC.view.frame;
//                                 frame.origin.x = -frame.size.width;
//                                 self.activeVC.view.frame = frame;
//                             }
//                         }
//                         completion:^(BOOL finished) {
//                             if (self.activeVC) {
//                                 [self.activeVC.view removeFromSuperview];
//                                 [self.activeVC removeFromParentViewController];
//                             }
//                             
//                             self.activeVC = vc;
//                         }];
//    } else {
//        vc.view.frame = self.view_subview.bounds;
//        
//        if (self.activeVC) {
//            [self.activeVC.view removeFromSuperview];
//            [self.activeVC removeFromParentViewController];
//        }
//        
//        self.activeVC = vc;
//    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
//    if ([self.vcList count] <= 1) {
//        // have only 1 view controller
//        return;
//    }
    
//    UIViewController *previousVC = [self.vcList objectAtIndex:([self.vcList count] - 2)];
//    [self.vcList removeLastObject];
    
    //[self addChildViewController:previousVC];
//    [self.view_subview addSubview:previousVC.view];
//    [previousVC didMoveToParentViewController:self];
    
//    if (animated) {
//        previousVC.view.frame = CGRectMake(-self.view_subview.frame.size.width, 0, self.view_subview.bounds.size.width, self.view_subview.bounds.size.height);
//        
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             previousVC.view.frame = self.view_subview.bounds;
//                             
//                             if (self.activeVC) {
//                                 CGRect frame = self.activeVC.view.frame;
//                                 frame.origin.x = frame.size.width;
//                                 self.activeVC.view.frame = frame;
//                             }
//                         }
//                         completion:^(BOOL finished) {
//                             if (self.activeVC) {
//                                 [self.activeVC.view removeFromSuperview];
//                                 [self.activeVC removeFromParentViewController];
//                             }
//                             
//                             self.activeVC = previousVC;
//                         }];
//    } else {
//        previousVC.view.frame = self.view_subview.bounds;
//        
//        if (self.activeVC) {
//            [self.activeVC.view removeFromSuperview];
//            [self.activeVC removeFromParentViewController];
//        }
//        
//        self.activeVC = previousVC;
//    }
}


@end

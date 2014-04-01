//
//  MultiTouchViewController.m
//  MultitouchTest
//
//  Created by Chris Lee on 1/4/14.
//  Copyright (c) 2014 Chris Lee. All rights reserved.
//

#import "MultiTouchViewController.h"

@interface MultiTouchViewController ()

@end

@implementation MultiTouchViewController

NSLock *livePointsLock;
NSMutableArray *livePoints;
UITextView *textView;
UILabel *label;

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
    // Do any additional setup after loading the view.
    
    livePoints = [NSMutableArray arrayWithCapacity:0];
    NSLog(@"View Loaded");
    self.view.multipleTouchEnabled = YES;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    int width = (int) [self.view frame].size.width;
    int height = (int) [self.view frame].size.height;
    
    CGRect rect = CGRectMake(0, 0, width, height/2);
    textView = [[UITextView alloc] initWithFrame:rect];
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;
    
    [self.view addSubview:textView];
 
    
    // button for clear text
    int btnWidth = 60;
    int btnHeight = 25;

    rect = CGRectMake( width-btnWidth, height-btnHeight, btnWidth-2, btnHeight-2);
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearBtn.frame = rect;
    [clearBtn.layer setCornerRadius:5.0f];
    [clearBtn setBackgroundColor:[UIColor grayColor]];
    [clearBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    
    [clearBtn addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.view addSubview:clearBtn];
    
    
    // label to show points
    label = [[UILabel alloc] initWithFrame:CGRectMake(2, height-25, 23, 23)];
    [self.view addSubview:label];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cacheBeginPointForTouches:touches];
    [self printPoints];
}

- (void)cacheBeginPointForTouches:(NSSet *)touches {
    if ([touches count] > 0) {
        [livePointsLock lock];
        for (UITouch *touch in touches) {
            [livePoints addObject:touch];
        }
        [livePointsLock unlock];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self printPoints];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] > 0) {
        [livePointsLock lock];
        for (UITouch *touch in touches) {
            [livePoints removeObject:touch];
        }
        [livePointsLock unlock];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] > 0) {
        [livePointsLock lock];
        for (UITouch *touch in touches) {
            [livePoints removeObject:touch];
        }
        [livePointsLock unlock];
    }
}

- (void)printPoints {
    [livePointsLock lock];
    if ( [livePoints count] > 0 ) {
        NSArray *tmp = [livePoints sortedArrayUsingComparator:^NSComparisonResult( id a, id b) {
            CGPoint t1 = [(UITouch *) a locationInView:self.view];
            CGPoint t2 = [(UITouch *) b locationInView:self.view];
            if ( (float)t1.y < (float)t2.y ) {
                return (NSComparisonResult) NSOrderedAscending;
            } else {
                return (NSComparisonResult) NSOrderedDescending;
            }
            if ( (float)t1.x < (float)t2.x ) {
                return (NSComparisonResult) NSOrderedAscending;
            } else {
                return (NSComparisonResult) NSOrderedDescending;
            }
        }];
        int i=0;
        NSString *text = @"";
        for ( UITouch *touch in tmp ) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"%d:\tx:%03.0f\ty:%03.0f\n", ++i, (float) [touch locationInView:self.view].x, (float) [touch locationInView:self.view].y]];
        }
        NSLog ( @"%@", text );
        [textView setText:text];
    }
    [label setText:[NSString stringWithFormat:@"%d", [livePoints count]]];
    [livePointsLock unlock];
}

- (void)clearText:(id)sender {
    [livePointsLock lock];
    [livePoints removeAllObjects];
    [livePointsLock unlock];
    [textView setText:@""];
    [label setText:@"0"];
}

@end

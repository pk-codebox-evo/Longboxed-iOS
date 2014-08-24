//
//  LBXIssueDetailViewController.m
//  Longboxed-iOS
//
//  Created by johnrhickey on 8/19/14.
//  Copyright (c) 2014 Longboxed. All rights reserved.
//

#import "LBXIssueDetailViewController.h"
#import "LBXTitleServices.h"

#import "UIImageView+LBBlurredImage.h"
#import "UIFont+customFonts.h"
#import "UIImage+ImageEffects.h"
#import "JTSImageViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>

@interface LBXIssueDetailViewController ()

@property (nonatomic) IBOutlet UIImageView *backgroundCoverImageView;
@property (nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic) IBOutlet UIImageView *coverImageView;
@property (nonatomic) IBOutlet UIButton *imageButton;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic) IBOutlet UILabel *distributorCodeLabel;
@property (nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic) IBOutlet UIButton *publisherButton;
@property (nonatomic) IBOutlet UIButton *releaseDateButton;

@property (nonatomic) NSArray *alternates;
@property (nonatomic, copy) UIImage *issueImage;
@property (nonatomic, copy) LBXIssue *issue;

@end

@implementation LBXIssueDetailViewController

- (instancetype)initWithMainImage:(UIImage *)image andAlternates:(NSArray *)alternates {
    if(self = [super init]) {
        _issueImage = [image copy];
        _backgroundCoverImageView = [UIImageView new];
        _descriptionTextView = [UITextView new];
        _coverImageView = [UIImageView new];
        _alternates = alternates;
    }
    return self;
}

- (instancetype)initWithAlternates:(NSArray *)alternates {
    if(self = [super init]) {
        _backgroundCoverImageView = [UIImageView new];
        _descriptionTextView = [UITextView new];
        _coverImageView = [UIImageView new];
        _alternates = alternates;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _issue = [LBXIssue MR_findFirstByAttribute:@"issueID" withValue:_issueID];
    NSLog(@"Selected issue %@", _issue.issueID);
    
    if (_issueImage == nil) {
        _issueImage = [UIImage new];
        [self setupImageViews];
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self setupImages];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&#?[a-zA-Z0-9z]+;" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *modifiedTitleString = [regex stringByReplacingMatchesInString:_issue.title.name options:0 range:NSMakeRange(0, [_issue.title.name length]) withTemplate:@""];
    _titleLabel.text = [NSString stringWithFormat:@"%@ #%@", modifiedTitleString, _issue.issueNumber];
    
    _subtitleLabel.text = _issue.subtitle;
    if (_issue.subtitle) {
        NSString *modifiedSubtitleString = [regex stringByReplacingMatchesInString:_issue.subtitle options:0 range:NSMakeRange(0, [_issue.subtitle length]) withTemplate:@""];
        _subtitleLabel.text = modifiedSubtitleString;
    }
    _distributorCodeLabel.text = _issue.diamondID;
    _priceLabel.text = [NSString stringWithFormat:@"$%.02f", [_issue.price floatValue]];
    [_publisherButton setTitle:_issue.publisher.name
                      forState:UIControlStateNormal];
    [_releaseDateButton setTitle:[LBXTitleServices localTimeZoneStringWithDate:_issue.releaseDate]
                      forState:UIControlStateNormal];
    
    [_publisherButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_releaseDateButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _publisherButton.tag = 1;
    _releaseDateButton.tag = 2;
    
    if (!_issue.releaseDate) {
        [_releaseDateButton setTitle:@"UNKNOWN" forState:UIControlStateNormal];
        _releaseDateButton.userInteractionEnabled = NO;
        _releaseDateButton.tintColor = [UIColor whiteColor];
    }
    if (!_issue.price) {
        _priceLabel.text = @"UNKNOWN";
    }
    if (!_issue.publisher.name) {
        [_publisherButton setTitle:@"UNKNOWN" forState:UIControlStateNormal];
        _publisherButton.userInteractionEnabled = NO;
        _publisherButton.tintColor = [UIColor whiteColor];
    }
    if (!_issue.diamondID) {
        _distributorCodeLabel.text = @"UNKNOWN";
    }
    
    NSString *modifiedDescriptionString = [regex stringByReplacingMatchesInString:_issue.issueDescription options:0 range:NSMakeRange(0, [_issue.issueDescription length]) withTemplate:@""];
    _descriptionTextView.text = modifiedDescriptionString;
    _descriptionTextView.selectable = NO;
    [_descriptionTextView scrollRangeToVisible:NSMakeRange(0, 0)]; // Scroll to the top
    
    [_imageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _imageButton.tag = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 0:
        {
            // Create image info
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
            imageInfo.image = _coverImageView.image;
            imageInfo.referenceRect = _imageButton.frame;
            imageInfo.referenceView = _imageButton.superview;
            
            // Setup view controller
            JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                   initWithImageInfo:imageInfo
                                                   mode:JTSImageViewControllerMode_Image
                                                   backgroundStyle:JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred];
            
            // Present the view controller.
            [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
            
            break;
        }
        case 1:
        {
            NSLog(@"pressed 1");
            break;
        }
        case 2:
        {
            NSLog(@"pressed 2");
            break;
        }
    }
}

#pragma mark Private Methods

- (void)setupImageViews
{
    UIImageView *imageView = [UIImageView new];
    // Get the image from the URL and set it
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_issue.coverImage]] placeholderImage:[UIImage imageNamed:@"NotAvailable"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        _issueImage = image;
        [self setupImages];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        _issueImage = [UIImage imageNamed:@"NotAvailable.jpeg"];
        [self setupImages];
        
    }];
}


- (void)setupImages
{
    [_backgroundCoverImageView setImageToBlur:_issueImage blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];
    [_issueImage applyDarkEffect];
    
    UIImage *blurredImage = [_issueImage applyBlurWithRadius:0.0
                                                   tintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]
                                       saturationDeltaFactor:0.5
                                                   maskImage:nil];
    
    [_coverImageView setImage:blurredImage];
    [_coverImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_coverImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_coverImageView(==%d)]", (int)self.view.frame.size.height/2]
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_coverImageView)]];    
}

@end
//
//  ImageViewController.m
//  Imaginarium
//
//  Created by S N on 1/24/14.
//  Copyright (c) 2014 S N. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView  *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) UIImage *image;
@end

@implementation ImageViewController


-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView=scrollView;
    _scrollView.minimumZoomScale=0.05;
    _scrollView.maximumZoomScale=2.0;
    _scrollView.delegate=self;
    
    self.scrollView.contentSize=self.image ? self.image.size: CGSizeZero;
    //because image may be set before setting scroll view which happens when storyboard is set i.e setting of outlets which is after prepare for segue
}

-(void)setImageURL:(NSURL *)imageURL
{
    _imageURL=imageURL;
    //self.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
    [self startDownloadingImage];
}

-(void)startDownloadingImage
{
    self.image=nil;
    if(self.imageURL)
    {
        [self.spinner startAnimating];
        NSURLRequest *request=[NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session=[NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task= [session downloadTaskWithRequest:request
                                                       completionHandler: ^(NSURL *localfile,NSURLResponse *response,NSError *err){
                                                           if (!err) {
                                                               if (request.URL==self.imageURL) // to check whether there was change in the selection 
                                                               {
                                                                   UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                   
                                                                   
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       self.image=image;
                                                                   });
                                                                    //[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                                                                   
                                                                   
                                                                }
                                                           }
                                                       }];
        [task resume];
    }
}

-(UIImageView *)imageView
{
    if(!_imageView) _imageView=[[UIImageView alloc] init];
    return _imageView;
    
}

-(UIImage *)image
{
    return self.imageView.image;
}
-(void)setImage:(UIImage *)image
{
    self.imageView.image=image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize=self.image ? self.image.size: CGSizeZero;
    [self.spinner stopAnimating];
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

@end

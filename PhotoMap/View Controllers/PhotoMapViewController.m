//
//  PhotoMapViewController.m
//  PhotoMap
//
//  Created by emersonmalca on 7/8/18.
//  Copyright © 2018 Codepath. All rights reserved.
//

#import "PhotoMapViewController.h"
#import <MapKit/MapKit.h>
#import "LocationsViewController.h"
#import "PhotoAnnotation.h"
#import "FullImageViewController.h"

@interface PhotoMapViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation PhotoMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set initial visible region to San Francisco
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:sfRegion animated:false];
    
    self.mapView.delegate = self;
}

- (IBAction)onCameraClick:(id)sender {
    // instantiate a UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    // check if camera is supported and choose source type
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// imagePickerController delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Save image captured by the UIImagePickerController to a property
    self.image = info[UIImagePickerControllerOriginalImage];
    
    // Dismiss UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:^(){
        // segue to LocationsViewController
        [self performSegueWithIdentifier:@"tagSegue" sender:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationsViewController:(LocationsViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    [self.navigationController popToViewController:self animated:YES];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    // call add annotation method on mapView instance
   PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.photo = [self resizeImage:self.image withSize:CGSizeMake(50.0, 50.0)];
    [self.mapView addAnnotation:annotation];

}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
 UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];

 resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
 resizeImageView.image = image;

 UIGraphicsBeginImageContext(size);
 [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();

 return newImage;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    // add camera icon to each annotation
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        annotationView.canShowCallout = true;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    imageView.image = self.image;
    annotationView.image = [self resizeImage:self.image withSize:CGSizeMake(50.0, 50.0)];
    
    return annotationView;
}

// delegate method when callout accessory is tapped
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    UIImageView *imageView = (UIImageView*)view.leftCalloutAccessoryView;
    [self performSegueWithIdentifier:@"fullImageSegue" sender:imageView.image];
};

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"tagSegue"]) {
        // set delegate
        LocationsViewController *destinationController = [segue destinationViewController];
        destinationController.delegate = self;
    }
    else  if ([segue.identifier isEqualToString:@"fullImageSegue"]) {
           // set photo
           FullImageViewController *destinationController = [segue destinationViewController];
        destinationController.image = sender;
       }
    
}

@end

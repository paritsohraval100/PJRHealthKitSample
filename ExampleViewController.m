//
//  ExampleViewController.m
//  HealthKitExample
//
//  Created by Paritosh Raval on 21/10/14.
//  Copyright (c) 2014 paritosh. All rights reserved.
//

#import "ExampleViewController.h"
@import HealthKit;

@interface ExampleViewController ()

@property (nonatomic, strong) HKHealthStore *healthStore;


@end

@implementation ExampleViewController

- (void)authentication
{
    self.healthStore = [[HKHealthStore alloc] init];
    
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the user interface based on the current user's health information.
            });
        }];
    }

}

- (IBAction)getWeight:(id)sender
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    
    // Since we are interested in retrieving the user's latest sample
    // we sort the samples in descending order by end date
    // and set the limit to 1
    // We are not filtering the data, and so the predicate is set to nil.
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // construct the query & since we are not filtering the data the predicate is set to nil
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:weightType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if(error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

        }
        // if there is a data point, dispatch to the main queue
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HKQuantitySample *quantitySample = results.firstObject;
                
                // pull out the quantity from the sample
                HKQuantity *quantity = quantitySample.quantity;
                
                HKUnit *weightUnit = [HKUnit poundUnit];
                double usersWeight = [quantity doubleValueForUnit:weightUnit];
                NSString *str = [NSString stringWithFormat:@"%@ lbs", [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];

            });
        }
    }];
    
    // do not forget to execute the query after its constructed
    [self.healthStore executeQuery:query];


}

- (IBAction)storeWeight:(id)sender
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKUnit *poundUnit = [HKUnit poundUnit];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:100];
    
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        
        if(error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weight added to health app" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

        }
    }];
    
}


#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects: heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects: heightType, weightType, birthdayType, biologicalSexType, nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self authentication];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

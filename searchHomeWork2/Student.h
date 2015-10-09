//
//  Student.h
//  searchHomeWork2
//
//  Created by Fox Lis on 09.10.15.
//  Copyright © 2015 Egor Bakaykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property(strong, nonatomic)NSString* firstName;
@property(strong, nonatomic)NSString* lastName;

@property(strong, nonatomic)NSDate* birthDate;
@property(strong, nonatomic)NSDateComponents* birthDateComponents;

- (Student*) getStudentInfo;

@end

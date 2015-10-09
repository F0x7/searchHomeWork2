//
//  Student.m
//  searchHomeWork2
//
//  Created by Fox Lis on 09.10.15.
//  Copyright © 2015 Egor Bakaykin. All rights reserved.
//

#import "Student.h"
#import "NameGenerator.h"


@implementation Student

- (Student*) getStudentInfo {
    
    [self generateStudentName];
    [self generateBirthDate];
    
    
    return self;
}

- (void) generateBirthDate{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    [dateComp setYear:[dateComp year] - arc4random() % 50];
    [dateComp setMonth:arc4random() % 31];
    [dateComp setDay:arc4random() % 31];
    
    NSDate *date = [calendar dateFromComponents:dateComp];
    
    NSDateComponents *components =
    [[NSCalendar currentCalendar]components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date];
    
    self.birthDateComponents = components;
    self.birthDate = date;
}
- (void) generateStudentName {
    NameGenerator* nameGenerator = [[NameGenerator alloc]init];
    NSString* name = [nameGenerator getName];
    
    NSArray* nameParts = [NSArray array];
    nameParts = [name componentsSeparatedByString:@" "];
    
    self.firstName = [nameParts firstObject];
    self.lastName = [nameParts lastObject];
}

@end

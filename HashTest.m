//
//  HashTest.m
//  TwoSumHash
//
//  Created by Frank Giraffe on 4/18/12.
//  Copyright (c) 2012 Like the Animal Productions. All rights reserved.
//

#import "HashTest.h"

#import "DebugUtils.h"

#define TEST_DATA_COUNT (100000)
#define TEST_DATA_PATH @"/Users/fgiraffe/Code/StanfordAlgorithmsTestData/HashInt.txt"

static NSMutableArray* CreateTestData(NSString* filePath)
{
    uint32_t        inputInt;
    NSMutableArray  *inputArray = [[NSMutableArray alloc] initWithCapacity:TEST_DATA_COUNT];
    NSNumber        *inputNumber = nil;
    
    QuietLog(@"Reading input file <%@>", filePath);
    const char *cStringPath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    FILE *bigTextFile = fopen(cStringPath, "r");
    if (bigTextFile) {
        
        while (!feof(bigTextFile)) {
            fscanf(bigTextFile, "%d", &inputInt);
            inputNumber = [NSNumber numberWithInt:inputInt];
            [inputArray addObject:inputNumber];
        }
    }
    fclose(bigTextFile);
    
    QuietLog(@"Read %d input numbers.", [inputArray count]);
    
    return inputArray;
}

static NSInteger numSortAscend(id num1, id num2, void *context) {
    return [num1 compare:num2];
}


static BOOL HashTwoSum(NSMutableArray *numbers, uint32_t targetNumber)
{
    int32_t    x = 0, y = 0;
    NSUInteger  i;
    NSNumber    *yNum = nil;
    BOOL        foundSum = NO;
    NSArray     *sortedNumbers = nil;
    
    sortedNumbers = [numbers sortedArrayUsingFunction:numSortAscend context:NULL];
    
    NSSet *sortedSet = [NSSet setWithArray:sortedNumbers];
    
    
    for (i = 0; i < [numbers count] && (foundSum == NO); i++) {
        x = [[sortedNumbers objectAtIndex:i] intValue];
        y = targetNumber - x;
        
        if (y > 0) {
            yNum = [NSNumber numberWithInt:y];
            if( [sortedSet member:yNum] ) {
                foundSum = YES;
                break;
            }
        }
    }
    
    if (foundSum) {
        QuietLog(@"Found sum %d", targetNumber );
        QuietLog(@"\tx:%d \ty:%d Target: %d", x, y, targetNumber);
    }
    else
        QuietLog(@"Did NOT find %d.", targetNumber);
    
    return foundSum;
}



static BOOL BinarySearchTwoSum(NSMutableArray *numbers, uint32_t targetNumber)
{
    int32_t    x = 0, y = 0;
    unsigned int index = 0;
    NSUInteger  i;
    NSNumber    *yNum = nil;
    BOOL        foundSum = NO;
    NSArray     *sortedNumbers = nil;
    
    sortedNumbers = [numbers sortedArrayUsingFunction:numSortAscend context:NULL];
    
    for (i = 0; i < [numbers count]; i++) {
        
        x = [[numbers objectAtIndex:i] intValue];
        y = targetNumber - x;
        
        if (y > 0) {
            
            yNum = [NSNumber numberWithInt:y];
            
            index = (unsigned)CFArrayBSearchValues((CFArrayRef)sortedNumbers,
                                                   CFRangeMake(0, CFArrayGetCount((CFArrayRef)sortedNumbers)),
                                                   (CFNumberRef)yNum,
                                                   (CFComparatorFunction)CFNumberCompare,
                                                   NULL);

            // CFArrayBSearchValues returns the index of the value greater than the target value, 
            // if the value lies between two of (or less than all of) the values in the range
            // IOW, just because the index is in range and non zero doesn't mean the value IS ACTUALLY IN THE ARRAY.
            // OOf, lost a day on this. 
            
            // so when we get an index back, do a redundant isEqual: test on it
            
            if(index < [sortedNumbers count] && [[sortedNumbers objectAtIndex:index] isEqual:yNum]) {
                foundSum = YES;
                break;
            }
            else {
                foundSum = NO;
            }
        }
    }
    
    if (foundSum) {
        QuietLog(@"Found sum %d", targetNumber );
    }
    else {
        QuietLog(@"Did NOT find %d.", targetNumber);
    }
    
    return foundSum;
}


static BOOL BruteForceTwoSum(NSMutableArray *numbers, uint32_t targetNumber)
{
//    NSMutableArray *numbers = [[NSMutableArray alloc] 
//                               initWithObjects:[NSNumber numberWithInt:2], 
//                               [NSNumber numberWithInt:3],
//                               [NSNumber numberWithInt:8],
//                               [NSNumber numberWithInt:4],
//                               [NSNumber numberWithInt:5],
//                               nil ];
    
    uint32_t currentSum = 0;
    uint32_t iTh = 0;
    uint32_t jTh = 0;
    NSUInteger i;
    NSUInteger j;
    
    BOOL    foundSum = NO;
    
    for (i = 0; i < [numbers count] && (foundSum == NO); i++) {
        
        for (j =0; j < [numbers count]  && (foundSum == NO); j++) {
            
            iTh = [[numbers objectAtIndex:i] intValue];
            jTh = [[numbers objectAtIndex:j] intValue];
            currentSum = iTh + jTh;

            if (targetNumber == currentSum) {
                foundSum = YES;
            }
            
        }
        if( (i % 2000) == 0 ) QuietLog(@"ith iteration %d", i);
        
    }
    
    if (foundSum) {
        QuietLog(@"Found sum %d, array[%d] %d and array[%d] %d", currentSum, i, iTh, j, jTh );
    }
    else
        QuietLog(@"Did not find %d.", targetNumber);

    return foundSum;
}

void RunHashTest(void)
{
   
    NSMutableArray *numsToFind = [[NSMutableArray alloc] initWithObjects:
                                  [NSNumber numberWithInt:231552], 
                                  [NSNumber numberWithInt:234756],
                                  [NSNumber numberWithInt:596873],
                                  [NSNumber numberWithInt:648219],
                                  [NSNumber numberWithInt:726312],
                                  [NSNumber numberWithInt:981237],
                                  [NSNumber numberWithInt:988331],
                                  [NSNumber numberWithInt:1277361],
                                  [NSNumber numberWithInt:1283379],
                                  nil ];
    BOOL success = NO;
    
    NSMutableArray *resultsStringArray = [[NSMutableArray alloc] initWithCapacity:[numsToFind count]];
    
    NSMutableArray *testArray = nil;
    testArray = CreateTestData(TEST_DATA_PATH);
    
    for (int32_t i = 0; i < [numsToFind count]; i++) {
        QuietLog(@"Looking for num %d", i);
        
        success = BinarySearchTwoSum(testArray, [[numsToFind objectAtIndex:i] intValue]);
        
        if (success) {
            NSNumber *num = [NSNumber numberWithInt:1];
            [resultsStringArray addObject:num];
        }
        else {
            NSNumber *num = [NSNumber numberWithInt:0];
            [resultsStringArray addObject:num];
        }
    }
    
    QuietLog(@"\n\nHomework answer:");
    for (int index = 0; index < [resultsStringArray count]; index++) {
        printf("%d", [[resultsStringArray objectAtIndex:index] intValue] );
    }
    printf("\n");
    
    [numsToFind release];
    [resultsStringArray release];
    [testArray release];
}










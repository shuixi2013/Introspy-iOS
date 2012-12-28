
#include <substrate.h>
#include <CommonCrypto/CommonCryptor.h>

#import "CCCryptorHooks.h"
#import "../IntrospySQLiteStorage.h"
#import "../PlistObjectConverter.h"
#import "../CallStackInspector.h"

// Nice global
extern IntrospySQLiteStorage *traceStorage;


// Utiity function
static int getIVLength(CCAlgorithm alg) {
    
    switch(alg) {
        case kCCAlgorithmAES128:
            return 16;
        case kCCAlgorithmDES:
            return 8;
        case kCCAlgorithm3DES:
            return 8;
        case kCCAlgorithmCAST:
            return 8;
        case kCCAlgorithmRC2:
            return 8;
        default:
            return 0;
    }    
}


// Hook CCCryptorCreate()
static CCCryptorStatus (*original_CCCryptorCreate)(
    CCOperation op, 
    CCAlgorithm alg, 
    CCOptions options, 
    const void *key, 
    size_t keyLength,
    const void *iv, 
    CCCryptorRef *cryptorRef);


static CCCryptorStatus replaced_CCCryptorCreate(
    CCOperation op, 
    CCAlgorithm alg, 
    CCOptions options, 
    const void *key, 
    size_t keyLength,
    const void *iv, 
    CCCryptorRef *cryptorRef) 
{


    CCCryptorStatus origResult = original_CCCryptorCreate(op, alg, options, key, keyLength, iv, cryptorRef);

    // Only log what the application directly calls. For example we don't want to log internal SSL crypto calls
    if ([CallStackInspector wasDirectlyCalledByApp]) {
        
        CallTracer *tracer = [[CallTracer alloc] initWithClass:@"C" andMethod:@"CCCryptorCreate"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) op] withKey:@"op"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) alg] withKey:@"alg"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) options] withKey:@"options"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: key withLength: keyLength] withKey:@"key"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: iv withLength: getIVLength(alg)] withKey:@"iv"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) cryptorRef] withKey:@"cryptorRef"];
        [tracer addReturnValueFromPlistObject: [NSNumber numberWithUnsignedInt:origResult]];
        [traceStorage saveTracedCall: tracer];
        [tracer release];
    }
    return origResult;
}


// Hook CCCryptorCreateFromData()
static CCCryptorStatus (*original_CCCryptorCreateFromData)(
    CCOperation op,
    CCAlgorithm alg, 
    CCOptions options,
    const void *key,
    size_t keyLength,   
    const void *iv,
    const void *data,
    size_t dataLength,
    CCCryptorRef *cryptorRef,
    size_t *dataUsed);


static CCCryptorStatus replaced_CCCryptorCreateFromData(
    CCOperation op,
    CCAlgorithm alg, 
    CCOptions options,
    const void *key,
    size_t keyLength,   
    const void *iv,
    const void *data,
    size_t dataLength,
    CCCryptorRef *cryptorRef,
    size_t *dataUsed)
{

    CCCryptorStatus origResult = original_CCCryptorCreateFromData(op, alg, options, key, keyLength, iv, data, dataLength, cryptorRef, dataUsed);

    if ([CallStackInspector wasDirectlyCalledByApp]) {
        
        CallTracer *tracer = [[CallTracer alloc] initWithClass:@"C" andMethod:@"CCCryptorCreateFromData"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) op] withKey:@"op"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) alg] withKey:@"alg"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) options] withKey:@"options"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: key withLength: keyLength] withKey:@"key"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: iv withLength: getIVLength(alg)] withKey:@"iv"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: data withLength: dataLength] withKey:@"data"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) *dataUsed] withKey:@"dataUsed"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) cryptorRef] withKey:@"cryptorRef"];
        [tracer addReturnValueFromPlistObject: [NSNumber numberWithUnsignedInt:origResult]];
        [traceStorage saveTracedCall: tracer];
        [tracer release];
    }
    return origResult;
}


// Hook CCCryptorUpdate()
static CCCryptorStatus (*original_CCCryptorUpdate)(
    CCCryptorRef cryptorRef, 
    const void *dataIn, 
    size_t dataInLength, 
    void *dataOut,
    size_t dataOutAvailable, 
    size_t *dataOutMoved);


static CCCryptorStatus replaced_CCCryptorUpdate(
    CCCryptorRef cryptorRef, 
    const void *dataIn, 
    size_t dataInLength, 
    void *dataOut,
    size_t dataOutAvailable, 
    size_t *dataOutMoved) 
{
    
    CCCryptorStatus origResult = original_CCCryptorUpdate(cryptorRef, dataIn, dataInLength, dataOut, dataOutAvailable, dataOutMoved);

    if ([CallStackInspector wasDirectlyCalledByApp]) {
        
        CallTracer *tracer = [[CallTracer alloc] initWithClass:@"C" andMethod:@"CCCryptorUpdate"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) cryptorRef] withKey:@"cryptorRef"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: dataIn withLength: dataInLength] withKey:@"dataIn"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: dataOut withLength: *dataOutMoved] withKey:@"dataOut"];
        [tracer addReturnValueFromPlistObject: [NSNumber numberWithUnsignedInt:origResult]];
        [traceStorage saveTracedCall: tracer];
        [tracer release];
    }
    return origResult;
}


// Hook CCCryptorFinal()
static CCCryptorStatus (*original_CCCryptorFinal)(
    CCCryptorRef cryptorRef,
    void *dataOut,
    size_t dataOutAvailable,
    size_t *dataOutMoved);  

static CCCryptorStatus replaced_CCCryptorFinal(
    CCCryptorRef cryptorRef,
    void *dataOut,
    size_t dataOutAvailable,
    size_t *dataOutMoved)
{
    CCCryptorStatus origResult = original_CCCryptorFinal(cryptorRef, dataOut, dataOutAvailable, dataOutMoved);

    if ([CallStackInspector wasDirectlyCalledByApp]) {
        
        CallTracer *tracer = [[CallTracer alloc] initWithClass:@"C" andMethod:@"CCCryptorFinal"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) cryptorRef] withKey:@"cryptorRef"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: dataOut withLength: *dataOutMoved] withKey:@"dataOut"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) dataOutAvailable] withKey:@"dataOutAvailable"];
        [tracer addReturnValueFromPlistObject: [NSNumber numberWithUnsignedInt:origResult]];
        [traceStorage saveTracedCall: tracer];
        [tracer release];
    }
    return origResult;    
}

// Hook CCCrypt()
static CCCryptorStatus (*original_CCCrypt)(
    CCOperation op, 
    CCAlgorithm alg, 
    CCOptions options, 
    const void *key, 
    size_t keyLength,
    const void *iv, 
    const void *dataIn, 
    size_t dataInLength, 
    void *dataOut, 
    size_t dataOutAvailable,
    size_t *dataOutMoved);

static CCCryptorStatus replaced_CCCrypt(
    CCOperation op, 
    CCAlgorithm alg, 
    CCOptions options, 
    const void *key, 
    size_t keyLength,
    const void *iv, 
    const void *dataIn, 
    size_t dataInLength, 
    void *dataOut, 
    size_t dataOutAvailable,
    size_t *dataOutMoved)
{

    CCCryptorStatus origResult = original_CCCrypt(op, alg, options, key, keyLength, iv, dataIn, 
        dataInLength, dataOut, dataOutAvailable, dataOutMoved);

    if ([CallStackInspector wasDirectlyCalledByApp]) {
        
        CallTracer *tracer = [[CallTracer alloc] initWithClass:@"C" andMethod:@"CCCrypt"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) op] withKey:@"op"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) alg] withKey:@"alg"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) options] withKey:@"options"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: key withLength: keyLength] withKey:@"key"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: iv withLength: getIVLength(alg)] withKey:@"iv"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: dataIn withLength: dataInLength] withKey:@"dataIn"];
        [tracer addArgFromPlistObject:[PlistObjectConverter convertCBuffer: dataOut withLength: *dataOutMoved] withKey:@"dataOut"];
        [tracer addArgFromPlistObject:[NSNumber numberWithUnsignedInt: (unsigned int) dataOutAvailable] withKey:@"dataOutAvailable"];
        [tracer addReturnValueFromPlistObject: [NSNumber numberWithUnsignedInt:origResult]];
        [traceStorage saveTracedCall: tracer];
        [tracer release];
    }
    return origResult;
}


@implementation CCCryptorHooks : NSObject 

+ (void)enableHooks {
     MSHookFunction((void *) CCCryptorCreate, (void *)  replaced_CCCryptorCreate, (void **) &original_CCCryptorCreate);
     MSHookFunction((void *) CCCryptorCreateFromData, (void *)  replaced_CCCryptorCreateFromData, (void **) &original_CCCryptorCreateFromData);
     MSHookFunction((void *) CCCryptorUpdate, (void *)  replaced_CCCryptorUpdate, (void **) &original_CCCryptorUpdate);
     MSHookFunction((void *) CCCryptorFinal, (void *)  replaced_CCCryptorFinal, (void **) &original_CCCryptorFinal);
     MSHookFunction((void *) CCCrypt, (void *)  replaced_CCCrypt, (void **) &original_CCCrypt);
}

@end
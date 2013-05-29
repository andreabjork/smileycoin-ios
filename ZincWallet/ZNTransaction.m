//
//  ZNTransaction.m
//  ZincWallet
//
//  Created by Aaron Voisine on 5/16/13.
//  Copyright (c) 2013 zinc. All rights reserved.
//

#import "ZNTransaction.h"
#import "NSMutableData+Bitcoin.h"
#import "NSData+Hash.h"
#import "ZNKey.h"

#define TX_VERSION      0x00000001u
#define TX_LOCKTIME     0x00000000u
#define TXIN_SEQUENCE   UINT32_MAX
#define TXOUT_PUBKEYLEN 25
#define SIGHASH_ALL     0x00000001u

@interface ZNTransaction ()

@property (nonatomic, strong) NSArray *inputHashes, *inputIndexes, *inputScripts, *outputAddresses, *outputAmounts;
@property (nonatomic, strong) NSMutableArray *signatures;

@end

@implementation ZNTransaction

- (id)initWithInputHashes:(NSArray *)inputHashes inputIndexes:(NSArray *)inputIndexes
inputScripts:(NSArray *)inputScripts outputAddresses:(NSArray *)outputAddresses
andOutputAmounts:(NSArray *)outputAmounts
{
    if (! inputHashes.count || inputHashes.count != inputIndexes.count || inputHashes.count != inputScripts.count ||
        ! outputAddresses.count || outputAddresses.count != outputAmounts.count) return nil;

    if (! (self = [self init])) return nil;
        
    self.inputHashes = inputHashes;
    self.inputIndexes = inputIndexes;
    self.inputScripts = inputScripts;
    self.signatures = [NSMutableArray arrayWithCapacity:inputHashes.count];
    [self.inputHashes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.signatures addObject:[NSNull null]];
    }];
    
    self.outputAddresses = outputAddresses;
    self.outputAmounts = outputAmounts;
    
    return self;
}

- (BOOL)isSigned
{
    return (self.signatures.count && self.signatures.count == self.inputHashes.count &&
            ! [self.signatures containsObject:[NSNull null]]);
}

- (BOOL)signWithPrivateKeys:(NSArray *)privateKeys
{
    NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:privateKeys.count],
                   *keys = [NSMutableArray arrayWithCapacity:privateKeys.count];
    
    [privateKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZNKey *key = [[ZNKey alloc] initWithPrivateKey:obj];

        if (! key) return;
 
        [keys addObject:key];
        [addresses addObject:key.hash160];
    }];

    for (NSUInteger i = 0; i < self.inputHashes.count; i++) {
        NSUInteger keyIdx = [addresses indexOfObject:[self.inputScripts[i]
                             subdataWithRange:NSMakeRange([self.inputScripts[i] length] - 22, 20)]];

        if (keyIdx == NSNotFound) continue;
    
        NSData *txhash = [[self toDataWithSubscriptIndex:i] SHA256_2];
        NSMutableData *sig = [NSMutableData data];
        NSMutableData *s = [NSMutableData dataWithData:[keys[keyIdx] sign:txhash]];

        [s appendUInt8:SIGHASH_ALL];
        [sig appendScriptPushData:s];
        [sig appendScriptPushData:[keys[keyIdx] publicKey]];

        [self.signatures replaceObjectAtIndex:i withObject:sig];
    }
    
    return [self isSigned];
}

- (NSData *)toDataWithSubscriptIndex:(NSUInteger)subscriptIndex
{
    NSMutableData *d = [NSMutableData dataWithCapacity:10 + 148*self.inputHashes.count + 34*self.outputAddresses.count];

    [d appendUInt32:TX_VERSION];

    [d appendVarInt:self.inputHashes.count];

    for (NSUInteger i = 0; i < self.inputHashes.count; i++) {
        [d appendData:self.inputHashes[i]];
        [d appendUInt32:[self.inputIndexes[i] unsignedIntValue]];

        if ([self isSigned] && subscriptIndex == NSNotFound) {
            [d appendVarInt:[self.signatures[i] length]];
            [d appendData:self.signatures[i]];
        }
        else if (i == subscriptIndex) {// || subscriptIndex == NSNotFound) {
            //XXX to fully match the reference implementation, OP_CODESEPARATOR related checksig logic should go here
            [d appendVarInt:[self.inputScripts[i] length]];
            [d appendData:self.inputScripts[i]];
        }
        else [d appendVarInt:0];
        
        [d appendUInt32:TXIN_SEQUENCE];
    }
    
    [d appendVarInt:self.outputAddresses.count];
    
    for (NSUInteger i = 0; i < self.outputAddresses.count; i++) {
        [d appendUInt64:[self.outputAmounts[i] unsignedLongLongValue]];
        
        [d appendVarInt:TXOUT_PUBKEYLEN]; //XXX this shouldn't be hard coded
        [d appendScriptPubKeyForAddress:self.outputAddresses[i]];
    }
    
    [d appendUInt32:TX_LOCKTIME];
    
    if (subscriptIndex != NSNotFound) {
        [d appendUInt32:SIGHASH_ALL];
    }
    
    return d;
}

- (NSData *)toData
{
    return [self toDataWithSubscriptIndex:NSNotFound];
}

- (NSString *)toHex
{
    return [[self toData] toHex];
}

@end
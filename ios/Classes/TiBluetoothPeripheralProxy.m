/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothUtils.h"
#import "TiUtils.h"

@implementation TiBluetoothPeripheralProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andPeripheral:(CBPeripheral *)__peripheral
{
    if ([super _initWithPageContext:[self pageContext]]) {
        _peripheral = __peripheral;
    }
    
    return self;
}
    
- (CBPeripheral *)peripheral
{
    return _peripheral;
}

#pragma mark Public API's

- (id)name
{
    return _peripheral.name;
}
    
- (id)rssi
{
    return NUMINT(_peripheral.RSSI);
}
    
- (id)state
{
    return NUMINT(_peripheral.state);
}
    
- (id)services
{
    return [self arrayFromServices:_peripheral.services];
}

- (void)readRSSI:(id)unused
{
    [_peripheral readRSSI];
}

- (void)discoverServices:(id)args
{
    [_peripheral discoverServices:[TiBluetoothUtils UUIDArrayFromStringArray:args]];
}

- (void)discoverIncludedServicesForService:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id includedServices = [args objectAtIndex:0];
    id service = [args objectAtIndex:1];
    
    ENSURE_TYPE(includedServices, NSArray);
    ENSURE_TYPE(service, TiBluetoothServiceProxy);
    
    [_peripheral discoverIncludedServices:[TiBluetoothUtils UUIDArrayFromStringArray:includedServices]
                               forService:[(TiBluetoothServiceProxy *)service service]];
}

- (void)discoverCharacteristicsForService:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id characteristics = [args objectAtIndex:0];
    id service = [args objectAtIndex:1];
    
    ENSURE_TYPE(characteristics, NSArray);
    ENSURE_TYPE(service, TiBluetoothServiceProxy);

    [_peripheral discoverCharacteristics:[TiBluetoothUtils UUIDArrayFromStringArray:characteristics]
                              forService:[(TiBluetoothServiceProxy *)service service]];
}

- (void)readValueForCharacteristic:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothCharacteristicProxy);
    
    [_peripheral readValueForCharacteristic:[(TiBluetoothCharacteristicProxy *)value characteristic]];
}

- (id)maximumWriteValueLengthForType:(id)value
{
    return NUMUINTEGER([_peripheral maximumWriteValueLengthForType:[TiUtils intValue:value]]);
}

- (void)writeValueForCharacteristicWithType:(id)args
{
    ENSURE_ARG_COUNT(args, 3);
    
    id value = [args objectAtIndex:0];
    id characteristic = [args objectAtIndex:1];
    id type = [args objectAtIndex:2];
    
    ENSURE_TYPE(value, TiBlob);
    ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
    ENSURE_TYPE(type, NSNumber);

    
    [_peripheral writeValue:[(TiBlob*)value data]
         forCharacteristic:[(TiBluetoothCharacteristicProxy *)characteristic characteristic]
                      type:[TiUtils intValue:type]];
}

- (void)setNotifyValueForCharacteristic:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id notifyValue = [args objectAtIndex:0];
    id characteristic = [args objectAtIndex:1];
    
    ENSURE_TYPE(notifyValue, NSNumber);
    ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
    
    [_peripheral setNotifyValue:[TiUtils boolValue:notifyValue]
             forCharacteristic:[(TiBluetoothCharacteristicProxy *)characteristic characteristic]];
}

- (void)discoverDescriptorsForCharacteristic:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothCharacteristicProxy);
    
    [_peripheral discoverDescriptorsForCharacteristic:[(TiBluetoothCharacteristicProxy *)value characteristic]];
}

- (void)readValueForDescriptor:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothDescriptorProxy);

    [_peripheral readValueForDescriptor:[(TiBluetoothDescriptorProxy *)value descriptor]];
}

- (void)writeValueForDescriptor:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id value = [args objectAtIndex:0];
    id descriptor = [args objectAtIndex:1];
    
    ENSURE_TYPE(value, TiBlob);
    ENSURE_TYPE(descriptor, TiBluetoothDescriptorProxy);
    
    [_peripheral writeValue:[(TiBlob*)value data]
             forDescriptor:[(TiBluetoothDescriptorProxy *)descriptor descriptor]];
}


#pragma mark Peripheral Delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didDiscoverServices"]) {
        [self fireEvent:@"didDiscoverServices" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didDiscoverCharacteristicsForService"]) {
        [self fireEvent:@"peripheral:didDiscoverCharacteristicsForService" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"service": [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didUpdateValueForCharacteristic"]) {
        [self fireEvent:@"peripheral:didUpdateValueForCharacteristic" withObject:@{
            @"characteristic": [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

#pragma mark Utilities

- (NSArray *)arrayFromServices:(NSArray<CBService *> *)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service]];
    }
    
    return result;
}

@end

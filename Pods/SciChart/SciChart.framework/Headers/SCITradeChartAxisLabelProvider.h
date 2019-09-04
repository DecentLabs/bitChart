//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2018. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SCITradeChartAxisLabelProvider.h is part of SCICHART®, High Performance Scientific Charts
// For full terms and conditions of the license, see http://www.scichart.com/scichart-eula/
//
// This source code is protected by international copyright law. Unauthorized
// reproduction, reverse-engineering, or distribution of all or any portion of
// this source code is strictly prohibited.
//
// This source code contains confidential and proprietary trade secrets of
// SciChart Ltd., and should at no time be copied, transferred, sold,
// distributed or made available without express written permission.
//******************************************************************************

#import <Foundation/Foundation.h>
#import "SCICategoryLabelProviderBase.h"

/**
 * Default label provider which is used by `SCICategoryDateTimeLabelProvider` class.
 */
@interface SCITradeChartAxisLabelProvider : SCICategoryLabelProviderBase

/**
 * Creates a new instance of `SCITradeChartAxisLabelProvider` class.
 *
 * @param labelFormatter The `SCILabelFormatterProtocol` used by this label provider.
 */
- (instancetype)initWithLabelFormatter:(id<SCILabelFormatterProtocol>)labelFormatter;

@end
//
//  WeChatOrderModel.h
//  GreatDifference
//
//  Created by xiaodou_yxg on 2017/3/15.
//  Copyright © 2017年 xiaodou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignInfoModel.h"

@interface WeChatOrderModel : NSObject
@property (nonatomic, copy) NSString    *orderId;
@property (nonatomic, copy) NSString    *orderCode;
@property (nonatomic, copy) NSString    *orderDetails;
@property (nonatomic, copy) NSString    *notifyUrl;
@property (nonatomic, copy) NSString    *payMoney;
@property (nonatomic, copy) NSString    *discountMoney;
@property (nonatomic, strong) SignInfoModel    *signInfo;


/**
 *  支付完成返回的字段
 */
@property (nonatomic, copy) NSString  *createTime;
@property (nonatomic, copy) NSString  *orderPrice;


@end

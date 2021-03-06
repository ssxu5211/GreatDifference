//
//  PersonInfoViewController.m
//  GreatDifference
//
//  Created by 杨旭根 on 2016/11/15.
//  Copyright © 2016年 xiaodou. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "PersonInfoDetailViewController.h"
#import "IdentifyManagerViewController.h"
#import "QRCodeViewController.h"
#import "MapViewController.h"

#import "UIUtils.h"

#import "UserInfo.h"
#import "PersonalInfoCell.h"
#import "PersonalHttpManager.h"

#import "UserInfoResult.h"
#import "StringUtils.h"
#import "AddressDetailResult.h"
#import "AccountUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface PersonInfoViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) NSMutableArray        *dataSource;
@property (nonatomic, strong) UIImage               *avatarImage;
@property (nonatomic, strong) NSMutableDictionary   *paramsDic; // 存放请求参数的数组
@property (nonatomic, strong) AddressModel          *addressModel;//地区
@end

@implementation PersonInfoViewController
static NSString *normalIdentifier =     @"normalCell";
static NSString *avatarIdentifier =     @"avatarCell";
static NSString *pickerIdentifier =     @"pickerCell";
static NSString *qrCodeIdentifier =     @"qrCodeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"基础信息";
    [self.view addSubview:self.tableView];
    self.paramsDic = [NSMutableDictionary dictionary];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self fetchUserInfo];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveUserInfo)];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)fetchUserInfo{
    [HUDUtils showLoading:@"正在加载"];
    [PersonalHttpManager getUserInfoWithParams:nil success:^(UserInfoResult *responseObj) {
        UserInfo *userInfo  = responseObj.data;
        [self createDataWithModel:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUDUtils hideHud];
            [self.tableView reloadData];
        });
    } failure:^(id responseObj, NSError *error) {
        
        NSString *message = [responseObj objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUDUtils hideHud];
            [HUDUtils showError:message];
        });

    }];
}

#pragma mark -- getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSMutableArray *)createDataWithModel:(UserInfo *)user
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        
        [dic1 setValue:@"头像" forKey:@"title"];
        [dic1 setValue:user.headImgUrl forKey:@"detail"];
        [dic1 setValue:@"1" forKey:@"cellType"];
        
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        [dic2 setValue:@"昵称" forKey:@"title"];
        [dic2 setValue:user.nickName forKey:@"detail"];
        [dic2 setValue:@"0" forKey:@"cellType"];
        [dic2 setValue:@"nickName" forKey:@"key"];
        
        [self.paramsDic setValue:user.nickName forKey:@"nickName"];
        
        NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
        [dic3 setValue:@"性别" forKey:@"title"];
        [dic3 setValue:[user getGenderName] forKey:@"detail"];
        [dic3 setValue:@"2" forKey:@"cellType"];
        [dic3 setValue:@"gender" forKey:@"key"];
        [self.paramsDic setValue:user.gender forKey:@"gender"];

        
        NSMutableDictionary *dic5 = [NSMutableDictionary dictionary];
        [dic5 setValue:@"手机号" forKey:@"title"];
        [dic5 setValue:user.mob forKey:@"detail"];
        [dic5 setValue:@"0" forKey:@"cellType"];

        
        NSMutableDictionary *dic6 = [NSMutableDictionary dictionary];
        [dic6 setValue:@"地区" forKey:@"title"];
        [dic6 setValue:@"0" forKey:@"cellType"];
//        [dic6 setValue:@"gender" forKey:@"key"];
        if ([StringUtils isEmpty:user.province]) {
            user.province = @"";
        }
        
        if ([StringUtils isEmpty:user.city]) {
            user.city = @"";
        }
        
        NSString *address = [NSString stringWithFormat:@"%@%@",user.province,user.city];

//        address = [NSString stringWithFormat:@"%@", address];
        [dic6 setValue:address forKey:@"detail"];
        
        [self.paramsDic setValue:user.province forKey:@"province"];
        [self.paramsDic setValue:user.city forKey:@"city"];

        NSMutableDictionary *dic7 = [NSMutableDictionary dictionary];
        [dic7 setValue:@"我的二维码" forKey:@"title"];
        [dic7 setValue:user.invitationCode forKey:@"detail"];
        [dic7 setValue:@"3" forKey:@"cellType"];
        
        NSMutableDictionary *dic8 = [NSMutableDictionary dictionary];
        [dic8 setValue:@"身份管理" forKey:@"title"];
        [dic8 setValue:@"" forKey:@"detail"];
        [dic8 setValue:@"0" forKey:@"cellType"];

        [_dataSource addObject:dic1];
        [_dataSource addObject:dic2];
        [_dataSource addObject:dic3];
        [_dataSource addObject:dic5];
        [_dataSource addObject:dic6];
//        [_dataSource addObject:dic7];
        [_dataSource addObject:dic8];

        
    }
    return _dataSource;
}

#pragma mark -- tableViewDataSource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString *type = [dic valueForKey:@"cellType"];
    NSString *cellIdentifier;
    CellType celltype = CellTypeNormal;

    switch ([type integerValue]) {
        case 0:{
            cellIdentifier = normalIdentifier;
            celltype = CellTypeNormal;
        }
            break;
        case 1:{
            cellIdentifier = avatarIdentifier;
            celltype = CellTypeAvatar;
        }
            break;
        case 2:{
            cellIdentifier = pickerIdentifier;
            celltype = CellTypePicker;
        }
            break;
        case 3:{
            cellIdentifier = qrCodeIdentifier;
            celltype = CellTypeqrCode;
        }
            break;
//            default:
////            celltype = CellTypeNormal
    }
    PersonalInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PersonalInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier cellType:celltype];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([dic[@"title"] isEqualToString:@"手机号"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setContent:dic];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WS(self);
    PersonalInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.finishedBlock = ^(NSString *content){
        [self.paramsDic setValue:content forKey:@"gender"];
    };

    
    if ([[cell getCellTitle] isEqualToString:@"头像"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            BOOL isAvaliable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
            if (!isAvaliable) {
                XGLog(@"当前设备不支持拍照功能");
                
                return ;
            }

//
            
            picker.delegate = self;
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{
                
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusDenied){

                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未获得授权使用摄像头" message:@"请在iOS“设置”-“隐私”-“相机”中打开" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            }];
        }];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BOOL isAvaliable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
            if (!isAvaliable) {
                XGLog(@"当前设备不支持此功能");
                
                return ;
            }
            
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:action];
        [alertController addAction:cancelAction];
        [alertController addAction:action1];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([[cell getCellTitle] isEqualToString:@"性别"]){
        [cell.textField becomeFirstResponder];
    }
    else{
        if ([[cell getCellTitle] isEqualToString:@"手机号"]) {
            return;
        }
        
        if ([[cell getCellTitle] isEqualToString:@"我的二维码"]) {
            QRCodeViewController *qrCodeVc = [[QRCodeViewController alloc]init];
            [self.navigationController pushViewController:qrCodeVc animated:YES];
            return;
        }
        if ([[cell getCellTitle] isEqualToString:@"地区"]) {
            NSString *longitudeStr = [MyUserDefaults objectForKey:CurrentLongitude];
            NSString *latitudeStr = [MyUserDefaults objectForKey:CurrentLatitude];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:longitudeStr forKey:@"longitude"];
            [params setValue:latitudeStr forKey:@"latitude"];
            
            [PersonalHttpManager getProvinceCityWithParams:params success:^(AddressDetailResult *responseObj) {
                AddressModel *address = responseObj.data;
                self.addressModel = address;
                cell.detailLabel.text = [NSString stringWithFormat:@"%@%@",address.province, address.city];
                
            } failure:^(id responseObj, NSError *error) {
                
            }];
//            MapViewController *qrCodeVc = [[MapViewController alloc]init];
//            [self.navigationController pushViewController:qrCodeVc animated:YES];
            return;
        }
        
        if ([[cell getCellTitle] isEqualToString:@"身份管理"]) {
            IdentifyManagerViewController *managerVc = [[IdentifyManagerViewController alloc]init];
            [self.navigationController pushViewController:managerVc animated:YES];
            return;
        }
        
        PersonInfoDetailViewController *detailVc = [[PersonInfoDetailViewController alloc]initWithType:InputTypeTextField andText:cell.detailLabel.text];
        detailVc.saveBlock = ^(NSString *text){
            NSString *key = [weakself.dataSource[indexPath.row] objectForKey:@"key"];
            
            PersonalInfoCell *cell = [weakself.tableView cellForRowAtIndexPath:indexPath];
            cell.detailLabel.text = text;
            if (![StringUtils isEmpty:key]) {
                [weakself.paramsDic setValue:text forKey:key];
            }
        };
        [self.navigationController pushViewController:detailVc animated:YES];

    }
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    UIImage *image;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        image = info[UIImagePickerControllerEditedImage];
        
    }else{
        image = info[UIImagePickerControllerOriginalImage];
    }
    //    self.avatarImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadUserAvatar:image];
    }];
    

}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//
//}

- (void)uploadUserAvatar:(UIImage *)image{
    
    [HUDUtils showLoading:@"正在上传头像"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"1" forKey:@"iconType"];
    [params setValue:@"png" forKey:@"fixType"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [params setObject:encodeResult forKey:@"content"];
    
    [UserInfo uploadHeadImageWithUrl:UPLOAD_IMAGE_URL
    params:params image:self.avatarImage completionHandle:^(id response, NSError *error) {
            NSString *resultCode = [[response objectForKey:@"state"] stringValue];
            [HUDUtils hideHud];
          if ([resultCode isEqualToString:@"1"]) {
          
              PersonalInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
              cell.avatarImg.image = image;
              
              NSDictionary *resultDic = [response objectForKey:@"data"];
              
              UserInfo *oldUser = [AccountUtils account];
              oldUser.headImgUrl = resultDic[@"imgUrl"];
              [AccountUtils save:oldUser];

            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATE_USERINFO object:nil];
//                  [self.navigationController popViewControllerAnimated:YES];

          }else{
              NSString *message = [response objectForKey:@"message"];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [HUDUtils hideHud];
                  [HUDUtils showError:message];
              });
          }
      }];
    
}

- (void)saveUserInfo{

//    [self.paramsDic setValue:@"1" forKey:@"gender"];
    [self.paramsDic setValue:self.addressModel.province forKey:@"province"];
    [self.paramsDic setValue:self.addressModel.city forKey:@"city"];
    [HUDUtils showLoading:@"正在保存"];
    [PersonalHttpManager modifyUserInfoWithParams:self.paramsDic success:^(UserInfoResult *responseObj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UserInfo *currentUser = responseObj.data;
            
            UserInfo *oldUser = [AccountUtils account];
            oldUser.gender = currentUser.gender;
            oldUser.headImgUrl = currentUser.headImgUrl;
            oldUser.nickName    = currentUser.nickName;
            oldUser.province    = currentUser.province;
            oldUser.city        = currentUser.city;
            [AccountUtils save:oldUser];
            
            [HUDUtils hideHud];
            [HUDUtils showAlert:@"保存成功"];
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8*NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATE_USERINFO object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    } failure:^(id responseObj, NSError *error) {
        NSString *message = [responseObj objectForKey:@"message"];
        XGLog(@"%@", message);
        [HUDUtils showAlert:message];
        
    }];
    
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

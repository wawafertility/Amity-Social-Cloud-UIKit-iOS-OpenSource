//
//  AmityPostReviewSettingsScreenViewModelProtocol.swift
//  AmityUIKit
//
//  Created by Sarawoot Khunsri on 11/3/2564 BE.
//  Copyright © 2564 BE Amity. All rights reserved.
//

import UIKit

enum AmityPostReviewSettingsAction {
    case retrieveMenu(settingItem: [AmitySettingsItem])
    case turnOnApproveMemberPost(content: AmitySettingsItem.ToggleContent)
    case turnOffApproveMemberPost(content: AmitySettingsItem.ToggleContent)
}


protocol AmityPostReviewSettingsScreenViewModelDelegate: class {
    func screenViewModel(_ viewModel: AmityPostReviewSettingsScreenViewModelType, didFinishWithAction action: AmityPostReviewSettingsAction)
    func screenViewModel(_ viewModel: AmityPostReviewSettingsScreenViewModelType, didFailWithAction action: AmityPostReviewSettingsAction)
    func screenViewModel(_ viewModel: AmityPostReviewSettingsScreenViewModelType, didFailWithError error: AmityError)
}

protocol AmityPostReviewSettingsScreenViewModelDataSource {
    
}

protocol AmityPostReviewSettingsScreenViewModelAction {
    func retrieveMenu()
    func turnOffApproveMemberPost(content: AmitySettingsItem.ToggleContent)
    func turnOnApproveMemberPost(content: AmitySettingsItem.ToggleContent)
}

protocol AmityPostReviewSettingsScreenViewModelType: AmityPostReviewSettingsScreenViewModelAction, AmityPostReviewSettingsScreenViewModelDataSource {
    var delegate: AmityPostReviewSettingsScreenViewModelDelegate? { get set }
    var action: AmityPostReviewSettingsScreenViewModelAction { get }
    var dataSource: AmityPostReviewSettingsScreenViewModelDataSource { get }
}

extension AmityPostReviewSettingsScreenViewModelType {
    var action: AmityPostReviewSettingsScreenViewModelAction { return self }
    var dataSource: AmityPostReviewSettingsScreenViewModelDataSource { return self }
}

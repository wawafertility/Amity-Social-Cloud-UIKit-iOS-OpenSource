//
//  AmityCommunitySettingsViewController.swift
//  AmityUIKit
//
//  Created by Sarawoot Khunsri on 10/3/2564 BE.
//  Copyright © 2564 BE Amity. All rights reserved.
//

import UIKit

final class AmityCommunitySettingsViewController: AmityViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet private var settingTableView: AmitySettingsItemTableView!
    
    // MARK: - Properties
    private var screenViewModel: AmityCommunitySettingsScreenViewModelType!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        screenViewModel.delegate = self
        setupView()
        setupSettingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screenViewModel.action.retrieveCommunity()
        screenViewModel.action.retrieveNotifcationSettings()
    }
    
    static func make(community: AmityCommunityModel) -> AmityCommunitySettingsViewController {
        let userNotificationController = AmityUserNotificationSettingsController()
        let communityNotificationController = AmityCommunityNotificationSettingsController(withCommunityId: community.communityId)
        let communityLeaveController = AmityCommunityLeaveController(withCommunityId: community.communityId)
        let communityDeleteController = AmityCommunityDeleteController(withCommunityId: community.communityId)
        let communityInfoController = AmityCommunityInfoController(communityId: community.communityId)
        let viewModel: AmityCommunitySettingsScreenViewModelType = AmityCommunitySettingsScreenViewModel(community: community,
                                                                                                     userNotificationController: userNotificationController,
                                                                                                     communityNotificationController: communityNotificationController,
                                                                                                     communityLeaveController: communityLeaveController,
                                                                                                     communityDeleteController: communityDeleteController,
                                                                                                     communityInfoController: communityInfoController)
        let vc = AmityCommunitySettingsViewController(nibName: AmityCommunitySettingsViewController.identifier, bundle: AmityUIKitManager.bundle)
        vc.screenViewModel = viewModel
        return vc
    }
    
    // MARK: - Setup view
    private func setupView() {
        title = screenViewModel.dataSource.community.displayName
        view.backgroundColor = AmityColorSet.backgroundColor
    }
    
    private func setupSettingTableView() {
        settingTableView.actionHandler = { [weak self] settingsItem in
            self?.handleActionItem(settingsItem: settingsItem)
        }
    }
    
    private func handleActionItem(settingsItem: AmitySettingsItem) {
        switch settingsItem {
        case .navigationContent(let content):
            guard let item = AmityCommunitySettingsItem(rawValue: content.identifier) else { return }
            switch item {
            case .editProfile:
                let vc = AmityCommunityEditorViewController.make(withCommunityId: screenViewModel.dataSource.community.communityId)
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            case .members:
                let vc = AmityCommunityMemberSettingsViewController.make(community: screenViewModel.dataSource.community.object)
                navigationController?.pushViewController(vc, animated: true)
            case .notification:
                let vc = AmityCommunityNotificationSettingsViewController.make(community: screenViewModel.dataSource.community)
                navigationController?.pushViewController(vc, animated: true)
            case .postReview:
                let vc = AmityPostReviewSettingsViewController.make()
                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case .textContent(let content):
            guard let item = AmityCommunitySettingsItem(rawValue: content.identifier) else { return }
            switch item {
            case .leaveCommunity:
                AmityAlertController.present(
                    title: AmityLocalizedStringSet.CommunitySettings.alertTitleLeave.localizedString,
                    message: AmityLocalizedStringSet.CommunitySettings.alertDescLeave.localizedString,
                    actions: [.cancel(handler: nil),
                              .custom(title: AmityLocalizedStringSet.leave.localizedString,
                                      style: .destructive, handler: { [weak self] in
                                        self?.screenViewModel.action.leaveCommunity()
                                      })],
                    from: self)
            case .closeCommunity:
                AmityAlertController.present(
                    title: AmityLocalizedStringSet.CommunitySettings.alertTitleClose.localizedString,
                    message: AmityLocalizedStringSet.CommunitySettings.alertDescClose.localizedString,
                    actions: [.cancel(handler: nil),
                              .custom(title: AmityLocalizedStringSet.close.localizedString,
                                      style: .destructive,
                                      handler: { [weak self] in
                                        self?.screenViewModel.action.closeCommunity()
                                      })],
                    from: self)
            default:
                break
            }
        default:
            break
        }
    }
}

extension AmityCommunitySettingsViewController: AmityCommunitySettingsScreenViewModelDelegate {
  
    func screenViewModel(_ viewModel: AmityCommunitySettingsScreenViewModelType, didGetSettingMenu settings: [AmitySettingsItem]) {
        settingTableView.settingsItems = settings
    }
    
    func screenViewModel(_ viewModel: AmityCommunitySettingsScreenViewModelType, didGetCommunitySuccess community: AmityCommunityModel) {
        title = community.displayName
    }
        
    func screenViewModelDidLeaveCommunity() {
        AmityHUD.hide()
        navigationController?.popViewController(animated: true)
    }
    
    func screenViewModelDidCloseCommunity() {
        AmityHUD.hide()
        if let communityHomePage = navigationController?.viewControllers.first(where: { $0.isKind(of: AmityCommunityHomePageViewController.self) }) {
            navigationController?.popToViewController(communityHomePage, animated: true)
        } else if let globalFeedViewController = navigationController?.viewControllers.first(where: { $0.isKind(of: AmityGlobalFeedViewController.self) }) {
            navigationController?.popToViewController(globalFeedViewController, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
  
    func screenViewModelDidLeaveCommunityFail() {
        AmityAlertController.present(title: AmityLocalizedStringSet.CommunitySettings.alertFailTitleLeave.localizedString,
                                   message: AmityLocalizedStringSet.somethingWentWrongWithTryAgain.localizedString,
                                   actions: [.ok(handler: nil)], from: self)
    }
    
    func screenViewModelDidCloseCommunityFail() {
        AmityAlertController.present(title: AmityLocalizedStringSet.CommunitySettings.alertFailTitleClose.localizedString,
                                   message: AmityLocalizedStringSet.somethingWentWrongWithTryAgain.localizedString,
                                   actions: [.ok(handler: nil)], from: self)
    }
    
    func screenViewModel(_ viewModel: AmityCommunitySettingsScreenViewModelType, failure error: AmityError) {
        switch error {
        case .noPermission:
            AmityAlertController.present(title: AmityLocalizedStringSet.Community.alertUnableToPerformActionTitle.localizedString,
                                       message: AmityLocalizedStringSet.Community.alertUnableToPerformActionDesc.localizedString,
                                       actions: [.ok(handler: { [weak self] in
                                        self?.navigationController?.popToRootViewController(animated: true)
                                       })], from: self)
        default:
            break
        }
    }
    
}

extension AmityCommunitySettingsViewController: AmityCommunityProfileEditorViewControllerDelegate {

    func viewController(_ viewController: AmityCommunityProfileEditorViewController, didFinishCreateCommunity communityId: String) {
        AmityEventHandler.shared.communityDidTap(from: self, communityId: communityId)
    }

    func viewController(_ viewController: AmityCommunityProfileEditorViewController, didFailWithNoPermission: Bool) {
        navigationController?.popToRootViewController(animated: true)
    }

}
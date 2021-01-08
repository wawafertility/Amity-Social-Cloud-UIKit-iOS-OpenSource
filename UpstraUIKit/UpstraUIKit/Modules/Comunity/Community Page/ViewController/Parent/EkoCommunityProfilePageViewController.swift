//
//  EkoCommunityProfilePageViewController.swift
//  UpstraUIKit
//
//  Created by sarawoot khunsri on 1/8/21.
//  Copyright © 2021 Upstra. All rights reserved.
//

import UIKit

public enum EkoCommunityProfilePageViewType {
    case present
    case navigation
}

public class EkoCommunityProfilePageSettings {
    public init() { }
    public var shouldChatButtonHide: Bool = true
}

/// A view controller for providing community profile and community feed.
public final class EkoCommunityProfilePageViewController: EkoProfileViewController {
    
    // MARK: - Properties
    private var viewType: EkoCommunityProfilePageViewType = .navigation
    private var settings: EkoCommunityProfilePageSettings!
    private var header: EkoCommunityProfileHeaderViewController!
    private var bottom: EkoCommunityFeedViewController!
    private var postButton: EkoFloatingButton = EkoFloatingButton()
    
    private var screenViewModel: EkoCommunityProfileScreenViewModelType!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        screenViewModel.delegate = self
        setupView()
        screenViewModel.action.getCommunity()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screenViewModel.action.getUserRole()
        navigationController?.setBackgroundColor(with: .white)
    }
    
    override func headerViewController() -> UIViewController {
        return header
    }
    
    override func bottomViewController() -> UIViewController & EkoProfilePagerAwareProtocol {
        return bottom
    }
    
    override func minHeaderHeight() -> CGFloat {
        return topInset
    }
    
    public static func make(withCommunityId communityId: String, settings: EkoCommunityProfilePageSettings = EkoCommunityProfilePageSettings(), _ viewType: EkoCommunityProfilePageViewType = .navigation) -> EkoCommunityProfilePageViewController {
        let viewModel: EkoCommunityProfileScreenViewModelType = EkoCommunityProfileScreenViewModel(communityId: communityId)
        let vc = EkoCommunityProfilePageViewController()
        vc.screenViewModel = viewModel
        vc.header = EkoCommunityProfileHeaderViewController.make(with: viewModel, settings: settings)
        vc.bottom = EkoCommunityFeedViewController.make(communityId: communityId)
        vc.settings = settings
        vc.viewType = viewType
        return vc
    }
    
    override func didTapLeftBarButton() {
        switch viewType {
        case .present:
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            transition.subtype = .fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            view.window?.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        case .navigation:
            navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - Setup view
private extension EkoCommunityProfilePageViewController {
    func setupView() {
        setupPostButton()
    }
    
    func setupPostButton() {
        postButton.image = EkoIconSet.iconCreatePost
        postButton.add(to: view, position: .bottomRight)
        postButton.actionHandler = { [weak self] button in
            self?.postAction()
        }
    }
    
    func setupNavigationItem(with isJoined: Bool) {
        let item = UIBarButtonItem(image: EkoIconSet.iconOption, style: .plain, target: self, action: #selector(optionTap))
        item.tintColor = EkoColorSet.base
        navigationItem.rightBarButtonItem = isJoined ? item : nil
    }
    
}

// MARK: - Action
private extension EkoCommunityProfilePageViewController {
    
    @objc func optionTap() {
        screenViewModel.action.route(.settings)
    }
    
    func postAction() {
        screenViewModel.action.route(.post)
    }
}

// MARK: - Refreshable
extension EkoCommunityProfilePageViewController: EkoRefreshable {
    func handleRefreshing() {
        screenViewModel.action.getCommunity()
    }
}

// MARK: - Screen ViewModel Delegate
extension EkoCommunityProfilePageViewController: EkoCommunityProfileScreenViewModelDelegate {
    func screenViewModelDidGetCommunity(with community: EkoCommunityModel) {
        setupNavigationItem(with: community.isJoined)
        header.update(with: community)
    }
    
    /// Routing to another scenes
    /// - Parameter route: to destination view
    func screenViewModelRoute(_ viewModel: EkoCommunityProfileScreenViewModel, route: EkoCommunityProfileRoute) {
        switch route {
        case .member:
            let vc = EkoCommunityMemberSettingsViewController.make(communityId: viewModel.communityId)
            navigationController?.pushViewController(vc, animated: true)
        case .editProfile:
            let vc = EkoCommunityProfileEditViewController.make(viewType: .edit(communityId: viewModel.communityId))
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .post:
            guard let community = viewModel.community else { return }
            let vc = EkoPostTextEditorViewController.make(postTarget: .community(object: community))
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .settings:
            let vc = EkoCommunitySettingsViewController.make(communityId: viewModel.communityId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func screenViewModelDidJoinCommunitySuccess() {
        EkoHUD.hide()
    }
    
    func screenViewModelDidJoinCommunity(_ status: EkoCommunityProfileScreenViewModel.CommunityJoinStatus) {
        postButton.isHidden = status == .notJoin
    }
    
    func screenViewModelFailure() {
        EkoHUD.hide {
            EkoHUD.show(.error(message: EkoLocalizedStringSet.HUD.somethingWentWrong))
        }
    }
}
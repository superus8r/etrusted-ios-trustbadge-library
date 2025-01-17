//
//  TrustbadgeView.swift
//  Trustylib
//
//  Created by Prem Pratap Singh on 10/11/22.
//

import SwiftUI

/**
 TrustbadgeView shows trust badge image for the shop
 */
public struct TrustbadgeView: View {

    // MARK: Public properties

    /// This boolean property controls the visibility of the trustbadge view
    public var isHidden: Bool = false {
        willSet {
            self.currentState = newValue == true ? .invisible : .default(self.isTrustmarkValid)
        }
    }

    // MARK: Private properties
    
    @StateObject private var trustmarkDataService = TrustmarkDataService()
    @State private var currentState: TrustbadgeState = .default(false)
    @State private var isTrustmarkValid: Bool = false
    @State private var shouldShowExpendedStateContent: Bool = false
    @State private var iconImageName: String = TrustbadgeState.default(false).iconImageName
    @State private var iconImage: UIImage?

    private var tsid: String
    private var channelId: String
    private var alignment: TrustbadgeViewAlignment = .leading
    private var context: TrustbadgeContext

    private let badgeIconHeightPercentToBackgroudCircle: CGFloat = 0.8

    // MARK: Initializer

    public init(
        tsid: String,
        channelId: String,
        context: TrustbadgeContext) {
            self.tsid = tsid
            self.channelId = channelId
            self.context = context
    }

    // MARK: User interface

    public var body: some View {
        GeometryReader { geoReader in

            let proposedWidth = geoReader.frame(in: .global).width
            let proposedHeight = geoReader.frame(in: .global).height
            HStack(alignment: .center) {

                // This spacer helps in keeping the trustmark icon and expanding view
                // aligned to the right
                if self.alignment == .trailing {
                    Spacer()
                }

                if self.trustmarkDataService.trustMarkDetails != nil {
                    ZStack(alignment: self.alignment == .leading ? .leading : .trailing) {

                        // Expendable view is added to the view only if the client id and
                        // client secret details were loaded from the configuration file
                        // which are reuired for showing shop grade, product grade, etc
                        
                        if TrustbadgeConfigurationService.shared.clientId != nil, TrustbadgeConfigurationService.shared.clientSecret != nil {

                            ZStack(alignment: .center) {
                                // Background
                                RoundedRectangle(cornerRadius: proposedHeight * 0.5)
                                    .fill(Color.white)
                                    .frame(
                                        width: self.currentState == .default(self.isTrustmarkValid) ? proposedHeight : proposedWidth,
                                        height: proposedHeight
                                    )
                                    .animation(.easeOut(duration: 0.3), value: self.currentState)
                                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)

                                // Content - Shop grade, product grade, etc
                                ZStack {
                                    if self.context == .shopGrade {
                                        ShopGradeView(
                                            channelId: self.channelId,
                                            currentState: self.currentState,
                                            isTrustmarkValid: self.isTrustmarkValid,
                                            height: proposedHeight,
                                            width: proposedWidth,
                                            alignment: self.alignment,
                                            delegate: self
                                        )
                                    }
                                }
                                .opacity(self.shouldShowExpendedStateContent ? 1 : 0)
                                .animation(.easeIn(duration: 0.2), value: self.shouldShowExpendedStateContent)
                            }
                        }

                        // Trustbadge Icon
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: proposedWidth, height: proposedHeight)
                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)

                            if let image = self.iconImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: proposedHeight * self.badgeIconHeightPercentToBackgroudCircle,
                                        height: proposedHeight * self.badgeIconHeightPercentToBackgroudCircle
                                    )
                            }
                        }
                        .frame(width: proposedHeight, height: proposedHeight)
                    }
                }

                // This spacer helps in keeping the trustmark icon and expanding view
                // aligned to the left
                if self.alignment == .leading {
                    Spacer()
                }
            }
        }
        .opacity(self.isHidden ? 0 : 1)
        .animation(.easeIn(duration: 0.2), value: self.isHidden)
        .onAppear {
            self.getTrustmarkDetails()
        }
    }

    // MARK: Private methods

    /**
     Calls backend API to download trustbadge details for the given tsid
     */
    private func getTrustmarkDetails() {
        guard self.trustmarkDataService.trustMarkDetails == nil else { return }
        
        self.trustmarkDataService.getTrustmarkDetails(for: self.tsid) { didLoadDetails in
            guard didLoadDetails else {
                TSConsoleLogger.log(
                    messege: "Error loading trustmark details for shop with tsid: \(self.tsid)",
                    severity: .error
                )
                return
            }
            TSConsoleLogger.log(
                messege: "Successfully loaded trustmark details for shop with tsid: \(self.tsid)",
                severity: .info
            )

            let trustMarkDetails = self.trustmarkDataService.trustMarkDetails
            self.isTrustmarkValid = trustMarkDetails?.trustMark.isValid ?? false
            self.currentState = TrustbadgeState.default(isTrustmarkValid)

            let validityString = isTrustmarkValid ? "is valid": "isn't valid!"
            TSConsoleLogger.log(
                messege: "Trustmark for shop with tsid: \(self.tsid) \(validityString)",
                severity: .info
            )

            self.setIconForState()
        }
    }

    /**
     Sets icon name for the current state
     */
    private func setIconForState() {
        if self.currentState == .default(self.isTrustmarkValid) {
            self.iconImageName = self.currentState.iconImageName

        } else if self.currentState == .expended {
            self.iconImageName = self.context.iconImageName
        }

        guard let imgPath = TrustbadgeResources.resourceBundle.path(forResource: self.iconImageName,
                                                                    ofType: ResourceExtension.png),
              let image = UIImage(contentsOfFile: imgPath) else {
            return
        }
        self.iconImage = image
    }

    /**
     Animates trustbadge UI components to show a subtle experience
     It first animates the expended background view. When the background view animation is completed,
     it then sets the visibility flag on for the expended view content like shop grade, product grade, etc
     */
    private func expandBadgeToShowDetails() {
        guard self.context != .trustMark else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.shouldShowExpendedStateContent = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentState = .expended
            self.setIconForState()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.shouldShowExpendedStateContent = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                self.currentState = .default(self.isTrustmarkValid)
                self.setIconForState()
            }
        }
    }
}

// MARK: ShopGradeViewDelegate methods

extension TrustbadgeView: ShopGradeViewDelegate {
    func didLoadShopGrades() {
        self.expandBadgeToShowDetails()
    }
}

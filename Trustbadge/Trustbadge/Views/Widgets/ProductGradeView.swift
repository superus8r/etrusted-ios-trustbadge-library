//
//  ProductGradeView.swift
//  Trustbadge
//
//  Created by Prem Pratap Singh on 24/11/22.
//

import SwiftUI

struct ProductGradeView: View {

    // MARK: Public properties
    
    var height: CGFloat
    var currentState: TrustbadgeState

    // MARK: User interface

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // Product Grade Text
            HStack(alignment: .center, spacing: 5) {
                Text(NSLocalizedString("Excellant", comment: "Trustbadge: Excellant grade title"))
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .semibold))
                Text(NSLocalizedString("product reviews", comment: "Trustbadge: Product grade title"))
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .regular))
            }

            // Star Rating View
            HStack(alignment: .center, spacing: 10) {
                StarRatingView(rating: 4.5)
                HStack(alignment: .center, spacing: 0) {
                    Text("4.5")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .semibold))
                    Text("/5.00")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .regular))
                }
            }
        }
        .frame(width: self.currentState == .default ? 0 : 200, height: self.height)
    }
}

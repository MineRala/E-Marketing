//
//  CampaignBanner.swift
//  E-Marketing
//

import Foundation

struct CampaignBanner: Identifiable, Hashable {
    let id: String
    let titleKey: String
    let subtitleKey: String
    let symbol: String
    let style: BannerStyle

    static let samples: [CampaignBanner] = [
        CampaignBanner(
            id: "summer",
            titleKey: "home.banner.summer.title",
            subtitleKey: "home.banner.summer.subtitle",
            symbol: "sun.max.fill",
            style: .summer
        ),
        CampaignBanner(
            id: "tech",
            titleKey: "home.banner.tech.title",
            subtitleKey: "home.banner.tech.subtitle",
            symbol: "iphone.gen3",
            style: .tech
        ),
        CampaignBanner(
            id: "home",
            titleKey: "home.banner.home.title",
            subtitleKey: "home.banner.home.subtitle",
            symbol: "sofa.fill",
            style: .home
        )
    ]
}

enum BannerStyle: Hashable {
    case summer
    case tech
    case home
}

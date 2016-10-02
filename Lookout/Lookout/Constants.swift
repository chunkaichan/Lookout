//
//  Constants.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/9/27.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignInToFp = "SignInToFP"
        static let FpToSignIn = "FPToSignIn"
    }
    
    struct Location {
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let timestamp = "timestamp"
    }
    
    enum LeftMenuKeys: String {
        case profile = "menu-profile"
        case settings = "menu-settings"
        case logOut = "menu-logout"
    }
}
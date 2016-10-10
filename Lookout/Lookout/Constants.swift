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
    
    struct Profile {
        static let name = "name"
        static let address = "address"
        static let birth = "birth"
        static let phone = "phone"
        static let blood = "blood"
    }
    
    enum LeftMenuKeys: String {
        case profile = "menu-profile"
        case settings = "menu-settings"
        case logOut = "menu-signout"
    }
}
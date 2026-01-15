//
//  placticeApp.swift
//  plactice
//
//  Created by 高橋沙久哉 on 2025/12/05.
//

import GoogleSignIn
import SwiftUI

@main
struct placticeApp: App {
    // アプリ全体で共有するSignInManager
    @StateObject private var signInManager = GoogleSignInManager()

    init() {
        // ここにClient IDを設定します
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "15096898414-81hp94vvqc6t88p78lvfjkt56ba13iuu.apps.googleusercontent.com"  // <-- YOUR_CLIENT_ID を置き換える
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(signInManager)
                .onOpenURL { url in
                    // Googleサインインからのリダイレクトを処理
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

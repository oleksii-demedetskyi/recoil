//
//  RecoilView.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 05.03.2021.
//

import Foundation
import SwiftUI
import Recoil

struct RecoilStoreEnvironmentKey: EnvironmentKey {
    static let defaultValue = Store()
}

extension EnvironmentValues {
    var recoilStore: Store {
        get { self[RecoilStoreEnvironmentKey.self] }
        set { self[RecoilStoreEnvironmentKey.self] = newValue }
    }
}

//struct RecoilRootView<V: View>: View {
//    let content: () -> V
//    
//    var body: some View {
//        content()
//    }
//}

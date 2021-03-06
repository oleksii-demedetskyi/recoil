//
//  RecoilView.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 06.03.2021.
//

import Foundation
import SwiftUI

struct GraphView<V: View>: View {
    var graph = Graph()
    let content: (Graph) -> V
    
    var body: V {
        return content(graph)
    }
}

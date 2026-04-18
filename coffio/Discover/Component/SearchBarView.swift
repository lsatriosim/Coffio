//
//  SearchBarView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 17/04/26.
//

import Foundation
import SwiftUI

struct SearchBarView: View {
    @State var searchInput: String = ""
    
    var body: some View {
        HStack {
            Spacer()
            TextField(text: $searchInput) {
                HStack(alignment: .bottom, spacing: 4.0) {
                    Label("Start your Search", systemImage: "magnifyingglass")
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12.0)
        .padding(.vertical, 8.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.clear)
                .stroke(.black, lineWidth: 0.5)
        }
    }
}

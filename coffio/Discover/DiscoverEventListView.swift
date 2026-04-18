//
//  DiscoverEventListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverEventListView: View {
    @StateObject var viewModel: DiscoverEventListViewModel = DiscoverEventListViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text("Incoming Event")
                .font(.title2)
                .bold()
                .padding(.horizontal, 20.0)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .center, spacing: 16) {
                    
                    if viewModel.isLoading {
                        ForEach(0..<2) { _ in
                            DiscoverEventFrontCardSkeletonView()
                        }
                    }
                    else {
                        ForEach(viewModel.events, id: \.id) { event in
                            DiscoverEventFrontCardItemView(dataModel: event)
                        }
                    }
                }
                .padding(.horizontal, 20.0)
                .padding(.top, 8)
            }
        }
        .task {
            viewModel.onViewDidLoad()
        }
    }
}

//
//  EventRegistrationCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

struct MyEventCardDataModel: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date?
    let location: String
    let address: String
}

struct MyEventCardView: View {
    let dataModel: MyEventCardDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8.0) {
                HStack(alignment: .top) {
                    Text(dataModel.title)
                        .font(.headline)
                        .bold()
                        .lineLimit(2)
                    Spacer()
                    Text(
                        DateFormatterUtil.formatEventDuration(
                            start: dataModel.startDate,
                            end: dataModel.endDate
                        )
                    )
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.gray.opacity(0.25))
                        .clipShape(Capsule())
                }
                
                VStack(alignment: .leading, spacing: 4.0) {
                    Label(dataModel.location, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .bold()
                    Text(dataModel.address)
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    let calendar = Calendar.current
    let baseDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 12, hour: 16, minute: 0))!
    let differentDayEnd = calendar.date(byAdding: .day, value: 2, to: baseDate)!
    
    VStack {
        MyEventCardView(
            dataModel: MyEventCardDataModel(
                id: UUID().uuidString,
                title: "Brew and Tiles",
                startDate: baseDate,
                endDate: differentDayEnd,
                location: "Yellow Fox - Pluit",
                address: "Jl Pluit No 145, Jakarta utara"
            )
        )
    }
    .padding(.horizontal, 16.0)
}

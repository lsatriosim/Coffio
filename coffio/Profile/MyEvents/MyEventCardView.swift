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
    let participantNeedConfirmation: Int
    let status: EventStatus
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
                    HStack(spacing: 6) {
                        // 💡 Dynamic Status Tag Layout
                        if dataModel.status == .pending {
                            Text("Waiting Approval")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(.orange)
                                .background(.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        Text(
                            DateFormatterUtil.formatEventDuration(
                                start: dataModel.startDate,
                                end: dataModel.endDate
                            )
                        )
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(.secondary)
                        .background(.gray.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                
                VStack(alignment: .leading, spacing: 4.0) {
                    Label(dataModel.location, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .bold()
                    Text(dataModel.address)
                        .font(.caption)
                }
            }
            
            if dataModel.participantNeedConfirmation > 0 {
                Divider()
                    .padding(.top, 2)
                
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "ad6928"))
                    
                    Text("\(dataModel.participantNeedConfirmation) registration\(dataModel.participantNeedConfirmation > 1 ? "s" : "") need confirmation")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "ad6928"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "ad6928").opacity(0.7))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color(hex: "ad6928").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                address: "Jl Pluit No 145, Jakarta utara",
                participantNeedConfirmation: 4,
                status: .approved
            )
        )
    }
    .padding(.horizontal, 16.0)
}

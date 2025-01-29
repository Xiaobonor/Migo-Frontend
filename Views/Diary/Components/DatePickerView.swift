import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(-3...3, id: \.self) { offset in
                    let date = calendar.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    DateCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 100)
    }
}

private struct DateCell: View {
    let date: Date
    let isSelected: Bool
    
    private let calendar = Calendar.current
    private let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(weekDayFormatter.string(from: date))
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .gray)
            
            Text("\(calendar.component(.day, from: date))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .blue : .primary)
        }
        .frame(width: 45, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
} 
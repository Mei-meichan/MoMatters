import SwiftUI

struct RemindersView: View {
    @ObservedObject var viewModel: KickCounterViewModel
    @State private var showingTimePicker = false
    @State private var selectedReminder: KickReminder?
    @State private var isAddingReminder = false  // Flag to indicate adding a new reminder
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header text
                Text("Set daily reminder")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Reminders list
                VStack(spacing: 12) {
                    ForEach(viewModel.reminders) { reminder in
                        ReminderRow(
                            reminder: reminder,
                            onEdit: {
                                selectedReminder = reminder
                                showingTimePicker = true
                            },
                            onToggle: { isEnabled in
                                if let index = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
                                    viewModel.reminders[index].isEnabled = isEnabled
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Explanation text
                Text("Please set these reminders after your meals as this is when baby is most active. We will remind you every day at these times.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Add reminder button
                Button(action: {
                    isAddingReminder = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add a new reminder")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingTimePicker) {
            FullPageTimePickerView(
                reminder: selectedReminder ?? KickReminder(time: Date(), isEnabled: true),
                onSave: { newTime in
                    if let reminder = selectedReminder,
                       let index = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
                        viewModel.reminders[index].time = newTime
                    }
                }
            )
        }
        .sheet(isPresented: $isAddingReminder) {
            FullPageAddReminderView(viewModel: viewModel, isPresented: $isAddingReminder)
        }
    }
}

struct ReminderRow: View {
    let reminder: KickReminder
    let onEdit: () -> Void
    let onToggle: (Bool) -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            Text(timeFormatter.string(from: reminder.time))
                .font(.title3)
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { onToggle($0) }
            ))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct FullPageTimePickerView: View {
    let reminder: KickReminder
    let onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    
    init(reminder: KickReminder, onSave: @escaping (Date) -> Void) {
        self.reminder = reminder
        self.onSave = onSave
        _selectedDate = State(initialValue: reminder.time)
    }
    
    var body: some View {
        VStack {
            Spacer()
            DatePicker(
                "Select Time",
                selection: $selectedDate,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .padding()
                
                Spacer()
                
                Button("Save") {
                    onSave(selectedDate)
                    dismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct FullPageAddReminderView: View {
    @ObservedObject var viewModel: KickCounterViewModel
    @Binding var isPresented: Bool
    @State private var selectedTime: Date = Date()
    
    var body: some View {
        VStack {
            Spacer()
            Text("Select Time for New Reminder")
                .font(.title)
                .padding()
            
            DatePicker(
                "Select Time for Reminder",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .padding()
            
            Spacer()
            
            Button("Save Reminder") {
                let newReminder = KickReminder(time: selectedTime, isEnabled: true)
                viewModel.reminders.append(newReminder)
                isPresented = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.headline)
            
            Spacer()
            
            Button("Cancel") {
                isPresented = false
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

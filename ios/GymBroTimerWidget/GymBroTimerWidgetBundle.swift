import WidgetKit
import SwiftUI

  @main
  struct GymBroTimerWidgetBundle: WidgetBundle {
      var body: some Widget {
          GymBroTimerWidget()
          if #available(iOS 16.1, *) {
              GymBroTimerLiveActivity()
              GymBroRPELiveActivity()  // ✅ Aggiungi widget RPE
          }
      }
  }

  // MARK: - Static Widget (for Home Screen)
  struct GymBroTimerWidget: Widget {
      let kind: String = "GymBroTimerWidget"

      var body: some WidgetConfiguration {
          StaticConfiguration(kind: kind, provider: Provider()) { entry in
              GymBroTimerWidgetEntryView(entry: entry)
          }
          .configurationDisplayName("GymBro Timer")
          .description("Quick access to your workout timer")
          .supportedFamilies([.systemSmall, .systemMedium])
      }
  }

  // MARK: - Static Widget Components
  struct Provider: TimelineProvider {
      func placeholder(in context: Context) -> SimpleEntry {
          SimpleEntry(date: Date(), exerciseName: "Bench Press", timeRemaining: "02:30")
      }

      func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
          let entry = SimpleEntry(date: Date(), exerciseName: "Bench Press", timeRemaining: "02:30")
          completion(entry)
      }

      func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
          var entries: [SimpleEntry] = []
          let currentDate = Date()
          let entry = SimpleEntry(date: currentDate, exerciseName: "Bench Press", timeRemaining: "02:30")
          entries.append(entry)

          let timeline = Timeline(entries: entries, policy: .atEnd)
          completion(timeline)
      }
  }

  struct SimpleEntry: TimelineEntry {
      let date: Date
      let exerciseName: String
      let timeRemaining: String
  }

  // MARK: - Static Widget Entry View
  struct GymBroTimerWidgetEntryView: View {
      var entry: Provider.Entry

      var body: some View {
          VStack(spacing: 8) {
              Image(systemName: "timer")
                  .font(.title)
                  .foregroundColor(.blue)

              Text("GymBro Timer")
                  .font(.headline)
                  .fontWeight(.semibold)

              Text("Tap to open")
                  .font(.caption)
                  .foregroundColor(.secondary)
          }
          .padding()
          .containerBackground(.fill.tertiary, for: .widget)
      }
  }

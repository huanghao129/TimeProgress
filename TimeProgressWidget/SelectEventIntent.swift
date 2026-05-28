//
//  SelectEventIntent.swift
//  TimeProgressWidget
//

import AppIntents
import Foundation

struct EventSelectionEntity: AppEntity, Identifiable {
    let id: String
    let name: String

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "事件")
    static var defaultQuery = EventSelectionQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct EventSelectionQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [EventSelectionEntity] {
        WidgetEventStore.loadEvents()
            .filter { identifiers.contains($0.id.uuidString) }
            .map { EventSelectionEntity(id: $0.id.uuidString, name: $0.name) }
    }

    func suggestedEntities() async throws -> [EventSelectionEntity] {
        WidgetEventStore.loadEvents().map {
            EventSelectionEntity(id: $0.id.uuidString, name: $0.name)
        }
    }
}

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择事件"
    static var description = IntentDescription("选择小组件展示的事件")

    @Parameter(title: "事件")
    var event: EventSelectionEntity?
}


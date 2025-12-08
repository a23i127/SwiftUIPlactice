// TabItem.swift
// Model for a tab

import Foundation

struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
}

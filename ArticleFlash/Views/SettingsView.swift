import SwiftUI

struct SettingsView: View {
    @AppStorage("notion_api_key") private var notionApiKey = ""
    @AppStorage("notion_database_id") private var notionDatabaseId = ""
    @AppStorage("review_notification_enabled") private var reviewNotificationEnabled = true
    @AppStorage("weekly_quiz_notification_enabled") private var weeklyQuizNotificationEnabled = true

    @State private var showingNotionSetup = false

    private var isNotionConnected: Bool {
        !notionApiKey.isEmpty && !notionDatabaseId.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notion
                Section {
                    HStack {
                        Text("接続状態")
                        Spacer()
                        Text(isNotionConnected ? "● 連携済み" : "● 未接続")
                            .foregroundStyle(isNotionConnected ? .green : .secondary)
                    }

                    if isNotionConnected {
                        HStack {
                            Text("データベース")
                            Spacer()
                            Text("学習カードDB")
                                .foregroundStyle(.secondary)
                        }

                        Button("連携を解除", role: .destructive) {
                            notionApiKey = ""
                            notionDatabaseId = ""
                            Task { await NotionService.shared.disconnect() }
                        }
                    } else {
                        Button("Notionと連携する") {
                            showingNotionSetup = true
                        }
                    }
                } header: {
                    Text("NOTION連携")
                }

                // MARK: - Notifications
                Section {
                    Toggle("翌日復習通知", isOn: $reviewNotificationEnabled)
                    Toggle("週次クイズ通知", isOn: $weeklyQuizNotificationEnabled)
                        .onChange(of: weeklyQuizNotificationEnabled) { _, newValue in
                            if newValue {
                                NotificationService.scheduleWeeklyQuiz()
                            } else {
                                UNUserNotificationCenter.current()
                                    .removePendingNotificationRequests(withIdentifiers: ["weekly-quiz"])
                            }
                        }
                } header: {
                    Text("通知")
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("アプリについて")
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showingNotionSetup) {
                NotionSetupView(
                    apiKey: $notionApiKey,
                    databaseId: $notionDatabaseId
                )
            }
        }
    }
}

// MARK: - Notion Setup

struct NotionSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var apiKey: String
    @Binding var databaseId: String
    @State private var inputApiKey = ""
    @State private var inputDatabaseId = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("API Key", text: $inputApiKey)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("Notion API Key")
                } footer: {
                    Text("Notion Integrationの内部シークレットキーを入力してください")
                }

                Section {
                    TextField("Database ID", text: $inputDatabaseId)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("データベースID")
                } footer: {
                    Text("カードを保存するNotionデータベースのIDを入力してください")
                }
            }
            .navigationTitle("Notion連携設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        apiKey = inputApiKey
                        databaseId = inputDatabaseId
                        Task {
                            await NotionService.shared.configure(
                                apiKey: inputApiKey,
                                databaseId: inputDatabaseId
                            )
                        }
                        dismiss()
                    }
                    .disabled(inputApiKey.isEmpty || inputDatabaseId.isEmpty)
                }
            }
        }
    }
}

import UserNotifications

//
//  ChatHistoryModel.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Combine
import Foundation
import SwiftUI

class ChatHistoryModel: ObservableObject, Identifiable {
    @Published var topic_id = ""
    @Published var topic_name = ""

    init(topic_id: String = "", topic_name: String = "") {
        self.topic_id = topic_id
        self.topic_name = topic_name
    }

    var id: String {
        return topic_id
    }
}

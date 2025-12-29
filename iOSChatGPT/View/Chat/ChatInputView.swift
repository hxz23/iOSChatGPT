//
//  ChatInputView.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import SwiftUI
import SwiftUIX

struct ChatInputView: View {
    @StateObject var chatModel: ChatTopicModel
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "figure").font(.system(size: 16))
                        Text("深度思考").font(.system(size: 12))
                    }
                }
                .padding(.horizontal, 4)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }

            let inputIsEmpty = chatModel.inputText.isEmpty

            HStack(alignment: .center) {
                if inputIsEmpty {
                    Button(action: {}, label: {
                        Image(systemName: "camera")
                    })
                }
                TextField("请输入内容...", text: $chatModel.inputText, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .lineLimit(4) // 最多4行
                    .font(.system(size: 16)) // 统一字体（影响高度计算）
                    .padding(12) // 内边距
                    .background(Color(.systemGray6)) // 背景色
                    .cornerRadius(8) // 圆角
                    .padding(.horizontal, 16) // 外层间距
                    .submitLabel(.send)
                    .onSubmit {
                        handleSendAction()
                    }
                    .onChange(of: chatModel.inputText) { newValue, _ in
                        guard let newValueLastChar = newValue.last else { return }
                        if newValueLastChar == "\n" {
                            print("submission!")
                            handleSendAction()
                        }
                    }

                if inputIsEmpty {
                    Button(action: {}, label: {
                        Image(systemName: "waveform.circle")
                    })
                    Button(action: {}, label: {
                        Image(systemName: "plus.circle")
                    })
                } else {
                    Button(action: {
                        handleSendAction()

                    }, label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue) // 白色图标

                    })
                }
            }
            .padding(8)
            .background(Color.white)
            // 自定义阴影参数：深色阴影+小偏移，更有立体感
            .cornerRadius(8)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 12,
                x: 0,
                y: 4
            )
        }
        .padding(.bottom, 10)
    }

    func changedInput(isEditing: Bool) {
        self.isEditing = isEditing
    }

    func handleSendAction()  {
        let inputText = chatModel.inputText.trimmingCharacters(in: .whitespaces)
        guard !inputText.isEmpty else {
            print("⚠️ 输入内容为空，不发送")
            return
        }
        print("✅ 点击确定按钮，当前输入：\(inputText)")
        isTextFieldFocused = false

        Task {
            await fetchResponse()
            chatModel.inputText = ""
        }



    }

    func fetchResponse() async {
        guard !chatModel.inputText.isEmpty else {
            return
        }
        #if DEBUG
            debugPrint(chatModel.inputText)
        #endif


        await chatModel.request(inputText: chatModel.inputText)
//        chatModel.inputText = ""
//        chatModel.getChatResponse(prompt: searchText)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            clearSearch()
//        }
    }

    func clearSearch() {
        chatModel.inputText = ""
    }
}

#Preview {
    let model = ChatTopicModel()
    var isEditing = false
    ChatInputView(chatModel: model)
}

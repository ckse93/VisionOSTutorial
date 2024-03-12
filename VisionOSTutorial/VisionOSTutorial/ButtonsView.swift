//
//  ButtonsView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/8/24.
//

import SwiftUI

struct ButtonsView: View {
    var body: some View {
        HStack {
            ButtonsViewDefault()
            
            Divider()
            
            ButtonsViewTypical()
            
            Divider()
            
            ButtonsViewButtonStyle()
        }
        .glassBackgroundEffect()
    }
}

struct ButtonsViewDefault: View {
    var body: some View {
        VStack {
            Text("default button")
                .font(.largeTitle)
                .padding()
            
            Button {
                print("button")
            } label: {
                Text("default button")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

struct ButtonsViewTypical: View {
    var body: some View {
        VStack {
            Text("typical approach")
                .font(.largeTitle)
            
            Button(action: {
                
            }, label: {
                Text("iOS pattern custom capsule button")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.vertical)
                    .padding()
                    .background(Color(uiColor: .systemOrange))
                    .clipShape(Capsule())
            })
            .padding()
            
            Button(action: {
                
            }, label: {
                Text("iOS pattern custom rectangle button")
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding()
                    .background(Color(uiColor: .systemOrange))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15.0)
                    )
            })
            .padding()
        }
        
    }
}

struct ButtonsViewButtonStyle: View {
    var body: some View {
        VStack {
            Text("using buttonStyle")
                .font(.largeTitle)
            
            Button(action: {
                
            }, label: {
                Text("custom ButtonStyle")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.vertical)
                    .padding()
                    .background(Color(uiColor: .systemOrange))
                    .clipShape(Capsule())
            })
            .buttonStyle(.custom)
            .padding()
            
            Button(action: {
                
            }, label: {
                Text("iOS pattern custom rounded rectangle button")
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding()
                    .background(Color(uiColor: .systemOrange))
            })
            .buttonStyle(.rounded)
            .padding()
            
            Button(action: {
                
            }, label: {
                Text("iOS pattern custom rectangle button")
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding()
                    .background(Color(uiColor: .systemOrange))
            })
            .buttonStyle(.rectangular)
            .padding()

        }
    }
}

struct RecButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger, label: {
            configuration.label
                .hoverEffect()
        })
        .buttonStyle(.plain)
    }
}

extension PrimitiveButtonStyle where Self == RecButtonStyle {
    static var rectangular: Self {
        .init()
    }
}

struct RoundedButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger, label: {
            configuration.label
                .hoverEffect()
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
        })
        .buttonStyle(.plain)
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }
}

extension PrimitiveButtonStyle where Self == RoundedButtonStyle {
    static var rounded: Self {
        .init()
    }
}

struct CustomButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger, label: {
            configuration.label
        })
        .buttonStyle(.plain)
    }
}

extension PrimitiveButtonStyle where Self == CustomButtonStyle {
    static var custom: Self {
        .init()
    }
}

#Preview {
    ButtonsView()
}

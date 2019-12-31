import Foundation
import LambdaRuntime
import NIO

struct Input: Codable {
  let number: Double
}

struct Output: Codable {
  let result: Double
}

func squareNumber(input: Input, context: Context) -> EventLoopFuture<Output> {
  let squaredNumber = input.number * input.number
  return context.eventLoop.makeSucceededFuture(Output(result: squaredNumber))
}

func printNumber(input: Input, context: Context) -> EventLoopFuture<Void> {
  context.logger.info("Number is: \(input.number)")
  return context.eventLoop.makeSucceededFuture(Void())
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
  try! group.syncShutdownGracefully()
}

do {
  
  let handler: LambdaRuntime.Handler
  switch ProcessInfo.processInfo.environment["_HANDLER"] {
  case "printNumber":
    handler = LambdaRuntime.codable(printNumber)
  default:
    handler = LambdaRuntime.codable(squareNumber)
  }
  
  let runtime = try LambdaRuntime.createRuntime(eventLoopGroup: group, handler: handler)
  defer { try! runtime.syncShutdown() }
  
  try runtime.start().wait()
}
catch {
  print(String(describing: error))
}



import XCTest
import QBToast

class Tests: XCTestCase {
  var toast: QBToast!
  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    toast = nil
    super.tearDown()
  }

  func testCreateToast() {
    toast = QBToast(message: "test")
    XCTAssertEqual(toast.message, "test")
    XCTAssertEqual(toast.position, QBToastPosition.bottom)
    XCTAssertEqual(toast.duration, 3.0)
    XCTAssertEqual(toast.state, QBToastState.custom)
    toast.showToast()
  }

  func testToastStyle() {
    toast = QBToast(message: "test2")
    XCTAssertEqual(toast.message, "test2")
    XCTAssertEqual(toast.style.messageColor, UIColor.white)
    XCTAssertEqual(toast.style.messageAlignment, NSTextAlignment.left)
    XCTAssertEqual(toast.style.cornerRadius, 4.0)
    XCTAssertEqual(toast.style.fadeDuration, 0.4)
    XCTAssertEqual(toast.style.backgroundColor, UIColor(hex: "#323232"))
    XCTAssertEqual(toast.style.toastPadding, 16)
    XCTAssertEqual(toast.style.messageNumberOfLines, 0)
    toast.showToast()
  }

  func testToastShow() {
    toast = QBToast(message: "test3", duration: 0.5)
    toast.showToast()

    let appearExpectation = self.expectation(description: "Wait for toast appear")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appearExpectation.fulfill()
      XCTAssertEqual(self.toast.message, "test3")
      XCTAssertEqual(self.toast.style.backgroundColor, UIColor(hex: "#323232"))
    }
    wait(for: [appearExpectation], timeout: 1)
  }
}

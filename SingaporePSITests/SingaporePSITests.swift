//
//  SingaporePSITests.swift
//  SingaporePSITests
//
//  Created by Krishna Singana on 10/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import XCTest
@testable import SingaporePSI

class SingaporePSITests: XCTestCase {

    var psiViewController: PSIViewController!

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let psiVC: PSIViewController = storyboard.instantiateViewController(withIdentifier:
            String(describing: PSIViewController.self)) as! PSIViewController
        psiViewController = psiVC
        _ = psiViewController.view  //  Used to load PSIViewController view
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCombiningStringsIntoAttributedStringSuccessCase() {
        var attributedString = NSMutableAttributedString()
        //Applied Bold font for valueStr in "psiViewController.combineStringsIntoAttributedStringWith" method
        psiViewController.combineStringsIntoAttributedStringWith(
            dataStr: "Test string", valueStr: "Test value", attributedString: &attributedString)
        XCTAssertEqual(21, attributedString.length)
    }

    func testCombiningStringsIntoAttributedStringFailureCase() {
        var attributedString = NSMutableAttributedString()
        //Applied Bold font for valueStr in "psiViewController.combineStringsIntoAttributedStringWith" method
        psiViewController.combineStringsIntoAttributedStringWith(
            dataStr: "Test string", valueStr: "Test value", attributedString: &attributedString)
        XCTAssertNotEqual(10, attributedString.length)
    }

    func testCreatingTitleAttributedString() {
        var underLineStyleExists = false
        var titleAttributedString = NSMutableAttributedString()
        //UnderlineStyle applied for text
        psiViewController.getTitleAttributedStringWith(dataStr: "Central", attributedStr: &titleAttributedString)

        // retrieving attributes
        var range = NSRange(location: 0, length: titleAttributedString.length)
        let attributes = titleAttributedString.attributes(at: 0, effectiveRange: &range)

        for attr in attributes where attr.key == NSAttributedString.Key.underlineStyle {
            underLineStyleExists = true
            XCTAssertEqual(1, attr.value as? Int)
        }
        XCTAssertTrue(underLineStyleExists)
    }

    func testNationalDetailsViewCurveEaseOutAnimation() {
        psiViewController.nationalDetailsViewCurveEaseOutAnimation()
        XCTAssertFalse(psiViewController.nationalDetailsView.isHidden)
        XCTAssertEqual(psiViewController.nationalDetailsViewWidthConstraint.constant, 282)
        XCTAssertEqual(psiViewController.nationalDetailsViewHeightConstraint.constant, 330)
        XCTAssertEqual(psiViewController.nationalDetailsViewLeadingConstraint.constant, 32)
        XCTAssertEqual(psiViewController.nationalDetailsViewBottomConstraint.constant, 16)
    }

    func testNationalDetailsViewCurveEaseInAnimation() {
        psiViewController.nationalDetailsViewCurveEaseInAnimation()
        XCTAssertTrue(psiViewController.nationalDetailsView.isHidden)
        XCTAssertEqual(psiViewController.nationalDetailsViewWidthConstraint.constant, 0)
        XCTAssertEqual(psiViewController.nationalDetailsViewHeightConstraint.constant, 0)
        XCTAssertEqual(psiViewController.nationalDetailsViewLeadingConstraint.constant, 56)
        XCTAssertEqual(psiViewController.nationalDetailsViewBottomConstraint.constant, -4)
    }

    func testInformationViewCurveEaseOutAnimation() {
        psiViewController.informationViewCurveEaseOutAnimation()
        XCTAssertFalse(psiViewController.informationDetailsView.isHidden)
        XCTAssertEqual(psiViewController.informationViewWidthConstraint.constant, 300)
        XCTAssertEqual(psiViewController.informationViewHeightConstraint.constant, 150)
        XCTAssertEqual(psiViewController.informationViewTrailingConstraint.constant, 32)
        XCTAssertEqual(psiViewController.informationViewBottomConstraint.constant, 16)
    }

    func testInformationViewCurveEaseInAnimation() {
        psiViewController.informationViewCurveEaseInAnimation()
        XCTAssertTrue(psiViewController.informationDetailsView.isHidden)
        XCTAssertEqual(psiViewController.informationViewWidthConstraint.constant, 0)
        XCTAssertEqual(psiViewController.informationViewHeightConstraint.constant, 0)
        XCTAssertEqual(psiViewController.informationViewTrailingConstraint.constant, 56)
        XCTAssertEqual(psiViewController.informationViewBottomConstraint.constant, -4)
    }

    func testGeneratingPollutionApiURLRequest() {
        let dateTimeString = psiViewController.getSingaporeDateTimeFromDate(date: Date())
        let psiDetailsURLString = "https://api.data.gov.sg/v1/environment/psi?date_time=\(dateTimeString)"
        let urlRequest = psiViewController.getPollutionApiRequest(with: dateTimeString)
        XCTAssertNotNil(urlRequest)
        XCTAssertNotNil(urlRequest?.url?.absoluteString)
        XCTAssertEqual(psiDetailsURLString, urlRequest?.url?.absoluteString)
    }
}

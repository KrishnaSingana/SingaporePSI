# SingaporePSI

**Required Data:**
 -  Current date and time(YYYY-MM-DD[T]HH:mm:ss) in SGT time zone. Used as a parameter in *api request* for getting Singapore PSI data.
 - Programatically generating current date and time string in above format on app launch.

**App Usage:**

 - Use botton left corner button for National PSI average data.
 - Use pins for Central and Cardinal directions PSI average data.
 - Use iota button on bottom right corner for detailed string names used
   in pollution data.

**Unit Test Cases by XCTest:**

 - testCombiningStringsIntoAttributedStringSuccessCase()
 - testCombiningStringsIntoAttributedStringFailureCase()
 - testCreatingTitleAttributedString()
 - testNationalDetailsViewCurveEaseOutAnimation()
 - testNationalDetailsViewCurveEaseInAnimation()
 - testInformationViewCurveEaseOutAnimation()
 - testInformationViewCurveEaseInAnimation()
 - testGeneratingPollutionApiURLRequest()

import Foundation

class HtmlHelper {
  /// A wrapper for loading the html page with `viewport`
  /// References: https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html
  /// https://developer.mozilla.org/en-US/docs/Mozilla/Mobile/Viewport_meta_tag
  static func wrap(html: String, withClass wrapClass: String = "") -> String {
    // "Proper" Html needs some things:
    // <head></head><body></body>
    // in <head> ->
    //    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    //    <style></style>
    let wrappedHtml = """
      <head>
        <title>Deskbook WebView</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link href="style.css" rel="stylesheet" type="text/css">
      </head>
      <body>
        <div class="\(wrapClass)">\(html)</div>
      </body>
    """
    return wrappedHtml
  }
  
  /**
   Instead of using <link href="style.css" rel="stylesheet" type="text/css">,
   We returns  an inline CSS block <style> with the bundle-included css as type in ` \(getCss())`
   Why not use <style src="path/to/local/file"></style>?
   Since Swift 3, WKWebView's security settings disallows it from loading LOCAL files without some extra settings.
   To keep the code simple, we'll use the "string injection" trick!
   */
  static func getCss() -> String {
    // Check to see if we have a style.css in the bundle
    if let path = Bundle.main.path(forResource: "style", ofType: "css") {
      // We do have a style.css in the bundle!
      NSLog("Style sheet found in bundle: \(path)")
      // Read the CSS into a string. Why? WKWebView won't read it from file:// in some scenarios (blame AppTransportSecurity)
      var cssString: String
      do {
        cssString = try String(contentsOfFile: path)
        // Successful read... return the CSS wrapped in a <style> node
        return "<style type=\"text/css\">\(cssString)</style>"
      } catch (let error) {
        // Oh man... no css for whatever reason. Log it.
        NSLog("Error reading the css file: \(error)")
      }
    }
    // If we did not have a style.css in the bundle or had an issue reading, just return an empty string!
    return ""
  }
  
}


= Setup =

 rails new dummy --database=postgresql --javascript=webpack --css=sass --skip-bundle

= Develop =

sw = IronWarbler::StockWatch.new({ ticker: 'QQQ', notification_type: 'EMAIL', price: 1000, direction: 'ABOVE',


= Test =
= Run =

= Build =

== Android ==

From: https://capacitorjs.com/docs/android#adding-the-android-platform

 ionic build --prod --source-map

=== Troubleshoot ===

From: https://stackoverflow.com/questions/68440676/unable-to-open-asset-url-ionic-capacitor


= Setup =

 rails new dummy --database=postgresql --javascript=webpack --css=sass --skip-bundle

= Develop =

sw = IronWarbler::StockWatch.new({ ticker: 'QQQ', notification_type: 'EMAIL', price: 1000, direction: 'ABOVE',


= Test =
= Run =

= Build =

== Android ==

From: https://capacitorjs.com/docs/android#adding-the-android-platform

From: https://wiki.wasya.co/index.php/Ionic

 ionic init
 ionic build --prod --source-map
 npx cap copy

=== Troubleshoot ===

From: https://stackoverflow.com/questions/68440676/unable-to-open-asset-url-ionic-capacitor

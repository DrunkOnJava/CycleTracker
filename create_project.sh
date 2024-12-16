#!/bin/bash

# Create a new Xcode project using the iOS App template
open -a Xcode -n --args -AppleLanguages "(en)" -IBCustomFontSizeEnabled YES -AppleLocale en_US -AppleICUNumberSymbols "(en_US)" -AppleKeyboards "en_US" -AppleTextDirection LTR -NSShowNonLocalizedStrings YES -NSForceRightToLeftWritingDirection NO -NSDocumentRevisionsDebugMode YES -NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints YES -NSWindowResizeTime 0.001 -NSTableViewDefaultSizeMode 2 -NSBrowserColumnSizeMode 3 -NSScrollAnimationEnabled NO -NSWindowRestorationEnabled NO -NSTextShowsControlCharacters YES -NSDisableAutomaticTermination YES -NSAutomaticWindowAnimationsEnabled NO -NSWindowShouldDragOnGesture NO -NSInitialToolTipDelay 1000 -createProject CycleTracker -template "iOS App"

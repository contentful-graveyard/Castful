.PHONY: build setup storyboard_ids

build:
	xcodebuild -workspace Castful.xcworkspace -scheme Castful

setup:
	bundle install
	bundle exec pod install

storyboard_ids:
	bundle exec sbconstants --swift Code/StoryboardIdentifiers.swift

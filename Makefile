.PHONY: setup storyboard_ids

setup:
	bundle install
	bundle exec pod install

storyboard_ids:
	bundle exec sbconstants --swift Code/StoryboardIdentifiers.swift

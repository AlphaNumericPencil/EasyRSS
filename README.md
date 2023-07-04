# EasyRSS
### A helpful little RSS Reader plasmoid (sub-functional, early development)
Test instructions:
1. Download
2. run plasmoidviewer -a ~/path/to/easyRSS/package

# Requirements Document
# Introduction
This document lays out the requirements for the development of an RSS Reader Plasmoid for the KDE desktop environment. The Plasmoid is intended to provide a user-friendly way for users to read and manage RSS feeds directly from their KDE desktop.

# Functional Requirements
## Feed Display:
The plasmoid should contain a hidden list, which is made visible upon clicking the message, "Currently showing [preset]". The list will comprise feeds that belong to a selected and named "preset" and be contained by the dimensions of the application.

## Feed Presets:
Users should be able to create named presets by adding feeds to them from an interface which shows all the feeds that the user has subscribed to via the plasmoid 

## Feed Details:
The plasmoid should display a list populated with details from the currently viewed RSS feeds. Each list item should include a thumbnail, the title of the article, and a relevant article description. Clicking the article's card will open a link to the article in the system's default browser.

## Add Feed:
The plasmoid should provide a button that allows users to add a new feed. The input box should be able to parse feeds based on popular formats such as RSS, Atom, etc, without the user specifying the feed type. 

## Manage Presets:
The plasmoid should include a button that enables users to create a new preset. In addition, users should be able to delete and modify existing presets.

## Non-Functional Requirements
Usability:
The plasmoid interface should be user-friendly, allowing users to easily view, add, and manage feeds and presets.

## Performance:
The plasmoid should be responsive and able to handle a large number of feeds without lag or decreased performance.

## Reliability:
The plasmoid should reliably fetch and display the correct feeds, and properly manage presets as created, modified, or deleted by the user.

## Integration:
The plasmoid should integrate seamlessly with the KDE desktop environment, following its design guidelines and conventions.

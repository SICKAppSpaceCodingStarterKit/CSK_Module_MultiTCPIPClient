# Changelog
All notable changes to this project will be documented in this file.

## Release 2.0.0

### New features
- Supports FlowConfig feature to provide received messages / to send content to TCP/IP server
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- Check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon

### Bugfix
- Error if trying to deregister from all events / commands

## Release 1.0.0
- Initial commit
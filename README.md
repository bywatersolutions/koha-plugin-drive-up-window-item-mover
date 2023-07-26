# Introduction

Koha Drive Up Window Item Mover

## Description

If the action is return, and the holding branch is a Window, the plugin will check the mapping then delete the transfer and modify the holding branch to be that of the mapped branch.

If the action is return, and the item is now a hold in transit from the library to the window, delete the transfer and modify the holding branch to be that of the mapped branch.

## Configuration

The plugin configuration has one setting, the mapping of branches to windows.
It should look something like
```yaml
BranchA: WindowA
BranchB: WindowB
BranchC: WindowC
```
where all the values are valid branchcodes.

# Downloading

From the [release page](https://github.com/bywatersolutions/koha-plugin-driveup-window-item-mover/releases) you can download the relevant *.kpz file

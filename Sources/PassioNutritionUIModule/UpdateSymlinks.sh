#!/bin/sh

# Before running, set PASSIO_XCODE_Source and PASSIO_XCODE_Target using the following command:
# export PASSIO_XCODE_Source="/path/to/folder_containing_source_projects (e.g. /Users/mind/Desktop/Nikunj/iOS Projects/Passio/Nutritions Projects/Nutrition SDK)"
# export PASSIO_XCODE_Target="/path/to/folder_containing_target_folder_for_symlink (e.g. /Users/mind/Desktop/Nikunj/iOS Projects/Passio/Nutritions Projects/Nutrition SDK/Distribution/Passio-Nutrition-AI-iOS-UI-Module-Distribution/Sources/PassioNutritionUIModule)"
#
# You may also need to run the following command the first time you use this:
# chmod 755 UpdateSymlinks.sh
# /path/to/source: The path to the file or directory you want to create a symlink to.
# /path/to/target: The path where you want to create the symlink.
# add sudo befor ln -s for permission issue

rm PassioNutritionAI

sudo ln -s $PASSIO_XCODE_Source/iOS-Passio-Nutrition-SDK/PassioNutritionAI $PASSIO_XCODE_Target

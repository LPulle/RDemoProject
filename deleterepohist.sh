#!/bin/bash
# 1) sync repo
# 2) delete the files out locally then run this
# - this creates a temp branch adds all the files to it commits, deletes the master branch, renames temp branch to master
# - finally git pushes master back
# Since this is a temp repo will want to run this quite often to reset
git checkout --orphan temp_branch
git add -A
git commit -am "the first commit"
git branch -D master
git branch -m master
git push -f origin master
git gc --aggressive --prune=all
git push -f origin master

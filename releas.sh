#!/bin/bash
cd themes/my_harbor/
npm run build-prod
git add static
git commit -m "build"
git push

cd ../../
hugo
git add docs/
git commit -m "build"
git push

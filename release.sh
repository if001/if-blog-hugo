#!/bin/bash
## themeはbuildする必要なくなったのでskip
# cd themes/my_harbor/ &&\
# git add . &&\
# git commit -m "build" &&\
# git push &&\

# cd ../../ &&\
hugo &&\
git add docs/ &&\
git commit -m "build" &&\
git push

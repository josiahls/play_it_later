#!/bin/bash

source activate play_it_later && nbdev_build_docs
cd docs
bundle exec jekyll serve --host=0.0.0.0 --port=4000 &

cd ../
source activate play_it_later && python setup.py develop
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/opt/project/play_it_later --allow-root &

sleep 2
bash
exec "$@"
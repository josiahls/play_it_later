# play_it_later
> A program for saving games for later dates for those with little self control.

Doc site can be found here: https://josiahls.github.io/play_it_later/


## Install

If you are using linux, and run into a `PyperclipException` you may need do `sudo apt-get install xclip`

## Conda

`conda env create -f environment.yaml`

`source activate play_it_later && python setup.py develop`

## Docker (highly recommend)

For cpu execution
```bash
docker build -f play_it_later.Dockerfile -t play_it_later:latest .
docker run --rm -it -p 8888:8888 -p 4000:4000 --user "$(id -u):$(id -g)" \
             -v $(pwd):/opt/project/play_it_later play_it_later:latest \
             -v /etc/localtime:/etc/localtime /bin/bash
```

## Contributing

After you clone this repository, please run `nbdev_install_git_hooks` in your terminal. This sets up git hooks, which clean up the notebooks to remove the extraneous stuff stored in the notebooks (e.g. which cells you ran) which causes unnecessary merge conflicts.

Before submitting a PR, check that the local library and notebooks match. The script `nbdev_diff_nbs` can let you know if there is a difference between the local library and the notebooks.
* If you made a change to the notebooks in one of the exported cells, you can export it to the library with `nbdev_build_lib` or `make fastai2`.
* If you made a change to the library, you can export it back to the notebooks with `nbdev_update_lib`.

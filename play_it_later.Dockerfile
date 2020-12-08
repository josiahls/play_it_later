FROM continuumio/miniconda:4.7.12

RUN apt-get update -y && apt-get install -y nano make curl jq

ENV DEBIAN_FRONTEND noninteractive
ENV CONTAINER_USER play_it_later
ENV CONTAINER_GROUP play_it_later_group
ENV CONTAINER_UID 1000
# Add user to conda
RUN addgroup --gid $CONTAINER_UID $CONTAINER_GROUP && \
    adduser --uid $CONTAINER_UID --gid $CONTAINER_UID $CONTAINER_USER --disabled-password  && \
    mkdir -p /opt/conda && \
    chown $CONTAINER_USER /opt/conda

USER $CONTAINER_USER
USER root

# Create Conda env for play_it_later from environment.yaml
WORKDIR /opt/project/play_it_later
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP environment.yaml environment.yaml
RUN conda env create -f environment.yaml
RUN chown -R $CONTAINER_USER /opt/conda/envs/play_it_later/ && chmod -R 777 /opt/conda/envs/play_it_later/
RUN /bin/bash -c "source activate play_it_later && conda install -c conda-forge nodejs ptvsd"
#RUN /bin/bash -c "source activate play_it_later && jupyter labextension install @jupyterlab/debugger"

# Add local jekk serving
RUN apt-get update && apt-get install -y --fix-missing ruby-full build-essential zlib1g-dev
RUN echo '# Install Ruby Gems to ~/.gems' >> ~/.bashrc
RUN echo 'export GEM_HOME="$HOME/.gems"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/.gems/bin:$PATH"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
RUN gem install jekyll
RUN gem i bundler -v 2.0.2

RUN chown $CONTAINER_USER /opt/project/
WORKDIR /opt/project/play_it_later/docs
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP docs/Gemfile Gemfile
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP docs/Gemfile.lock Gemfile.lock
RUN bundle install
WORKDIR /opt/project/play_it_later/

EXPOSE 8888
EXPOSE 4000

ENV PATH /opt/conda/envs/play_it_later/bin:$PATH
ENV CONDA_DEFAULT_ENV play_it_later
ENV FONTCONFIG_FILE $CONDA_PREFIX/etc/fonts/fonts.conf
ENV FONTCONFIG_PATH $CONDA_PREFIX/etc/fonts/
WORKDIR /opt/project/play_it_later

USER root
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP play_it_later play_it_later
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP settings.ini settings.ini
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP README.md README.md
RUN /bin/bash -c "source activate play_it_later && jt -t grade3 -cellw=90% -fs=20 -tfs=20 -ofs=20"
#COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP entrypoint.sh /usr/local/bin/
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP entrypoint.sh entrypoint.sh
#RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x entrypoint.sh
RUN mkdir /home/play_it_later/.gem && \
        chown $CONTAINER_USER -R /home/$CONTAINER_USER/.gem && \
        chown $CONTAINER_USER -R /opt/project

#WORKDIR /opt/project/

#RUN chown -R $CONTAINER_USER /opt/conda/envs/play_it_later && chmod -R 777 /opt/conda/envs/play_it_later

RUN apt-get install -y python-opengl
RUN apt-get install -y xvfb
USER $CONTAINER_USER
RUN conda init bash
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP . .
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP themes.jupyterlab-settings /home/play_it_later/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP shortcuts.jupyterlab-settings /home/play_it_later/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/

# Install the deploy package for system access
ENTRYPOINT "entrypoint.sh"
RUN echo 'source activate play_it_later' >> ~/.bashrc
CMD ["/bin/bash","-c"]
RUN /bin/bash -c "source activate play_it_later && pip install ptan --no-dependencies && python setup.py develop"
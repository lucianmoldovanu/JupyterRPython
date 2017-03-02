FROM rickyking/ds-xgboost
MAINTAINER Lucian Moldovanu <lucian.moldovanu@gmail.com>

RUN apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    mercurial subversion

WORKDIR /

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-4.3.0-Linux-x86_64.sh && \
    /bin/bash /Anaconda3-4.3.0-Linux-x86_64.sh -b -p /opt/conda && \
    rm /Anaconda3-4.3.0-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH
RUN conda install -y -c https://conda.anaconda.org/anaconda setuptools
RUN cd /opt/xgboost/python-package/ && python setup.py install
ENV LANG C.UTF-8

# Install R
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    r-base \
    libzmq3-dev \
    libxml2-dev \
    && apt-get clean

COPY scripts/rpackages.R /sbin/rpackages.R
RUN chmod +x /sbin/rpackages.R
RUN /sbin/rpackages.R

# Add a notebook profile.
RUN mkdir -p -m 700 /root/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888
CMD ["jupyter", "notebook"]
#CMD sh -c "jupyter notebook --ip=*"

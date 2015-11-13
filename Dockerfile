FROM ubuntu:14.04
MAINTAINER Roni Choudhury <roni.choudhury@kitware.com>

# The environment variables beginning with KWDEMO can be used to map this demo
# to the main url space.  See the end of this file.
ENV KWDEMO_READY FALSE

EXPOSE 3000

RUN apt-get update && apt-get install -y \
python \
python-pip \
git \
npm \
build-essential \
python-dev

RUN pip install \
tangelo \
pystache \
pymongo

# Need to symlink node to nodejs because Ubuntu names things in a way that npm
# doesn't expect.
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install gulp globally.
RUN npm install -g gulp

# Create and switch to a tangelo user
RUN useradd -c "tangelo user" -m -d /home/tangelo -s /bin/bash tangelo
USER tangelo
ENV HOME /home/tangelo
WORKDIR /home/tangelo

# Use https universally instead of git (comes up during bower phase).
RUN git config --global url."https://".insteadOf git://

# Clone the repo.
RUN git clone https://github.com/xdata-year-3/clique-twitter && \
cd clique-twitter && \
git checkout bd96143664f998277088ebc7c9e7f3422859fa34 && \
git reset --hard
WORKDIR clique-twitter

# Build clique.
RUN npm install
RUN gulp

# Install config file.
COPY config.json build/site/

# Set up KWDemo vars.
ENV KWDEMO_NAME Clique Twitter
ENV KWDEMO_KEY clique-twitter
ENV KWDEMO_READY TRUE

# Start the clique application when this image is run.
CMD ["sh", "-c", "tangelo --host 0.0.0.0 --port 3000 --root build/site --config tangelo-config.yaml"]

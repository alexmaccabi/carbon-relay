FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:jonathonf/python-3.6
RUN apt-get update

# Install required packages
RUN apt-get install -y build-essential python3.6 python3.6-dev python3-pip libcairo2-dev curl git supervisor
RUN python3.6 -m pip install pip --upgrade
RUN python3.6 -m pip install wheel
RUN pip install --upgrade setuptools
RUN pip install gunicorn

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs
#RUN     pip install Twisted==18.7.0
RUN pip install Twisted>=13.2.0

RUN     pip install pytz
RUN     git clone https://github.com/graphite-project/whisper.git /src/whisper            &&\
        cd /src/whisper                                                                   &&\
        git checkout  1.1.5                                                               &&\
        python3.6 setup.py install

RUN     git clone https://github.com/graphite-project/carbon.git /src/carbon              &&\
        cd /src/carbon                                                                    &&\
        git checkout  1.1.5                                                              &&\
        python3.6 setup.py install


ADD conf/carbon.conf.template /opt/graphite/conf/carbon.conf.template
ADD conf/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /kube-watch
RUN cd /kube-watch && npm install hashring kubernetes-client@5 json-stream
ADD kube-watch.js /kube-watch/kube-watch.js

EXPOSE 2003

CMD ["/usr/bin/supervisord"]

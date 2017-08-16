FROM python:3.5

ENV GITHUB_USERNAME="cbuto"
ENV DOCKER_IMAGE_NAME="django-app-jenkins"



RUN apt-get -q update && apt-get install -y nginx && apt-get install -y supervisor \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8

COPY django_app /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-available/default && rm /etc/nginx/sites-enabled/default

RUN cd
RUN git clone https://github.com/${GITHUB_USERNAME}/${DOCKER_IMAGE_NAME}.git

ADD /config/requirements.pip /config/requirements.pip
RUN pip install --no-cache-dir -r /config/requirements.pip

WORKDIR /django-app-jenkins/django-app

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf



FROM python:3.5

ENV GITHUB_USERNAME="cbuto"
ENV DOCKER_IMAGE_NAME="django-app"



RUN apt-get -q update && apt-get install -y -q \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8



RUN git clone https://github.com/${GITHUB_USERNAME}/${DOCKER_IMAGE_NAME}.git

ADD /config/requirements.pip /config/requirements.pip
RUN pip install --no-cache-dir -r /config/requirements.pip

EXPOSE 8000

WORKDIR /django-app

CMD gunicorn django_app.wsgi -b 0.0.0.0:8000

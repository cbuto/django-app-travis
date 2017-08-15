FROM nginx:1.10.3

MAINTAINER Casey Buto

USER root

RUN mkdir /etc/nginx/sites-enabled && mkdir /etc/nginx/sites-available

RUN sed -i '/include/a include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
RUN cat /etc/nginx/nginx.conf
COPY django_app /etc/nginx/sites-enabled
RUN ls /etc/nginx
RUN cd /etc/nginx/sites-enabled/
RUN ln -s ../sites-available/django-app


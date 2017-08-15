#!/bin/bash
sudo su - postgres
psql -c "CREATE USER django WITH PASSWORD 'changeme';"
psql -c "CREATE database django owner django";


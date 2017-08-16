#!groovy​
podTemplate(label: 'pod-django-app', 
    containers: [
        containerTemplate(name: 'django-app', image: 'cbuto/django-app-jenkins', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'django-postgres', image: 'cbuto/django-postgres', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'kubectl', image: 'cbuto/kubectl', ttyEnabled: true, command: 'cat',
            volumes: [secretVolume(secretName: 'kube-config', mountPath: '/root/.kube')]),
        containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat',
            envVars: [containerEnvVar(key: 'DOCKER_CONFIG', value: '/tmp/'),])],
            volumes: [secretVolume(secretName: 'docker-config', mountPath: '/tmp'),
                  hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
  ]) 
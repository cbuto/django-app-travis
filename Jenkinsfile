#!groovy​
podTemplate(label: 'pod-django-app', containers: [
        containerTemplate(name: 'django-app', image: 'cbuto/django-app-jenkins', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'django-postgres', image: 'cbuto/django-postgres', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'kubectl', image: 'cbuto/kubectl', ttyEnabled: true, command: 'cat',
            volumes: [secretVolume(secretName: 'kube-config', mountPath: '/root/.kube')]),
  ]) {


    node('pod-django-app') {

        def DOCKER_HUB_ACCOUNT = 'cbuto'
        def DOCKER_IMAGE_NAME = 'django-app-jenkins'
        def K8S_DEPLOYMENT_NAME = 'django-app'

        stage('Clone Django App Repository') {
            checkout scm
        }        
    }
}

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
  ]) {

    node('pod-django-app') {

        def DOCKER_HUB_ACCOUNT = 'cbuto'
        def DOCKER_IMAGE_NAME = 'django-app-jenkins2'
        def K8S_DEPLOYMENT_NAME = 'django-app'

        stage('Clone Django App Repository') {
            checkout scm
 
            container('django-app-jenkins') {
                stage('Build Django Site') {
                    sh ("ls")
                }
            }

            container('django-postgres') {
                stage('Build Postgres') {
                    sh ("ls")
                }
            }

            container('docker') {
                stage('Docker Build & Push Current & Latest Versions') {
                    sh ("docker build -t ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} .")
                    sh ("docker push ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                    sh ("docker tag ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:latest")
                    sh ("docker push ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:latest")
                }
            }

            container('kubectl') {
                stage('Deploy New Build To Kubernetes') {
                    sh ("kubectl set image deployment/${K8S_DEPLOYMENT_NAME} ${K8S_DEPLOYMENT_NAME}=${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }

        }        
    }
}

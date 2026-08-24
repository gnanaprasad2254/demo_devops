pipeline {

    agent any

    environment {
        NEXUS_URL    = "3.238.188.142:8081"
        NEXUS_DOCKER = "3.238.188.142:8082"
        IMAGE_NAME   = "demo-app"
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        EKS_CLUSTER  = "devops-pipeline-eks"
        AWS_REGION   = "us-east-1"
    }

    stages {

        stage('Maven Build & Test') {
            steps {
                sh 'mvn -f app/pom.xml clean package'
            }
        }

        stage('Publish Artifact to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-credentials',
                    usernameVariable: 'NEXUS_USERNAME',
                    passwordVariable: 'NEXUS_PASSWORD'
                )]) {

                    sh '''
                        set -e
                        umask 077
                        trap 'rm -f settings.xml' EXIT

                        printf '%s\\n' \
                        '<?xml version="1.0" encoding="UTF-8"?>' \
                        '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"' \
                        '          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' \
                        '          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">' \
                        '  <servers>' \
                        '    <server>' \
                        '      <id>nexus</id>' \
                        '      <username>'"$NEXUS_USERNAME"'</username>' \
                        '      <password>'"$NEXUS_PASSWORD"'</password>' \
                        '    </server>' \
                        '  </servers>' \
                        '</settings>' \
                        > settings.xml

                        echo "Publishing Maven artifact to Nexus..."

                        mvn -f app/pom.xml deploy \
                            -DskipTests \
                            -s settings.xml
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t ${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Docker Push to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-credentials',
                    usernameVariable: 'NEXUS_USERNAME',
                    passwordVariable: 'NEXUS_PASSWORD'
                )]) {

                    sh '''
                        echo "$NEXUS_PASSWORD" | docker login ${NEXUS_DOCKER} \
                            --username "$NEXUS_USERNAME" \
                            --password-stdin

                        docker push ${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${EKS_CLUSTER}

                    sed -i \
                        "s|IMAGE_PLACEHOLDER|${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}|g" \
                        k8s/deployment.yaml

                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl rollout status deployment/demo-app --timeout=180s
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded: ${IMAGE_NAME}:${IMAGE_TAG} deployed to EKS."
        }

        failure {
            echo "Pipeline failed - check logs above."
        }
    }
}
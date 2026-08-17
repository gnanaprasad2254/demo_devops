// STEP 5: The pipeline that glues Git -> Maven -> Nexus -> Docker -> EKS together.
// Create a Jenkins Pipeline job pointing at this repo; a GitHub webhook triggers it on push.

pipeline {
    agent any

    environment {
        NEXUS_URL       = "<CICD_SERVER_IP>:8081"
        NEXUS_DOCKER    = "<CICD_SERVER_IP>:8082"
        IMAGE_NAME      = "demo-app"
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        EKS_CLUSTER     = "devops-pipeline-eks"
        AWS_REGION      = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-org>/<your-repo>.git'
            }
        }

        stage('Maven Build & Test') {
            steps {
                sh 'mvn -f app/pom.xml clean package'
            }
        }

        stage('Publish Artifact to Nexus') {
            steps {
                sh 'mvn -f app/pom.xml deploy -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Docker Push to Nexus') {
            steps {
                sh "docker push ${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                    sed -i 's|IMAGE_PLACEHOLDER|${NEXUS_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}|' k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                """
            }
        }
    }

    post {
        success { echo "Pipeline succeeded: ${IMAGE_NAME}:${IMAGE_TAG} deployed to EKS." }
        failure { echo "Pipeline failed - check logs above." }
    }
}

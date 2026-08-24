// STEP 5: The pipeline that glues Git -> Maven -> Nexus -> Docker -> EKS together.
// Create a Jenkins Pipeline job pointing at this repo; a GitHub webhook triggers it on push.

pipeline {
    agent any

    environment {
        NEXUS_URL       = "3.238.188.142:8081"
        NEXUS_DOCKER    = "3.238.188.142:8082"
        IMAGE_NAME      = "demo-app"
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        EKS_CLUSTER     = "devops-pipeline-eks"
        AWS_REGION      = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/gnanaprasad2254/demo_devops.git'
            }
        }

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
                        cat > settings.xml <<EOF
        <settings>
            <servers>
                <server>
                    <id>nexus</id>
                    <username>${NEXUS_USERNAME}</username>
                    <password>${NEXUS_PASSWORD}</password>
                </server>
            </servers>
        </settings>
        EOF

                        mvn -f app/pom.xml deploy -DskipTests -s settings.xml

                        rm -f settings.xml
                    '''
                }
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

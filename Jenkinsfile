pipeline {
    agent any

    tools {
        maven 'MAVEN_HOME'
    }

    environment {
        // Nexus
        NEXUS_VERSION       = 'nexus3'
        NEXUS_PROTOCOL      = 'http'
        NEXUS_URL           = '13.217.7.157:8081'
        NEXUS_REPOSITORY    = 'devops'
        NEXUS_CREDENTIAL_ID = 'Nexus_server'

        // Sonar
        SONARQUBE_SERVER    = 'MySonar'
        SONARQUBE_URL       = 'http://35.175.252.12/'

        // Slack
        SLACK_CHANNEL       = '#new-channel'

        // Application source repo
        APP_REPO_URL        = 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
        APP_GIT_BRANCH      = 'master'

        // Kubernetes manifests repo
        MANIFEST_REPO_URL   = 'https://github.com/mubeen-hub78/ArgoCD-Java.git'
        MANIFEST_GIT_BRANCH = 'main'
        MANIFEST_CRED_ID    = 'git-manifest-cred'

        // Docker
        DOCKER_IMAGE_NAME   = 'mubeendochub/java-app'
        DOCKER_REGISTRY     = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'Docker-cred'

        // ArgoCD
        ARGO_APP_NAME       = 'java-app'
        ARGO_SERVER         = '54.172.117.25:31630'
        ARGO_CRED_ID        = 'argocd-password'
    }

    stages {
        stage('Checkout App Code') {
            steps {
                git branch: "${env.APP_GIT_BRANCH}", url: "${env.APP_REPO_URL}"
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn -Dmaven.test.failure.ignore=true clean install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONARQUBE_SERVER}") {
                    sh "mvn sonar:sonar -Dsonar.host.url=${env.SONARQUBE_URL}"
                }
            }
        }

        stage('Publish to Nexus') {
            steps {
                script {
                    def pom = readMavenPom file: 'pom.xml'
                    def artifacts = findFiles(glob: "target/*.${pom.packaging}")

                    if (artifacts.size() == 0) {
                        error "No artifact found for packaging type: ${pom.packaging}"
                    }

                    nexusArtifactUploader(
                        nexusVersion: env.NEXUS_VERSION,
                        protocol: env.NEXUS_PROTOCOL,
                        nexusUrl: env.NEXUS_URL,
                        groupId: pom.groupId,
                        version: "${env.BUILD_NUMBER}-SNAPSHOT",
                        repository: env.NEXUS_REPOSITORY,
                        credentialsId: env.NEXUS_CREDENTIAL_ID,
                        artifacts: [
                            [artifactId: pom.artifactId, classifier: '', file: artifacts[0].path, type: pom.packaging],
                            [artifactId: pom.artifactId, classifier: '', file: 'pom.xml', type: 'pom']
                        ]
                    )
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def fullImageName = "${env.DOCKER_REGISTRY}/${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker tag ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${fullImageName}"

                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${env.DOCKER_REGISTRY}"
                    }

                    sh "docker push ${fullImageName}"
                }
            }
        }

        stage('Update Manifest Repo with New Image Tag') {
            steps {
                dir('manifests') {
                    git branch: "${env.MANIFEST_GIT_BRANCH}", url: "${env.MANIFEST_REPO_URL}", credentialsId: "${env.MANIFEST_CRED_ID}"
                    sh """
                        sed -i 's|image: ${env.DOCKER_IMAGE_NAME}:.*|image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}|' deployment.yaml
                        git config user.email "jenkins@ci.local"
                        git config user.name "Jenkins CI"
                        git add deployment.yaml
                        git commit -m "Update image tag to ${env.BUILD_NUMBER}"
                        git push origin ${env.MANIFEST_GIT_BRANCH}
                    """
                }
            }
        }

        stage('Deploy via ArgoCD') {
            steps {
                withCredentials([string(credentialsId: env.ARGO_CRED_ID, variable: 'ARGOCD_PASS')]) {
                    sh """
                        argocd login ${env.ARGO_SERVER} --username admin --password $ARGOCD_PASS --insecure
                        argocd app sync ${env.ARGO_APP_NAME}
                        argocd app wait ${env.ARGO_APP_NAME} --timeout 600
                    """
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: "${env.SLACK_CHANNEL}", color: 'good',
                message: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
        failure {
            slackSend(channel: "${env.SLACK_CHANNEL}", color: 'danger',
                message: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
    }
}

pipeline {
    agent any

    tools {
        maven 'MVN_HOME'
    }

    environment {
        NEXUS_VERSION        = "${env.NEXUS_VERSION ?: 'nexus3'}"
        NEXUS_PROTOCOL       = "${env.NEXUS_PROTOCOL ?: 'http'}"
        // Removed invalid comment here
        NEXUS_URL            = "${env.NEXUS_URL ?: '107.23.211.86:8081'}"
        NEXUS_REPOSITORY     = "${env.NEXUS_REPOSITORY ?: 'devops'}"
        NEXUS_CREDENTIAL_ID  = "${env.NEXUS_CREDENTIAL_ID ?: 'Nexus_server'}"

        SONARQUBE_SERVER     = "${env.SONARQUBE_SERVER ?: 'MySonarQube'}"  /* Ensure this server is configured with URL http://107.23.211.86:9000 in Jenkins config */

        SLACK_CHANNEL        = "${env.SLACK_CHANNEL ?: '#new-channel'}"

        REPO_URL             = "https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git"
        GIT_BRANCH           = "master"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: "${env.REPO_URL}"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -Dmaven.test.failure.ignore=true clean install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONARQUBE_SERVER}") {
                    sh 'mvn sonar:sonar'
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

                    def artifactPath = artifacts[0].path

                    withCredentials([usernamePassword(credentialsId: "${env.NEXUS_CREDENTIAL_ID}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        nexusArtifactUploader(
                            nexusVersion: "${env.NEXUS_VERSION}",
                            protocol: "${env.NEXUS_PROTOCOL}",
                            nexusUrl: "${env.NEXUS_URL}",
                            groupId: pom.groupId,
                            version: env.BUILD_NUMBER,
                            repository: "${env.NEXUS_REPOSITORY}",
                            credentialsId: "${env.NEXUS_CREDENTIAL_ID}",
                            artifacts: [
                                [artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging],
                                [artifactId: pom.artifactId, classifier: '', file: 'pom.xml', type: 'pom']
                            ]
                        )
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: "${env.SLACK_CHANNEL}", color: 'good', message: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
        failure {
            slackSend(channel: "${env.SLACK_CHANNEL}", color: 'danger', message: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
        }
        unstable {
            slackSend(channel: "${env.SLACK_CHANNEL}", color: 'warning', message: "⚠️ UNSTABLE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
        }
    }
}

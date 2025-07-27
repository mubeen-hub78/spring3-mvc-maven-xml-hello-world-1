pipeline {
    agent any

    tools {
        maven 'MAVEN_HOME'
        jdk 'JDK11'
    }

    environment {
        SONARQUBE = 'MySonar'
        NEXUS = 'Nexus_server'
        GIT_REPO = 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
        GIT_BRANCH = 'master'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: "${GIT_REPO}",
                    credentialsId: 'Github_server'
            }
        }

        stage('Parallel Jobs') {
            parallel {
                stage('Build') {
                    steps {
                        sh 'mvn clean package -DskipTests'
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv("${SONARQUBE}") {
                            sh "mvn sonar:sonar -Dsonar.projectKey=simplecustomerapp-sp-parallel"
                        }
                    }
                }
                stage('Deploy to Nexus') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: "${NEXUS}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                            sh 'mvn deploy -DskipTests'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: '#new-channel', color: 'good', tokenCredentialId: 'slack', message: "Parallel Pipeline SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
        failure {
            slackSend(channel: '#new-channel', color: 'danger', tokenCredentialId: 'slack', message: "Parallel Pipeline FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
    }
}

pipeline {
    agent any

    environment {
        SONARQUBE = 'MySonar'
        NEXUS_URL = 'http://107.23.211.86:8081/repository/devops/'
        APP_NAME = 'simplecustomerapp-parallel'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'feature-1.1',
                    url: 'https://github.com/sabair0509/sabear_simplecutomerapp.git'
            }
        }

        stage('Parallel Jobs') {
            parallel {
                stage('Build') {
                    steps {
                        sh '/usr/bin/mvn clean package -DskipTests'
                    }
                }

                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv("${SONARQUBE}") {
                            sh "/usr/bin/mvn sonar:sonar -Dsonar.projectKey=com.javatpoint:${APP_NAME}"
                        }
                    }
                }

                stage('Deploy to Nexus') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'Nexus_server',
                                                          usernameVariable: 'NEXUS_USER',
                                                          passwordVariable: 'NEXUS_PASS')]) {
                            sh """
                                /usr/bin/mvn deploy -DskipTests \
                                -Dnexus.username=$NEXUS_USER \
                                -Dnexus.password=$NEXUS_PASS
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend channel: '#new-channel', color: 'good',
                message: "✅ Build & Deploy SUCCESS for ${APP_NAME}"
        }
        failure {
            slackSend channel: '#new-channel', color: 'danger',
                message: "❌ Build FAILED for ${APP_NAME}"
        }
    }
}

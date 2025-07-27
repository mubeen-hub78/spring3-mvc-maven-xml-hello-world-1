pipeline {
    agent any
    tools {
        maven 'MAVEN_HOME'
    }
    environment {
        SONARQUBE = 'sonar'
        NEXUS = 'Nexus_server'
        APP_NAME = 'simplecustomerapp-sp-parallel'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
            }
        }

        stage('Parallel Jobs') {
            parallel {
                stage('Build') {
                    steps {
                        sh "mvn clean package -DskipTests"
                    }
                }

                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv("${SONARQUBE}") {
                            sh "mvn sonar:sonar -Dsonar.projectKey=${APP_NAME} -Dsonar.projectName=${APP_NAME}"
                        }
                    }
                }

                stage('Deploy to Nexus') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: "${NEXUS}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                            sh '''
                                mvn deploy -DskipTests \
                                -DaltDeploymentRepository=nexus::default::http://107.23.211.86:8081/repository/devops \
                                -Dnexus.username=$USER -Dnexus.password=$PASS
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: '#new-channel', color: 'good', message: "Build Successful for ${APP_NAME}")
        }
        failure {
            slackSend(channel: '#new-channel', color: 'danger', message: "Build Failed for ${APP_NAME}")
        }
    }
}

pipeline {
    agent any

    tools {
        maven 'MAVEN_HOME'
    }

    environment {
        SONARQUBE_SERVER = 'MySonarQube'
        NEXUS_REPO_URL = 'http://107.23.211.86:8081/repository/devops/'
        GIT_REPO = 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
        SONAR_PROJECT_KEY = 'com.javatpoint:simplecustomerapp-sp-parallel'
        SONAR_PROJECT_NAME = 'simplecustomerapp-parallel'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: "${env.GIT_REPO}"
            }
        }

        stage('Parallel Stages') {
            parallel {
                stage('Build') {
                    steps {
                        sh 'mvn clean install -Dmaven.test.failure.ignore=true'
                    }
                }

                stage('SonarQube Analysis') {
                    steps {
                        withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONARQUBE_TOKEN')]) {
                            withSonarQubeEnv("${env.SONARQUBE_SERVER}") {
                                sh """
                                    mvn sonar:sonar \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                    -Dsonar.projectName=${SONAR_PROJECT_NAME} \
                                    -Dsonar.login=$SONARQUBE_TOKEN
                                """
                            }
                        }
                    }
                }

                stage('Deploy to Nexus') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'Nexus_server', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                            sh """
                                mvn clean deploy -DskipTests \
                                -DaltDeploymentRepository=nexus::default::${NEXUS_REPO_URL} \
                                -Dnexus.username=$NEXUS_USER -Dnexus.password=$NEXUS_PASS
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: '#new-channel', color: 'good', message: "✅ SUCCESS: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (<${env.BUILD_URL}|Open>)")
        }
        failure {
            slackSend(channel: '#new-channel', color: 'danger', message: "❌ FAILURE: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (<${env.BUILD_URL}|Open>)")
        }
    }
}

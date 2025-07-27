pipeline {
    agent any

    parameters {
        string(name: 'GIT_BRANCH', defaultValue: 'master', description: 'Git branch to build')
        string(name: 'SLACK_CHANNEL', defaultValue: '#new-channel', description: 'Slack channel for notifications')
        string(name: 'SONARQUBE_PROJECT_KEY', defaultValue: 'com.javatpoint:simplecustomerapp-sp', description: 'SonarQube project key')
        string(name: 'SONARQUBE_PROJECT_NAME', defaultValue: 'simplecustomerapp-parameterized', description: 'SonarQube project display name')
    }

    tools {
        maven 'MAVEN_HOME' // Ensure your Jenkins Maven tool is named MAVEN_HOME
    }

    environment {
        SONARQUBE_SERVER = 'MySonarQube'                                  // Your SonarQube server in Jenkins
        NEXUS_REPO_URL = 'http://107.23.211.86:8081/repository/devops/'  // Your Nexus repo URL
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.GIT_BRANCH}",
                    url: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install -Dmaven.test.failure.ignore=true'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONARQUBE_TOKEN')]) {
                    withSonarQubeEnv("${env.SONARQUBE_SERVER}") {
                        sh """mvn sonar:sonar \
                         -Dsonar.projectKey=${params.SONARQUBE_PROJECT_KEY} \
                         -Dsonar.projectName=${params.SONARQUBE_PROJECT_NAME} \
                         -Dsonar.login=$SONARQUBE_TOKEN"""
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

    post {
        success {
            withCredentials([string(credentialsId: 'slack', variable: 'SLACK_TOKEN')]) {
                slackSend(channel: "${params.SLACK_CHANNEL}", color: 'good', token: SLACK_TOKEN, message: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
            }
        }
        failure {
            withCredentials([string(credentialsId: 'slack', variable: 'SLACK_TOKEN')]) {
                slackSend(channel: "${params.SLACK_CHANNEL}", color: 'danger', token: SLACK_TOKEN, message: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
            }
        }
    }
}

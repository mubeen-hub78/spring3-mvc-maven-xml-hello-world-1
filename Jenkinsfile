pipeline {
    agent any

    parameters {
        string(name: 'GIT_BRANCH', defaultValue: 'master', description: 'Git branch to build')
        string(name: 'NEXUS_REPOSITORY', defaultValue: 'devops', description: 'Nexus repository name')
        string(name: 'VERSION_SUFFIX', defaultValue: '-SNAPSHOT', description: 'Version suffix (e.g., -SNAPSHOT or empty for releases)')
        string(name: 'SLACK_CHANNEL', defaultValue: '#new-channel', description: 'Slack channel for notifications')
        string(name: 'SONARQUBE_PROJECT_KEY', defaultValue: 'com.javatpoint:simplecustomerapp-sp', description: 'SonarQube project key')
        string(name: 'SONARQUBE_PROJECT_NAME', defaultValue: 'Simple Customer App', description: 'SonarQube project display name')
    }

    tools {
        maven 'MAVEN_HOME'  // Make sure Maven tool in Jenkins is named MAVEN_HOME
    }

    environment {
        NEXUS_VERSION       = "${env.NEXUS_VERSION ?: 'nexus3'}"
        NEXUS_PROTOCOL      = "${env.NEXUS_PROTOCOL ?: 'http'}"
        NEXUS_URL           = "${env.NEXUS_URL ?: '107.23.211.86:8081'}"
        NEXUS_CREDENTIAL_ID = "${env.NEXUS_CREDENTIAL_ID ?: 'Nexus_server'}"

        SONARQUBE_SERVER    = "${env.SONARQUBE_SERVER ?: 'MySonarQube'}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.GIT_BRANCH}", url: "https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git"
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
                    sh "mvn sonar:sonar -Dsonar.projectKey='${params.SONARQUBE_PROJECT_KEY}' -Dsonar.projectName='${params.SONARQUBE_PROJECT_NAME}'"
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
                    def versionString = "${env.BUILD_NUMBER}${params.VERSION_SUFFIX}"

                    withCredentials([usernamePassword(credentialsId: "${env.NEXUS_CREDENTIAL_ID}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        nexusArtifactUploader(
                            nexusVersion: "${env.NEXUS_VERSION}",
                            protocol: "${env.NEXUS_PROTOCOL}",
                            nexusUrl: "${env.NEXUS_URL}",
                            groupId: pom.groupId,
                            version: versionString,
                            repository: "${params.NEXUS_REPOSITORY}",
                            credentialsId: "${env.NEXUS_CREDENTIAL_ID}",
                            artifacts: [
                                [artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging],
                                [artifactId: pom.artifactId, classifier

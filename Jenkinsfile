#!/usr/bin/env groovy

node {
    // -------- Config (same repo & conf, just “-scripted” identities) --------
    def REPO_URL            = 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
    def GIT_BRANCH          = 'master'

    def SONARQUBE_SERVER    = (env.SONARQUBE_SERVER ?: 'MySonarQube')
    def SONAR_PROJECT_KEY   = 'simplecustomerapp-sp-scripted'
    def SONAR_PROJECT_NAME  = 'simplecustomerapp-sp-scripted'

    def NEXUS_VERSION       = (env.NEXUS_VERSION ?: 'nexus3')
    def NEXUS_PROTOCOL      = (env.NEXUS_PROTOCOL ?: 'http')
    def NEXUS_URL           = (env.NEXUS_URL ?: '107.23.211.86:8081')
    def NEXUS_REPOSITORY    = (env.NEXUS_REPOSITORY ?: 'devops')
    def NEXUS_CREDENTIAL_ID = (env.NEXUS_CREDENTIAL_ID ?: 'Nexus_server')

    def SLACK_CHANNEL       = (env.SLACK_CHANNEL ?: '#new-channel')

    try {
        stage('Checkout') {
            checkout([$class: 'GitSCM',
                branches: [[name: "*/${GIT_BRANCH}"]],
                userRemoteConfigs: [[url: REPO_URL]]
            ])
        }

        stage('Build & Sonar (parallel)') {
            parallel(
                Build: {
                    sh 'mvn -Dmaven.test.failure.ignore=true clean install'
                },
                SonarQube_Analysis: {
                    withSonarQubeEnv(SONARQUBE_SERVER) {
                        sh """
                          mvn sonar:sonar \
                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                            -Dsonar.projectName=${SONAR_PROJECT_NAME}
                        """
                    }
                }
            )
        }

        stage('Publish to Nexus') {
            def pom = readMavenPom file: 'pom.xml'
            def artifacts = findFiles(glob: "target/*.${pom.packaging}")
            if (!artifacts || artifacts.size() == 0) {
                error "No artifact found for packaging type: ${pom.packaging}"
            }
            def artifactPath = artifacts[0].path
            def versionString = "${env.BUILD_NUMBER}-SNAPSHOT"

            withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIAL_ID,
                                             usernameVariable: 'NEXUS_USER',
                                             passwordVariable: 'NEXUS_PASS')]) {
                nexusArtifactUploader(
                    nexusVersion: NEXUS_VERSION,
                    protocol: NEXUS_PROTOCOL,
                    nexusUrl: NEXUS_URL,
                    groupId: pom.groupId,
                    version: versionString,
                    repository: NEXUS_REPOSITORY,
                    credentialsId: NEXUS_CREDENTIAL_ID,
                    artifacts: [
                        [artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging],
                        [artifactId: pom.artifactId, classifier: '', file: 'pom.xml',      type: 'pom']
                    ]
                )
            }
        }

        currentBuild.result = 'SUCCESS'
    } catch (err) {
        currentBuild.result = 'FAILURE'
        throw err
    } finally {
        // Simple Slack notify
        def color = (currentBuild.result == 'SUCCESS') ? 'good' : 'danger'
        slackSend(channel: SLACK_CHANNEL, color: color,
                  message: "${currentBuild.result}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (<${env.BUILD_URL}|Open>)")
    }
}

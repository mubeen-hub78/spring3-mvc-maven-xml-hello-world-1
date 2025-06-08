pipeline {
    agent any

    tools {
        maven "MVN_HOME"
    }

    parameters {
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Specify the Git branch to build (e.g., main, develop, feature/my-branch)')
        string(name: 'BUILD_VERSION', defaultValue: 'SNAPSHOT', description: 'Specify the version for the artifact (e.g., 1.0.0-SNAPSHOT, 1.0.0)')
    }

    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "52.23.219.98:8081" // Updated Nexus URL
        NEXUS_REPOSITORY = "devops"
        NEXUS_CREDENTIAL_ID = "Nexus_server"
    }

    stages {
        stage("Clone Code") {
            steps {
                script {
                    git branch: "${params.GIT_BRANCH}", url: 'https://github.com/betawins/spring3-mvc-maven-xml-hello-world-1.git';
                }
            }
        }

        stage("Maven Build") {
            steps {
                script {
                    sh 'mvn clean install -Dmaven.test.failure.ignore=true'
                }
            }
        }

        stage("Publish to Nexus") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");

                    if(filesByGlob.size() > 0) {
                        artifactPath = filesByGlob[0].path;

                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${params.BUILD_VERSION}";

                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: "${params.BUILD_VERSION}",
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [
                                    artifactId: pom.artifactId,
                                    classifier: '',
                                    file: artifactPath,
                                    type: pom.packaging
                                ],
                                [
                                    artifactId: pom.artifactId,
                                    classifier: '',
                                    file: "pom.xml",
                                    type: "pom"
                                ]
                            ]
                        );
                    } else {
                        error "*** No artifact found in target directory with packaging: ${pom.packaging}";
                    }
                }
            }
        }
    }
}
